//
//  String+formattedDate.swift
//  MailClientTCA
//
//  Created by yuchekan on 21.11.2025.
//

import Foundation

nonisolated extension String {
    func toFormattedDateString() -> String? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = isoFormatter.date(from: self) else {
            return nil
        }
        
        let calendar = Calendar.current
        
        // Получаем время в формате HH:mm
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeString = timeFormatter.string(from: date)
        
        // Проверяем, сегодня ли это
        if calendar.isDateInToday(date) {
            return "\(timeString), Сегодня"
        }
        
        // Если не сегодня, возвращаем с датой
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        let dateString = dateFormatter.string(from: date)
        
        return "\(timeString), \(dateString)"
    }
}
