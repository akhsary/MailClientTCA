//
//  AuthError.swift
//  MailClientTCA
//
//  Created by yuchekan on 23.11.2025.
//

import Foundation

public struct AuthError: Sendable, Identifiable, Equatable, Error {
    let title: String
    let message: String
    
    public var id: String {
        title + message
    }
}
