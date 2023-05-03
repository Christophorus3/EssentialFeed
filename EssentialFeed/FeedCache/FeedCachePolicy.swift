//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Christoph Wottawa on 05.02.23.
//

internal final class FeedCachePolicy {
    private static let calendar = Calendar(identifier: .gregorian)
    private static let maxCacheAgeInDays = 7
    
    private init () {}
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
