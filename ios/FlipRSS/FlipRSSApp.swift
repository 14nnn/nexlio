//
//  FlipRSSApp.swift
//  FlipRSS
//
//  Created by Darian on 13.10.2024..
//

import SwiftUI



@main
struct FlipRSSApp: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .background(Color.black)
        }
    }
}
