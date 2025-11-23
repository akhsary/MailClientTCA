//
//  MainFeature.swift
//  MailClientTCA
//
//  Created by yuchekan on 16.11.2025.
//

import Foundation
@preconcurrency import ComposableArchitecture

@Reducer
public struct MainFeature: Sendable {
    public init() {}
    
    @Dependency(\.mailDataStorage) var mailDataStorage
    
    private let socketClient = MailSocketClient.liveValue
    
    @ObservableState
    public struct State: Equatable, Sendable {
        var isLoading = false
        var items = LetterModels()
        var path = StackState<Path.State>()
        
        @ObservationStateIgnored
        fileprivate var isFirstAppear: Bool = true
        
        @ObservationStateIgnored
        fileprivate var existingLetterIDs: Set<String> = []
    }
    
    public enum Action: Sendable {
        case onAppear
        case updating
        case updated
        case connectToSocket
        case takeNewLetters(LetterModels)
        case path(StackActionOf<Path>)
        case letterTapped(LetterItemModel)
        case logout
    }
    
    @Reducer
    public enum Path: Sendable {
        case detail(MainDetailFeature)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.isFirstAppear else { return .none }
                state.isFirstAppear = false
                return .send(.connectToSocket)
                
            case .connectToSocket:
                return .run { send in
                    await send(.updating)
                    
                    // Загружаем существующие письма из базы
                    let storedLetters = (try? await mailDataStorage.fetch()) ?? []
                    await send(.takeNewLetters(storedLetters))
                    
                    // Подключаемся к сокету с ID последнего письма
                    let lastLetterID = Int(storedLetters.first?.id ?? "0") ?? 0
                    await socketClient.connect(with: lastLetterID)
                    
                    // Обрабатываем события из сокета
                    for await event in socketClient.events {
                        switch event {
                        case .updating:
                            await send(.updating)
                            
                        case .newMails(let newMails):
                            let newLetters = newMails.map { mail in
                                LetterItemModel(
                                    id: "\(mail.id)",
                                    name: mail.sender ?? "",
                                    theme: mail.snippet,
                                    date: mail.updatedAt.toDate(),
                                    message: mail.message,
                                    sendedTo: mail.to
                                )
                            }
                            
                            await withTaskGroup { group in
                                group.addTask {
                                    try? await mailDataStorage.save(newLetters)
                                }
                                group.addTask {
                                    await send(.takeNewLetters(newLetters))
                                }
                            }
                            
                        case .updated:
                            await send(.updated)
                            
                        default:
                            continue
                        }
                    }
                }
                
            case .takeNewLetters(let newLetters):
                let uniqueNewLetters = newLetters.filter { letter in
                    !state.existingLetterIDs.contains(letter.id)
                }
                
                state.existingLetterIDs.formUnion(newLetters.map(\.id))
                
                if !uniqueNewLetters.isEmpty {
                    state.items = uniqueNewLetters + state.items
                }
                
                return .none
                
            case .letterTapped(let letter):
                let detail = LetterDetailModel(
                    name: letter.name,
                    sendedTo: letter.sendedTo ?? "",
                    theme: letter.theme,
                    date: letter.date?.toFormattedDateString()
                )
                state.path.append(.detail(MainDetailFeature.State(letterHeader: detail)))
                return .none
                
            case .updated:
                state.isLoading = false
                return .none
                
            case .updating:
                state.isLoading = true
                return .none
                
            case .path:
                return .none
                
            case .logout:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension MainFeature.Path.State: Equatable, Sendable {}

extension MainFeature.Path.Action: Sendable {}
