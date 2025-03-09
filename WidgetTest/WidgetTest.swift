//
//  WidgetTest.swift
//  WidgetTest
//
//  Created by Mischa (privat) on 09.03.25.
//

import CoreData
import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        .init(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping @Sendable (SimpleEntry) -> Void) {
        completion(.init(date: Date()))
    }
    
    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<SimpleEntry>) -> Void) {
        completion(Timeline(entries: [.init(date: Date())], policy: .atEnd))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct WidgetTestEntryView : View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \SimpleItem.timestamp, ascending: false)], animation: .default)
    private var items: FetchedResults<SimpleItem>
    
    private var newestItem: SimpleItem {
        guard let first = items.first else {
            fatalError("Empty items array. --> No items were fetched from the Core Data store.")
        }
        return first
    }

    var entry: Provider.Entry

    var body: some View {
        // When this button is tapped, the timestamp for this item should be updated:
        // 1. on the widget
        // 2. everywhere in the app where it's displayed as soon as the user brings the app to the foreground
        // 3. it the app and the widgets on other devices with the same logged-in iCloud user
        Button(intent: UpdateTimestampAppIntent(item: newestItem)) {
            Text("\(newestItem.timestamp!)")
        }
    }
}

struct WidgetTest: Widget {
    let kind: String = "WidgetTest"
    let isPreview: Bool
    
    init(isPreview: Bool) {
        self.isPreview = isPreview
    }
    
    init() {
        self.init(isPreview: false)
    }
    
    var viewContext: NSManagedObjectContext {
        if isPreview {
            PersistenceController.preview.container.viewContext
        } else {
            PersistenceController.shared.container.viewContext
        }
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetTestEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .environment(\.managedObjectContext, viewContext)
        }
    }
}

#Preview(as: .systemMedium) {
    WidgetTest(isPreview: true)
} timeline: {
    SimpleEntry(date: .now)
}
