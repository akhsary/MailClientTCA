//
//  MainServiceResponceDTO.swift
//  MailClientTCA
//
//  Created by yuchekan on 19.11.2025.
//

import Foundation

nonisolated
public struct MainServiceResponceDTO: Codable, Sendable {
    let status: Int
    let message: String
    let data: MailData
    let service: String
    let action: String
    let security: String
}

nonisolated
public struct MailData: Codable, Sendable {
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
    let attachments: [String?]?
    
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
        case attachments
    }
}

/*
 DEBUG: MainServiceResponceDTO(status: 1, message: "success", data: MailClientTCA.MailData(id: 126492, userId: 43187, snippet: Optional("Без темы"), sender: Optional("Yuriy Chekan"), createdAt: "2025-11-19T16:25:59.086Z", updatedAt: "2025-11-19T16:25:59.086Z", read: true, important: false, cc: nil, bcc: nil, subject: Optional("Без темы"), message: nil, to: Optional("yrashka2004@xyecoc.com"), messageId: Optional("CAP-nxrtq2jyd=n8L1QEbs8X6yE8QeAMPgPTgVu86-KTn0cwCtg@mail.gmail.com"), fromEmail: Optional("chekanyr@gmail.com"), fromName: Optional("Yuriy Chekan"), violation: nil, threadId: nil, attachments: Optional([nil])), service: "mail", action: "view", security: "private")
 takeNewLetters([MailClientTCA.LetterItemModel(id: "126492", name: "Yuriy Chekan", theme: "Без темы", date: "2025-11-19T16:25:59.086Z")])
 */
