//
//  AuthorizationFeature.swift
//  MailClientTCA
//
//  Created by yuchekan on 15.11.2025.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct AuthorizationFeature: Sendable {
    public init() {}
    
    @MainActor
    @KeychainStorage("access_token")
    private var accessToken
    
    @Dependency(\.authService) private var authService
    
    @ObservableState
    public struct State: Equatable, Sendable {
        var isLoading = false
        var username: String = ""
        var password: String = ""
        var isButtonDisabled: Bool = true
    }
    
    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case login
        case takeLogin
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(\.username):
                state.isButtonDisabled = (state.username.isEmpty || state.password.isEmpty)
                return .none
            case .binding(\.password):
                state.isButtonDisabled = (state.username.isEmpty || state.password.isEmpty)
                return .none
            case .binding(_):
                return .none
            case .login:
                print("DEBUG: login")
                state.isLoading = true
                return .run { [state = state] send in
                    do {
                        let responce = try await authService.login(username: state.username, password: state.password)
                        print("DEBUG: \(responce)")
                        Task { @MainActor in
                            accessToken = responce.data
                        }
                        await send(.takeLogin)
                    } catch {
                        print("DEBUG: \(error)")
                    }
                }
            case .takeLogin:
                return .none
            }
        }
    }
}
