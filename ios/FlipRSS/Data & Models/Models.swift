//
//  Models.swift
//  FlipRSS
//
//  Created by Darian on 14.10.2024..
//

import Foundation

struct News: Identifiable {
    let id = UUID()
    let title: String
    var details: String
    let imageName: String
}

enum Card {
    case oneAtwoBCard(news: [News])
}
