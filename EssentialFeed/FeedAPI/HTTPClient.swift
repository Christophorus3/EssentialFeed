//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Christoph Wottawa on 30.09.22.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
