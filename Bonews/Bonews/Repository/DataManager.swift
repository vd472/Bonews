//
//  DataManager.swift
//  Bonews
//
//  Created by vijayesha on 06.10.25.
//

import Foundation
import SwiftData
import UIKit

@MainActor
final class DataManager {
    static let shared = DataManager()
    
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    // Cache Config 1 hour
    private let maxCacheAge: TimeInterval = 3600
    // Maximum number of articles to cache
    private let maxCacheSize: Int = 100
    
    // Create SwiftData model container
    private init() {
        do {
            let schema = Schema([NewsArticle.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContext = modelContainer.mainContext
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    // MARK: - Article Caching
    
    func saveArticles(_ articles: [NewsArticle]) async {
        do {
            // Clear old articles first
            await clearExpiredArticles()
            
            // Limit cache size
            let articlesToCache = Array(articles.prefix(maxCacheSize))
            
            for article in articlesToCache {
                // Check if article already exists
                let existingArticle = await getCachedArticle(by: article.id)
                
                if existingArticle != nil {
                    // Update existing article
                    await updateCachedArticle(article)
                } else {
                    // Create new cached article
                    article.cachedAt = Date()
                    modelContext.insert(article)
                }
            }
            
            try modelContext.save()
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    // MARK: - Load Articles
    func loadArticles() async -> [NewsArticle] {
        do {
            let descriptor = FetchDescriptor<NewsArticle>(
                sortBy: [SortDescriptor(\.cachedAt, order: .reverse)]
            )
            
            let cachedArticles = try modelContext.fetch(descriptor)
            
            // Filter out expired articles
            let validArticles = cachedArticles.filter { article in
                Date().timeIntervalSince(article.cachedAt) < maxCacheAge
            }
            
            return validArticles
        } catch {
            debugPrint(error.localizedDescription)
            return []
        }
    }
    
    
    // MARK: - Private Helper Methods
    
    private func getCachedArticle(by id: String) async -> NewsArticle? {
        do {
            let descriptor = FetchDescriptor<NewsArticle>()
            let articles = try modelContext.fetch(descriptor)
            return articles.first { $0.id == id }
        } catch {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
    private func updateCachedArticle(_ article: NewsArticle) async {
        do {
            let descriptor = FetchDescriptor<NewsArticle>()
            let articles = try modelContext.fetch(descriptor)
            
            if let cachedArticle = articles.first(where: { $0.id == article.id }) {
                cachedArticle.title = article.title
                cachedArticle.summary = article.summary
                cachedArticle.imageURL = article.imageURL
                cachedArticle.publishedDate = article.publishedDate
                cachedArticle.source = article.source
                cachedArticle.url = article.url
                cachedArticle.cachedAt = Date()
                cachedArticle.loadedImage = article.loadedImage
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    private func clearExpiredArticles() async {
        do {
            let cutoffDate = Date().addingTimeInterval(-maxCacheAge)
            let descriptor = FetchDescriptor<NewsArticle>()
            let allArticles = try modelContext.fetch(descriptor)
            
            let expiredArticles = allArticles.filter { $0.cachedAt < cutoffDate }
            
            for article in expiredArticles {
                modelContext.delete(article)
            }
            
            if !expiredArticles.isEmpty {
                try modelContext.save()
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    // MARK: - Image Caching
    func saveCachedImage(_ image: UIImage, for articleId: String) async {
        do {
            let descriptor = FetchDescriptor<NewsArticle>()
            let articles = try modelContext.fetch(descriptor)
            
            if let article = articles.first(where: { $0.id == articleId }) {
                article.loadedImage = image
                try modelContext.save()
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}
