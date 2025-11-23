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
        let id: String
        let letterHeader: LetterDetailModel
        var letterTextURLString: String = ""
    }
    
    public enum Action: Sendable {
        case onAppear
        case takeletterTextURLString(String)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .onAppear:
                return .run { [id = state.id] send in
                    let urlString = mainService.getLetterURL(mailID: id)
                    await send(.takeletterTextURLString(urlString))
                }
            case .takeletterTextURLString(let letterTextURLString):
                state.letterTextURLString = letterTextURLString
                return .none
            }
        }
    }
}
