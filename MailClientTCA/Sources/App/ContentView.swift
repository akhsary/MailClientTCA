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
    @MainActor
    @KeychainStorage("access_token")
    var accessToken
    
    @ObservableState
    struct State: Equatable, Sendable {
        // Что сейчас показываем — auth или main
        var route: Route = .auth
        
        // Презентации
        @Presents var auth: AuthorizationFeature.State?
        @Presents var main: MainFeature.State?
    }
    
    enum Route: Equatable {
        case auth
        case main
    }
    
    enum Action: Sendable {
        case onAppear
        
        case setRoute(Route)
        
        // Презентуемые фичи
        case auth(PresentationAction<AuthorizationFeature.Action>)
        case main(PresentationAction<MainFeature.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // accessToken = nil
                if accessToken != nil {
                    state.route = .main
                } else {
                    state.route = .auth
                }
                switch state.route {
                case .auth:
                    state.auth = AuthorizationFeature.State()
                case .main:
                    state.main = MainFeature.State()
                }
                return .none
            case .setRoute(_):
                return .none
            case let .auth(.presented(action)):
                if action == .takeLogin {
                    state.auth = nil
                    state.route = .main
                    state.main = .init()
                }
                return .none
            case let .main(.presented(action)):
                print(action)
                return .none
            case .auth, .main:
                return .none
            }
        }
        .ifLet(\.$auth, action: \.auth) {
            AuthorizationFeature()
        }
        .ifLet(\.$main, action: \.main) {
            MainFeature()
        }
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
    }
}

#Preview {
    ContentView(store: Store(initialState: ContentFeature.State()) {
        ContentFeature()
    })
}
