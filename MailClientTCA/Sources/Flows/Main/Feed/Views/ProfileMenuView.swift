//
//  ProfileMenuView.swift
//  MailClientTCA
//
//  Created by yuchekan on 23.11.2025.
//

import SwiftUI

struct ProfileMenuView: View {
    let name: String
    let logoutAction:() -> Void
    
    var body: some View {
        Menu {
            Section("Аккаунт:") {
                Text(name)
                    .lineLimit(1)
            }
            
            Section("Действия:") {
                Button(role: .destructive) {
                    logoutAction()
                } label: {
                    Label("Выход",
                          systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        } label: {
            Image(systemName: "person.circle.fill")
        }
    }
}

#Preview {
    NavigationStack {
        VStack {
            Text("Profile menu preview")
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ProfileMenuView(name: "yrashka2004@xyecoc.com") {}
            }
        }
    }
}
