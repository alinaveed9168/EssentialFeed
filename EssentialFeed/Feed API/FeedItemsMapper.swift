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
    internal static func map(from root: Data,httpResponse: HTTPURLResponse) throws -> [FeedItem] {
        guard httpResponse.statusCode == ok_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: root)
        return root.items.map{$0.feedItem}
    }
}
