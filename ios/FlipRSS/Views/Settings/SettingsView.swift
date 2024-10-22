//
//  SettingsView.swift
//  FlipRSS
//
//  Created by Darian on 17.10.2024..
//

import SwiftUI
import Kingfisher

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Feed.sortOrder, ascending: true)],
        animation: .default)
    private var feeds: FetchedResults<Feed>
    
    var feedCount: Int {
        feeds.count
    }
    
    @State private var isAddingFeed = false
    @State private var isEditingFeed = false
    
    @State private var selectedFeed: Feed? = nil
    
    @State private var newFeedURL = ""
    @State private var newFeedName = ""
    @State private var newFeedDescription: String? = ""
    @State private var newFeedImageURL: URL? = nil
    
    var body: some View {
        NavigationView {
            List {
                ForEach(feeds) { feed in
                    SettingsFeedRowView(feed: feed, onEdit: {
                        selectedFeed = feed
                        newFeedName = feed.name ?? ""
                        newFeedURL = feed.url?.absoluteString ?? ""
                        isEditingFeed = true
                    }, onToggleFavorite: {
                        toggleFavorite(for: feed)
                    })
                }
                .onDelete(perform: deleteFeeds)
                .onMove(perform: moveFeeds)
            }
            .listStyle(.plain)
            .navigationTitle("Feeds")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        newFeedName = ""
                        newFeedURL = ""
                        newFeedImageURL = nil
                        isAddingFeed = true
                    } label: {
                        Label("Add Feed", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingFeed) {
                SettingsEditFeedView(isPresented: $isAddingFeed,
                                     feedName: $newFeedName,
                                     feedURL: $newFeedURL,
                                     feedDescription: $newFeedDescription,
                                     feedIconURL: $newFeedImageURL,
                                     feedCount: feedCount,
                                     onSave: saveNewFeed,
                                     isAdding: true)
                .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $isEditingFeed) {
                SettingsEditFeedView(isPresented: $isEditingFeed,
                                     feedName: $newFeedName,
                                     feedURL: $newFeedURL,
                                     feedDescription: $newFeedDescription,
                                     feedIconURL: $newFeedImageURL,
                                     feedCount: feedCount,
                                     onSave: saveEditedFeed,
                                     isAdding: false)
                .environment(\.managedObjectContext, viewContext)
            }
        }
    }
    
    private func deleteFeeds(offsets: IndexSet) {
        withAnimation {
            offsets.map { feeds[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }
    
    private func moveFeeds(from source: IndexSet, to destination: Int) {
        var revisedFeeds: [Feed] = feeds.map { $0 }
        revisedFeeds.move(fromOffsets: source, toOffset: destination)
        
        for reverseIndex in stride(from: feeds.count - 1, through: 0, by: -1) {
            revisedFeeds[reverseIndex].sortOrder = Int16(reverseIndex)
        }
        
        saveContext()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
            NotificationCenter.default.post(name: .refreshFeeds, object: nil)
        } catch {
            let error = error as NSError
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    private func saveNewFeed() {
        let newFeed = Feed(context: viewContext)
        newFeed.id = UUID()
        newFeed.name = newFeedName
        newFeed.url = URL(string: newFeedURL)
        newFeed.iconImage = newFeedImageURL?.absoluteString
        newFeed.feedDescription = newFeedDescription
        newFeed.sortOrder = Int16(feedCount)
        saveContext()
    }
    
    private func saveEditedFeed() {
        if let feed = selectedFeed {
            feed.name = newFeedName
            feed.url = URL(string: newFeedURL)
            feed.iconImage = newFeedImageURL?.absoluteString
            feed.feedDescription = newFeedDescription
            saveContext()
        }
    }
    
    private func toggleFavorite(for feed: Feed) {
        feed.isFavorite.toggle()
        saveContext()
        NotificationCenter.default.post(name: .refreshFeeds, object: nil)
    }
}



