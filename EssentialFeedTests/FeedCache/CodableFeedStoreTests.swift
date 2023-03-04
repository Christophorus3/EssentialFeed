//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Christoph Wottawa on 25.02.23.
//

import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpec {
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
        
        assertThatRetrieveDeliversEmptyOnEmptyStore(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyStore() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnEmptyStore(on: sut)
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyStore() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversFoundValuesOnNonEmptyStore(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyStore() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnNonEmptyStore(on: sut)
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
    
    func test_insert_deliversNoErrorOnEmptyStore() {
        let sut = makeSUT()
        
        assertThatInsertDeliversNoErrorOnEmptyStore(on: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyStore() {
        let sut = makeSUT()
        
        assertThatInsertDeliversNoErrorOnNonEmptyStore(on: sut)
    }
    
    func test_insert_overridesPreviouslyInsertedStoreValues() {
        let sut = makeSUT()
        
        assertThatInsertOverridesPreviouslyInsertedStoreValues(on: sut)
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidURL = URL(string: "invalid://test-url")
        let sut = makeSUT(storeURL: invalidURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let error = insert((feed, timestamp), to: sut)
        
        XCTAssertNotNil(error, "Expected insertion error on invalid url")
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidURL = URL(string: "invalid://test-url")
        let sut = makeSUT(storeURL: invalidURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversNoErrorOnEmptyStore() {
        let sut = makeSUT()
        
        assertThatDeleteDeliversNoErrorOnEmptyStore(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyStore() {
        let sut = makeSUT()
        
        assertThatDeleteHasNoSideEffectsOnEmptyStore(on: sut)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyStore() {
        let sut = makeSUT()
        
        assertThatDeleteDeliversNoErrorOnNonEmptyStore(on: sut)
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
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let sut = makeSUT(storeURL: nonDeletableURL)
        
        deleteStore(from: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        var completedOperationsInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected operations finished in correct order (serially) but they did not.")
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
