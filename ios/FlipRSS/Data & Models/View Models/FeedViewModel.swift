//
//  FeedViewModel.swift
//  FlipRSS
//
//  Created by Darian on 16.10.2024..
//

import SwiftUI
import Combine

class FeedViewModel: ObservableObject {
    @Published var cards: [Card] = []
    
    private var cancellable: AnyCancellable?
    
    /// Fetches feed if defined, if not favorites feed. Force refresh will force a refresh, otherwise it will fetch new feed items after 15 minutes.
    func fetchFeed(from feed: Feed?, forceRefresh: Bool = false) {
        FeedDataManager.shared.fetchNewsForFeed(feed, forceRefresh: forceRefresh)
        
        if let feed = feed {
            cancellable = FeedDataManager.shared.$newsByFeed
                .map { $0[feed] ?? [] }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] news in
                    self?.cards = CardFactory.createCards(from: news)
                }
        } else {
            cancellable = FeedDataManager.shared.$favoritesNews
                .receive(on: DispatchQueue.main)
                .sink { [weak self] news in
                    self?.cards = CardFactory.createCards(from: news)
                }
        }
    }
}
