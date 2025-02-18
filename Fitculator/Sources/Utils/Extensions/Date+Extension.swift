//
//  Date+Extension.swift
//  Fitculator
//
//  Created by MadCow on 2025/2/17.
//

import Foundation

extension Date {
    enum IncludeDay {
        case year
        case month
        case monthDay
        case day
        case dayOfWeek
        case time
        case custom
    }
    
    /// Date() 타입을 각 format에 맞는 String으로 변환
    /// - year: "yyyy"
    /// - month: "yyyy.MM"
    /// - monthDay: "MM.dd"
    /// - day: "yyyy.MM.dd"
    /// - dayOfWeek: "yyyy.MM.dd EEEE"
    /// - time: "yyyy.MM.dd HH:MM"
    func dateToString(includeDay: IncludeDay = .dayOfWeek) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        var format: String = ""
        switch includeDay {
        case .year:
            format = "yyyy"
        case .month:
            format = "yyyy.MM"
        case .monthDay:
            format = "MM.dd"
        case .day:
            format = "yyyy.MM.dd"
        case .dayOfWeek:
            format = "yyyy.MM.dd EEEE"
        case .time:
            format = "yyyy.MM.dd HH:MM"
        case .custom:
            format = ""
        }
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
}

// MARK: format에 맞는 형식의 String에 대해 맞는 Date 타입을 리턴 만약 올바르지 않은 format이라면 현재 날짜를 리턴
extension String {
    func stringToDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        return dateFormatter.date(from: self) ?? Date()
    }
}
