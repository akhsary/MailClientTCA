//
//  MainService.swift
//  MailClientTCA
//
//  Created by yuchekan on 19.11.2025.
//

import Foundation
import Dependencies
import DependenciesMacros

@DependencyClient
nonisolated
public struct MainService: Sendable {
    public var login: @Sendable (String, String) async throws -> MainServiceResponceDTO
}

nonisolated
extension MainService: DependencyKey {
    public static let liveValue = MainService { token, mailID in
        let body = MainServiceRequestDTO(service: "mail",
                                         params: ["mail_id": mailID, "param_1": mailID],
                                         action: "view",
                                         currentLang: "mail",
                                         token: token)
        
        let request = await Request<MainServiceResponceDTO>.post(baseURL: "https://api.xyecoc.com",
                                                           endpoint: "request",
                                                           body: body)
        let result = try await NetworkClient.liveValue.send(request)
        print("DEBUG: \(result)")
        return result
    }
    
    public static let previewValue = MainService { username, password in
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("DEBUG: preview auth")

        return MainServiceResponceDTO(
            status: 1,
            message: "success",
            data: .init(
                id: 126492,
                userId: 43187,
                snippet: "Без темы",
                sender: "Yuriy Chekan",
                createdAt: "2025-11-19T16:25:59.086Z",
                updatedAt: "2025-11-19T16:25:59.086Z",
                read: false,
                important: false,
                cc: nil,
                bcc: nil,
                subject: "Без темы",
                message: nil,
                to: "yrashka2004@xyecoc.com",
                messageId: "CAP-nxrtq2jyd=n8L1QEbs8X6yE8QeAMPgPTgVu86-KTn0cwCtg@mail.gmail.com",
                fromEmail: "chekanyr@gmail.com",
                fromName: "Yuriy Chekan",
                violation: nil,
                threadId: nil,
                attachments: [nil]
            ),
            service: "mail",
            action: "view",
            security: "private"
        )
    }

}

extension DependencyValues {
    nonisolated public var mainService: MainService {
        get { self[MainService.self] }
        set { self[MainService.self] = newValue }
    }
}
