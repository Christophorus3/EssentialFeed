//
//  Date+Helpers.swift
//  EssentialFeedTests
//
//  Created by Christoph Wottawa on 08.01.23.
//

import Foundation

internal extension Date {
    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
