//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Sheila Rodriguez on 6/9/23.
//

import Foundation
import EssentialFeed

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

final class RemoteFeedLoader {
    private let url: URL
    private let client : HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    init(url: URL, client: HTTPClient){
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (Result) -> Void){
        client.get(from: url){
            result in
            switch result {
            case let .success(data, _):
                if let root = try?
                    JSONDecoder().decode(Root.self, from: data){
                    completion(.success(root.items))
                }
                else{
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private struct Root: Decodable {
    let items: [FeedItem]
}
