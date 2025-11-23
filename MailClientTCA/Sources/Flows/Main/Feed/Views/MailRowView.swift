//
//  MailRowView.swift
//  MailClientTCA
//
//  Created by yuchekan on 19.11.2025.
//

import SwiftUI

struct MailRowView: View {
    let model: LetterItemModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if !model.read {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
                    .padding(.top, 6)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Top row: Sender and Time
                HStack(alignment: .top) {
                    Text(model.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if let date = model.date {
                        Text(date.toFormattedDateString())
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                
                if let theme = model.theme, !theme.isEmpty {
                    Text(theme)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
                
                if let message = model.message, !message.isEmpty {
                    Text(message)
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                if let sendedTo = model.sendedTo, !sendedTo.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "paperplane")
                            .font(.system(size: 12))
                        Text("To: \(sendedTo)")
                            .font(.system(size: 13))
                    }
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
