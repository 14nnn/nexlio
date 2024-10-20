//
//  CardFactory.swift
//  FlipRSS
//
//  Created by Darian on 16.10.2024..
//

import SwiftUI

/// Creates cards from news. Current implementation is to split into three and run the only card style available.
class CardFactory {
    static func createCards(from news: [News]) -> [Card] {
        var cards: [Card] = []
        let numberOfFullCards = news.count / 3
        let remainingItems = news.count % 3
        
        for index in 0..<numberOfFullCards {
            let startIndex = index * 3
            let endIndex = startIndex + 3
            let newsSlice = Array(news[startIndex..<endIndex])
            if newsSlice.count == 3 {
                let card: Card
                
                if index % 2 == 0 {
                    card = Card.oneAtwoBCard(news: newsSlice)
                } else {
                    card = Card.twoAoneBCard(news: newsSlice)
                }
                
                cards.append(card)
            }
        }
        
        if remainingItems > 0 {
            let startIndex = numberOfFullCards * 3
            let newsSlice = Array(news[startIndex...])
            if !newsSlice.isEmpty {
                let card = Card.oneAtwoBCard(news: newsSlice)
                cards.append(card)
            }
        }
        
        return cards
    }
}
