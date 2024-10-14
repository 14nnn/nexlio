//
//  Data.swift
//  FlipRSS
//
//  Created by Darian on 14.10.2024..
//

import Foundation

struct Data {
    static let mockNews: [News] = [
        News(
            title: "Breaking: Lorem Ipsum Dolor Sit Amet",
            details: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla euismod, nisl eget aliquam ultricies, nunc nisl ultricies nunc, vitae aliquam nisl nunc vel nisl. Nulla euismod, nisl eget aliquam ultricies, nunc nisl ultricies nunc, vitae aliquam nisl nunc vel nisl.",
            imageName: "https://picsum.photos/id/237/1200/1800"
        ),
        News(
            title: "Consectetur Adipiscing Elit",
            details: "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
            imageName: "https://picsum.photos/id/238/1200/1800"
        ),
        News(
            title: "Ut Enim Ad Minim Veniam",
            details: "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
            imageName: "https://picsum.photos/id/239/1200/1800"
        ),
        News(
            title: "Duis Aute Irure Dolor",
            details: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.",
            imageName: "https://picsum.photos/id/240/1200/1800"
        ),
        News(
            title: "Nemo Enim Ipsam Voluptatem",
            details: "Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.",
            imageName: "https://picsum.photos/id/241/1200/1800"
        ),
        News(
            title: "Nemo Enim Ipsam Voluptatem",
            details: "Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.",
            imageName: "https://picsum.photos/id/242/1200/1800"
        ),
        News(
            title: "Nemo Enim Ipsam Voluptatem",
            details: "Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.",
            imageName: "https://picsum.photos/id/243/1200/1800"
        ),
        News(
            title: "Nemo Enim Ipsam Voluptatem",
            details: "Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.",
            imageName: "https://picsum.photos/id/244/1200/1800"
        ),
    ]
    
    static let mockCards: [Card] = [
        .oneAtwoBCard(news: [mockNews[0], mockNews[1], mockNews[2]]),
        .oneAtwoBCard(news: [mockNews[3], mockNews[4], mockNews[5]]),
        .oneAtwoBCard(news: [mockNews[0], mockNews[1], mockNews[2]]),
        .oneAtwoBCard(news: [mockNews[3], mockNews[4], mockNews[5]]),
        .oneAtwoBCard(news: [mockNews[0], mockNews[1], mockNews[2]])
    ]
}
