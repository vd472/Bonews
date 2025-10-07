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
    @Published var hasMoreArticles = true
    @Published var isLoadingMore = false
    @Published var isUsingCache = false
    
    private var currentPage = 1
    private let apiService = ApiRequest()
    private let dataManager = DataManager.shared
    private var apikey : String {
        guard let apikey =  Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            debugPrint("apiKey not found")
            return ""
        }
       return apikey
    }
    
    init() {
        // Load from cache initially on startup
        Task {
            await loadFromCache()
        }
    }
    
    // MARK: - Fetch News Headlines via ViewModel
    
    func fetchHeadlines() async {
        isLoading = true
        errorMessage = nil
        isUsingCache = false
        
        if articles.isEmpty {
            await loadFromCache()
        }
    
        await loadData()
        isLoading = false
    }
    
    // Load data from cache
    private func loadFromCache() async {
        let cachedArticles = await dataManager.loadArticles()
        if !cachedArticles.isEmpty {
            articles = cachedArticles
            isUsingCache = true
            lastRefreshDate = cachedArticles.first?.publishedDate != nil ?
                ISO8601DateFormatter().date(from: cachedArticles.first!.publishedDate!) : Date()
        }
    }
    
    // Load data from api
    private func loadData(_ currentPage: Int = 1) async {
        do {
            // Fetch from API
            let fetchedData = try await apiService.request(ApiRequestBuilder.init(apiKey: apikey, page: currentPage), responseType: NewsResponse.self)
            
            if fetchedData.articles?.count != 0 {
                // model fetch data into NewsArticle
                let newsArticles = await loadNewsArticle(fetchedData)
                
                // Load images for articles
                let articlesWithImages = await loadImagesForArticles(newsArticles)
                
                // Update UI with fresh data
                if currentPage == 1 {
                    articles = articlesWithImages
                } else {
                    articles.append(contentsOf: articlesWithImages)
                }
                
                // Cache the articles using SwiftData
                await dataManager.saveArticles(articles)
                isUsingCache = false
                lastRefreshDate = Date()
                hasMoreArticles = true
                
            } else {
                hasMoreArticles = false
            }
        } catch {
            debugPrint("\(error.localizedDescription)")
            
            // Handle specific error types
            await handleSpecificError(error)
         
            if currentPage != 1 {
                self.currentPage -= 1
            }
        }
    }
    
    // model fetch data into NewsArticle
    private func loadNewsArticle(_ fetchedData: NewsResponse) async  -> [NewsArticle] {
        guard let articles = fetchedData.articles else { return [] }
        return articles.compactMap { (article: Article) -> NewsArticle? in
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
        var articlesWithImages: [NewsArticle] = []
        
        for article in articles {
            let updatedArticle = article
            
            if let imageURL = article.imageURL, Validator.isValidURL(article.imageURL) {
                do {
                    let fetchedImage = try await apiService.requestImage(ApiRequestBuilder.init(rawURL: imageURL))
                    updatedArticle.loadedImage = fetchedImage
                   
                    await dataManager.saveCachedImage(fetchedImage, for: article.id)
                } catch {
                    debugPrint("Failed to load image for article: \(String(describing:article.title))")
                }
            }
            
            articlesWithImages.append(updatedArticle)
        }
        
        return articlesWithImages
    }
}

extension NewsHeadlinesViewModel {
    // Refresh
    func refresh() async {
        hasMoreArticles = true
        currentPage = 1
        articles.removeAll()
        isUsingCache = false
        await fetchHeadlines()
    }
    
    //Pagination
    func loadMoreArticles() async {
        guard !isLoadingMore && hasMoreArticles else { return }
        isLoadingMore = true
        currentPage += 1
        await loadData(currentPage)
        isLoadingMore = false
    }
    
    //Error Handling
    func handleSpecificError(_ error: Error) async {
        if let apiError = error as? ApiError {
              switch apiError {
              case .rateLimited(let message):
                  // Handle rate limiting specifically
                  if articles.isEmpty {
                      await loadFromCache()
                      if articles.isEmpty {
                          errorMessage = "API rate limit exceeded. Please try again later or upgrade your plan for more requests."
                      } else {
                          errorMessage = "Rate limit exceeded. Showing cached news. Please try again later."
                      }
                  } else {
                      errorMessage = "Rate limit exceeded. Showing cached news. Please try again later."
                  }
              default:
                  // Handle other API errors
                  if articles.isEmpty {
                      await loadFromCache()
                      if articles.isEmpty {
                          errorMessage = "Failed to fetch news. Please check your internet connection and try again."
                      } else {
                          errorMessage = "Showing cached news. Pull to refresh to get latest updates."
                      }
                  } else {
                      errorMessage = "Failed to fetch latest news: \(error.localizedDescription)"
                  }
              }
          } else {
              // Handle non-API errors
              if articles.isEmpty {
                  await loadFromCache()
                  if articles.isEmpty {
                      errorMessage = "Failed to fetch news. Please check your internet connection and try again."
                  } else {
                      errorMessage = "Showing cached news. Pull to refresh to get latest updates."
                  }
              } else {
                  errorMessage = "Failed to fetch latest news: \(error.localizedDescription)"
              }
          }

    }
}

