//
//  MainView.swift
//  MailClientTCA
//
//  Created by yuchekan on 16.11.2025.
//

import SwiftUI
import ComposableArchitecture

struct MainView: View {
    let store: StoreOf<MainFeature>
    
    @State private var service = MailSocketClient()
    
    public init(store: StoreOf<MainFeature>) {
        self.store = store
    }
    
    var body: some View {
        List(store.items) { item in
            LetterItemView(model: item)
        }
        .onAppear {
            store.send(.startListening)
        }
        .onDisappear {
            store.send(.stopListening)
        }
        .task {
            await MailSocketClient.liveValue.connect()
        }
    }
}

#Preview {
    MainView(store: Store(initialState: MainFeature.State()) {
        MainFeature()
    })
}
