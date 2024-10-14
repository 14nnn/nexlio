import SwiftUI

struct ContentView: View {
    @State private var currentIndex: Int = 0
    
    var body: some View {
        CardsStackView(cardIndex: currentIndex)
            .onReceive(NotificationCenter.default.publisher(for: .didFlipCardStackView)) { notification in
                if let direction = notification.object as? CardsStackView.FlipDirection {
                    if direction == .forward && currentIndex < Data.mockNews.count - 1 {
                        currentIndex += 1
                    } else if direction == .backward && currentIndex > 0 {
                        currentIndex -= 1
                    }
                }
            }
            .background(Color.black)
        
    }
}

#Preview {
    ContentView().background(Color.black)
}
