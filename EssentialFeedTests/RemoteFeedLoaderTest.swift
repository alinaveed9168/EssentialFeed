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
        expect(sut, error: .connectivity) {
            let clientError = NSError(domain: "test", code: 0)
            clientSpy.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut,clientSpy) = makeSUT()
        let sampleErrorCode = [199,201,300,400,500]
        sampleErrorCode.enumerated().forEach { offset, code in
            expect(sut, error: .invalidData) {
                clientSpy.complete(withStatusCode: code,index: offset)
            }
        }
    }
    
    func test_load_develierErrorOnInvalidJSONWith200HTTPResponse() {
        let (sut,clientSpy) = makeSUT()
        
        expect(sut, error: .invalidData) {
            let invalidJson = "invalid".data(using: .utf8)!
            clientSpy.complete(withStatusCode: 200, data: invalidJson)
        }
    }
    
    
    // MARK: - Helpers
    private func makeSUT(url:URL = URL(string: "https://a-given-dummy.com")!) -> (sut:RemoteFeedLoader,client:HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut,client)
    }
    
    private func expect(_ sut:RemoteFeedLoader,
                        error:RemoteFeedLoader.Error,action: (() -> Void),file: StaticString = #file, line:UInt = #line) {
        var capturedError = [RemoteFeedLoader.Error?]()
        sut.load { capturedError.append($0) }
        action()
        XCTAssertEqual(capturedError, [error],file: file,line: line)
        
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
        
        func complete(withStatusCode code: Int,data:Data = Data(), index:Int = 0){
            let response = HTTPURLResponse(
                url: requestURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
             
            messagesArray[index].completion(.success(data,response))
        }
    }
}

// constraction Dinjection
// property Dinjection
// parameter Dinjection
