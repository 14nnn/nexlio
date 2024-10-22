//
//  DataController.swift
//  FlipRSS
//
//  Created by Darian on 16.10.2024..
//

import Foundation
import CoreData

class DataController: ObservableObject {
    static let shared = DataController()
    
    let container = NSPersistentContainer(name: "FlipRSS")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
            
            // Print Core Data database path
            if let storeUrl = description.url {
                print("Core Data DB Path: \(storeUrl.path)")
            }
        }
    }
}
