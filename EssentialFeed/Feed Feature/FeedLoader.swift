//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by ali naveed on 21/05/2026.
//

import Foundation
public enum LoadFeedResult <Error: Swift.Error>{
    case success([FeedItem])
    case failure(Error)
}
  
protocol FeedLoader {
    associatedtype Error: Swift.Error
    func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
