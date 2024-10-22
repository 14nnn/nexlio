//
//  NewsItem.swift
//  FlipRSS
//
//  Created by Darian on 20.10.2024..
//

import CoreData

extension NewsItem {
    convenience init(context: NSManagedObjectContext, news: News, feed: Feed) {
        self.init(context: context)
        self.id = news.id
        self.title = news.title
        self.details = news.details
        self.date = news.date
        self.imageURL = news.imageURL
        self.link = news.link
        self.feed = feed
    }
}
