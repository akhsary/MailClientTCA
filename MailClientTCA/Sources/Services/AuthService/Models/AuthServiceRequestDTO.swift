//
//  AuthServiceRequestDTO.swift
//  MailClientTCA
//
//  Created by yuchekan on 15.11.2025.
//

import Foundation

nonisolated
public struct AuthServiceRequestDTO: Encodable, Sendable {
    let service: String
    let action: String
    let data: AuthServiceRequestDTO.Data
    
    struct Data: Encodable, Sendable {
        let email: String
        let password: String
    }
}
