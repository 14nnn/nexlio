//
//  EdgeShadow.swift
//  FlipRSS
//
//  Created by Darian on 14.10.2024..
//

import SwiftUI

struct EdgeShadow: ViewModifier {
    var color: Color = .black.opacity(1.0)
    var radius: CGFloat = 0.0
    var edges: [Edge] = [.top, .leading, .trailing]
    var lineWidth = 1.0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                EdgeShadowShape(edges: edges)
                    .stroke(color, lineWidth: lineWidth)
            )
    }
}

struct EdgeShadowShape: Shape {
    var edges: [Edge] = [.top, .leading, .trailing]
    var cornerRadius: CGFloat = 5.0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let hasTop = edges.contains(.top)
        let hasBottom = edges.contains(.bottom)
        let hasLeading = edges.contains(.leading)
        let hasTrailing = edges.contains(.trailing)

        if hasTop {
            if hasLeading {
                path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
            } else {
                path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            }

            path.addLine(to: CGPoint(x: rect.maxX - (hasTrailing ? cornerRadius : 0), y: rect.minY))

            if hasTrailing {
                path.addArc(
                    center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle.degrees(-90),
                    endAngle: Angle.degrees(0),
                    clockwise: false
                )
            }
        }

        if hasTrailing {
            if hasTop {
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - (hasBottom ? cornerRadius : 0)))
            } else {
                path.move(to: CGPoint(x: rect.maxX, y: rect.minY + (hasTop ? cornerRadius : 0)))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - (hasBottom ? cornerRadius : 0)))
            }

            if hasBottom {
                path.addArc(
                    center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle.degrees(0),
                    endAngle: Angle.degrees(90),
                    clockwise: false
                )
            }
        }

        if hasBottom {
            if hasTrailing {
                path.addLine(to: CGPoint(x: rect.minX + (hasLeading ? cornerRadius : 0), y: rect.maxY))
            } else {
                path.move(to: CGPoint(x: rect.maxX - (hasTrailing ? cornerRadius : 0), y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.minX + (hasLeading ? cornerRadius : 0), y: rect.maxY))
            }

            if hasLeading {
                path.addArc(
                    center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle.degrees(90),
                    endAngle: Angle.degrees(180),
                    clockwise: false
                )
            }
        }

        if hasLeading {
            if hasBottom {
                path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + (hasTop ? cornerRadius : 0)))
            } else {
                path.move(to: CGPoint(x: rect.minX, y: rect.maxY - (hasBottom ? cornerRadius : 0)))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + (hasTop ? cornerRadius : 0)))
            }

            if hasTop {
                path.addArc(
                    center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle.degrees(180),
                    endAngle: Angle.degrees(270),
                    clockwise: false
                )
            }
        }

        return path
    }
}

extension View {
    func edgeShadow(color: Color = .white.opacity(0.5),
                    radius: CGFloat = 1.0,
                    edges: [Edge] = [.top, .leading, .trailing]) -> some View {
        self.modifier(EdgeShadow(color: color, radius: radius, edges: edges))
    }
}
