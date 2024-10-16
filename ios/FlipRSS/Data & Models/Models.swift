//
//  Models.swift
//  FlipRSS
//
//  Created by Darian on 14.10.2024..
//

import Foundation

struct News: Identifiable {
    let id = UUID()
    var title: String
    var details: String
    var imageURL: URL?
    var link: URL?
    
    init(title: String, details: String, imageURL: URL?, link: URL?) {
        self.title = title
        self.details = details
        self.imageURL = imageURL
        self.link = link
    }
}

enum Card {
    case oneAtwoBCard(news: [News])
}

struct Feed: Identifiable {
    let id = UUID()
    let url: URL
    let title: String
    let iconUrl: URL?
}
