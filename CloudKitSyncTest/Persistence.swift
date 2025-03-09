//
//  Persistence.swift
//  CloudKitSyncTest
//
//  Created by Mischa (privat) on 09.03.25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = SimpleItem(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "CloudKitSyncTest")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Use a shared app group allow the app and the widget to access the same on-device store
            let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.CloudKitSyncTestContainer")!
            let storeURL = containerURL.appendingPathComponent("SharedStore.sqlite")
            let description = NSPersistentStoreDescription(url: storeURL)
            container.persistentStoreDescriptions = [description]
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Try to make sure that the notifications are posted whenever the store changes
        let description = container.persistentStoreDescriptions.first
        description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // When uncommenting the following line, no crashes occur, but the app is still not updated after the widget has updated an item's timestamp:
        // container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
}
