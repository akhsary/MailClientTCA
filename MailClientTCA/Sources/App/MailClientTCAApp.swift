//
//  MailClientTCAApp.swift
//  MailClientTCA
//
//  Created by yuchekan on 15.11.2025.
//

import SwiftUI
import ComposableArchitecture

@main
struct MailClientTCAApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(initialState: ContentFeature.State()) {
                ContentFeature()
            })
        }
    }
}
