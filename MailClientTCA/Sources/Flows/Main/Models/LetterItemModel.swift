//
//  LetterItemModel.swift
//  MailClientTCA
//
//  Created by yuchekan on 19.11.2025.
//

import Foundation

nonisolated
public struct LetterItemModel: Equatable, Identifiable {
    public let id: String
    public let name: String
    public let theme: String?
    public let date: String?
    public let message: String?
}
