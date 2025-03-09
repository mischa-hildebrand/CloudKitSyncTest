//
//  SimpleItemEntity.swift
//  CloudKitSyncTest
//
//  Created by Mischa (privat) on 09.03.25.
//

import CoreData
import WidgetKit
import SwiftUI
import AppIntents

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
