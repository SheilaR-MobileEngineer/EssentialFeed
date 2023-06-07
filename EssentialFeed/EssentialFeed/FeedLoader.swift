//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by sr0922 on 6/6/23.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
