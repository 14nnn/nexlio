//
//  Data.swift
//  FlipRSS
//
//  Created by Darian on 14.10.2024..
//

import Foundation

struct Data {
    static let mockFeeds: [Feed] = [
        .init(url: URL(string: "https://xkcd.com/rss.xml")!, title: "xkcd", iconUrl: URL(string: "https://xkcd.com/favicon.ico")!),
        .init(url: URL(string: "https://feeds.bbci.co.uk/news/world/rss.xml")!, title: "BBC", iconUrl: URL(string: "https://www.bbc.co.uk/favicon.ico")!),
        .init(url: URL(string: "https://www.index.hr/rss")!, title: "Index", iconUrl: URL(string: "https://www.index.hr/favicon.ico")!),
        .init(url: URL(string: "https://www.24sata.hr/feeds/aktualno.xml")!, title: "24sata", iconUrl: URL(string: "https://www.24sata.hr/favicon.ico")!)
    ]
}
