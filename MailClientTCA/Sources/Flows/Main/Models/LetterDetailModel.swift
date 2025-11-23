//
//  LetterDetailModel.swift
//  MailClientTCA
//
//  Created by yuchekan on 22.11.2025.
//

import Foundation

public struct LetterDetailModel: Equatable, Sendable {
    public let name: String
    public let sendedTo: String
    public let theme: String?
    public let date: String?
}
