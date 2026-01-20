//
//  ContentView.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/18.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        TabView {
            SourceView()
                .tabItem {
                    Image(systemName: "arrow.2.circlepath.circle")
                    Text("Source")
                }
            LogView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Log")
                }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
