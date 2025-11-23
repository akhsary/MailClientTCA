//
//  AuthService.swift
//  MailClientTCA
//
//  Created by yuchekan on 15.11.2025.
//

import Foundation
import Dependencies
import DependenciesMacros

@DependencyClient
public struct AuthService: Sendable {
    public var login: @Sendable (_ username: String, _ password: String) async throws -> AuthServiceResponceDTO
}

extension AuthService: DependencyKey {
    public static let liveValue = AuthService { username, password in
        let body = AuthServiceRequestDTO(service: "account",
                                         action: "authorization",
                                         data: .init(email: username,
                                                     password: password))
        
        let request = Request<AuthServiceResponceDTO>.post(baseURL: "https://api.xyecoc.com",
                                                           endpoint: "request",
                                                           body: body)
        let result = try await NetworkClient.liveValue.send(request)
//        print("DEBUG: \(result)")
        return result
    }
    
    public static let previewValue = AuthService { username, password in
        try await Task.sleep(nanoseconds: 1_000_000_000)
//        print("DEBUG: preview auth")
        return AuthServiceResponceDTO(status: 1, data: "", message: "", service: "", action: "")
    }
}

extension DependencyValues {
    nonisolated public var authService: AuthService {
        get { self[AuthService.self] }
        set { self[AuthService.self] = newValue }
    }
}
