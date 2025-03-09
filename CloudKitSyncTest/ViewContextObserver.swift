//
//  ViewContextObserver.swift
//  CloudKitSyncTest
//
//  Created by Mischa (privat) on 09.03.25.
//

import Foundation

/// This class is my attempt to get the ContentView to refresh when the interactive widget has updated an item. Unfortunatly, it doesn't work.
class ViewContextObserver: ObservableObject {
    
    let dataContainer = PersistenceController.shared.container
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleChange), name: .NSPersistentStoreRemoteChange, object: dataContainer.persistentStoreCoordinator)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleChange), name: .NSPersistentStoreCoordinatorStoresDidChange, object: dataContainer.persistentStoreCoordinator)
    }
    
    @objc private func handleChange(_ notification: Notification) {
        DispatchQueue.main.async {
            self.dataContainer.viewContext.refreshAllObjects()
            self.objectWillChange.send()
        }
    }
}
