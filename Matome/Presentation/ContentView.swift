//
//  ContentView.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/18.
//

import SwiftUI
import SwiftData

struct ContentView: View {
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
}

#Preview {
    ContentView()
}
