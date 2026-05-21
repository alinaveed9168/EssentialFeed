//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by ali naveed on 21/05/2026.
//

import Foundation
enum LoadFeedResult {
    case success([FeedItem])
    case  failure(Error)
}
protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
