//
//  News.swift
//  FlipRSS
//
//  Created by Darian on 22.10.2024..
//

import Foundation

struct News: Identifiable {
    let id: UUID?
    var title: String
    var details: String
    let date: Date?
    
    var imageURL: URL?
    var link: URL?
    
    init(title: String, details: String, date: Date?, imageURL: URL?, link: URL?) {
        self.id = UUID()
        self.title = title
        self.details = details
        self.date = date
        self.imageURL = imageURL
        self.link = link
    }
    
    init(newsItem: NewsItem) {
        self.id = newsItem.id!
        self.title = newsItem.title ?? ""
        self.details = newsItem.details ?? ""
        self.date = newsItem.date
        self.imageURL = newsItem.imageURL
        self.link = newsItem.link
    }
}
