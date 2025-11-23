//
//  DataStorageService.swift
//  XMail
//
//  Created by yuchekan on 23.11.2025.
//

import SwiftData

public enum ModelContainerProvider {
    static let mailStorageContainer: ModelContainer = {
        do {
            let container = try ModelContainer(
                for: LetterItemDTO.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
            return container
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
}
