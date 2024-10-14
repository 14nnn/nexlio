//
//  EdgeShadow.swift
//  FlipRSS
//
//  Created by Darian on 14.10.2024..
//

import SwiftUI

struct EdgeShadow: ViewModifier {
    var color: Color = .black.opacity(1.0)
    var radius: CGFloat = 1.0
    var edges: [Edge] = [.top, .leading, .trailing]
    
    func body(content: Content) -> some View {
        content
            .overlay(
                EdgeShadowShape(edges: edges)
                    .stroke(color, lineWidth: 1.0)
                    .blur(radius: radius)
                    .padding(-radius)
            )
    }
}

struct EdgeShadowShape: Shape {
    var edges: [Edge] = [.top, .leading, .trailing]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        for edge in edges {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var width: CGFloat = rect.width
            var height: CGFloat = rect.height
            
            switch edge {
            case .top:
                height = 0
            case .bottom:
                y = rect.maxY
                height = 0
            case .leading:
                width = 0
            case .trailing:
                x = rect.maxX
                width = 0
            }
            
            path.move(to: CGPoint(x: x, y: y))
            if edge == .top || edge == .bottom {
                path.addLine(to: CGPoint(x: x + rect.width, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y + rect.height))
            }
        }
        
        return path
    }
}

extension View {
    func edgeShadow(color: Color = .black.opacity(1.0), 
                    radius: CGFloat = 1.0,
                    edges: [Edge] = [.top, .leading, .trailing]) -> some View {
        self.modifier(EdgeShadow(color: color, radius: radius, edges: edges))
    }
}
