//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by ali naveed on 22/05/2026.
//
import Foundation

public enum HTTPClientResult {
    case success(Data,HTTPURLResponse)
    case failure(Error)
    
}
public protocol HttpClient {
    func get(from url: URL,completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    private let url :URL
    private let client :HttpClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    public init(url:URL, client: HttpClient) {
        self.client = client
        self.url = url
    }
    public enum Result:Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public func load(completion: @escaping (Result) -> Void)  {
        client.get(from: url) { resultType in
        switch resultType {
            case .failure:
            completion(.failure(.connectivity))
        case let .success(data,httpResponse):
            do {
                let feed = try FeedMapper().map(from: data, httpResponse: httpResponse)
                completion(.success(feed))
            } catch {
                completion(.failure(.invalidData))
            }
        }
        }
    }
}

private class FeedMapper {
    
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
    static func map(from root: Data,httpResponse: HTTPURLResponse) throws -> [FeedItem] {
        guard httpResponse.statusCode == ok_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: root)
        return root.items.map{$0.feedItem}
    }
}


