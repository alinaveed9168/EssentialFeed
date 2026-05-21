//
//  RemoteFeedLoaderTest.swift
//  EssentialFeed
//
//  Created by ali naveed on 21/05/2026.
//

import XCTest

class RemoteFeedLoader {
    let client :HttpClient
    init(client: HttpClient) {
        self.client = client
    }
    func load()  {
        client.get(from: URL(string: "https://dummy.com")!)
    }
}

protocol HttpClient {
    func get(from url: URL)
}

class HttpClientSpy: HttpClient {
    var requestedURL: URL?
    func get(from url: URL) {
        requestedURL = url
    }
}

final class RemoteFeedLoaderTest: XCTestCase {
    
    func test_init_doest_not_request_from_URL() {
        let client = HttpClientSpy()
        _ = RemoteFeedLoader(client: client)
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requests_from_URL() {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(client: client)
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }
}

// constraction Dinjection
// property Dinjection
// parameter Dinjection
