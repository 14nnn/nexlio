//
//  FlipRSSApp.swift
//  FlipRSS
//
//  Created by Darian on 13.10.2024..
//

import SwiftUI

@main
struct FlipRSSApp: App {
    @StateObject private var dataController = DataController.shared
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .background(Color.black)
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                FeedDataManager.shared.startRefreshTimer()
            case .background, .inactive:
                FeedDataManager.shared.invalidateRefreshTimer()
            @unknown default:
                break
            }
        }
    }
}
