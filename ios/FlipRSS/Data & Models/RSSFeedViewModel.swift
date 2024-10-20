//
//  RSSFeedViewModel.swift
//  FlipRSS
//
//  Created by Darian on 16.10.2024..
//

import SwiftUI
import Combine

class RSSFeedViewModel: ObservableObject {
    @Published var cards: [Card] = []
    
    private var cancellable: AnyCancellable?
    
    func fetchRSSFeed(from feed: Feed, forceRefresh: Bool = false) {
        FeedDataManager.shared.fetchNewsForFeed(feed, forceRefresh: forceRefresh)
        
        cancellable = FeedDataManager.shared.$newsByFeed
            .map { $0[feed] ?? [] }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] news in
                self?.cards = CardFactory.createCards(from: news)
            }
    }
}
