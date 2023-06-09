//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by sr0922 on 6/9/23.
//

import Foundation

protocol HTTPClient {
    func get(from url: URL)
}

final class RemoteFeedLoader {
    private let url: URL
    private let client : HTTPClient

    init(url: URL, client: HTTPClient){
        self.url = url
        self.client = client
    }
    
    func load(){
        client.get(from: url)
    }
}
