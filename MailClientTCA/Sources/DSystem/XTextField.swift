//
//  XTextField.swift
//  MailClientTCA
//
//  Created by yuchekan on 15.11.2025.
//

import SwiftUI

struct XTextField: View {
    let isSecure: Bool
    let title: String
    let text: Binding<String>
    
    init(isSecure: Bool = false,
         title: String,
         text: Binding<String>) {
        self.isSecure = isSecure
        self.title = title
        self.text = text
    }
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(title, text: text)
                    .keyboardType(.asciiCapable)
                    .textContentType(.password)
            } else {
                TextField(title, text: text)
                    .keyboardType(.emailAddress)
                    .textContentType(.username) // TODO: if used for auth only
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black, lineWidth: 2)
        )
        .autocapitalization(.none)
        .autocorrectionDisabled(true)
    }
}
