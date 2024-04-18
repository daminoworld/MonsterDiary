//
//  Date+.swift
//  MonsterDiary
//
//  Created by Damin on 4/12/24.
//

import Foundation

extension Date {
    
    func toString(dateFormat format: String ) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
        
    }
    
    func dayString() -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "E"  // "E"는 주의 일을 약어로 표시합니다.
            formatter.locale = Locale(identifier: "en_US")
            formatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 한국 시간대
            return formatter.string(from: self)
        }

}
