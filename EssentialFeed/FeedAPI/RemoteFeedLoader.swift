//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Christoph Wottawa on 02.03.22.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public enum HTTPClientResult {
    case success(HTTPURLResponse)
    case failure(Error)
}

public final class RemoteFeedLoader {
    let url: URL
    let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalid
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success:
                completion(.invalid)
            case .failure:
                completion(.connectivity)
            }
        }
    }
}
