//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Christoph Wottawa on 15.02.22.
//

import Foundation

// needs to be equatable, but we dont know if the Error is equatable
// therefore make it generic
public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    associatedtype Error: Swift.Error
    func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
