//
//  ContentView.swift
//  CloudKitSyncTest
//
//  Created by Mischa (privat) on 09.03.25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewContextObserver = ViewContextObserver()

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SimpleItem.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<SimpleItem>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Button(intent: UpdateTimestampAppIntent(item: item)) {
                            Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                        }
                        .buttonStyle(.bordered)
                    } label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
        .onAppear {
            // Just making sure the observer is active --> probably not needed
            _ = viewContextObserver
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = SimpleItem(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
