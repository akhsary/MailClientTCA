//
//  LetterItemDTO.swift
//  XMail
//
//  Created by yuchekan on 23.11.2025.
//

import SwiftData
import Foundation

@Model
public final class LetterItemDTO {
    @Attribute(.unique) public var id: String
    public var name: String
    public var theme: String?
    public var date: Date?
    public var message: String?
    public var sendedTo: String?
    
    public init(
        id: String,
        name: String,
        theme: String? = nil,
        date: Date? = nil,
        message: String? = nil,
        sendedTo: String? = nil
    ) {
        self.id = id
        self.name = name
        self.theme = theme
        self.date = date
        self.message = message
        self.sendedTo = sendedTo
    }
}

// MARK: - Mapping Extensions
extension LetterItemDTO {
    public func toModel() -> LetterItemModel {
        LetterItemModel(
            id: id,
            name: name,
            theme: theme,
            date: date,
            message: message,
            sendedTo: sendedTo
        )
    }
    
    static func fromModel(_ model: LetterItemModel) -> LetterItemDTO {
        LetterItemDTO(
            id: model.id,
            name: model.name,
            theme: model.theme,
            date: model.date,
            message: model.message,
            sendedTo: model.sendedTo
        )
    }
}
