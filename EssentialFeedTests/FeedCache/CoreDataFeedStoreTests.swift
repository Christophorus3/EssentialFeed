//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Christoph Wottawa on 04.03.23.
//

import XCTest
import EssentialFeed

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
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
    
    func test_insert_overridesPreviouslyInsertedStoreValues() {
        
    }
    
    func test_delete_hasNoSideEffectsOnEmptyStore() {
        
    }
    
    func test_delete_emptiesPreviouslyInsertedStore() {
        
    }
    
    func test_storeSideEffects_runSerially() {
        
    }
    
    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
