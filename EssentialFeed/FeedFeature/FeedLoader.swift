//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Christoph Wottawa on 15.02.22.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
