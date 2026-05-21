//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by ali naveed on 22/05/2026.
//
import Foundation

public protocol HttpClient {
    func get(from url: URL)
}

public final class RemoteFeedLoader {
    private let url :URL
    private let client :HttpClient
    
    public init(url:URL, client: HttpClient) {
        self.client = client
        self.url = url
    }
    public func load()  {
        client.get(from: url)
    }
}
