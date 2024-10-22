import SwiftUI
import Kingfisher
import CoreData

struct FeedHeaderView: View {
    let currentIndex: Int?
    let hasFavorites: Bool
    let feeds: FetchedResults<Feed>
    
    var body: some View {
        let currentIndexWithDefault = (currentIndex ?? 0)
        let isFavorite = currentIndexWithDefault == 0 && hasFavorites
        
        // Feed header view.
        if isFavorite {
            HStack {
                Image(systemName: "star.fill")
                    .resizable()
                    .frame(width: 24.0, height: 24.0)
                    .foregroundColor(.yellow)
                
                Text("Favorites")
                    .font(.system(size: 34.0, weight: .bold, design: .default))
                    .foregroundColor(.white)
            }.padding(.bottom, 21.0)
        } else {
            let areFeedsEmpty = feeds.isEmpty
            let isCurrentIndexAboveFeedCount = currentIndexWithDefault < (hasFavorites ? feeds.count + 1 : feeds.count)
            let currentFeed = (!areFeedsEmpty && isCurrentIndexAboveFeedCount) ? feeds[hasFavorites ? (currentIndexWithDefault - 1) : currentIndexWithDefault] : nil
            
            HStack {
                FeedIconView(feed: currentFeed, size: 24.0)
                
                Text(currentFeed?.name ?? "Unnamed Feed")
                    .font(.system(size: 34.0, weight: .bold, design: .default))
                    .foregroundColor(.white)
            }
            
            if let lastRefreshDate = currentFeed?.lastRefreshDate {
                RelativeTimeText(targetDate: lastRefreshDate, style: { label in
                    label
                        .font(.system(size: 16.0, weight: .regular, design: .default))
                        .foregroundColor(.white.opacity(0.8))
                })
            }
        }
    }
}

struct FeedPagesView: View {
    let feedCount: Int
    let hasFavorites: Bool
    let currentIndex: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<(hasFavorites ? (feedCount + 1) : feedCount), id: \.self) { index in
                if index == 0 && hasFavorites {
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .foregroundColor(currentIndex == 0 ? .yellow : .gray)
                        .scaleEffect(currentIndex == 0 ? 1.0 : 0.9)
                } else {
                    Circle()
                        .frame(width: 8, height: 8)
                        .scaleEffect(currentIndex == index ? 1.0 : 0.9)
                        .foregroundColor(currentIndex == index ? .white : .gray)
                }
            }
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Feed.sortOrder, ascending: true)],
        animation: .default)
    private var feeds: FetchedResults<Feed>
    
    @State private var currentIndex: Int? = 0
    @State private var isDragging: Bool = false
    @State private var showSettings = false
    @State private var dragOffset: CGSize = .zero
    @State private var isVerticalDrag: Bool = false
    @State private var refreshID = UUID()
    
    private var hasFavorites: Bool {
        feeds.contains { $0.isFavorite }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let padding = 0.0
            let aspectRatioCards = 16.0 / 10.0
            let cardsWidth = geometry.size.width - (padding * 4.0)
            
            VStack(spacing: 16.0) {
                HStack(alignment: .center, spacing: 8.0) {
                    VStack(alignment: .leading, spacing: 2.0) {
                        FeedHeaderView(currentIndex: currentIndex, 
                                       hasFavorites: hasFavorites,
                                       feeds: feeds)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 22.0))
                            .foregroundColor(Color.white)
                            .frame(width: 28.0, height: 28.0)
                            .background(
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                            )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10.0)
                
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0.0) {
                        ForEach(0..<(hasFavorites ? (feeds.count + 1) : feeds.count), id: \.self) { i in
                            if i == 0 && hasFavorites { // Favorites
                                FeedView(feed: nil)
                                    .frame(width: cardsWidth, height: .infinity)
                                    .zIndex(currentIndex == i ? 10 : 0)
                            } else {
                                let feed = feeds[hasFavorites ? i - 1 : i]
                                FeedView(feed: feed)
                                    .frame(width: cardsWidth, height: .infinity)
                                    .zIndex(currentIndex == i ? 10 : 0)
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .id(refreshID)
                .scrollIndicators(.never)
                .scrollClipDisabled()
                .scrollPosition(id: $currentIndex)
                .scrollTargetBehavior(.paging)
                .safeAreaPadding(.zero)
                .onReceive(NotificationCenter.default.publisher(for: .refreshFeeds)) { _ in
                    refreshID = UUID()
                    currentIndex = 0
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                            isVerticalDrag = abs(dragOffset.height) > abs(dragOffset.width)
                        }
                        .onEnded { _ in
                            dragOffset = .zero
                            isVerticalDrag = false
                        }
                )
                .simultaneousGesture(
                    DragGesture().onChanged { _ in }.onEnded { _ in }
                )
                
                FeedPagesView(feedCount: feeds.count,
                              hasFavorites: hasFavorites,
                              currentIndex: currentIndex ?? 0)
                .zIndex(-1)
            }
        }
        .background(Color.black)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
        .background(Color.black)
}
