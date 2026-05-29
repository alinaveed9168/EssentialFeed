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
        expect(sut, result:.failure(.connectivity) ) {
            let clientError = NSError(domain: "test", code: 0)
            clientSpy.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut,clientSpy) = makeSUT()
        let sampleErrorCode = [199,201,300,400,500]
        sampleErrorCode.enumerated().forEach { offset, code in
            expect(sut, result:.failure(.invalidData)) {
                let json = makeItemJSON([])
                clientSpy.complete(withStatusCode: code,
                                   data: json,
                                   index: offset)
            }
        }
    }
    
    func test_load_develierErrorOnInvalidJSONWith200HTTPResponse() {
        let (sut,clientSpy) = makeSUT()
        
        expect(sut, result:.failure(.invalidData) ) {
            let invalidJson = "invalid".data(using: .utf8)!
            clientSpy.complete(withStatusCode: 200, data: invalidJson)
        }
    }
    
    func test_load_emptyDataWith200HTTPResponse() {
        let (sut,clientSpy) = makeSUT()
        expect(sut, result:.success([])) {
            let emptyListJson = makeItemJSON([])
            clientSpy.complete(withStatusCode: 200, data: emptyListJson)
        }
    }
    
    func test_load_deliversItemOn200HTTPResponseWithValidJSONItems() {
        let (sut,clientSpy) = makeSUT()
        
        let item1 = makeItem(id: UUID(), imageURL: URL(string: "https://a-given-dummy.com")!)
        
        let item2 = makeItem(id: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string: "https://a-given-dummy.com")!)
        let results = [item1.model,item2.model]
        expect(sut,
               result:.success(results),
               when : {
            let json = makeItemJSON([item1.json,item2.json])
            clientSpy.complete(withStatusCode: 200, data: json)
        })
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HttpClientSpy()
        let url = URL(string: "https://a-given-dummy.com")!
        var sut:RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        var capturedError = [RemoteFeedLoader.Result]()
        sut?.load { capturedError.append($0) }
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemJSON([]))
        XCTAssertTrue(capturedError.isEmpty)

    }
    
    // MARK: - Helpers
    private func makeSUT(url:URL = URL(string:  "https://a-given-dummy.com")!,file:StaticString = #filePath, line:UInt = #line) -> (sut:RemoteFeedLoader,client:HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        track_forMemoryLeak(instance: client,file: file,line: line)
        track_forMemoryLeak(instance: sut,file: file,line: line)
        return (sut,client)
    }
    
    private func track_forMemoryLeak(instance:any AnyObject,file:StaticString = #filePath, line:UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance,"sut should be deallocated",file: file,line: line)
        }
    }
    
    private func makeItem(id:UUID, description:String? = nil, location:String?  = nil, imageURL:URL) -> (model:FeedItem,json:[String:Any]) {
        
        let feed = FeedItem(id: id,
                            description: description,
                            location: location,
                            imageURL: imageURL)
        // reduce into new dictionaey and reduce to new value
        let itemJSON = [
            "id" : id.uuidString,
            "description" :description,
            "location" : location,
            "image" : imageURL.absoluteString
        ].reduce(into: [String:Any]()) { (acc,e) in
            if let value = e.value {
                acc[e.key] = value
            }
        }
        return (feed,itemJSON)
    }
    
    private func makeItemJSON(_ items : [[String:Any]]) -> Data {
        let itemJSON = [
            "items" : items
        ]
        let json = try! JSONSerialization.data(withJSONObject: itemJSON)
        return json
    }
    
    private func expect(_ sut:RemoteFeedLoader,
                        result:RemoteFeedLoader.Result,
                        when action: (() -> Void),file: StaticString = #file, line:UInt = #line) {
        
        let exp = expectation(description: "wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult,result) {
                case let (.success(receivedItems),.success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems,file: file,line: line)
            case let (.failure(receivedError),.failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError,file: file,line: line)
            default:
                XCTFail("expected \(result) but received \(receivedResult)",file: file,line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
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
        
        func complete(withStatusCode code: Int,data:Data, index:Int = 0){
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

