//
//  FeedView.swift
//  FlipRSS
//
//  Created by Darian on 22.10.2024..
//

import SwiftUI
import Kingfisher
import CoreData

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var currentIndex: Int = 0
    
    let id = UUID()
    let feed: Feed?
    
    var body: some View {
        CardsStackView(id: id, cardIndex: currentIndex, cards: viewModel.cards, onRefresh: {
            viewModel.fetchFeed(from: feed, forceRefresh: true)
        })
        .onReceive(NotificationCenter.default.publisher(for: .didFlipCardStackView)) { notification in
            if let object = notification.object as? CardsStackView.NotificationObject, object.id == id {
                if object.direction == .forward && currentIndex < viewModel.cards.count - 1 {
                    currentIndex += 1
                } else if object.direction == .backward && currentIndex > 0 {
                    currentIndex -= 1
                }
            }
        }
        .onAppear {
            viewModel.fetchFeed(from: feed)
        }
    }
}
