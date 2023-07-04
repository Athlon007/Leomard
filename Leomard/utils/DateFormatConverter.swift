//
//  DateFormatter.swift
//  Leomard
//
//  Created by Konrad Figura on 01/07/2023.
//

import Foundation

struct DateFormatConverter
{
    private static let format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
    private static let formatAlternative: String = "yyyy-MM-dd'T'HH:mm:ss"
    static func formatToDate(from text: String) throws -> Date
    {
        let formatter = DateFormatter()
        formatter.dateFormat = text.contains(".") ? DateFormatConverter.format : DateFormatConverter.formatAlternative
        
        guard let date = formatter.date(from: text) else {
            print("Invalid date format. Expected: \(DateFormatConverter.format). Received: \(text)")
            return Date()
        }
        
        return date
    }
    
    static func getElapsedTime(from date: Date) -> ElapsedTime {
        let calendar = Calendar.current
        let currentDate = Date()
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: date, to: currentDate)
        return ElapsedTime(days: components.day ?? 0, hours: components.hour ?? 0, minutes: components.minute ?? 0, seconds: components.second ?? 0)
    }
}
