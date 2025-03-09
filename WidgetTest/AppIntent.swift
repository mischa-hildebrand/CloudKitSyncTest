//
//  AppIntent.swift
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


struct SimpleItemEntity: AppEntity {
    var id: String
    var timestamp: Date?
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "SimpleItem"
    var displayRepresentation: DisplayRepresentation {
        guard let timestamp else {
            return .init(stringLiteral: "No timestamp")
        }
        return .init(stringLiteral: "\(timestamp)")
    }
    
    static var defaultQuery = SimpleItemEntityQuery()
}

struct SimpleItemEntityQuery: EntityQuery {
    func suggestedEntities() async throws -> [SimpleItemEntity] {
        let fetchRequest = NSFetchRequest<SimpleItem>(entityName: "SimpleItem")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \SimpleItem.timestamp, ascending: true)]
        do {
            return try PersistenceController.shared.container.viewContext
                .fetch(fetchRequest)
                .map { item in
                        .init(id: item.objectID.uriRepresentation().absoluteString, timestamp: item.timestamp)
                }
        } catch {
            print("Error fetching items:", error)
            return []
        }
    }
    
    func entities(for identifiers: [SimpleItemEntity.ID]) async throws -> [SimpleItemEntity] {
        let fetchRequest = NSFetchRequest<SimpleItem>(entityName: "SimpleItem")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \SimpleItem.timestamp, ascending: true)]
        do {
            return try PersistenceController.shared.container.viewContext
                .fetch(fetchRequest)
                .filter { item in
                    return identifiers.contains(item.objectID.uriRepresentation().absoluteString)
                }
                .map { item in
                        .init(id: item.objectID.uriRepresentation().absoluteString, timestamp: item.timestamp)
                }
        } catch {
            print("Error fetching items for identifiers:", identifiers, error)
            return []
        }
    }
}
