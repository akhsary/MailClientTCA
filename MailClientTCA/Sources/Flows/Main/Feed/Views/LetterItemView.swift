//
//  LetterItemView.swift
//  MailClientTCA
//
//  Created by yuchekan on 19.11.2025.
//

import SwiftUI

struct LetterItemView: View, Equatable {
    let model: LetterItemModel
    
    var body: some View {
        HStack(alignment: .top) {
            if let firstLetter = model.name.first {
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
                    Text(model.name)
                        .font(.subheadline)
                        .bold()
                    
                    Spacer()
                    
                    if let date = model.date {
                        Text(date)
                            .font(.footnote)
                    }
                }
                
                if let theme = model.theme {
                    Text(theme)
                        .font(.footnote)
                }
                
                Text(model.message ?? " ")
                    .font(.caption2)
                    .lineLimit(2, reservesSpace: true)
                    .foregroundStyle(Color.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    LetterItemView(model: .init(id: "1", name: "Yuriy Chekan", theme: "Letter theme", date: "17:56", message: "Message text placeholder at least 2 lines long to test line limit feature and make sure it works properly :) and also to test how line linit works", sendedTo: nil))
        .padding()
}
