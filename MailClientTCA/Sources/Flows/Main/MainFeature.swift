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
    
    @ObservableState
    public struct State: Equatable, Sendable {}
    
    public enum Action {}
    
    public var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}

