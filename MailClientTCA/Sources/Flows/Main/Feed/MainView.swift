//
//  MainView.swift
//  MailClientTCA
//
//  Created by yuchekan on 16.11.2025.
//

import SwiftUI
import ComposableArchitecture

struct MainView: View {
    @Bindable var store: StoreOf<MainFeature>
    
    public init(store: StoreOf<MainFeature>) {
        self.store = store
    }
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            List(store.items) { item in
                Button(action: {
                    store.send(.letterTapped(item))
                }) {
                    LetterItemView(model: item)
                        .foregroundStyle(Color.black)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ProfileMenuView(name: "yrashka2004") {
                        store.send(.logout)
                    }
                }
            }
            .navigationTitle("Inbox")
            .navigationSubtitle(store.state.isLoading ? "Загружаем письма..." : "")
            .onAppear {
                store.send(.onAppear)
            }
        } destination: { store in
            switch store.case {
            case .detail(let detailStore):
                MailDetailView(store: detailStore)
            }
        }
    }
}


#Preview {
    MainView(store: Store(initialState: MainFeature.State()) {
        MainFeature()
    })
}
