//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Christoph Wottawa on 25.02.23.
//

import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }

    func test_retrieve_devliversEmptyOnEmptyStore() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyStore() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .empty)
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyStore() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyStore() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp  ))
    }
    
    func test_retrieve_deliversErrorOnRetrievalError() {
        let storeURL = testSpecificStoreURL
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_overridesPreviouslyInsertedStoreValues() {
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert store successfully")
        
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)
        XCTAssertNil(latestInsertionError, "Expected to override store successfully")
        
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidURL = URL(string: "invalid://test-url")
        let sut = makeSUT(storeURL: invalidURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let error = insert((feed, timestamp), to: sut)
        
        XCTAssertNotNil(error, "Expected insertion error on invalid url")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyStore() {
        let sut = makeSUT()
        
        let deletionError = deleteStore(from: sut)
        
        XCTAssertNil(deletionError, "Expected no error on deletion of empty store")
    }
    
    func test_delete_emptiesPreviouslyInsertedStore() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let deletionError: Error?
        
        insert((feed, timestamp), to: sut)
        deletionError = deleteStore(from: sut)
        
        expect(sut, toRetrieve: .empty)
        XCTAssertNil(deletionError, "Expected no error on deletion of non empty store")
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let sut = makeSUT(storeURL: nonDeletableURL)
        let deletionError: Error?
        
        deletionError = deleteStore(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected error on deletion error (no permission)")
    }
    
    // MARK: - Helpers
    
    private let testSpecificStoreURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        .first!.appendingPathComponent("\(type(of: self)).store")
    
    private let nonDeletableURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    @discardableResult
    private func deleteStore(from sut: FeedStore) -> Error? {
        var deletionError: Error?
        let exp = expectation(description: "wait for store deletion")
        
        sut.deleteCachedFeed { receivedError in
            deletionError = receivedError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    @discardableResult
    private func insert(_ store: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        var insertionError: Error?
        let exp = expectation(description: "wait for store insertion")
        
        sut.insert(store.feed, timestamp: store.timestamp) { receivedError in
            insertionError = receivedError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    private func expect(_ sut: FeedStore,
                        toRetrieveTwice expectedResult: RetrieveCachedFeedResult,
                        file: StaticString = #file,
                        line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: FeedStore,
                        toRetrieve expectedResult: RetrieveCachedFeedResult,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for store retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty),
                 (.failure, .failure):
                break
                
            case let (.found(expected), .found(retrieved)):
                XCTAssertEqual(expected.feed, retrieved.feed, file: file, line: line)
                XCTAssertEqual(expected.timestamp, retrieved.timestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult) got \(retrievedResult) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func setupEmptyStoreState() {
        deleteStoreStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreStoreArtifacts()
    }
    
    private func deleteStoreStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL)
    }

}
