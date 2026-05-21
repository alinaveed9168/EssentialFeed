//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by ali naveed on 22/05/2026.
//
import Foundation

public protocol HttpClient {
    func get(from url: URL,completion: @escaping (Error) -> Void)
}

public final class RemoteFeedLoader {
    private let url :URL
    private let client :HttpClient
    
    public enum Error: Swift.Error {
        case connectivity
    }
    public init(url:URL, client: HttpClient) {
        self.client = client
        self.url = url
    }
    public func load(completion: @escaping (Error) -> Void = { _ in })  {
        client.get(from: url) { error in
            completion(.connectivity)
        }
    }
}
