//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Christoph Wottawa on 08.01.23.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(), description: "any", location: "any", imageURL: anyURL())
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage(), uniqueImage()]
    let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url) }
    return (models, local)
}

extension Date {
    private var maxCacheAgeInDays: Int {
        7
    }
    
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -maxCacheAgeInDays)
    }
    
    private func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
