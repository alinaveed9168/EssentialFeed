//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by ali naveed on 25/05/2026.
//
import Foundation

internal final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
        var feedItems:[FeedItem] {
            return items.map{$0.feedItem}
        }
    }
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL

        var feedItem: FeedItem {
            return FeedItem(
                id: id,
                description: description,
                location: location,
                imageURL: image
            )
        }
    }
    static let ok_200 = 200
    internal static func map(from data: Data,
                             httpResponse: HTTPURLResponse)  -> RemoteFeedLoader.Result {
        
        guard httpResponse.statusCode == ok_200,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
         return .success(root.feedItems)
    }
}
