//
//  RemoteFeedLoaderTest.swift
//  EssentialFeed
//
//  Created by ali naveed on 21/05/2026.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTest: XCTestCase {
    
    func test_init_doesNotRequestFromURL() {
        let (_,clientSpy) = makeSUT()
        XCTAssertTrue(clientSpy.requestURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-dummy.com")!
        let (sut,clientSpy) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(clientSpy.requestURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-dummy.com")!
        let (sut,clientSpy) = makeSUT(url: url)
        sut.load()
        sut.load()
        
        XCTAssertEqual(clientSpy.requestURLs, [url,url])
    }
    
    
    func test_load_deliversErrorOnClientError() {
        let (sut,clientSpy) = makeSUT()
        var capturedError = [RemoteFeedLoader.Error?]()
        sut.load { capturedError.append($0) }
        let clientError = NSError(domain: "test", code: 0)
        clientSpy.complete(with: clientError)
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
    
    // MARK: - Helpers
    private func makeSUT(url:URL = URL(string: "https://a-given-dummy.com")!) -> (sut:RemoteFeedLoader,client:HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut,client)
    }
    
    private class HttpClientSpy: HttpClient {
        private var messagesArray = [(url:URL,completion:(Error) -> Void)]()
        var requestURLs:[URL] {
            return messagesArray.map{ $0.url}
        }

        func get(from url: URL,completion: @escaping (Error) -> Void) {
            messagesArray.append((url,completion))
        }
        
        func complete(with error: Error,index:Int = 0){
            messagesArray[index].completion(error)
        }
    }
}

// constraction Dinjection
// property Dinjection
// parameter Dinjection
