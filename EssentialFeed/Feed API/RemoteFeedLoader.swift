//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by ali naveed on 22/05/2026.
//
import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse)
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
    public func load(completion: @escaping (Error) -> Void)  {
        client.get(from: url) { resultType in
        switch resultType {
            case .failure:
            completion(.connectivity)
        case .success:
            completion(.invalidData)
        }
        }
    }
}
