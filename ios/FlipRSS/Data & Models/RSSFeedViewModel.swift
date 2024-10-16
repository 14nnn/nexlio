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
    
    func fetchRSSFeed(from url: URL) {
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .map { data -> [News] in
                let parser = RSSParser()
                return parser.parse(data: data)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] news in
                let cards = CardFactory.createCards(from: news)
                self?.cards = cards
            })
    }
}
