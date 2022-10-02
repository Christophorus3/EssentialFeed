//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Christoph Wottawa on 01.10.22.
//

import XCTest
import EssentialFeed

class EssentialFeedAPIEndToEndTests: XCTestCase {
    var items = [FeedItem]()
    
    override func setUp() {
        let fileURL = Bundle(for: self.classForCoder).url(forResource: "feed-test", withExtension: "json")!
        let data = try! Data(contentsOf: fileURL)
        let json = try! JSONSerialization.jsonObject(with: data) as! [String: AnyObject]
        let items = json["items"] as! [AnyObject]
        for item in items {
            if let item = item as? [String: AnyObject] {
                let id = UUID(uuidString: item["id"] as! String)!
                let description = item["description"] as? String
                let location = item["location"] as? String
                let imageURL = URL(string: item["image"] as! String)!
                
                let newItem = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
                
                self.items.append(newItem)
            }
        }
    }
    
    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        switch getFeedResult() {
        case let .success(items):
            XCTAssertEqual(items.count, 8, "Expected 8 items in the test feed")
            
            items.enumerated().forEach { (index,item) in
                XCTAssertEqual(item, expectedItem(at: index))
            }
        case let .failure(error):
            XCTFail("Expected successful feed result, got \(error) instead")
        default:
            XCTFail("Expected successful feed result, got no result instead")
        }
    }
    
    func getFeedResult() -> LoadFeedResult? {
        let url = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5c52cdd0b8a045df091d2fff/1548930512083/feed-case-study-test-api-feed.json")!
        let client = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(url: url, client: client)
        
        let exp = expectation(description: "wait for load completion")
        
        var receivedResult: LoadFeedResult?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
        return receivedResult
    }
    
    private func expectedItem(at index: Int) -> FeedItem {
        return items[index]
    }
}
