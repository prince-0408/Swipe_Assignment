//
//  Swipe_AssignmentApp.swift
//  Swipe_Assignment
//
//  Created by Prince Yadav on 31/01/25.
//

import SwiftUI

@main
struct Swipe_AssignmentApp: App {
    let persistenceController = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ProductListView()
                .environment(\.managedObjectContext, persistenceController.persistentContainer.viewContext)
                .onAppear {
                    // Initialize Core Data stack
                    _ = persistenceController.persistentContainer
                }
        }
    }
}
