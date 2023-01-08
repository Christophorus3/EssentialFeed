//
//  SharedTestHelpers.swift
//  EssentialFeed
//
//  Created by Christoph Wottawa on 08.01.23.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any domain", code: 7)
}

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}
