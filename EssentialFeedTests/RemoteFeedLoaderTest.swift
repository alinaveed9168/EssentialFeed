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
        sut.load{ _ in }
        XCTAssertEqual(clientSpy.requestURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-dummy.com")!
        let (sut,clientSpy) = makeSUT(url: url)
        sut.load{ _ in }
        sut.load{ _ in }

        
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
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut,clientSpy) = makeSUT()
        let sampleErrorCode = [199,201,300,400,500]
        sampleErrorCode.enumerated().forEach { offset, code in
            var capturedError = [RemoteFeedLoader.Error?]()
            sut.load { capturedError.append($0) }
            clientSpy.complete(withStatusCode: code,index: offset)
            XCTAssertEqual(capturedError, [.invalidData ])
        }
    }
    
    
    // MARK: - Helpers
    private func makeSUT(url:URL = URL(string: "https://a-given-dummy.com")!) -> (sut:RemoteFeedLoader,client:HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut,client)
    }
    
    private class HttpClientSpy: HttpClient {
        private var messagesArray = [(url:URL,completion:(HTTPClientResult) -> Void)]()
        var requestURLs:[URL] {
            return messagesArray.map{ $0.url}
        }

        func get(from url: URL,completion: @escaping (HTTPClientResult) -> Void) {
            messagesArray.append((url,completion))
        }
        
        func complete(with error: Error,index:Int = 0){
            messagesArray[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int,index:Int = 0){
            let response = HTTPURLResponse(
                url: requestURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
             
            messagesArray[index].completion(.success(response))
        }
    }
}

// constraction Dinjection
// property Dinjection
// parameter Dinjection
