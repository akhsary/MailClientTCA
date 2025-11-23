//
//  MailDetailView.swift
//  MailClientTCA
//
//  Created by yuchekan on 21.11.2025.
//

import SwiftUI
import ComposableArchitecture

struct MailDetailView: View, Equatable {
    let store: StoreOf<MainDetailFeature>
    
    var body: some View {
        ScrollView(.vertical) {
                HStack(alignment: .top) {
                    if let firstLetter = store.letterHeader.name.first {
                        Text(String(firstLetter))
                            .font(.subheadline)
                            .padding(8)
                            .background {
                                Circle()
                                    .fill(Color.cyan)
                            }
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(store.letterHeader.name)
                                .font(.subheadline)
                                .bold()
                            
                            Spacer()
                            
                            if let date = store.letterHeader.date {
                                Text(date)
                                    .font(.footnote)
                            }
                        }
                        
                        if let theme = store.letterHeader.theme {
                            Text(theme)
                                .font(.footnote)
                        }
                        
                        Divider()
                        
                        Text(store.letterText)
                            .font(.title)
                            .foregroundStyle(Color.black)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
        }
        .scrollBounceBehavior(.basedOnSize)
        .padding(.horizontal, 16)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    MailDetailView(store: Store(initialState: MainDetailFeature.State(
        letterHeader: .init(name: "Yuriy Chekan",
                            sendedTo: "yrashka2004@xyecoc.com",
                            theme: "Letter theme",
                            date: Date().formatted()))) {
        MainDetailFeature()
    })
}

