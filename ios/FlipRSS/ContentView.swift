import SwiftUI
import Kingfisher
import CoreData

struct CardsStackHolderView: View {
    @StateObject private var viewModel = RSSFeedViewModel()
    @State private var currentIndex: Int = 0
    
    let id = UUID()
    let feedURL: URL
    
    var body: some View {
        CardsStackView(id: id, cardIndex: currentIndex, cards: viewModel.cards)
            .onReceive(NotificationCenter.default.publisher(for: .didFlipCardStackView)) { notification in
                if let object = notification.object as? CardsStackView.NotificationObject, object.id == id {
                    if object.direction == .forward && currentIndex < viewModel.cards.count - 1 {
                        currentIndex += 1
                    } else if object.direction == .backward && currentIndex > 0 {
                        currentIndex -= 1
                    }
                }
            }
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
                viewModel.fetchRSSFeed(from: feedURL)
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
                HStack(spacing: 8.0) {
                    let currentFeed = feeds.isEmpty ? nil : feeds[currentIndex ?? 0]
                    //if let icon = currentFeed.iconImage {
                    //    Image(uiImage: icon)
                    //        .resizable()
                    //        .scaledToFill()
                    //        .frame(width: 24.0, height: 24.0)
                    //}
                    
                    Text(currentFeed?.name ?? "Unnamed Feed")
                        .frame(width: .infinity)
                        .font(.system(size: 24.0, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 24.0))
                            .foregroundColor(Color("TopBarColors"))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10.0)
                
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0.0) {
                        ForEach(feeds.indices, id: \.self) { i in
                            let feed = feeds[i]
                            CardsStackHolderView(feedURL: feed.url!)
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
