//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Sheila Rodriguez on 6/9/23.
//

import Foundation

protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void)
}

final class RemoteFeedLoader {
    private let url: URL
    private let client : HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    init(url: URL, client: HTTPClient){
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (Error) -> Void){
        client.get(from: url){
            error, response in
            response != nil ? completion(.invalidData) : completion(.connectivity)
        }
    }
}
