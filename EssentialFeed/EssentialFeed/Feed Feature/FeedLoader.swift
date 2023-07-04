//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by sr0922 on 6/6/23.
//

import Foundation

public enum LoadFeedResult <Error: Swift.Error>{
    case success([FeedItem])
    case failure(Error)
}

extension LoadFeedResult: Equatable where Error: Equatable {}

protocol FeedLoader {
    associatedtype Error: Swift.Error
    
    func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
