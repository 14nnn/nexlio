//
//  SettingsEditFeedView.swift
//  FlipRSS
//
//  Created by Darian on 22.10.2024..
//

import SwiftUI
import Kingfisher

struct SettingsEditFeedView: View {
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
        FeedParser.fetchFeedDetails(from: url) { result in
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
