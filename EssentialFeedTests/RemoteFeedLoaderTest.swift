//
//  RemoteFeedLoaderTest.swift
//  EssentialFeed
//
//  Created by ali naveed on 21/05/2026.
//

import XCTest

class RemoteFeedLoader {
    let client :HttpClient
    let url :URL
    
    init(url:URL, client: HttpClient) {
        self.client = client
        self.url = url
    }
    func load()  {
        client.get(from: url)
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
        let url = URL(string: "https://a-given-dummy.com")!
        let client = HttpClientSpy()
        _ = RemoteFeedLoader(url: url, client: client)
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requests_from_URL() {
        let url = URL(string: "https://a-given-dummy.com")!
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url:url, client: client)
        sut.load()
        XCTAssertEqual(client.requestedURL, url)
    }
}

// constraction Dinjection
// property Dinjection
// parameter Dinjection
