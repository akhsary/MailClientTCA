//
//  String+formattedDate.swift
//  MailClientTCA
//
//  Created by yuchekan on 21.11.2025.
//

import Foundation

extension String {
    /// Преобразует ISO8601 строку в Date
    func toDate() -> Date? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = isoFormatter.date(from: self) {
            return date
        }
        
        // Фолбэк: пробуем без fractional seconds
        isoFormatter.formatOptions = [.withInternetDateTime]
        return isoFormatter.date(from: self)
    }
    
    /// Преобразует ISO8601 строку в отформатированную строку для UI
    func toFormattedDateString() -> String? {
        guard let date = self.toDate() else {
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
