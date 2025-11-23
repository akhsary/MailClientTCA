//
//  AuthError.swift
//  MailClientTCA
//
//  Created by yuchekan on 23.11.2025.
//

import Foundation

struct AuthError: Sendable, Identifiable, Error {
    let title: String
    let message: String
    
    var id: String {
        title + message
    }
}
