//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by ali naveed on 22/05/2026.
//
import Foundation

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
        client.get(from: url) { [weak self] resultType in
            guard self != nil else { return }
            switch resultType {
            case .failure:
                completion(.failure(.connectivity))
            case let .success(data,httpResponse):
                completion(FeedItemsMapper.map(from: data, httpResponse: httpResponse))
            }
        }
    }
}



