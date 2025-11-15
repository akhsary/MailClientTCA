//
//  XTextField.swift
//  MailClientTCA
//
//  Created by yuchekan on 15.11.2025.
//

import SwiftUI

struct XTextField: View {
    let title: String
    let text: Binding<String>
    
    var body: some View {
        TextField(title, text: text)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black, lineWidth: 2)
            )
    }
}
