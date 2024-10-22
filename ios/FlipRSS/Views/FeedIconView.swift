//
//  FeedIconView.swift
//  FlipRSS
//
//  Created by Darian on 22.10.2024..
//

import SwiftUI
import Kingfisher

/// A view that displays a feed's icon image with a fallback to a letter-based placeholder.
struct FeedIconView: View {
    // MARK: - Properties
    
    /// The feed whose icon should be displayed
    let feed: Feed?
    
    /// The size of the icon view (both width and height)
    let size: CGFloat
    
    /// The background color for the placeholder
    private let placeholderColor = Color(red: 0.85, green: 0.85, blue: 0.85)
    
    /// The timeout interval for image loading
    private let timeoutInterval: TimeInterval = 1.0
    
    // MARK: - Computed Properties
    
    /// Extracts the first letter from the feed name for the placeholder
    private var placeholderLetter: String {
        guard let name = feed?.name, !name.isEmpty else { return "?" }
        return String(name.prefix(1).uppercased())
    }
    
    // MARK: - Body
    
    var body: some View {
        if let iconImage = feed?.iconImage,
           let iconImageURL = URL(string: iconImage) {
            KFImage(iconImageURL)
                .placeholder {
                    PlaceholderView()
                }
                .onFailure { _ in
                    // Failure is handled by showing placeholder
                }
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: size, height: size)))
                .loadDiskFileSynchronously()
                .fade(duration: 0.3)
                .cacheOriginalImage()
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            PlaceholderView()
        }
    }
    
    // MARK: - Placeholder View
    
    @ViewBuilder
    private func PlaceholderView() -> some View {
        ZStack {
            Circle()
                .fill(placeholderColor)
            
            Text(placeholderLetter)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Preview Provider

#Preview {
    VStack(spacing: 20) {
        // Preview with a feed that has an icon
        FeedIconView(
            feed: {
                let feed = Feed(context: DataController.shared.container.viewContext)
                feed.name = "Apple News"
                feed.iconImage = "https://www.apple.com/favicon.ico"
                return feed
            }(),
            size: 44
        )
        
        // Preview with a feed that has no icon
        FeedIconView(
            feed: {
                let feed = Feed(context: DataController.shared.container.viewContext)
                feed.name = "Test Feed"
                return feed
            }(),
            size: 44
        )
        
        // Preview with nil feed
        FeedIconView(feed: nil, size: 44)
        
        // Preview with weird URL
        FeedIconView(
            feed: {
                let feed = Feed(context: DataController.shared.container.viewContext)
                feed.name = "Apple News"
                feed.iconImage = "https://www.apple.com/"
                return feed
            }(),
            size: 44
        )
    }
}
