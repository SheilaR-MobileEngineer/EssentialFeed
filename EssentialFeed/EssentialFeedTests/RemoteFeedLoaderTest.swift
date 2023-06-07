//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by sr0922 on 6/6/23.
//

import XCTest


class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}
class RemoteFeedLoaderTest: XCTestCase {
    
    func test_init_doesNotRequestDatFromRUL() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }

}
