//
//  MailSocketClient.swift
//  MailClientTCA
//
//  Created by yuchekan on 16.11.2025.
//

import Foundation
import SocketIO

final class MailSocketClient: NSObject, URLSessionWebSocketDelegate {
    @MainActor
    @KeychainStorage("access_token")
    private var accessToken
    
    private var task: URLSessionWebSocketTask?
    private var session: URLSession?
    
    private var url: URL?
    
    private var pingTimer: Timer?
    private var pingInterval: TimeInterval = 25
    private var pingTimeout: TimeInterval = 20
    
    var onEvent: ((String, Any?) -> Void)?
    var onDisconnect: (() -> Void)?
    
    @MainActor
    func start(baseURL: URL = URL(string: "https://api.xyecoc.com")!) {
        let token = accessToken ?? ""
        let wsURL = baseURL
            .appendingPathComponent("socket.io/")
            .appendingQueryItems([
                .init(name: "EIO", value: "4"),
                .init(name: "transport", value: "websocket"),
                .init(name: "token", value: token)
            ])
        
        self.url = wsURL
    }
    
    func connect() {
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
        
        task = session?.webSocketTask(with: url!)
        task?.resume()
        
        listen()
    }
    
    func disconnect() {
        pingTimer?.invalidate()
        task?.cancel()
        session?.invalidateAndCancel()
        onDisconnect?()
    }
    
    private func listen() {
        task?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let msg):
                switch msg {
                case .string(let str):
                    self.handleMessage(str)
                default:
                    break
                }
            case .failure:
                self.disconnect()
            }
            self.listen()
        }
    }
    
    private func handleMessage(_ text: String) {
        // Socket.IO EngineIO protocol:
        // 40 - connect
        // 42[...] - event
        // 2 - ping
        // 3 - pong
        
        if text == "2" {
            // Server ping → reply pong
            send(text: "3")
            return
        }
        
        if text.hasPrefix("42") {
            // Socket.IO event
            let json = String(text.dropFirst(2))
            handleSocketEvent(json)
        }
        
        if text == "40" {
            // connected
            print("Engine.IO connected")
        }
    }
    
    func emit(event: String, data: Any) {
        // Example: 42["sendMessage", {..}]
        let payload: String
        if let jsonData = try? JSONSerialization.data(withJSONObject: [event, data]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            payload = "42\(jsonString)"
        } else {
            return
        }
        send(text: payload)
    }
    
    private func handleSocketEvent(_ json: String) {
        guard
            let data = json.data(using: .utf8),
            let arr = try? JSONSerialization.jsonObject(with: data) as? [Any],
            arr.count >= 1,
            let event = arr[0] as? String
        else { return }
        
        let payload = arr.count > 1 ? arr[1] : nil
        onEvent?(event, payload)
    }
    
    private func send(text: String) {
        task?.send(.string(text)) { error in
            if let error {
                print("WS send error:", error)
            }
        }
    }
}

extension MailSocketClient {
    static let liveValue = MailSocketClient()
}
