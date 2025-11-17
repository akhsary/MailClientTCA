//
//  AuthView.swift
//  MailClientTCA
//
//  Created by yuchekan on 15.11.2025.
//

import SwiftUI
import ComposableArchitecture

struct AuthView: View {
    @Bindable var store: StoreOf<AuthorizationFeature>
    
    public init(store: StoreOf<AuthorizationFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("XYECOC.COM")
                .font(.title)
            
            VStack(spacing: 20) {
                XTextField(title: "Логин", text: $store.username)
                
                XTextField(title: "Пароль", text: $store.password)
            }
            .font(.footnote)
            .frame(maxHeight: .infinity, alignment: .center)
            
            Button {
                store.send(.login)
            } label: {
                Text("Войти")
                    .foregroundStyle(Color.white)
                    .padding()
                    .padding(.horizontal, 50)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black)
                    )
            }
            .disabled(store.isButtonDisabled)
        }
        .padding(16)
    }
}

#Preview {
    AuthView(store: Store(initialState: AuthorizationFeature.State()) {
        AuthorizationFeature()
    })
}
