//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Christoph Wottawa on 15.02.22.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
