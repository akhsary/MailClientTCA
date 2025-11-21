//
//  AuthServiceResponceDTO.swift
//  MailClientTCA
//
//  Created by yuchekan on 15.11.2025.
//

import Foundation

nonisolated
public struct AuthServiceResponceDTO: Sendable, Decodable {
    let status: Int
    let data: String
    let message: String
    let service: String
    let action: String
}

/*
 {
   "status": 0,
   "message": "authenticate error",
   "service": "account",
   "action": "authorization"
 }
 */
