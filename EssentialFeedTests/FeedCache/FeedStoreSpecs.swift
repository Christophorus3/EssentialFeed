//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Christoph Wottawa on 27.02.23.
//

typealias FailableFeedStoreSpec = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs

protocol FeedStoreSpecs {
    func test_retrieve_devliversEmptyOnEmptyStore()
    func test_retrieve_hasNoSideEffectsOnEmptyStore()
    func test_retrieve_deliversFoundValuesOnNonEmptyStore()
    func test_retrieve_hasNoSideEffectsOnNonEmptyStore()
    
    func test_insert_overridesPreviouslyInsertedStoreValues()
    
    func test_delete_hasNoSideEffectsOnEmptyStore()
    func test_delete_emptiesPreviouslyInsertedStore()
    
    func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversErrorOnRetrievalError()
    func test_retrieve_hasNoSideEffectsOnFailure()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectsOnDeletionError()
}
