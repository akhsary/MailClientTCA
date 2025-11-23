//
//  MailStorage.swift
//  XMail
//
//  Created by yuchekan on 23.11.2025.
//

import SwiftData
import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct MailStorage: Sendable {
    public var save: @Sendable (_ letters: LetterModels) async throws -> Void
    public var fetch: @Sendable () async throws -> LetterModels
    public var fetchById: @Sendable (_ id: String) async throws -> LetterItemModel?
    public var delete: @Sendable (_ withID: String) async throws -> Void
    public var deleteAll: @Sendable () async throws -> Void
}

extension MailStorage: DependencyKey {
    public static let liveValue: MailStorage = {
        let container = ModelContainerProvider.mailStorageContainer
        let actor = MailStorageActor(modelContainer: container)
        
        return MailStorage(
            save: { models in
                try await actor.saveMultiple(models)
            },
            fetch: {
                try await actor.fetchAll()
            },
            fetchById: { id in
                try await actor.fetchById(id)
            },
            delete: { id in
                try await actor.delete(withID: id)
            },
            deleteAll: {
                try await actor.deleteAll()
            }
        )
    }()
    
    public static let previewValue = MailStorage(
        save: { _ in },
        fetch: {
            [
                LetterItemModel(
                    id: "1",
                    name: "Preview Letter",
                    theme: "Test Theme",
                    date: Date(),
                    message: "Preview message",
                    sendedTo: "preview@example.com",
                    read: .random()
                )
            ]
        },
        fetchById: { _ in
            LetterItemModel(
                id: "1",
                name: "Preview Letter",
                theme: "Test Theme",
                date: Date(),
                message: "Preview message",
                sendedTo: "preview@example.com",
                read: .random()
            )
        },
        delete: { _ in },
        deleteAll: {}
    )
}

extension DependencyValues {
    public var mailDataStorage: MailStorage {
        get { self[MailStorage.self] }
        set { self[MailStorage.self] = newValue }
    }
}
