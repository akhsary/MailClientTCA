//
//  MailDetailFeature.swift
//  MailClientTCA
//
//  Created by yuchekan on 22.11.2025.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct MainDetailFeature: Sendable {
    public init() {}
    
    @Dependency(\.mainService) private var mainService
    
    @ObservableState
    public struct State: Equatable, Sendable {
        let letterHeader: LetterDetailModel
        var letterText: String = ""
    }
    
    public enum Action: Sendable {
        case onAppear
        case takeLetterText(String)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .onAppear:
//                return .run { [id = state.id] send in
//                    if let accessToken = await accessToken {
//                        let responce = try await mainService.login(accessToken, id)
//                        print("DEBUG: \n \(responce) \n ==========")
//                        let letter = LetterDetailModel(name: responce.data.sender ?? "",
//                                                       sendedTo: responce.data.to ?? "",
//                                                       theme: responce.data.subject,
//                                                       date: responce.data.updatedAt.toFormattedDateString(),
//                                                       message: responce.data.message)
//                        await send(.takeLetter(letter))
//                    }
//                }
                return .none
            case .takeLetterText(let letterText):
                state.letterText = letterText
                return .none
            }
        }
    }
}
