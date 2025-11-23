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
public struct MainService: Sendable {
    public var getLetter: @Sendable (_ mailID: String) async throws -> MainServiceResponceDTO
}

extension MainService: DependencyKey {
    public static let liveValue = MainService { mailID in
        let accessToken: String? = {
            let storage = _KeychainStorage.shared
            return storage.getPassword(for: "access_token")
        }()
        
        let body = MainServiceRequestDTO(service: "mail",
                                         params: ["mail_id": mailID, "param_1": mailID],
                                         action: "view",
                                         currentLang: "mail",
                                         token: accessToken ?? "")
        
        let request = Request<MainServiceResponceDTO>.post(baseURL: "https://api.xyecoc.com",
                                                           endpoint: "request",
                                                           body: body)
        let result = try await NetworkClient.liveValue.send(request)
//        print("DEBUG: \(result)")
        return result
    }
    
    public static let previewValue = MainService { _ in
        try await Task.sleep(nanoseconds: 1_000_000_000)
//        print("DEBUG: preview auth")

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
    public var mainService: MainService {
        get { self[MainService.self] }
        set { self[MainService.self] = newValue }
    }
}
