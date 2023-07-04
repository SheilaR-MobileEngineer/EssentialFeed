//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by sr0922 on 6/6/23.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
