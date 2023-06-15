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
        
        // act section
        var capturedErrors = [RemoteFeedLoader.Error]()
        
        sut.load{ capturedErrors.append($0)}
        
        let clientError = NSError(domain: "Test", code: 0)
        
        client.complete(with: clientError)
        
        // assert section
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse(){
        
        // arrange section
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500].enumerated()
        
        samples.forEach { index, code in
            // act section
            var capturedErrors = [RemoteFeedLoader.Error]()
            
            sut.load{ capturedErrors.append($0)}
            
            client.complete(withStatusCode: code, at: index)
            
            // assert section
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON(){
        let (sut, client) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        
        sut.load{ capturedErrors.append($0)}
        
        let invalidJSON = Data(_: "invalid json".utf8)
        client.complete(withStatusCode: 200, data: invalidJSON)
        
        // assert section
        XCTAssertEqual(capturedErrors, [.invalidData])
    }
    
// MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "defaulturl.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
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
