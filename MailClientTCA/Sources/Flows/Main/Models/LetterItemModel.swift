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
    }
    
    public let id: String
    public let name: String
    public let theme: String?
    public let date: Date?
    public let message: String?
    public let sendedTo: String?
}
