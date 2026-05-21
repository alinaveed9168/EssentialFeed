//
//  RemoteFeedLoaderTest.swift
//  EssentialFeed
//
//  Created by ali naveed on 21/05/2026.
//

import XCTest

class RemoteFeedLoader {
    
}

class HttpClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTest {
    
    func test_init_doest_not_request_from_URL() {
        let client = HttpClient()
        let sut = RemoteFeedLoader()
        XCTAssertNil(client.requestedURL)
    }
}

