//
//  RemoteFeedLoaderTest.swift
//  EssentialFeed
//
//  Created by ali naveed on 21/05/2026.
//

import XCTest

class RemoteFeedLoader {
    func load()  {
        HttpClient.shared.requestedURL = URL(string: "https://dummy.com")
    }
}

class HttpClient {
    static let shared = HttpClient()
    private init() {}
    var requestedURL: URL?
}

final class RemoteFeedLoaderTest: XCTestCase {
    
    func test_init_doest_not_request_from_URL() {
        let client = HttpClient.shared
        _ = RemoteFeedLoader()
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requests_from_URL() {
        let client = HttpClient.shared
        let sut = RemoteFeedLoader()
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }
}

// constraction Dinjection
// property Dinjection
// parameter Dinjection
