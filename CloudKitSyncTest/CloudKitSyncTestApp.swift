//
//  CloudKitSyncTestApp.swift
//  CloudKitSyncTest
//
//  Created by Mischa (privat) on 09.03.25.
//

import SwiftUI

@main
struct CloudKitSyncTestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
