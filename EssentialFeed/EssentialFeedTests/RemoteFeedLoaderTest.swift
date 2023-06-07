//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by sr0922 on 6/6/23.
//

import XCTest

class RemoteFeedLoader {
    let client : HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient){
        self.url = url
        self.client = client
    }
    
    func load(){
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL){
        requestedURL = url
    }
}

class RemoteFeedLoaderTest: XCTestCase {
    
    func test_init_doesNotRequestDatFromRUL() {
        let url = URL(string: "aurl.com")
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(url: url!, client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let url = URL(string: "aurl.com")
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url!, client: client)
            
        sut.load()

        XCTAssertEqual(client.requestedURL, url)
    }

}
