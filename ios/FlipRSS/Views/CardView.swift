//
//  CardView.swift
//  FlipRSS
//
//  Created by Darian on 14.10.2024..
//

import SwiftUI

/**
 View holding one card.
 */
struct CardView: View {
    /// Corner radius of the CardView.
    static let cornerRadius = 20.0
    
    let card: Card
    
    /// Which corners are rounded.
    var roundedCorners: UIRectCorner
    
    /// Which border edges are drawn.
    var drawnBorderEdges: [Edge]
    
    /// Is flipped and mirrored.
    var isFlipped: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0.0) {
                VStack(spacing: 0.0) {
                    switch (card) {
                    case let .oneAtwoBCard(news):
                        VStack(spacing: 0.0) {
                            NewsPhotoView(news: news.first!, isLarge: true)
                                .frame(height: geometry.size.height * 2 / 3)
                            HStack(spacing: 0.0) {
                                ForEach(news.dropFirst().prefix(2)) { newsItem in
                                    NewsPhotoView(news: newsItem, isLarge: false)
                                        .frame(width: geometry.size.width / 2)
                                }
                            }
                            .frame(height: geometry.size.height / 3)
                        }
                    }
                }
                .rotation3DEffect(
                    Angle(degrees: isFlipped ? .angles180 : 0),
                    axis: (x: 1.0, y: 0.0, z: 0.0)
                )
                .transaction { transaction in
                    transaction.animation = nil
                }
            }
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity)
            .background(Color.white)
            .cornerRadius(CardView.cornerRadius,
                          corners: roundedCorners)
            .edgeShadow(edges: drawnBorderEdges)
        }
    }
}
