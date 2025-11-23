//
//  MailSocketClient.swift
//  MailClientTCA
//
//  Created by yuchekan on 16.11.2025.
//

import ComposableArchitecture
import Foundation

@DependencyClient
struct MailSocketClient: Sendable {
    var connect: @Sendable (_ lastMailId: Int?) async -> Void
    var disconnect: @Sendable () async -> Void
    var requestNewMails: @Sendable (_ lastMailId: Int?) async -> Void
    var events: @Sendable () -> AsyncStream<SocketEvent> = {
        var continuation: AsyncStream<MailSocketClient.SocketEvent>.Continuation?
        let stream = AsyncStream<MailSocketClient.SocketEvent> { continuation = $0 }
        return stream
    }
    var requestUpdates: @Sendable () async -> Void
    
    enum SocketEvent: @unchecked Sendable, Equatable {
        case updating
        case updated
        case connected
        case disconnected
        case newMails([MailData])
        case error(String)
        case rawEvent(name: String, payload: [String: Any])
        
        static func == (lhs: SocketEvent, rhs: SocketEvent) -> Bool {
            switch (lhs, rhs) {
            case (.updating, .updating),
                 (.updated, .updated),
                 (.connected, .connected),
                 (.disconnected, .disconnected):
                return true
            case let (.newMails(lhsMails), .newMails(rhsMails)):
                return lhsMails == rhsMails
            case let (.error(lhsError), .error(rhsError)):
                return lhsError == rhsError
            case let (.rawEvent(lhsName, _), .rawEvent(rhsName, _)):
                return lhsName == rhsName
            default:
                return false
            }
        }
    }
}

extension MailSocketClient: DependencyKey {
    static let liveValue: MailSocketClient = {
        let actor = _MailSocketActor()
        
        return MailSocketClient(
            connect: { lastMailId in
                await actor.connect(with: lastMailId)
            },
            disconnect: {
                await actor.disconnect()
            },
            requestNewMails: { lastMailId in
                await actor.requestNewMails(lastMailId: lastMailId)
            },
            events: {
                actor.events
            },
            requestUpdates: {}
        )
    }()
    
    static let testValue = MailSocketClient()
    
    static let previewValue: MailSocketClient = {
        return MailSocketClient(
            connect: { _ in
                // No-op for preview
            },
            disconnect: {
                // No-op for preview
            },
            requestNewMails: { _ in
                // No-op for preview
            },
            events: {
                AsyncStream { continuation in
                    Task {
                        let randomMails = (0...5).map { _ in
                            MailData.preview
                        }
                        continuation.yield(.newMails(randomMails))
                        
                        // Emit random events every 10 seconds
                        while !Task.isCancelled {
                            try? await Task.sleep(for: .seconds(10))
                            
                            let randomEvent = Int.random(in: 0...4)
                            
                            switch randomEvent {
                            case 0:
                                continuation.yield(.connected)
                            case 1:
                                continuation.yield(.updating)
                            case 2:
                                continuation.yield(.updated)
                            case 3:
                                // Random mails
                                let randomMails = (1...Int.random(in: 1...5)).map { _ in
                                    MailData.preview
                                }
                                continuation.yield(.newMails(randomMails))
                            case 4:
                                continuation.yield(.disconnected)
                            default:
                                break
                            }
                        }
                        
                        continuation.finish()
                    }
                }
            },
            requestUpdates: {}
        )
    }()
}

extension DependencyValues {
    var mailSocketClient: MailSocketClient {
        get { self[MailSocketClient.self] }
        set { self[MailSocketClient.self] = newValue }
    }
}


