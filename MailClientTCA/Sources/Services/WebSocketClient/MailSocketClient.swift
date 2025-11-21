//
//  MailSocketClient.swift
//  MailClientTCA
//
//  Created by yuchekan on 16.11.2025.
//

import Foundation

final class MailSocketClient: NSObject, URLSessionWebSocketDelegate {
    private let accessToken: String? = {
        let storage = _KeychainStorage()
        return storage.getPassword(for: "access_token")
    }()
    
    private var task: URLSessionWebSocketTask?
    private var session: URLSession?
    
    private var baseURL: URL = URL(string: "https://api.xyecoc.com")!
    
    private var sessionId: String?
    private var pingTimer: Timer?
    private var pollTimer: Timer?
    private var pingInterval: TimeInterval = 25
    private var pingTimeout: TimeInterval = 20
    private var maxPayload: Int = 1000000
    
    private var lastMailId: Int = 0
    
    var onEvent: ((String, Any?) -> Void)?
    var onDisconnect: (() -> Void)?
    var enableDebugLogging: Bool = true
    
    // MARK: - Public Methods
    
    @MainActor
    func connect() async {
        do {
            // Шаг 1: HTTP handshake для получения session ID
            try await performHandshake()
            
            // Шаг 2: Отправить CONNECT пакет через polling
            try await sendConnectPacket()
            
            // Шаг 3: Апгрейд до WebSocket
            try await upgradeToWebSocket()
            
        } catch {
            print("❌ Connection error:", error)
            onDisconnect?()
        }
    }
    
    func disconnect() {
        pingTimer?.invalidate()
        pollTimer?.invalidate()
        task?.cancel(with: .goingAway, reason: nil)
        session?.invalidateAndCancel()
        sessionId = nil
        onDisconnect?()
    }
    
    func emit(event: String, data: Any) {
        // Формат Socket.IO: 42["eventName", {...}]
        let payload: String
        if let jsonData = try? JSONSerialization.data(withJSONObject: [event, data]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            payload = "42\(jsonString)"
        } else {
            print("❌ Failed to serialize event data")
            return
        }
        send(text: payload)
    }
    
    func requestNewMails(lastMailId: Int? = nil) {
        guard let token = accessToken else { return }
        
        if let id = lastMailId {
            self.lastMailId = id
        }
        
        let requestData: [String: Any] = [
            "service": "mail",
            "params": [:] as [String: Any],
            "action": "default",
            "currentLang": "inbox",
            "token": token
        ]
        
        emit(event: "request", data: requestData)
        logConnection("📤 Requesting new mails...")
    }
    
