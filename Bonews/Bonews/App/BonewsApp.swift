//
//  BonewsApp.swift
//  Bonews
//
//  Created by vijayesha on 03.10.25.
//

import SwiftUI
import SwiftData

@main
struct BonewsApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                NewsHeadlinesView()
            }
        }
        .modelContainer(for: NewsArticle.self)
    }
}
