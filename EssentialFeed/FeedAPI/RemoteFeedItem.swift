//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Christoph Wottawa on 23.12.22.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
