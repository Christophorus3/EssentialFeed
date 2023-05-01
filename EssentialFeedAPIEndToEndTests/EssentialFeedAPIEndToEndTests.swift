//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Christoph Wottawa on 01.10.22.
//

import XCTest
import EssentialFeed

class EssentialFeedAPIEndToEndTests: XCTestCase {
    var feed = [FeedImage]()
    
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
                
                let newItem = FeedImage(id: id, description: description, location: location, imageURL: imageURL)
                
                self.feed.append(newItem)
            }
        }
    }
    
    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        switch getFeedResult() {
        case let .success(imageFeed):
            XCTAssertEqual(imageFeed.count, 8, "Expected 8 items in the test feed")
            
            imageFeed.enumerated().forEach { (index,item) in
                XCTAssertEqual(item, expectedImage(at: index))
            }
        case let .failure(error):
            XCTFail("Expected successful feed result, got \(error) instead")
        default:
            XCTFail("Expected successful feed result, got no result instead")
        }
    }
    
    func getFeedResult(file: StaticString = #file, line: UInt = #line) -> FeedLoader.Result? {
        let url = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5c52cdd0b8a045df091d2fff/1548930512083/feed-case-study-test-api-feed.json")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        let exp = expectation(description: "wait for load completion")
        
        var receivedResult: FeedLoader.Result?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
        return receivedResult
    }
    
    private func expectedImage(at index: Int) -> FeedImage {
        return feed[index]
    }
}
