//
//  FeedDataManager.swift
//  FlipRSS
//
//  Created by Darian on 20.10.2024..
//

import SwiftUI
import CoreData

class FeedDataManager: ObservableObject {
    static let shared = FeedDataManager()
    
    private let viewContext = DataController.shared.container.viewContext
    private var refreshTimer: Timer?
    
    private let refreshInterval: TimeInterval = 15 * 60 // 15 minutes
    
    @Published var newsByFeed: [Feed: [News]] = [:]
    @Published var favoritesNews: [News] = []
    
    func fetchNewsForFeed(_ feed: Feed?, forceRefresh: Bool = false) {
        DispatchQueue.main.async {
            if let feed = feed {
                self.newsByFeed[feed] = []
            } else {
                self.favoritesNews = []
            }
        }
        
        if feed != nil && (forceRefresh || shouldRefresh(feed!)) {
            refreshFeed(feed!, completion: {
                self.fetchNewsFromCoreData(for: feed)
            })
        } else {
            var shouldRefresh = false
            if let feed = feed {
                // Check if there's at least one news item for this feed.
                let request: NSFetchRequest<NewsItem> = NewsItem.fetchRequest()
                request.predicate = NSPredicate(format: "feed == %@", feed)
                request.fetchLimit = 1
                
                do {
                    let count = try viewContext.count(for: request)
                    if count == 0 {
                        shouldRefresh = true
                    } else {
                        shouldRefresh = false
                    }
                } catch {
                    print("Error checking for news: \(error)")
                    shouldRefresh = true
                }
            } else {
                // Favorite feed.
                shouldRefresh = true
            }
            
            if shouldRefresh || forceRefresh || feed == nil {
                refreshFeeds(feed, forceRefresh: forceRefresh)
            } else {
                fetchNewsFromCoreData(for: feed)
            }
        }
    }
    
    private func fetchNewsFromCoreData(for feed: Feed?) {
        let request: NSFetchRequest<NewsItem> = NewsItem.fetchRequest()
        
        if let feed = feed {
            // Fetch news for a specific feed
            request.predicate = NSPredicate(format: "feed == %@", feed)
        } else {
            // Fetch news for all favorite feeds
            request.predicate = NSPredicate(format: "feed.isFavorite == %@", NSNumber(value: true))
        }
        
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let newsItems = try viewContext.fetch(request)
            let news = newsItems.map { News(newsItem: $0) }
            
            DispatchQueue.main.async {
                if let feed = feed {
                    self.newsByFeed[feed] = news
                } else {
                    self.favoritesNews = news
                }
            }
        } catch {
            print("Failed to fetch news items: \(error)")
        }
    }
    
    /// Refresh favorite feeds or a specific feed
    private func refreshFeeds(_ feed: Feed? = nil, forceRefresh: Bool = false) {
        let feedsToRefresh: [Feed]
        
        if let feed = feed {
            feedsToRefresh = [feed]
        } else {
            // Fetch all favorite feeds
            let request: NSFetchRequest<Feed> = Feed.fetchRequest()
            request.predicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
            feedsToRefresh = (try? viewContext.fetch(request)) ?? []
        }
        
        let dispatchGroup = DispatchGroup()
        
        for feedToRefresh in feedsToRefresh {
            if forceRefresh || shouldRefresh(feedToRefresh) {
                dispatchGroup.enter()
                refreshFeed(feedToRefresh) {
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.fetchNewsFromCoreData(for: feed)
        }
    }

    /// Check if feed should be refreshed based on lastRefreshDate
    private func shouldRefresh(_ feed: Feed) -> Bool {
        guard let lastRefreshDate = feed.lastRefreshDate else {
            return true
        }
        return Date().timeIntervalSince(lastRefreshDate) > refreshInterval
    }

    /// Refresh feed by fetching from remote, updating Core Data.
    private func refreshFeed(_ feed: Feed, completion: @escaping () -> Void) {
        guard let feedUrl = feed.url else {
            completion()
            return
        }
        
        RSSParser.fetchFeed(with: feedUrl) { [weak self] result in
            guard let self = self else {
                completion()
                return
            }
            
            switch result {
            case .success(let news):
                self.updateNewsInCoreData(news, for: feed)
                feed.lastRefreshDate = Date()
                self.saveContext()
            case .failure(let error):
                print("Failed to refresh feed: \(error)")
            }
            
            completion()
        }
    }
    
    /// Update news in Core Data
    private func updateNewsInCoreData(_ newsItems: [News], for feed: Feed) {
        // Create or update news items based on their links.
        for news in newsItems {
            let fetchRequest: NSFetchRequest<NewsItem> = NewsItem.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "link == %@", (news.link?.absoluteString)!)
            
            do {
                let existingNewsItems = try viewContext.fetch(fetchRequest)
                if let existingNewsItem = existingNewsItems.first {
                    // Update existing news item
                    existingNewsItem.title = news.title
                    existingNewsItem.details = news.details
                    existingNewsItem.date = news.date
                    existingNewsItem.imageURL = news.imageURL
                } else {
                    // Create new news item
                    let newsItem = NewsItem(context: viewContext)
                    newsItem.id = news.id
                    newsItem.title = news.title
                    newsItem.details = news.details
                    newsItem.date = news.date
                    newsItem.imageURL = news.imageURL
                    newsItem.link = news.link
                    newsItem.feed = feed
                }
            } catch {
                print("Failed to fetch existing news item: \(error)")
            }
        }
        
        saveContext()
    }
    
    /// Save Core Data context
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    /// Start periodic refresh timer
    func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.refreshFeeds()
        }
    }
    
    /// Invalidate refresh timer
    func invalidateRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
}
