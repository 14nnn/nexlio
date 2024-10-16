//
//  NewsPhotoView.swift
//  FlipRSS
//
//  Created by Darian on 14.10.2024..
//

import SwiftUI
import Kingfisher

/// A news view with a photo, title and a subtitle.
struct NewsPhotoView: View {
    /// Large font size for the title.
    static let largeTitleFontSize = 22.0
    
    /// Font size for the title.
    static let titleFontSize = 16.0
    
    /// Font size for the subtitle.
    static let subtitleFontSize = 14.0
    
    let news: News
    
    /// Used for larger news in the cards.
    let isLarge: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                KFImage(news.imageURL)
                    .placeholder {
                        ProgressView()
                    }
                    .loadDiskFileSynchronously()
                    .cacheMemoryOnly()
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                // Gradient so white text is always visible, even on white photos.
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.8), Color.clear]),
                    startPoint: .bottom,
                    endPoint: .top
                ).frame(height: 200)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(news.title)
                        .font(.system(size: isLarge ? NewsPhotoView.largeTitleFontSize : NewsPhotoView.titleFontSize, weight: .bold, design: .default))
                        .lineLimit(isLarge ? 3 : 4)
                        .foregroundColor(.white)
                        .frame(maxWidth: geometry.size.width, alignment: .leading)
                    
                    if (!news.details.isEmpty) {
                        Text(news.details)
                            .font(.system(size: NewsPhotoView.subtitleFontSize, weight: .regular, design: .default))
                            .foregroundColor(.white)
                            .frame(maxWidth: geometry.size.width, alignment: .leading)
                            .lineLimit(2)
                    }
                }
                .frame(maxWidth: geometry.size.width)
                .padding(12.0)
            }
            .frame(maxWidth: .infinity,
                   alignment: .leading)
            .clipped()
        }
    }
}
