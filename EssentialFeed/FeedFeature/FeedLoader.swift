//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Christoph Wottawa on 15.02.22.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
