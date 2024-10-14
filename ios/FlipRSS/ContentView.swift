import SwiftUI

struct CardsStackHolderView: View {
    @State private var currentIndex: Int = 0
    let id = UUID()
    
    var body: some View {
        CardsStackView(id: id, cardIndex: currentIndex)
            .onReceive(NotificationCenter.default.publisher(for: .didFlipCardStackView)) { notification in
                if let object = notification.object as? CardsStackView.NotificationObject, object.id == id {
                    if object.direction == .forward && currentIndex < Data.mockNews.count - 1 {
                        currentIndex += 1
                    } else if object.direction == .backward && currentIndex > 0 {
                        currentIndex -= 1
                    }
                }
            }
            .background(Color.black)
    }
}

struct ContentView: View {
    @State private var currentIndex: Int? = 0
    
    var body: some View {
        GeometryReader { geometry in
            let padding = 10.0
            let aspectRatioCards = 6.0 / 3.0
            let cardsWidth = geometry.size.width - (padding * 4.0)
            let cardsHeight = cardsWidth * aspectRatioCards
            
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(0..<Data.mockCards.count, id: \.self) { i in
                        CardsStackHolderView()
                            .opacity(currentIndex == i ? 1 : 0.8)
                            .frame(width: cardsWidth,
                                   height: cardsHeight)
                            .zIndex(currentIndex == i ? 10 : 0)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $currentIndex)
            .scrollTargetBehavior(.viewAligned)
            .safeAreaPadding(.horizontal, padding * 2.0)
            
        }
    }
}

#Preview {
    ContentView().background(Color.black)
}
