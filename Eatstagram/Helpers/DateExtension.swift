//
//  DateExtension.swift
//  Eatstagram
//
//  Created by hor kimleng on 4/29/19.
//  Copyright © 2019 hor kimleng. All rights reserved.
//

import UIKit

extension Date {
    func durationAgo() -> String {
        let seconds = Int(Date().timeIntervalSince(self))
        let minutes = 60
        let hours = 60 * minutes
        let day = 24 * hours
        let week = 7 * day
        
        if seconds < minutes {
            if seconds == 1 {
                return "\(seconds) second ago"
            }
            return "\(seconds) seconds ago"
        } else if seconds < hours {
            if seconds / minutes == 1 {
                return "\(seconds / minutes) minute ago"
            }
            return "\(seconds / minutes) minutes ago"
        } else if seconds < day {
            if seconds / hours == 1 {
                return "\(seconds / hours) hour ago"
            }
            return "\(seconds / hours) hours ago"
        } else if seconds < week {
            if seconds / day == 1 {
                return "\(seconds / day) day ago"
            }
            return "\(seconds / day) days ago"
        }
        
        if seconds / week == 1 {
            return "\(seconds / week) week ago"
        }
        return "\(seconds / week) weeks ago"
    }
}

extension String {
    func formatStringToDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = formatter.date(from: self)!
        return date
    }
}

