//
//  FeedSettingsView.swift
//  FlipRSS
//
//  Created by Darian on 17.10.2024..
//

import SwiftUI
import Kingfisher

struct FeedSettingsView: View {
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
    @State private var newFeedImageURL: URL? = nil
    
    var body: some View {
        NavigationView {
            List {
                ForEach(feeds) { feed in
                    FeedRow(feed: feed, onEdit: {
                        selectedFeed = feed
                        newFeedName = feed.name ?? ""
                        newFeedURL = feed.url?.absoluteString ?? ""
                        isEditingFeed = true
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
                AddFeedView(isPresented: $isAddingFeed,
                            feedName: $newFeedName,
                            feedURL: $newFeedURL,
                            feedIconURL: $newFeedImageURL,
                            feedCount: feedCount,
                            onSave: saveNewFeed,
                            isAdding: true)
                .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $isEditingFeed) {
                AddFeedView(isPresented: $isEditingFeed,
                            feedName: $newFeedName,
                            feedURL: $newFeedURL,
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
        newFeed.sortOrder = Int16(feedCount)
        saveContext()
    }
    
    private func saveEditedFeed() {
        if let feed = selectedFeed {
            feed.name = newFeedName
            feed.url = URL(string: newFeedURL)
            feed.iconImage = newFeedImageURL?.absoluteString
            saveContext()
        }
    }
}

struct FeedRow: View {
    @ObservedObject var feed: Feed
    var onEdit: () -> Void
    
    var body: some View {
        HStack {
            if let iconImage = feed.iconImage,
               let iconImageURL = URL(string: iconImage) {
                KFImage(iconImageURL)
                    .placeholder {
                        ProgressView()
                    }
                    .loadDiskFileSynchronously()
                    .cacheMemoryOnly()
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24.0, height: 24.0)
            }
            
            Text(feed.name ?? "Unnamed Feed")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
    }
}

struct AddFeedView: View {
    @Binding var isPresented: Bool
    @Binding var feedName: String
    @Binding var feedURL: String
    @Binding var feedIconURL: URL?
    
    @Environment(\.managedObjectContext) private var viewContext
    var feedCount: Int
    var onSave: () -> Void
    
    @State private var isLoading = false
    @State private var showError = false
    
    let isAdding: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $feedName)
                        .disabled(isLoading)
                    TextField("URL", text: $feedURL)
                        .disabled(isLoading)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textContentType(.URL)
                        .textInputAutocapitalization(.never)
                }
                
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(.circular)
                        Spacer()
                    }
                }
                
                Section {
                    Button("Save") {
                        if isValidInput() {
                            validateNewFeed()
                        } else {
                            showError = true
                        }
                    }
                    .centerHorizontally()
                    .disabled(isLoading)
                    .alert(isPresented: $showError) {
                        Alert(title: Text("Invalid Input"),
                              message: Text("Please enter a valid name and a valid feed URL."),
                              dismissButton: .default(Text("OK")))
                    }
                }
            }
            .navigationTitle(isAdding ? "New Feed" : "Edit Feed")
        }
    }
    
    private func validateNewFeed() {
        guard let url = URL(string: feedURL) else {
            showError = true
            return
        }
        
        isLoading = true
        RSSParser.fetchFeedDetails(from: url) { result in
            self.isLoading = false
            
            switch result {
            case .success(let iconImageURL):
                self.feedIconURL = iconImageURL
                self.onSave()
                isPresented = false
            case .failure(let error):
                print("Error fetching feed details: \(error.localizedDescription)")
                self.showError = true
            }
        }
    }
    
    private func isValidInput() -> Bool {
        guard !feedName.isEmpty else { return false }
        
        // Use data detector since it already covers all the URL cases.
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
            let matches = detector.matches(in: feedURL, options: [], range: NSRange(location: 0, length: feedURL.utf16.count))
            
            if let match = matches.first, match.range.length == feedURL.utf16.count {
                return true
            }
        }
        
        return false
    }
}
