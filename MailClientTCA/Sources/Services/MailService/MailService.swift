//
//  MailService.swift
//  MailClientTCA
//
//  Created by yuchekan on 21.11.2025.
//

import ComposableArchitecture
import Foundation

// MARK: - Mail ID Model
nonisolated
public struct MailID: Sendable, Equatable, Identifiable {
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
}

// MARK: - Mail Service
@DependencyClient
nonisolated
public struct MailService: Sendable {
    /// Стрим для получения новых ID писем
    /// Возвращает функцию, так как AsyncStream не поддерживает множественных подписчиков
    public var mailIDStream: @Sendable () -> AsyncStream<MailID> = { .finished }
}

// MARK: - Dependency Key
nonisolated
extension MailService: DependencyKey {
    public static let liveValue = MailService {
        // TODO: Здесь будет WebSocket подключение
        // Пока возвращаем моковый стрим
        AsyncStream { continuation in
            Task {
                /*
                 128218
                 128224
                 128227
                 */
                continuation.yield(MailID(id: "126492"))
                continuation.finish()
            }
        }
    }
    
    public static let previewValue = MailService {
        AsyncStream { continuation in
            Task {
                // Мокаем поступление новых писем каждые 3 секунды
                for i in 1...5 {
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    continuation.yield(MailID(id: "mail_\(i)"))
                }
                continuation.finish()
            }
        }
    }
    
    public static let testValue = MailService()
}

// MARK: - Dependency Values
extension DependencyValues {
    nonisolated public var mailService: MailService {
        get { self[MailService.self] }
        set { self[MailService.self] = newValue }
    }
}
