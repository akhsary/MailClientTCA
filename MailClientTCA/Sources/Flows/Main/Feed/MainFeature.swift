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
    
    private let socketClient = MailSocketClient.liveValue
    
    @ObservableState
    public struct State: Equatable, Sendable {
        var isLoading = true
        var items = [LetterItemModel]()
        var path = StackState<Path.State>()
    }
    
    public enum Action: Sendable {
        case connectToSocket
        case takeNewLetters([LetterItemModel])
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
            case .connectToSocket:
                return .run { send in
                    await socketClient.connect()
                    for await event in MailSocketClient.liveValue.events {
                        if case .newMails(let newMails) = event {
                            await send(.takeNewLetters(newMails.map {
                                LetterItemModel(id: "\($0.id)",
                                                name: $0.sender ?? "",
                                                theme: $0.snippet,
                                                date: $0.updatedAt.toFormattedDateString(),
                                                message: $0.message,
                                                sendedTo: $0.to)
                            }))
                        }
                    }
                }
            case .takeNewLetters(let letters):
                state.items = letters
                state.isLoading = false
                return .none
                
            case .letterTapped(let letter):
                let deatail = LetterDetailModel(name: letter.name,
                                                sendedTo: letter.sendedTo ?? "",
                                                theme: letter.theme,
                                                date: letter.date)
                state.path.append(.detail(MainDetailFeature.State(letterHeader: deatail)))
                return .none
                
            case .path(_):
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
