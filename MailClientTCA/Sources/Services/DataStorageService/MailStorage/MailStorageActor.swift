//
//  MailStorageActor.swift
//  XMail
//
//  Created by yuchekan on 23.11.2025.
//

import SwiftData
import Foundation

@ModelActor
public actor MailStorageActor {
    // Сохранение одного письма (принимаем Sendable модель)
    public func save(_ model: LetterItemModel) throws {
        let dto = LetterItemDTO.fromModel(model)
        modelContext.insert(dto)
        try modelContext.save()
    }
    
    // Сохранение нескольких писем
    public func saveMultiple(_ models: LetterModels) throws {
        for model in models {
            let dto = LetterItemDTO.fromModel(model)
            modelContext.insert(dto)
        }
        try modelContext.save()
    }
    
    // Получение всех писем (возвращаем Sendable модели)
    public func fetchAll() throws -> LetterModels {
        let descriptor = FetchDescriptor<LetterItemDTO>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let dtos = try modelContext.fetch(descriptor)
        return dtos.map { $0.toModel() }
    }
    
    // Получение письма по ID
    public func fetchById(_ id: String) throws -> LetterItemModel? {
        let descriptor = FetchDescriptor<LetterItemDTO>(
            predicate: #Predicate { $0.id == id }
        )
        let dtos = try modelContext.fetch(descriptor)
        return dtos.first?.toModel()
    }
    
    // Удаление письма по ID
    public func delete(withID id: String) throws {
        let descriptor = FetchDescriptor<LetterItemDTO>(
            predicate: #Predicate { $0.id == id }
        )
        let dtos = try modelContext.fetch(descriptor)
        if let dto = dtos.first {
            modelContext.delete(dto)
            try modelContext.save()
        }
    }
    
    // Удаление всех писем
    public func deleteAll() throws {
        try modelContext.delete(model: LetterItemDTO.self)
        try modelContext.save()
    }
}
