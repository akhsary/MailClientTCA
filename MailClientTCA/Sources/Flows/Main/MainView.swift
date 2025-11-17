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
    
    public init(store: StoreOf<MainFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            Text("MainView")
        }
    }
}

#Preview {
    MainView(store: Store(initialState: MainFeature.State()) {
        MainFeature()
    })
}
