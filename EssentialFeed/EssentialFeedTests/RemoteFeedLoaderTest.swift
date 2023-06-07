//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by sr0922 on 6/6/23.
//

import XCTest


class RemoteFeedLoader {
    func load(){
        HTTPClient.shared.requestedURL = URL(string: "MYURL.COM")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    private init(){}
    var requestedURL: URL?
}

class RemoteFeedLoaderTest: XCTestCase {
    
    func test_init_doesNotRequestDatFromRUL() {
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
            
        sut.load()

        XCTAssertNotNil(client.requestedURL)
    }

}
