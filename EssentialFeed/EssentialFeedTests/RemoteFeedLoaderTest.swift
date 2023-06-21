//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by sr0922 on 6/6/23.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTest: XCTestCase {
    
    func test_init_doesNotRequestDatFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL(){
        let url = URL(string: "aurl.com")
        let (sut, client) = makeSUT(url: url!)
        
        sut.load{_ in}
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice(){
        let url = URL(string: "aurl.com")
        let (sut, client) = makeSUT(url: url!)
        
        sut.load{_ in}
        sut.load{_ in}
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError(){
        
        // arrange section
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.connectivity), when: {
            
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse(){
        
        // arrange section
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500].enumerated()
        
        samples.forEach { index, code in
            expect(sut, toCompleteWithResult:  .failure(.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON(){
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult:  .failure(.invalidData), when: {
            let invalidJSON = Data(_: "invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmpty(){
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success([])) {
            let emptyListJson = Data(_: "{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJson)
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJsonItems(){
        
        let (sut, client) = makeSUT()
        
        let item1 = FeedItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "http://a-url.com")!)
        
        let item1JSON = [
            "id": item1.id.uuidString,
            "image": item1.imageURL.absoluteString
        ]
        
        let item2 = FeedItem(id: UUID(), description: "a description", location: "a location", imageURL: URL(string: "http://another-url.com")!)
        
        let item2JSON = [
            "id": item2.id.uuidString,
            "description": item2.description,
            "location": item2.location,
            "image": item2.imageURL.absoluteString
        ]
        
        let itemsJson = [
            "items": [item1JSON, item2JSON]
        ]
        
        expect(sut, toCompleteWithResult: .success([item1, item2]), when: {
            
            let json = try! JSONSerialization.data(withJSONObject: itemsJson)
            
            client.complete(withStatusCode: 200, data: json)
        }
        )
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "defaulturl.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line){
        
        // act section
        var capturedResults = [RemoteFeedLoader.Result]()
        
        sut.load{ capturedResults.append($0)}
        
        action()
        
        //file and line to show the exact line where it fails
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    // doesn't have behaviour only accumulates received properties
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map{$0.url}
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void){
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0){
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0){
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            
            messages[index].completion(.success(data, response))
        }
    }
}
