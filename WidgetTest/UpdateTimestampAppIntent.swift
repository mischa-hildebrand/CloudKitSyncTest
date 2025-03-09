//
//  UpdateTimestampAppIntent.swift
//  WidgetTest
//
//  Created by Mischa (privat) on 09.03.25.
//

import CoreData
import WidgetKit
import AppIntents

struct UpdateTimestampAppIntent: AppIntent {
    static var title: LocalizedStringResource { "Update Timestamp" }
    static var description: IntentDescription { "Sets the item's timestamp to the current time." }
    
    @Parameter(title: "Item", default: nil)
    var itemEntity: SimpleItemEntity?
    
    var viewContext: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<Date> {
        guard let id = itemEntity?.id,
             let url = URL(string: id),
              let managedObjectID = viewContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url),
              let item = viewContext.object(with: managedObjectID) as? SimpleItem else {
            fatalError("Item not found.")
        }
        let updatedTimestamp = Date()
        item.timestamp = updatedTimestamp
        do {
            try viewContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            let nsError = error as NSError
            fatalError("Saving the view context failed with unresolved error \(nsError), \(nsError.userInfo)")
        }
        return .result(value: updatedTimestamp)
    }
}

extension UpdateTimestampAppIntent {
    init(item: SimpleItem) {
        let itemEntity = SimpleItemEntity(
            id: item.objectID.uriRepresentation().absoluteString,
            timestamp: item.timestamp
        )
        let intent = UpdateTimestampAppIntent()
        intent.itemEntity = itemEntity
        self = intent
    }
}
