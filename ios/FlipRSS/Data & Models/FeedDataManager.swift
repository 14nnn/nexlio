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
    
    func fetchNewsForFeed(_ feed: Feed, forceRefresh: Bool = false) {
        DispatchQueue.main.async {
            self.newsByFeed[feed] = []
        }
        
        if forceRefresh || shouldRefresh(feed) {
            refreshFeed(feed)
        } else {
            // Check if there's at least one news item for this feed.
            let request: NSFetchRequest<NewsItem> = NewsItem.fetchRequest()
            request.predicate = NSPredicate(format: "feed == %@", feed)
            request.fetchLimit = 1
            
            do {
                let count = try viewContext.count(for: request)
                if count == 0 {
                    // No news load them.
                    refreshFeed(feed)
                } else {
                    // News exist, load them from core data.
                    fetchNewsFromCoreData(for: feed)
                }
            } catch {
                print("Error checking for news: \(error)")
                // In error try to refresh.
                refreshFeed(feed)
            }
        }
    }

    private func fetchNewsFromCoreData(for feed: Feed) {
        let request: NSFetchRequest<NewsItem> = NewsItem.fetchRequest()
        request.predicate = NSPredicate(format: "feed == %@", feed)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let newsItems = try viewContext.fetch(request)
            let news = newsItems.map { News(newsItem: $0) }
            DispatchQueue.main.async {
                self.newsByFeed[feed] = news
            }
        } catch {
            print("Failed to fetch news items: \(error)")
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
    private func refreshFeed(_ feed: Feed) {
        guard let feedUrl = feed.url else {
            return
        }
        
        RSSParser.fetchFeed(with: feedUrl) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let news):
                self.updateNewsInCoreData(news, for: feed)
                feed.lastRefreshDate = Date()
                self.saveContext()
                
                DispatchQueue.main.async {
                    self.newsByFeed[feed] = news
                }
            case .failure(let error):
                print("Failed to refresh feed: \(error)")
            }
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
            let fetchRequest: NSFetchRequest<Feed> = Feed.fetchRequest()
            
            do {
                let feeds = try self.viewContext.fetch(fetchRequest)
                for feed in feeds {
                    self.refreshFeed(feed)
                }
            } catch {
                print("Failed to fetch feeds: \(error)")
            }
        }
    }
    
    /// Invalidate refresh timer
    func invalidateRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
}
