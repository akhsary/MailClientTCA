//
//  MainServiceResponceDTO.swift
//  MailClientTCA
//
//  Created by yuchekan on 19.11.2025.
//

import Foundation

public struct MainServiceResponceDTO: Codable, Sendable, Equatable {
    let status: Int
    let message: String
    let data: MailData
    let service: String
    let action: String
    let security: String
}

public struct MailData: Codable, Sendable, Equatable {
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

// MARK: - MailData Extension for Preview

extension MailData {
    static var preview: MailData {
        let randomId = Int.random(in: 1..<999)
        
        let subjects = [
            "Meeting Tomorrow at 10 AM",
            "Project Update: Q4 Results",
            "Invoice #\(randomId)",
            "Important: Action Required",
            "Weekly Newsletter",
            "Re: Your Recent Purchase",
            "Subscription Confirmation",
            "Password Reset Request"
        ]
        
        let senders = [
            "Yuriy Chekan",
            "John Smith",
            "Maria Garcia",
            "Alex Johnson",
            "Sarah Williams",
            "Michael Brown"
        ]
        
        let snippets = [
            "SwiftUI is a declarative framework...",
            "Thank you for your recent order...",
            "Your payment has been processed...",
            "Please review the attached document...",
            "We're excited to announce...",
            "Action required: Please verify your email...",
            "Here's your weekly summary..."
        ]
        
        let messages = [
            "Dear user,\n\nThis is a preview message for testing purposes. Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            "Hello,\n\nWe hope this message finds you well. Please find the details below.\n\nBest regards",
            "Hi there,\n\nJust a quick update on the project status. Everything is progressing smoothly.",
            "Good morning,\n\nAttached you'll find the documents we discussed. Let me know if you have questions."
        ]
        
        let sender = senders.randomElement()!
        let senderEmail = sender.lowercased()
            .replacingOccurrences(of: " ", with: ".")
        
        return MailData(
            id: randomId,
            userId: Int.random(in: 1000...9999),
            snippet: snippets.randomElement()!,
            sender: sender,
            createdAt: Date().addingTimeInterval(-Double.random(in: 0...86400)).toFormattedDateString(), // Last week
            updatedAt: Date().addingTimeInterval(-Double.random(in: 0...86400)).toFormattedDateString(), // Last 24h
            read: Bool.random(),
            important: Int.random(in: 1...10) > 7, // 30% chance
            cc: Bool.random() ? "cc@example.com, another@example.com" : nil,
            bcc: Bool.random() ? "bcc@example.com" : nil,
            subject: subjects.randomElement()!,
            message: messages.randomElement()!,
            to: "you@xyecoc.com",
            messageId: "<\(UUID().uuidString)@xyecoc.com>",
            fromEmail: "\(senderEmail)@example.com",
            fromName: sender,
            violation: Int.random(in: 1...20) > 18 ? "spam" : nil, // 10% spam
            threadId: "thread_\(Int.random(in: 10000...99999))",
            attachments: nil
        )
    }
}
