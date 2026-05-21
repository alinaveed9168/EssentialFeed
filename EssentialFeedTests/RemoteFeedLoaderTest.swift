//
//  RemoteFeedLoaderTest.swift
//  EssentialFeed
//
//  Created by ali naveed on 21/05/2026.
//

import XCTest

class RemoteFeedLoader {
    func load()  {
        HttpClient.shared.get(from: URL(string: "https://dummy.com")!)
    }
}

class HttpClient {
    static var shared = HttpClient()
    func get(from url: URL) {}
}

class HttpClientSpy: HttpClient {
    var requestedURL: URL?
   override func get(from url: URL) {
        requestedURL = url
    }
}

final class RemoteFeedLoaderTest: XCTestCase {
    
    func test_init_doest_not_request_from_URL() {
        let client = HttpClientSpy()
        HttpClient.shared = client
        _ = RemoteFeedLoader()
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requests_from_URL() {
        let client = HttpClientSpy()
        HttpClient.shared = client
        let sut = RemoteFeedLoader()
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }
}

// constraction Dinjection
// property Dinjection
// parameter Dinjection
