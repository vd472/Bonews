//
//  DateExtension.swift
//  Bonews
//
//  Created by vijayesha on 05.10.25.
//

import Foundation

extension TimeInterval {
    func relativeTimeString() -> String {
        let minutes = Int(self / 60)
        let hours = Int(self / 3600)
        let days = Int(self / 86400)
        
        if minutes < 60 {
            return minutes <= 1 ? "now" : "\(minutes)m ago"
        } else if hours < 24 {
            return hours == 1 ? "1h ago" : "\(hours)h ago"
        } else if days < 7 {
            return days == 1 ? "1d ago" : "\(days)d ago"
        } else {
            let weeks = days / 7
            return weeks == 1 ? "1w ago" : "\(weeks)w ago"
        }
    }
}
