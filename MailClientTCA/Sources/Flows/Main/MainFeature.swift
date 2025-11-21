//
//  MainFeature.swift
//  MailClientTCA
//
//  Created by yuchekan on 16.11.2025.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct MainFeature: Sendable {
    public init() {}
    
    @MainActor
    @KeychainStorage("access_token")
    private var accessToken
    
    @Dependency(\.mainService) private var mainService
    
    @Dependency(\.mailService) private var mailService
    
    @ObservableState
    public struct State: Equatable, Sendable {
        var isLoading = true
        var mailIDs: [MailID] = []
        var items = [LetterItemModel]()
    }
    
    public enum Action {
        case startListening
        case stopListening
        case takeNewLetters([LetterItemModel])
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .startListening:
                return .run { send in
                    guard let accessToken = await accessToken else { return }
                    for await mailID in await mailService.mailIDStream() {
                        do {
                            let responce = try await mainService.login(accessToken, mailID.id)
                            let letter = LetterItemModel(id: "\(responce.data.id)",
                                                         name: responce.data.sender ?? "",
                                                         theme: responce.data.subject,
                                                         date: responce.data.updatedAt.toFormattedDateString(),
                                                         message: responce.data.message)
                            await send(.takeNewLetters([letter]))
                        } catch {
                            print("DEBUG: \(error)")
                        }
                    }
                }
            case .stopListening:
                return .none
            case .takeNewLetters(let letters):
                state.items = letters
                state.isLoading = false
                return .none
            }
        }
    }
    
    private func getLetter(_ state: inout MainFeature.State, id: String) -> Effect<MainFeature.Action> {
        if let accessToken {
            state.isLoading = true
            return .run { send in
                do {
                    let responce = try await mainService.login(accessToken, id)
                    let letter = LetterItemModel(id: "\(responce.data.id)",
                                                 name: responce.data.sender!,
                                                 theme: responce.data.subject!,
                                                 date: responce.data.updatedAt,
                                                 message: responce.data.message)
                    await send(.takeNewLetters([letter]))
                } catch {
                    print("DEBUG: \(error)")
                }
            }
        }
        return .none
    }
}

