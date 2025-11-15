//
//  ContentView.swift
//  MailClientTCA
//
//  Created by yuchekan on 15.11.2025.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    var body: some View {
        AuthView(store: Store(initialState: AuthorizationFeature.State()) {
            AuthorizationFeature()
        })
    }
}

#Preview {
    ContentView()
}
