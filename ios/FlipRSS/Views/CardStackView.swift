//
//  CardStackView.swift
//  FlipRSS
//
//  Created by Darian on 14.10.2024..
//

import SwiftUI


/**
 Holds a stack of card views enabling the user to flip through it.
 */
struct CardsStackView: View {
    static let horizontalPadding = 10.0
    
    /// This is the minimal drag required to flip to the previous / next page.
    static let minimalDrag = 50.0
    
    /// This is the duration of the flip animation.
    static let flipAnimationDuration = 0.3
    
    /// Perspective used to rotate around the cards.
    static let cardRotationPerspective = 0.6
    
    struct AnimationValues {
        /// Rotation of the actual card segment in degrees.
        var rotation = 0.0
    }
    
    /// Holds the flip direction.
    enum FlipDirection {
        case forward
        case backward
    }
    
    struct NotificationObject {
        let id: UUID
        let direction: FlipDirection
    }
    
    let id: UUID
    
    /// Index of the current card.
    var cardIndex: Int
    
    /// Cards.
    var cards: [Card] = []
    
    /// On refresh handler.
    let onRefresh: (() -> Void)?
    
    /// Holds the current card rotation angle.
    @State private var cardRotationAngle = 0.0
    
    /// Is set when dragging backwards. This is used to know if the top or bottom card segment is animated.
    @State private var isDraggingBackwards = false
    
    /// Is set when the drag gesture is used.
    @State private var isDragging = false
    
    /// Starts an animation using keyframe animator. It also changes if the cardRotationAngle is used or the KeyframeAnimatior angle.
    @State private var isAnimating = false
    
    /// Should animate reset of a position of a scroll. Used at first / last page or when not scrolled enough.
    @State private var shouldAnimateResetPosition = false
    
    @State private var isRefreshing = false
    
