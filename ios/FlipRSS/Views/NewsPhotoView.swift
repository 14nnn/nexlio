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
    
    /// Font size for the time.
    static let timeFontSize = 12.0
    
    let news: News
    
    /// Used for larger news in the cards.
    let isLarge: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                if let imageURL = news.imageURL {
                    KFImage(imageURL)
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
                            .font(.system(size: isLarge ? NewsPhotoView.largeTitleFontSize : NewsPhotoView.titleFontSize, weight: .bold, design: .serif))
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
                        
                        if (news.date != nil) {
                            RelativeTimeLabel(targetDate: news.date!, style: { label in
                                label
                                    .font(.system(size: NewsPhotoView.timeFontSize, weight: .regular, design: .default))
                                    .foregroundColor(.white.opacity(0.8))
                            })
                        }
                    }
                    .frame(maxWidth: geometry.size.width)
                    .padding(12.0)
                } else {
                    // No image - center the title and subtitle
                    // Gradient so it isn't all white.
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.1), Color.black.opacity(0.0)]),
                        startPoint: .bottom,
                        endPoint: .top
                    ).frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                    
                    VStack {
                        Spacer()
                        Text(news.title)
                            .font(.system(size: NewsPhotoView.largeTitleFontSize, weight: .bold, design: .serif))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 8)
                        
                        if (!news.details.isEmpty) {
                            Text(news.details)
                                .font(.system(size: NewsPhotoView.subtitleFontSize, weight: .regular, design: .default))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                        }
                        
                        if (news.date != nil) {
                            RelativeTimeLabel(targetDate: news.date!, style: { label in
                                label
                                    .font(.system(size: NewsPhotoView.timeFontSize, weight: .regular, design: .default))
                                    .foregroundColor(.black.opacity(0.8))
                            })
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                    .padding(12.0)
                }
            }
            .frame(maxWidth: .infinity,
                   alignment: .leading)
            .clipped()
        }
    }
}
