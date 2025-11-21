//
//  MainServiceRequestDTO.swift
//  MailClientTCA
//
//  Created by yuchekan on 19.11.2025.
//

import Foundation

nonisolated
public struct MainServiceRequestDTO: Codable, Sendable {
    let service: String
    let params: [String: String]?
    let action: String
    let currentLang: String?
    let token: String
}
