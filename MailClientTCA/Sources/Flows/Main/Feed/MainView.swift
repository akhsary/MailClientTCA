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
            List {
                ForEach(store.items) { item in
                    Button(action: {
                        store.send(.letterTapped(item))
                    }) {
                        MailRowView(model: item)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparatorTint(.gray.opacity(0.3))
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            // Mark as read action
                        } label: {
                            Label("Read", systemImage: "envelope.open")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            // Delete action
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            // Flag action
                        } label: {
                            Label("Flag", systemImage: "flag.fill")
                        }
                        .tint(.orange)
                        
                        Button {
                            // Archive action
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }
                        .tint(.purple)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ProfileMenuView(name: "yrashka2004") {
                        store.send(.logout)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Compose new mail
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .navigationTitle("Inbox")
            .navigationSubtitle(store.state.isLoading ? "Загружаем письма..." : "")
            .searchable(
                text: .constant(""),
                prompt: "Search"
            )
            .onAppear {
                store.send(.onAppear)
            }
            .refreshable {
                store.send(.requestUpdate)
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
