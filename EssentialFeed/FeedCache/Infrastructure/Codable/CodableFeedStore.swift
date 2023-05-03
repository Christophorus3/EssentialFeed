//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Christoph Wottawa on 26.02.23.
//

//import Foundation

public class CodableFeedStore: FeedStore {
    private struct Store: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
        
        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        // capture URL to async thread by copy, as its a value type
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(nil))
            }
            
            do {
                let decoder = JSONDecoder()
                let store = try decoder.decode(Store.self, from: data)
                return completion(.success(CachedFeed(feed: store.localFeed, timestamp: store.timestamp)))
            } catch {
                return completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        // capture URL to async thread by copy, as its a value type
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let store = Store(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
                let encoded = try encoder.encode(store)
                try encoded.write(to: storeURL)
                return completion(.success(Void()))
            } catch {
                return completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        // capture URL to async thread by copy, as its a value type
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(.success(Void()))
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                return completion(.success(Void()))
            } catch {
                return completion(.failure(error))
            }
        }
    }
}
