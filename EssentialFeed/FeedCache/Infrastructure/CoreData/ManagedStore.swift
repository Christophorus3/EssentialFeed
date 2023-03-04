//
//  ManagedStore.swift
//  EssentialFeed
//
//  Created by Christoph Wottawa on 04.03.23.
//

import CoreData

@objc(ManagedStore)
internal class ManagedStore: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
    
    var localFeed: [LocalFeedImage] {
        return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedStore {
        try find(in: context).map(context.delete)
        return ManagedStore(context: context)
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedStore? {
        let request = NSFetchRequest<Self>(entityName: Self.entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
}
