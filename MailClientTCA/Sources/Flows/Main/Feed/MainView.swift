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
            .onAppear {
                store.send(.connectToSocket)
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
