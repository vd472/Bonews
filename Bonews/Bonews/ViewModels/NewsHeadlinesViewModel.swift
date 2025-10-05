//
//  NewsHeadlinesViewModel.swift
//  Bonews
//
//  Created by vijayesha on 04.10.25.
//

import Foundation
import Combine

@MainActor
class NewsHeadlinesViewModel: ObservableObject {
    @Published var articles: [NewsArticle] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastRefreshDate: Date?
    
    init() {
    }
    
    // MARK: - Fetch News Headlines via ViewModel
    
    func fetchHeadlines() async {
        let apiService = ApiRequest()
        isLoading = true
        errorMessage = nil
        guard let apikey =  Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            print("apiKey not found")
            return
        }
        do {
            // Fetch from API
            let fetchedData = try await apiService.request(ApiRequestBuilder.init(apiKey: apikey), responseType: NewsResponse.self)
            
            // model fetch data into NewsArticle
            let newsArticles = await loadNewsArticle(fetchedData)
            
            // Load images for articles
            let articlesWithImages = await loadImagesForArticles(newsArticles)
            
            // Update UI with fresh data
            articles = articlesWithImages
            lastRefreshDate = Date()
            
        } catch {
            errorMessage = "Failed to fetch latest news: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // model fetch data into NewsArticle
    private func loadNewsArticle(_ fetchedData: NewsResponse) async  -> [NewsArticle] {
        return fetchedData.articles.compactMap { (article: Article) -> NewsArticle? in
            guard let title = article.title,
                  let description = article.description else { return nil }
            
            return NewsArticle(
                id: article.url ?? UUID().uuidString,
                title: title,
                summary: description,
                imageURL: article.urlToImage,
                publishedDate: article.publishedAt,
                source: article.source?.name,
                url: article.url
            )
        }
    }
        
    // Load images for articles
    private func loadImagesForArticles(_ articles: [NewsArticle]) async -> [NewsArticle] {
        return await withTaskGroup(of: NewsArticle.self) { group in
            var articlesWithImages: [NewsArticle] = []
            let apiService = ApiRequest()
            for article in articles {
                group.addTask {
                    var updatedArticle = article
                    if let imageURL = article.imageURL {
                        do {
                            let image = try await apiService.requestImage(ApiRequestBuilder.init(rawURL: imageURL))
                            updatedArticle.loadedImage = image
                        } catch {
                            print("Failed to load image for article: \(String(describing:article.title))")
                        }
                    }
                    return updatedArticle
                }
            }
            
            for await article in group {
                articlesWithImages.append(article)
            }
            
            return articlesWithImages
        }
    }
}

extension NewsHeadlinesViewModel {
    // Refresh
    func refresh() async {
        await fetchHeadlines()
    }

}

