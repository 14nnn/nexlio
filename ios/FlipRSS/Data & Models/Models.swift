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
    let date: Date?
    
    var imageURL: URL?
    var link: URL?
    
    init(title: String, details: String, date: Date?, imageURL: URL?, link: URL?) {
        self.title = title
        self.details = details
        self.date = date
        self.imageURL = imageURL
        self.link = link
    }
}

enum Card {
    case oneAtwoBCard(news: [News])
    case twoAoneBCard(news: [News])
}
