//
//  RSSParser.swift
//  FlipRSS
//
//  Created by Darian on 15.10.2024..
//

import SwiftUI
import FeedKit

/// Parser for RSS feeds.
class RSSParser {
    /// Parse RSS, atom or JSON and return a list of News.
    func parse(data: Foundation.Data) -> [News] {
        let parser = FeedParser(data: data)
        let result = parser.parse()
        
        switch result {
        case .success(let feed):
            switch feed {
            case .rss(let rssFeed):
                return parseRSSFeed(rssFeed)
            case .atom(let atomFeed):
                return parseAtomFeed(atomFeed)
            case .json(let jsonFeed):
                return parseJSONFeed(jsonFeed)
            }
        case .failure(let error):
            print("Parsing error: \(error)")
            return []
        }
    }
    
    /// Parse RSS feed with *magic* logic for handling all kinds of RSS.
    private func parseRSSFeed(_ feed: RSSFeed) -> [News] {
        return feed.items?.compactMap { item in
            // Attempt to get image URL from enclosure, media thumbnails or media contents.
            var imageUrl = item.enclosure?.attributes?.url.flatMap { URL(string: $0) }
            ?? item.media?.mediaContents?.first?.attributes?.url.flatMap { URL(string: $0) }
            ?? item.media?.mediaThumbnails?.first?.attributes?.url.flatMap { URL(string: $0) }
            
            // Attempt to parse <img> src from content if other methods fail
            if (imageUrl == nil), let rawContent = item.rawElements?["content"] {
                imageUrl = extractImageURL(from: rawContent)
            }
            
            // Attempt to parse <img> src from description if other methods fail
            if (imageUrl == nil), let rawContent = item.rawElements?["description"] {
                imageUrl = extractImageURL(from: rawContent)
            }
            
            // Strip HTML from the description or content before assigning to News.details
            let cleanDetails = item.description?.strippingHTML() ?? ""
            
            return News(
                title: item.title ?? "",
                details: cleanDetails,
                imageURL: imageUrl,
                link: item.link.flatMap { URL(string: $0) }
            )
        } ?? []
    }
    
    private func parseAtomFeed(_ feed: AtomFeed) -> [News] {
        return feed.entries?.compactMap { entry in
            // Attempt to get image URL from enclosure, media thumbnails or media contents.
            let imageUrl = entry.media?.mediaContents?.first?.attributes?.url.flatMap { URL(string: $0) }
            ?? entry.media?.mediaThumbnails?.first?.attributes?.url.flatMap { URL(string: $0) }
            
            return News(
                title: entry.title ?? "",
                details: entry.summary?.value ?? "",
                imageURL: imageUrl,
                link: entry.links?.first { $0.attributes?.rel == "alternate" }?.attributes?.href.flatMap { URL(string: $0) }
            )
        } ?? []
    }
    
    private func parseJSONFeed(_ feed: JSONFeed) -> [News] {
        return feed.items?.compactMap { item in
            News(
                title: item.title ?? "",
                details: item.contentText ?? item.summary ?? "",
                imageURL: item.image.flatMap { URL(string: $0) },
                link: item.url.flatMap { URL(string: $0) }
            )
        } ?? []
    }
    
    /// Used to extract img src from CDATA or content. This is important for feeds that don't follow the standard with image.
    private func extractImageURL(from content: String) -> URL? {
        let pattern = "<img[^>]+src=\"([^\"]+)\""
        if let regex = try? NSRegularExpression(pattern: pattern, options: []),
           let match = regex.firstMatch(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count)),
           let range = Range(match.range(at: 1), in: content) {
            let imageURLString = String(content[range])
            return URL(string: imageURLString)
        }
        return nil
    }
}
