//
//  LetterItemModel.swift
//  MailClientTCA
//
//  Created by yuchekan on 19.11.2025.
//

import Foundation

public typealias LetterModels = [LetterItemModel]

public struct LetterItemModel: Equatable, Identifiable, Sendable {
    public static func == (lhs: LetterItemModel, rhs: LetterItemModel) -> Bool {
        lhs.id == rhs.id
        && lhs.name == rhs.name
        && lhs.theme == rhs.theme
        && lhs.date == rhs.date
        && lhs.message == rhs.message
        && lhs.read == rhs.read
    }
    
    public let id: String
    public let name: String
    public let theme: String?
    public let date: Date?
    public let message: String?
    public let sendedTo: String?
    public let read: Bool
}

// MARK: - Preview Extension
extension LetterItemModel {
    static var preview: LetterItemModel {
        let senders = [
            "Yuriy Chekan",
            "John Smith",
            "Maria Garcia",
            "Alex Johnson",
            "Sarah Williams",
            "Michael Brown"
        ]
        
        let themes = [
            "Meeting Tomorrow at 10 AM",
            "Project Update: Q4 Results",
            "Invoice #\(Int.random(in: 1000...9999))",
            "Important: Action Required",
            "Weekly Newsletter",
            "Re: Your Recent Purchase",
            "Subscription Confirmation",
            "Password Reset Request"
        ]
        
        let messages = [
            "Dear user, this is a preview message for testing purposes. Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            "Hello, we hope this message finds you well. Please find the details below. Best regards",
            "Hi there, just a quick update on the project status. Everything is progressing smoothly.",
            "Good morning, attached you'll find the documents we discussed. Let me know if you have questions."
        ]
        
        let recipients = [
            "inbox@xyecoc.com",
            "support@xyecoc.com",
            "sales@xyecoc.com",
            nil
        ]
        
        return LetterItemModel(
            id: UUID().uuidString,
            name: senders.randomElement()!,
            theme: themes.randomElement()!,
            date: Date().addingTimeInterval(-Double.random(in: 0...604800)), // Last week
            message: messages.randomElement()!,
            sendedTo: recipients.randomElement() ?? nil,
            read: .random()
        )
    }
}
