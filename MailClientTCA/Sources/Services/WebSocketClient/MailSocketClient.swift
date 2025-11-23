//
//  MailSocketClient.swift
//  MailClientTCA
//
//  Created by yuchekan on 16.11.2025.
//

import Foundation

actor MailSocketClient: NSObject, URLSessionWebSocketDelegate {
    private let accessToken: String?
    private let baseURL: URL = URL(string: "https://api.xyecoc.com")!
    
    private var task: URLSessionWebSocketTask?
    private var session: URLSession?
    
    private var sessionId: String?
    private var pingInterval: TimeInterval = 25
    private var pingTimeout: TimeInterval = 20
    private var maxPayload: Int = 1000000
    
    private var lastMailId: Int = 0
    
    var enableDebugLogging: Bool = true
    
    // MARK: - AsyncStream
    
    private var eventContinuation: AsyncStream<SocketEvent>.Continuation?
    
    public let events: AsyncStream<SocketEvent>
    
    // MARK: - Event Types
    
    public enum SocketEvent: @unchecked Sendable {
        case updating
        case updated
        case connected
        case disconnected
        case newMails([MailData])
        case error(String)
        case rawEvent(name: String, payload: [String: Any])
    }
    
    // MARK: - Initialization
    
    override init() {
        let storage = _KeychainStorage.shared
        self.accessToken = storage.getPassword(for: "access_token")
        
        var continuation: AsyncStream<SocketEvent>.Continuation?
        let stream = AsyncStream<SocketEvent> { continuation = $0 }
        self.events = stream
        self.eventContinuation = continuation
        
        super.init()
    }
    
    deinit {
        eventContinuation?.finish()
        Task { [task, session] in
            task?.cancel(with: .goingAway, reason: nil)
            session?.invalidateAndCancel()
        }
    }
    
    // MARK: - Public Methods
    
    func connect(with id: Int?) async {
        defer {
            eventContinuation?.yield(.updated)
        }
        
        if let id {
            self.lastMailId = id
        }
        
        eventContinuation?.yield(.updating)
        do {
            try await performHandshake()
            try await sendConnectPacket()
            try await upgradeToWebSocket()
            
        } catch {
            logConnection("❌ Connection error: \(error)")
            eventContinuation?.yield(.error(error.localizedDescription))
            eventContinuation?.yield(.disconnected)
        }
    }
    
    func disconnect() {
        lastMailId = 0
        cleanup()
        eventContinuation?.yield(.disconnected)
    }
    
    func emit(event: String, data: Any) {
        let payload: String
        if let jsonData = try? JSONSerialization.data(withJSONObject: [event, data]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            payload = "42\(jsonString)"
        } else {
            logConnection("❌ Failed to serialize event data")
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
            "last_mail_id": self.lastMailId,
            "currentLang": "inbox",
            "token": token
        ]
        
        emit(event: "request", data: requestData)
        logConnection("📤 Requesting new mails with last_mail_id: \(self.lastMailId)")
        eventContinuation?.yield(.updated)
    }
    
    // MARK: - Private Methods: Cleanup
    
    private func cleanup() {
        task?.cancel(with: .goingAway, reason: nil)
        session?.invalidateAndCancel()
        sessionId = nil
    }
    
    // MARK: - Private Methods: Connection Flow
    
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
            guard let self, !Task.isCancelled else { return }
            
            Task {
                switch result {
                case .success(let msg):
                    switch msg {
                    case .string(let str):
                        await self.logMessage("RECV", str)
                        await self.handleMessage(str)
                        
                    case .data(let data):
                        await self.logMessage("RECV", "Binary data: \(data.count) bytes")
                        if let stringRepresentation = String(data: data, encoding: .utf8) {
                            await self.logMessage("RECV", "Data as String: \(stringRepresentation)")
                        }
                        
                    @unknown default:
                        break
                    }
                    
                case .failure(let error):
                    await self.logConnection("❌ WebSocket error: \(error.localizedDescription)")
                    await self.handleError(error)
                }
                
                await self.listen()
            }
        }
    }
    
    private func handleError(_ error: Error) {
        eventContinuation?.yield(.error(error.localizedDescription))
        disconnect()
    }
    
    private func handleMessage(_ text: String) {
        if text == "3probe" {
            logConnection("✅ Probe confirmed, sending upgrade packet")
            send(text: "5")
            return
        }
        
        if text == "2" {
            send(text: "3")
            return
        }
        
        if text.hasPrefix("40") {
            logConnection("✅ Socket.IO connected")
            if text.count > 2 {
                let json = String(text.dropFirst(2))
                logConnection("Connection data: \(json)")
            }
            
            eventContinuation?.yield(.connected)
            
            // Только один начальный запрос при подключении
            requestNewMails()
            return
        }
        
        if text.hasPrefix("42") {
            let json = String(text.dropFirst(2))
            handleSocketEvent(json)
        }
        
        if text.hasPrefix("43") {
            logConnection("Received ACK")
        }
        
        if text.hasPrefix("44") {
            logConnection("❌ Socket.IO error: \(text)")
            eventContinuation?.yield(.error(text))
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
            logConnection("Failed to parse event: \(json)")
            return
        }
        
        logConnection("📨 Event '\(event)'")
        
        if event == "response" {
            handleMailResponse(payload)
        } else {
            eventContinuation?.yield(.rawEvent(name: event, payload: payload))
        }
    }
    
    private func handleMailResponse(_ data: [String: Any]) {
        logConnection("📬 Mail response received")
        
        // Проверяем флаг nothing_changed
        if let nothingChanged = data["nothing_changed"] as? Bool, nothingChanged {
            logConnection("⏭️ Nothing changed, skipping request")
            // НЕ запрашиваем снова - просто выходим
            return
        } else {
            eventContinuation?.yield(.updating)
        }
        
        // Если есть изменения, обрабатываем почту
        guard let mailsArray = data["mails"] as? [[String: Any]] else {
            logConnection("❌ No mails array in response")
            // Запрашиваем снова даже при ошибке парсинга
            requestNewMails()
            return
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: mailsArray)
            let mails = try JSONDecoder().decode([MailData].self, from: jsonData)
            
            logConnection("📬 Parsed \(mails.count) mails")
            
            if let lastId = data["last_mail_id"] as? Int {
                lastMailId = lastId
            }
            
            eventContinuation?.yield(.newMails(mails))
            
            // После успешной обработки запрашиваем следующую порцию
            requestNewMails()
            
        } catch {
            logConnection("❌ Failed to decode mails: \(error)")
            eventContinuation?.yield(.error("Failed to decode mails: \(error.localizedDescription)"))
            // При ошибке декодирования тоже запрашиваем снова
            requestNewMails()
        }
    }
    
    private func send(text: String) {
        logMessage("SEND", text)
        
        task?.send(.string(text)) { [weak self] error in
            if let error {
                Task {
                    await self?.logConnection("❌ Send error: \(error.localizedDescription)")
                    await self?.eventContinuation?.yield(.error(error.localizedDescription))
                }
            }
        }
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
    
    nonisolated func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocolName: String?
    ) {
        Task {
            await logConnection("✅ WebSocket opened with protocol: \(protocolName ?? "none")")
        }
    }
    
    nonisolated func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        let reasonString = reason.flatMap { String(data: $0, encoding: .utf8) } ?? "No reason"
        Task {
            await logConnection("❌ WebSocket closed - Code: \(closeCode.rawValue), Reason: \(reasonString)")
            await handleDisconnection()
        }
    }
    
    private func handleDisconnection() {
        eventContinuation?.yield(.disconnected)
        disconnect()
    }
}

extension MailSocketClient {
    static let liveValue = MailSocketClient()
}
