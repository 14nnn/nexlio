//
//  SettingsFeedRowView.swift
//  FlipRSS
//
//  Created by Darian on 22.10.2024..
//

import SwiftUI
import Kingfisher

struct SettingsFeedRowView: View {
    @ObservedObject var feed: Feed
    var onEdit: () -> Void
    var onToggleFavorite: () -> Void
    
    var body: some View {
        HStack {
            FeedIconView(feed: feed, size: 24.0)
            
            Text(feed.name ?? "Unnamed Feed")
            
            Spacer()
            
            Button(action: {
                onToggleFavorite()
            }) {
                Image(systemName: feed.isFavorite ? "star.fill" : "star")
                    .foregroundColor(feed.isFavorite ? .yellow : .gray)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
    }
}
