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

final class RemoteFeedLoaderTest: XCTestCase {
    
    func test_init_doest_not_request_from_URL() {
        let (_,clientSpy) = makeSUT()
        XCTAssertNil(clientSpy.requestedURL)
    }
    
    func test_load_requests_from_URL() {
        let url = URL(string: "https://a-given-dummy.com")!
        let (sut,clientSpy) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(clientSpy.requestedURL, url)
    }
    
    // MARK: - Helpers
    private func makeSUT(url:URL = URL(string: "https://a-given-dummy.com")!) -> (sut:RemoteFeedLoader,client:HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut,client)
    }
    
    private class HttpClientSpy: HttpClient {
        var requestedURL: URL?
        func get(from url: URL) {
            requestedURL = url
        }
    }
}

// constraction Dinjection
// property Dinjection
// parameter Dinjection
