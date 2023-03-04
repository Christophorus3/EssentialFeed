//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Christoph Wottawa on 04.03.23.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
    public init() {}
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    // MARK: - CoreData Models
    private class ManagedStore: NSManagedObject {
        @NSManaged var timestamp: Date
        @NSManaged var feed: NSOrderedSet
    }
    
    private class ManagedFeedImage: NSManagedObject {
        @NSManaged var id: UUID
        @NSManaged var imageDescription: String?
        @NSManaged var location: String?
        @NSManaged var url: URL
        @NSManaged var store: ManagedStore
    }
}
