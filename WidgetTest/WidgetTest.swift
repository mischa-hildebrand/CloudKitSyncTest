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
        Button(intent: UpdateTimestampAppIntent(item: newestItem)) {
            Text("\(newestItem.timestamp!)")
        }
    }
}

struct WidgetTest: Widget {
    let kind: String = "WidgetTest"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetTestEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
}

#Preview(as: .systemSmall) {
    WidgetTest()
} timeline: {
    SimpleEntry(date: .now)
    SimpleEntry(date: .now)
}
