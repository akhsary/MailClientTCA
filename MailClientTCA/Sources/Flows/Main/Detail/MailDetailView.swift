//
//  MailDetailView.swift
//  MailClientTCA
//
//  Created by yuchekan on 21.11.2025.
//

import SwiftUI
import WebKit
import ComposableArchitecture

struct MailDetailView: View {
    let store: StoreOf<MainDetailFeature>
    
    var body: some View {
        VStack(spacing: 0) {
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
                        Text("Subject: \(Text(theme).bold())")
                            .font(.footnote)
                    }
                    
                    Text("To: \(Text(store.letterHeader.sendedTo).bold())")
                    .font(.footnote)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            
            Divider()
                .padding(.top, 12)
            
            WebView(
                url: URL(string: store.letterTextURLString)
            )
            .padding(.horizontal, 5)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    MailDetailView(store: Store(initialState: MainDetailFeature.State(
        id: "1",
        letterHeader: .init(name: "Yuriy Chekan",
                            sendedTo: "yrashka2004@xyecoc.com",
                            theme: "Letter theme",
                            date: Date().formatted()))) {
        MainDetailFeature()
    })
}

