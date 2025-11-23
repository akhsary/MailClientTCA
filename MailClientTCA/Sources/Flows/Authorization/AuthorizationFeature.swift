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
    
    public enum Action: Equatable, Sendable, BindableAction {
        case binding(BindingAction<State>)
        case login
        case loginSuccess
        case loginFailure(AuthError)
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
                state.isLoading = true
                return .run { [state = state] send in
                    do {
                        let response = try await authService.login(username: state.username, password: state.password)
                        
                        await Task { @MainActor in
                            accessToken = response.data
                        }.value
                        
                        await send(.loginSuccess)
                    } catch let error as AuthError {
                        await send(.loginFailure(error))
                    } catch {
                        print("DEBUG: \(error)")
                    }
                }
                
            case .loginSuccess:
                state.isLoading = false
                return .none
                
            case .loginFailure:
                state.isLoading = false
                return .none
            }
        }
    }
}
