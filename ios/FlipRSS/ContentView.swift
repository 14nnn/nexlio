import SwiftUI
import Kingfisher

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
            .onAppear {
                viewModel.fetchRSSFeed(from: feedURL)
            }
    }
}



struct ContentView: View {
    @State private var currentIndex: Int? = 0
    @State private var isDragging: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let padding = 0.0
            let aspectRatioCards = 16.0 / 10.0
            let cardsWidth = geometry.size.width - (padding * 4.0)
            let cardsHeight = cardsWidth * aspectRatioCards
            
            VStack(spacing: 16.0) {
                HStack(spacing: 8.0) {
                    let currentFeed = Data.mockFeeds[currentIndex ?? 0]
                    let icon = currentFeed.iconUrl
                    if (icon != nil) {
                        KFImage(currentFeed.iconUrl)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 24.0, height: 24.0)
                    }
                    
                    Text(currentFeed.title)
                        .frame(width: .infinity)
                        .font(.system(size: 24.0, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
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
                        ForEach(0..<Data.mockFeeds.count, id: \.self) { i in
                            let feed = Data.mockFeeds[i]
                            CardsStackHolderView(feedURL: feed.url)
                                .frame(width: cardsWidth, height: .infinity)
                                .zIndex(currentIndex == i ? 10 : 0)
                                .disabled(currentIndex != i)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollIndicators(.never)
                .scrollClipDisabled()
                .scrollPosition(id: $currentIndex)
                .scrollTargetBehavior(.paging)
                .safeAreaPadding(.zero)
                
                
                HStack(spacing: 8) {
                    ForEach(0..<Data.mockFeeds.count, id: \.self) { index in
                        Circle()
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentIndex == index ? 1.0 : 0.9)
                            .foregroundColor(currentIndex == index ? .white : .gray)
                    }
                }
                .zIndex(-1)
            }
        }.background(Color.black)
    }
}

#Preview {
    ContentView().background(Color.black)
}
