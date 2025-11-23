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
    public var getLetterURL: @Sendable (_ mailID: String) -> String = { _ in "" }
}

extension MainService: DependencyKey {
    public static let liveValue = MainService { id in
        let token = _KeychainStorage.shared.getPassword(for: "access_token") ?? ""
        return "https://cdn.xyecoc.com/mail/\(token)/\(id)?token=\(token)"
    }
    
    public static let previewValue = MainService { _ in
        return "https://cdn.xyecoc.com/mail/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NDMxODcsImVtYWlsIjoieXJhc2hrYTIwMDRAeHllY29jLmNvbSIsImZpcnN0X25hbWUiOiJ5cmFzaGthMjAwNCIsImxhc3RfbmFtZSI6IiIsImF2YXRhciI6bnVsbCwic3RvcmFnZV91c2VkIjo2OS40NTEwMDAwMDAwMDAwMSwic3RvcmFnZV90b3RhbCI6MTA1MDAwMCwiaWF0IjoxNzYzOTI1MTk0LCJleHAiOjE3OTU0NjExOTR9.CaC_ML_Rn9weMZFxfhii8OibkqQlNmVvDICKnFCQf1Q/129349?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NDMxODcsImVtYWlsIjoieXJhc2hrYTIwMDRAeHllY29jLmNvbSIsImZpcnN0X25hbWUiOiJ5cmFzaGthMjAwNCIsImxhc3RfbmFtZSI6IiIsImF2YXRhciI6bnVsbCwic3RvcmFnZV91c2VkIjo2OS40NTEwMDAwMDAwMDAwMSwic3RvcmFnZV90b3RhbCI6MTA1MDAwMCwiaWF0IjoxNzYzOTI1MTk0LCJleHAiOjE3OTU0NjExOTR9.CaC_ML_Rn9weMZFxfhii8OibkqQlNmVvDICKnFCQf1Q"
    }

}

extension DependencyValues {
    public var mainService: MainService {
        get { self[MainService.self] }
        set { self[MainService.self] = newValue }
    }
}
