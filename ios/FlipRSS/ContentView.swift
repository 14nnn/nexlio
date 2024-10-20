import SwiftUI
import Kingfisher
import CoreData

struct CardsStackHolderView: View {
    @StateObject private var viewModel = RSSFeedViewModel()
    @State private var currentIndex: Int = 0
    
    let id = UUID()
    let feed: Feed
    
    var body: some View {
        CardsStackView(id: id, cardIndex: currentIndex, cards: viewModel.cards, onRefresh: {
            viewModel.fetchRSSFeed(from: feed, forceRefresh: true)
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
            viewModel.fetchRSSFeed(from: feed)
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
    
    var body: some View {
        GeometryReader { geometry in
            let padding = 0.0
            let aspectRatioCards = 16.0 / 10.0
            let cardsWidth = geometry.size.width - (padding * 4.0)
            let cardsHeight = cardsWidth * aspectRatioCards
            
            VStack(spacing: 16.0) {
                HStack(alignment: .center, spacing: 8.0) {
                    let currentIndexWithDefault = currentIndex ?? 0
                    let areFeedsEmpty = feeds.isEmpty
                    let isCurrentIndexAboveFeedCount = currentIndexWithDefault < feeds.count
                    let currentFeed = (!areFeedsEmpty && isCurrentIndexAboveFeedCount) ? feeds[currentIndex ?? 0] : nil
                    
                    
                    
                    VStack(alignment: .leading, spacing: 2.0) {
                        HStack {
                            if let iconImage = currentFeed?.iconImage,
                               let iconImageURL = URL(string: iconImage) {
                                KFImage(iconImageURL)
                                    .placeholder {
                                    }
                                    .onFailure({ error in
                                        
                                    })
                                    .loadDiskFileSynchronously()
                                    .cacheMemoryOnly()
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 24.0, height: 24.0)
                            }
                            
                            Text(currentFeed?.name ?? "Unnamed Feed")
                                .font(.system(size: 34.0, weight: .bold, design: .default))
                                .foregroundColor(.white)
                        }
                        
                        if let lastRefreshDate = currentFeed?.lastRefreshDate {
                            RelativeTimeLabel(targetDate: lastRefreshDate, style: { label in
                                label
                                    .font(.system(size: 16.0, weight: .regular, design: .default))
                                    .foregroundColor(.white.opacity(0.8))
                            })
                        }
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
                        ForEach(feeds.indices, id: \.self) { i in
                            let feed = feeds[i]
                            CardsStackHolderView(feed: feed)
                                .frame(width: cardsWidth, height: .infinity)
                                .zIndex(currentIndex == i ? 10 : 0)
                                .disabled(currentIndex != i)
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
                
                HStack(spacing: 8) {
                    ForEach(feeds.indices, id: \.self) { index in
                        Circle()
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentIndex == index ? 1.0 : 0.9)
                            .foregroundColor(currentIndex == index ? .white : .gray)
                    }
                }
                .zIndex(-1)
            }
        }
        .background(Color.black)
        .sheet(isPresented: $showSettings) {
            FeedSettingsView()
        }
    }
}

#Preview {
    ContentView()
        .background(Color.black)
}
