//
//  HabitPetApp.swift
//  HabitPet
//
//  Created by m1 on 04/04/2026.
//

import SwiftUI
import CoreData

@main
struct HabitPetApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
