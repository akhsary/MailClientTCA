//
//  SocketMailResponse.swift
//  MailClientTCA
//
//  Created by yuchekan on 21.11.2025.
//

import Foundation

nonisolated
public struct SocketMailResponse: Codable, Sendable {
    let mails: [SoketMailData]
    let total: TotalCount
    let folders: [String] // или создайте модель Folder если нужно
    let tags: [String] // или создайте модель Tag если нужно
    let lastMailId: Int
    let params: [String: String]? // пустой объект
    let service: String
    let action: String
    let security: String
    
    enum CodingKeys: String, CodingKey {
        case mails
        case total
        case folders
        case tags
        case lastMailId = "last_mail_id"
        case params
        case service
        case action
        case security
    }
}

nonisolated
public struct TotalCount: Codable, Sendable {
    let count: String // Сервер отправляет строку, не число!
    
    var countInt: Int {
        Int(count) ?? 0
    }
}

// Модель одного письма (ваша существующая, чуть доработанная)
nonisolated
public struct SoketMailData: Codable, Sendable {
    let id: Int
    let userId: Int
    let snippet: String?
    let sender: String?
    let createdAt: String
    let updatedAt: String
    let read: Bool
    let important: Bool
    let cc: String?
    let bcc: String?
    let subject: String?
    let message: String?
    let to: String?
    let messageId: String?
    let fromEmail: String?
    let fromName: String?
    let violation: String?
    let threadId: String?
    let boxFlag: String? // НОВОЕ поле из ответа
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case snippet
        case sender
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case read
        case important
        case cc
        case bcc
        case subject
        case message
        case to
        case messageId = "message_id"
        case fromEmail = "from_email"
        case fromName = "from_name"
        case violation
        case threadId = "thread_id"
        case boxFlag = "box_flag"
    }
}
