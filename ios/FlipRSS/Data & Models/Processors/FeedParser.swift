//
//  FeedParser.swift
//  FlipRSS
//
//  Created by Darian on 15.10.2024..
//

import SwiftUI
import FeedKit

/// Parser for RSS feeds.
class FeedParser {
    typealias FeedParsingResult = ([News], FeedInfo?)
    
    /// Struct containing feed info.
    struct FeedInfo {
        /// Icon for feed. In RSS, feed image is used, in atom icon is used, in JSON icon is used as well.
        let favIcon: URL?
        
        let description: String?
    }
    
    /// Fetch and parse a feed based on the URL.
    static func fetchFeed(with url: URL, completion: @escaping (Result<[News], Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "RSSParserError",
                                            code: 0,
                                            userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            let parser = FeedParser()
            let result = parser.parse(data: data)
            
            switch result {
            case .success(let feed):
                completion(.success(feed.0))
            case .failure(let error):
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Parse RSS, atom or JSON and return a list of News and feed info..
    func parse(data: Foundation.Data) -> Result<FeedParsingResult, Error> {
        let parser = FeedKit.FeedParser(data: data)
        let result = parser.parse()
        
        switch result {
        case .success(let feed):
            var feedInfo: FeedInfo? = nil
            
            switch feed {
            case .rss(let rssFeed):
                let feedDescription = rssFeed.description
                if let feedImage = rssFeed.image?.link, let parsedFeedImage = URL(string: feedImage) {
                    feedInfo = FeedInfo(favIcon: parsedFeedImage, description: feedDescription)
                }
                
                return .success((parseRSSFeed(rssFeed), feedInfo))
            case .atom(let atomFeed):
                let feedDescription = atomFeed.title
                if let feedImage = atomFeed.icon, let parsedFeedImage = URL(string: feedImage) {
                    feedInfo = FeedInfo(favIcon: parsedFeedImage, description: feedDescription)
                }
                
                return .success((parseAtomFeed(atomFeed), nil))
            case .json(let jsonFeed):
                let feedDescription = jsonFeed.description
                if let feedImage = jsonFeed.icon, let parsedFeedImage = URL(string: feedImage) {
                    feedInfo = FeedInfo(favIcon: parsedFeedImage, description: feedDescription)
                }
                
                return .success((parseJSONFeed(jsonFeed), nil))
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// This will fetch the feed details. Used to get the feed info such as description and feed icon. This is also a validation step.
    static func fetchFeedDetails(from url: URL, completion: @escaping (Result<(URL?), Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "FeedDetailsError",
                                            code: 0,
                                            userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            let parser = FeedParser()
            guard case let .success(feed) = parser.parse(data: data) else {
                completion(.failure(NSError(domain: "FeedDetailsError",
                                            code: 0,
                                            userInfo: [NSLocalizedDescriptionKey: "Feed parsing failed"])))
                return
            }
            
            var iconImageURL: URL?
            
            if let imageURL = feed.1?.favIcon {
                iconImageURL = imageURL
                completion(.success(iconImageURL))
            } else {
                // Fallback to favicon.ico.
                let rootDomain = (url.scheme ?? "https") + "://" + url.host!
                iconImageURL = URL(string: rootDomain)!.appendingPathComponent("favicon.ico")
                completion(.success(iconImageURL))
            }
        }.resume()
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
                date: item.pubDate,
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
                date: entry.published ?? entry.updated,
                imageURL: imageUrl,
                link: entry.links?.first?.attributes?.href.flatMap { URL(string: $0) }
            )
        } ?? []
    }
    
    private func parseJSONFeed(_ feed: JSONFeed) -> [News] {
        return feed.items?.compactMap { item in
            News(
                title: item.title ?? "",
                details: item.contentText ?? item.summary ?? "",
                date: item.datePublished,
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
