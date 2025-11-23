//
//  Date+formattedString.swift
//  XMail
//
//  Created by yuchekan on 23.11.2025.
//

import Foundation

extension Date {
    func toFormattedDateString() -> String {
            let calendar = Calendar.current
            
            // Получаем время в формате HH:mm
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let timeString = timeFormatter.string(from: self)
            
            // Проверяем сегодня/вчера/завтра
            if calendar.isDateInToday(self) {
                return "\(timeString), Сегодня"
            } else if calendar.isDateInYesterday(self) {
                return "\(timeString), Вчера"
            }
            
            // Если другая дата, возвращаем с датой
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM"
            let dateString = dateFormatter.string(from: self)
            
            return "\(timeString), \(dateString)"
        }
}
