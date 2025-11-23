//
//  ContentView.swift
//  MailClientTCA
//
//  Created by yuchekan on 15.11.2025.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct ContentFeature {
    private var accessToken: String? {
        get {
            return _KeychainStorage.shared.getPassword(for: "access_token")
        }
        
        nonmutating set {
            _KeychainStorage.shared.updatePassword(newValue ?? "", for: "access_token")
        }
    }
    
    @Dependency(\.mailDataStorage) var mailDataStorage
    
    @ObservableState
    struct State: Equatable, Sendable {
        var route: Route = .auth
        
        @Presents var auth: AuthorizationFeature.State?
        @Presents var main: MainFeature.State?
        @Presents var alert: AlertState<Action.Alert>?
    }
    
    enum Route: Equatable {
        case auth
        case main
    }
    
    enum Action: Sendable {
        case onAppear
        case setRoute(Route)
        
        case auth(PresentationAction<AuthorizationFeature.Action>)
        case main(PresentationAction<MainFeature.Action>)
        case alert(PresentationAction<Alert>)
        
        public enum Alert: Equatable, Sendable {
            case dismiss
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if let accessToken,
                   !accessToken.isEmpty {
                    state.route = .main
                    state.main = MainFeature.State()
                } else {
                    state.route = .auth
                    state.auth = AuthorizationFeature.State()
                }
                return .none
                
            case .setRoute(let route):
                state.route = route
                return .none
                
                // Перехватываем ошибки из AuthorizationFeature
            case .auth(.presented(.loginFailure(let error))):
                state.alert = AlertState {
                    TextState(error.title)
                } actions: {
                    ButtonState(action: .dismiss) {
                        TextState("OK")
                    }
                } message: {
                    TextState(error.message)
                }
                return .none
                
            case .auth(.presented(.loginSuccess)):
                state.auth = nil
                state.route = .main
                state.main = MainFeature.State()
                return .none
                
            case .auth:
                return .none
                
            case .main(.presented(.logout)):
                accessToken = nil
                state.route = .auth
                state.auth = AuthorizationFeature.State()
                state.main = nil
                return .run { _ in
                    async let _ = MailSocketClient.liveValue.disconnect()
                    async let _ = mailDataStorage.deleteAll()
                }
                
            case .main:
                return .none
                
            case .alert:
                return .none
            }
        }
        .ifLet(\.$auth, action: \.auth) {
            AuthorizationFeature()
        }
        .ifLet(\.$main, action: \.main) {
            MainFeature()
        }
        .ifLet(\.$alert, action: \.alert)
    }
}


struct ContentView: View {
    @Bindable private var store: StoreOf<ContentFeature>
    
    public init(store: StoreOf<ContentFeature>) {
        self.store = store
    }
    
    var body: some View {
        Color.white.ignoresSafeArea()
            .onAppear {
                store.send(.onAppear)
            }
            .fullScreenCover(
                item: $store.scope(state: \.auth, action: \.auth)
            ) { authStore in
                AuthView(store: authStore)
            }
            .fullScreenCover(
                item: $store.scope(state: \.main, action: \.main)
            ) { mainStore in
                MainView(store: mainStore)
            }
            .alert(store: store.scope(state: \.$alert, action: \.alert))
    }
}

