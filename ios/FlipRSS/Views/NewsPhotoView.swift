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
    /// Font size for the title.
    static let titleFontSize = 24.0
    
    /// Font size for the subtitle.
    static let subtitleFontSize = 16.0
    
    let news: News
    
    /// Used for larger news in the cards.
    let isLarge: Bool
    
    var body: some View {
        ZStack() {
            GeometryReader { geometry in
                KFImage(URL(string: news.imageName))
                    .placeholder {
                        ProgressView()
                    }
                    .loadDiskFileSynchronously()
                    .cacheMemoryOnly()
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
            
            ZStack(alignment: .bottomLeading) {
                // Gradient so white text is always visible, even on white photos.
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.6), Color.clear]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(news.title)
                        .font(.system(size: NewsPhotoView.titleFontSize, weight: .bold, design: .default))
                        .lineLimit(2)
                        .foregroundColor(.white)
                    
                    Text(news.details)
                        .font(.system(size: NewsPhotoView.subtitleFontSize, weight: .regular, design: .default))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .lineLimit(isLarge ? nil : 2)
                }
                .padding()
            }
            .frame(maxWidth: .infinity, 
                   alignment: .leading)
        }
        .clipped()
    }
}
