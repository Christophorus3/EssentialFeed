//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Christoph Wottawa on 15.02.22.
//

import Foundation

struct FeedItem {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