    func startMailPolling(interval: TimeInterval = 5.0) {
        pollTimer?.invalidate()
        pollTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.requestNewMails()
        }
    }
    
    func stopMailPolling() {
        pollTimer?.invalidate()
        pollTimer = nil
    }
    
    // MARK: - Private Methods: Connection Flow
    
    @MainActor
    private func performHandshake() async throws {
        guard let token = accessToken else {
            throw NSError(domain: "MailSocketClient", code: 1, userInfo: [NSLocalizedDescriptionKey: "No access token"])
        }
        
        let url = baseURL
            .appendingPathComponent("socket.io/")
            .appendingQueryItems([
                .init(name: "EIO", value: "4"),
                .init(name: "transport", value: "polling"),
                .init(name: "token", value: token),
                .init(name: "t", value: generateTimestamp())
            ])
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let responseText = String(data: data, encoding: .utf8) ?? ""
        
        logMessage("RECV", "Handshake: \(responseText)")
        
        guard responseText.hasPrefix("0") else {
            throw NSError(domain: "MailSocketClient", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid handshake response"])
        }
        
        let jsonString = String(responseText.dropFirst(1))
        if let jsonData = jsonString.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
            sessionId = json["sid"] as? String
            pingInterval = (json["pingInterval"] as? Double ?? 25000) / 1000
            pingTimeout = (json["pingTimeout"] as? Double ?? 20000) / 1000
            maxPayload = json["maxPayload"] as? Int ?? 1000000
            
            logConnection("✅ Handshake successful, sid: \(sessionId ?? "nil")")
        }
    }
    
    @MainActor
    private func sendConnectPacket() async throws {
        guard let sessionId = sessionId, let token = accessToken else { return }
        
        let url = baseURL
            .appendingPathComponent("socket.io/")
            .appendingQueryItems([
                .init(name: "EIO", value: "4"),
                .init(name: "transport", value: "polling"),
                .init(name: "sid", value: sessionId),
                .init(name: "token", value: token),
                .init(name: "t", value: generateTimestamp())
            ])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "40".data(using: .utf8)
        
        logMessage("SEND", "CONNECT packet: 40")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            logConnection("✅ CONNECT packet sent")
        }
    }
    
    @MainActor
    private func upgradeToWebSocket() async throws {
        guard let sessionId = sessionId, let token = accessToken else { return }
        
        let wsURL = URL(string: "wss://api.xyecoc.com")!
            .appendingPathComponent("socket.io/")
            .appendingQueryItems([
                .init(name: "EIO", value: "4"),
                .init(name: "transport", value: "websocket"),
                .init(name: "sid", value: sessionId),
                .init(name: "token", value: token)
            ])
        
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
        
        task = session?.webSocketTask(with: wsURL)
        task?.resume()
        
        send(text: "2probe")
        
        listen()
        logConnection("✅ WebSocket upgrade initiated")
    }
    
    // MARK: - Private Methods: Message Handling
    
    private func listen() {
        task?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let msg):
                switch msg {
                case .string(let str):
                    self.logMessage("RECV", str)
                    self.handleMessage(str)
                    
                case .data(let data):
                    self.logMessage("RECV", "Binary data: \(data.count) bytes")
                    if let stringRepresentation = String(data: data, encoding: .utf8) {
                        self.logMessage("RECV", "Data as String: \(stringRepresentation)")
                    }
                    
                @unknown default:
                    break
                }
            case .failure(let error):
                self.logConnection("❌ WebSocket error: \(error.localizedDescription)")
                Task { @MainActor in
                    self.disconnect()
                }
            }
            self.listen()
        }
    }
    
    private func handleMessage(_ text: String) {
        // Engine.IO probe ответ
        if text == "3probe" {
            logConnection("✅ Probe confirmed, sending upgrade packet")
            send(text: "5")
            return
        }
        
        // Engine.IO ping
        if text == "2" {
            send(text: "3")
            return
        }
        
        // Socket.IO CONNECT response: 40{"sid":"..."}
        if text.hasPrefix("40") {
            logConnection("✅ Socket.IO connected")
            if text.count > 2 {
                let json = String(text.dropFirst(2))
                print("Connection data:", json)
            }
            startPing()
            
            // Сразу запрашиваем почту
            requestNewMails()
            
            // Запускаем периодический опрос
            startMailPolling()
            return
        }
        
        // Socket.IO EVENT: 42[...]
        if text.hasPrefix("42") {
            let json = String(text.dropFirst(2))
            handleSocketEvent(json)
        }
        
        // Socket.IO ACK: 43[...]
        if text.hasPrefix("43") {
            logConnection("Received ACK")
        }
        
        // Socket.IO ERROR: 44{...}
        if text.hasPrefix("44") {
            logConnection("❌ Socket.IO error: \(text)")
        }
    }
    
    private func handleSocketEvent(_ json: String) {
        guard
            let data = json.data(using: .utf8),
            let arr = try? JSONSerialization.jsonObject(with: data) as? [Any],
            arr.count >= 2,
            let event = arr[0] as? String,
            let payload = arr[1] as? [String: Any]
        else {
            print("Failed to parse event:", json)
            return
        }
        
        logConnection("📨 Event '\(event)'")
        
        if event == "response" {
            handleMailResponse(payload)
        } else {
            onEvent?(event, payload)
        }
    }
    
    private func handleMailResponse(_ data: [String: Any]) {
        print("📬 Mail response:", data)
        
        if let nothingChanged = data["nothing_changed"] as? Bool {
            if nothingChanged {
                print("📭 No new mails")
            } else {
                print("📬 New mails available!")
                
                // Если есть массив писем (проверьте ключ на сервере)
                if let mails = data["mails"] as? [[String: Any]] {
                    print("New mails count:", mails.count)
                    
                    // Обновляем last_mail_id
                    if let maxId = mails.compactMap({ $0["id"] as? Int }).max() {
                        lastMailId = maxId
                    }
                }
                
                onEvent?("newMails", data)
            }
        }
    }
    
    private func send(text: String) {
        logMessage("SEND", text)
        
        task?.send(.string(text)) { [weak self] error in
            if let error {
                self?.logConnection("❌ Send error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private Methods: Heartbeat
    
    private func startPing() {
        pingTimer?.invalidate()
//        pingTimer = Timer.scheduledTimer(withTimeInterval: pingInterval, repeats: true) { [weak self] _ in
//            // В Engine.IO v4 пинги отправляет сервер, клиент только отвечает
//        }
    }
    
    // MARK: - Logging
    
    private func logMessage(_ direction: String, _ message: String) {
        guard enableDebugLogging else { return }
        
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let arrow = direction == "SEND" ? "📤" : "📥"
        
        print("[\(timestamp)] \(arrow) \(direction): \(message)")
    }
    
    private func logConnection(_ event: String) {
        guard enableDebugLogging else { return }
        
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        print("[\(timestamp)] 🔌 \(event)")
    }
    
    // MARK: - Utilities
    
    private func generateTimestamp() -> String {
        let base36Chars = "0123456789abcdefghijklmnopqrstuvwxyz"
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        var result = ""
        var value = timestamp
        
        while value > 0 {
            let index = base36Chars.index(base36Chars.startIndex, offsetBy: value % 36)
            result = String(base36Chars[index]) + result
            value /= 36
        }
        
        return result.isEmpty ? "0" : result
    }
    
    // MARK: - URLSessionWebSocketDelegate
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol _protocol: String?) {
        logConnection("✅ WebSocket opened with protocol: \(_protocol ?? "none")")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        let reasonString = reason.flatMap { String(data: $0, encoding: .utf8) } ?? "No reason"
        logConnection("❌ WebSocket closed - Code: \(closeCode.rawValue), Reason: \(reasonString)")
        Task { @MainActor in
            disconnect()
        }
    }
}

extension MailSocketClient {
    static let liveValue = MailSocketClient()
}
