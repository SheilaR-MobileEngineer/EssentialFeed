//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by sr0922 on 6/6/23.
//

import XCTest


class RemoteFeedLoader {
    func load(){
        HTTPClient.shared.get(from: URL(string: "myurl.com")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient()
    var requestedURL: URL?
    
    func get(from url: URL){}
}

class HTTPClientSpy: HTTPClient {
    
    override func get(from url: URL){
        requestedURL = url
    }
}

class RemoteFeedLoaderTest: XCTestCase {
    
    func test_init_doesNotRequestDatFromRUL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
            
        sut.load()

        XCTAssertNotNil(client.requestedURL)
    }

}