    var body: some View {
        Group {
            if self.cards.isEmpty {
                // Loading screen.
                ZStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }.background(Color.black)
            } else {
                GeometryReader { geometry in
                    ZStack {
                        Color.black
                        
                        let currentCard = self.cards[cardIndex]
                        let nextIndex = min(cardIndex + 1, self.cards.count - 1)
                        let prevIndex = max(cardIndex - 1, 0)
                        let nextCard = self.cards[nextIndex]
                        let prevCard = self.cards[prevIndex]
                        
                        KeyframeAnimator(initialValue: AnimationValues(), trigger: isAnimating) { content in
                            // Shorthard.
                            let isDraggingForwards = !isDraggingBackwards
                            
                            // If it's animating use the animation value of the KeyframeAnimator, if not then use the cardRotationAngle. I also check if the animation value is NaN which it can be in some cases such as an animation start.
                            let usedRotationAngle = (isAnimating && !content.rotation.isNaN) ? content.rotation : cardRotationAngle
                            let limitedRotationAngle = max(min(usedRotationAngle, .angles180), -.angles180)
                            
                            // It's very important I can check if the card has been flipped past the mid. point since it's a diffrent card (backside) after that point.
                            let hasFlippedPastMid = abs(limitedRotationAngle) > .angles90
                            
                            // Regarding the cards, we have duplicated the same view twice since in SwiftUI it's a bit harder to animate than in UIKit. The upper half is the full CardsStackView height but cut at half, while the lower half is the CardsStackView height as well but offsetted by half.
                            
                            // Width of the cards = Full width of the component minus the padding.
                            let cardsWidth = geometry.size.width - (CardsStackView.horizontalPadding * 2.0)
                            let halfCardHeight = geometry.size.height / 2.0
                            
                            // Upper Half
                            VStack(spacing: 0.0) {
                                ZStack {
                                    // Back Face of Upper Half
                                    // This is seen behind the flipped card segment.
                                    if !isDraggingBackwards && cardIndex > 0 {
                                        VStack(spacing: 0.0) {
                                            CardView(card: prevCard,
                                                     roundedCorners: [.topLeft, .topRight],
                                                     drawnBorderEdges: [.top, .leading, .trailing])
                                            .frame(width: cardsWidth,
                                                   height: geometry.size.height)
                                            .offset(y: halfCardHeight / 2.0)
                                        }
                                        .frame(width: cardsWidth,
                                               height: halfCardHeight)
                                        .clipped()
                                        .rotation3DEffect(
                                            Angle(degrees: 0),
                                            axis: (x: 1.0, y: 0.0, z: 0.0),
                                            anchor: .bottom,
                                            perspective: CardsStackView.cardRotationPerspective
                                        )
                                    }
                                    
                                    // Front Face of Upper Half
                                    VStack(spacing: 0.0) {
                                        CardView(card: (isDraggingForwards && hasFlippedPastMid) ? prevCard : currentCard,
                                                 roundedCorners: [.topLeft, .topRight],
                                                 drawnBorderEdges: [.top, .leading, .trailing],
                                                 isFlipped: isDraggingForwards && hasFlippedPastMid)
                                        .frame(width: cardsWidth,
                                               height: geometry.size.height)
                                        .offset(y: halfCardHeight / 2.0)
                                        
                                    }
                                    .frame(width: cardsWidth,
                                           height: halfCardHeight)
                                    .clipped()
                                    .rotation3DEffect(
                                        Angle(degrees: !isDraggingBackwards ? usedRotationAngle : 0),
                                        axis: (x: 1.0, y: 0.0, z: 0.0),
                                        anchor: .bottom,
                                        perspective: CardsStackView.cardRotationPerspective
                                    )
                                }
                                Spacer(minLength: 0)
                            }
                            .zIndex(isDragging && !isDraggingBackwards ? 1 : 0)
                            
                            // Lower Half
                            VStack(spacing: 0.0) {
                                ZStack {
                                    // Back Face of Lower Half
                                    // This is seen behind the flipped card segment.
                                    if isDraggingBackwards && cardIndex < self.cards.count - 1 {
                                        VStack(spacing: 0.0) {
                                            CardView(card: nextCard,
                                                     roundedCorners: [.bottomLeft, .bottomRight],
                                                     drawnBorderEdges: [.bottom, .leading, .trailing])
                                            .frame(width: cardsWidth,
                                                   height: geometry.size.height)
                                            .offset(y: -halfCardHeight / 2.0)
                                        }
                                        .frame(width: cardsWidth,
                                               height: halfCardHeight)
                                        .clipped()
                                        .rotation3DEffect(
                                            Angle(degrees: 0),
                                            axis: (x: 1.0, y: 0.0, z: 0.0),
                                            anchor: .top,
                                            perspective: CardsStackView.cardRotationPerspective
                                        )
                                    }
                                    
                                    // Front Face of Lower Half
                                    VStack(spacing: 0.0) {
                                        CardView(card: (isDraggingBackwards && hasFlippedPastMid) ? nextCard : currentCard,
                                                 roundedCorners: [.bottomLeft, .bottomRight],
                                                 drawnBorderEdges: [.bottom, .leading, .trailing],
                                                 isFlipped: isDraggingBackwards && hasFlippedPastMid)
                                        .frame(width: cardsWidth,
                                               height: geometry.size.height)
                                        .offset(y: -halfCardHeight / 2.0)
                                    }
                                    .frame(width: cardsWidth,
                                           height: halfCardHeight)
                                    .clipped()
                                    .rotation3DEffect(
                                        Angle(degrees: isDraggingBackwards ? usedRotationAngle : 0),
                                        axis: (x: 1.0, y: 0.0, z: 0.0),
                                        anchor: .top,
                                        perspective: CardsStackView.cardRotationPerspective
                                    )
                                }
                            }
                            .zIndex(isDragging && isDraggingBackwards ? 1 : 0)
                        } keyframes: { _ in
                            KeyframeTrack(\.rotation) {
                                if isDraggingBackwards {
                                    LinearKeyframe(cardRotationAngle, duration: .zero)
                                    LinearKeyframe(!shouldAnimateResetPosition ? .angles180 : 0.0,
                                                   duration: CardsStackView.flipAnimationDuration)
                                } else {
                                    LinearKeyframe(cardRotationAngle, duration: .zero)
                                    LinearKeyframe(!shouldAnimateResetPosition ? -.angles180 : 0.0,
                                                   duration: CardsStackView.flipAnimationDuration)
                                }
                            }
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let dragOffset = value.translation.height
                                cardRotationAngle = Double(-dragOffset / geometry.size.height * .angles180)
                                isDraggingBackwards = dragOffset < 0
                                isDragging = true
                                
                                if cardIndex == 0 && dragOffset > 0 {
                                    if dragOffset > CardsStackView.minimalDrag && !isRefreshing {
                                        let impact = UIImpactFeedbackGenerator(style: .medium)
                                        impact.impactOccurred()
                                        isRefreshing = true
                                    }
                                }
                            }
                            .onEnded { value in
                                let dragOffset = value.translation.height
                                
                                let didMinimalDragForward = dragOffset < -CardsStackView.minimalDrag
                                let didMinimalDragBackward = dragOffset > CardsStackView.minimalDrag
                                let hasNextCard = cardIndex < self.cards.count - 1
                                let hasPrevCard = cardIndex > 0
                                
                                isRefreshing = false
                                
                                // Stop the drag since there's nothing previous / next.
                                if !((didMinimalDragForward && hasNextCard) || (didMinimalDragBackward && hasPrevCard)) {
                                    shouldAnimateResetPosition = true
                                    isAnimating = true
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + CardsStackView.flipAnimationDuration) {
                                        cardRotationAngle = 0.0
                                        isAnimating = false
                                        isDragging = false
                                        shouldAnimateResetPosition = false
                                    }
                                    
                                    if cardIndex == 0 && dragOffset > CardsStackView.minimalDrag {
                                        onRefresh?()
                                    }
                                    
                                    return
                                }
                                
                                isAnimating = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + CardsStackView.flipAnimationDuration) {
                                    if didMinimalDragForward {
                                        NotificationCenter.default.post(name: .didFlipCardStackView,
                                                                        object: NotificationObject(id: self.id, direction: FlipDirection.forward))
                                    } else if didMinimalDragBackward {
                                        NotificationCenter.default.post(name: .didFlipCardStackView,
                                                                        object: NotificationObject(id: self.id, direction: FlipDirection.backward))
                                    }
                                    
                                    cardRotationAngle = 0
                                    isAnimating = false
                                    isDragging = false
                                }
                            }
                    )
                }
            }
        }
    }
}
