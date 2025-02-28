//
//  CardView.swift
//  FlipRSS
//
//  Created by Darian on 14.10.2024..
//

import SwiftUI
import SafariServices

/**
 View holding one card.
 */
struct CardView: View {
    /// Corner radius of the CardView.
    static let cornerRadius = 6.0
    
    let card: Card
    
    /// Which corners are rounded.
    var roundedCorners: UIRectCorner
    
    /// Which border edges are drawn.
    var drawnBorderEdges: [Edge]
    
    /// Is flipped and mirrored.
    var isFlipped: Bool = false
    
    @State private var selectedURL: URL?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0.0) {
                VStack(spacing: 0.0) {
                    switch (card) {
                    case let .layoutA(news):
                        VStack(spacing: 0.0) {
                            NewsItemView(news: news.first!, isLarge: true)
                                .frame(height: geometry.size.height * 2 / 3)
                                .onTapGesture {
                                    if let url = news.first?.link {
                                        openSafariView(with: url)
                                    }
                                }
                            
                            HStack(spacing: 0.0) {
                                ForEach(news.dropFirst().prefix(2)) { newsItem in
                                    NewsItemView(news: newsItem, isLarge: false)
                                        .frame(width: geometry.size.width / 2)
                                    
                                        .onTapGesture {
                                            if let url = newsItem.link {
                                                openSafariView(with: url)
                                            }
                                        }
                                }
                            }
                            .frame(height: geometry.size.height / 3)
                        }
                        
                    case .layoutB(news: let news):
                        VStack(spacing: 0.0) {
                            HStack(spacing: 0.0) {
                                ForEach(news.dropFirst().prefix(2)) { newsItem in
                                    NewsItemView(news: newsItem, isLarge: false)
                                        .frame(width: geometry.size.width / 2)
                                    
                                        .onTapGesture {
                                            if let url = newsItem.link {
                                                openSafariView(with: url)
                                            }
                                        }
                                }
                            }
                            .frame(height: geometry.size.height / 3)
                            
                            NewsItemView(news: news.first!, isLarge: true)
                                .frame(height: geometry.size.height * 2 / 3)
                                .onTapGesture {
                                    if let url = news.first?.link {
                                        openSafariView(with: url)
                                    }
                                }
                        }
                    }
                }
                // When the card is "flipped" we need to mirror the content so it looks right.
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
        .sheet(isPresented: Binding<Bool>(
            get: { selectedURL != nil },
            set: { if !$0 { selectedURL = nil } }
        ), onDismiss: {
            selectedURL = nil
        }) {
            if let url = selectedURL {
                SafariView(url: url)
            }
        }
    }
    
    /// Will open a Safari view controller to view the article.
    private func openSafariView(with url: URL) {
        selectedURL = url
    }
}
