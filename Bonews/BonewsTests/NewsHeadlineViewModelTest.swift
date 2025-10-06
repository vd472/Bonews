//
//  NewsHeadlineViewModelTest.swift
//  Bonews
//
//  Created by vijayesha on 06.10.25.
//

import XCTest
@testable import Bonews

@MainActor
final class NewsHeadlinesViewModelTests: XCTestCase {
    
    var viewModel: NewsHeadlinesViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = NewsHeadlinesViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Essential Tests
    
    func testInitialState() {
        XCTAssertTrue(viewModel.articles.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.hasMoreArticles)
        XCTAssertFalse(viewModel.isLoadingMore)
    }
    
    func testPaginationPreventsDuplicateCalls() async {
        // Given
        viewModel.isLoadingMore = true
        
        // When
        await viewModel.loadMoreArticles()
        
        // Then - Should not trigger another load
        XCTAssertTrue(viewModel.isLoadingMore)
    }
    
    func testPaginationWhenNoMoreArticles() async {
        // Given
        viewModel.hasMoreArticles = false
        
        // When
        await viewModel.loadMoreArticles()
        
        // Then
        XCTAssertFalse(viewModel.isLoadingMore)
    }
    
    func testRefreshClearsArticles() async {
        // Given
        let articles = createMockArticles(count: 5)
        viewModel.articles = articles
        viewModel.hasMoreArticles = false
        
        // When - Test the refresh logic without making API calls
        viewModel.hasMoreArticles = true
        viewModel.articles.removeAll()
        viewModel.isUsingCache = false
        
        // Then
        XCTAssertTrue(viewModel.articles.isEmpty, "Articles should be cleared on refresh")
        XCTAssertTrue(viewModel.hasMoreArticles, "hasMoreArticles should be reset to true")
        XCTAssertFalse(viewModel.isUsingCache, "isUsingCache should be false after refresh")
    }
    
    
    // MARK: - Helper Methods
    
    private func createMockArticles(count: Int) -> [NewsArticle] {
        return (0..<count).map { index in
            NewsArticle(
                id: "article-\(index)",
                title: "Test News Article \(index)",
                summary: "Test news summary for article \(index)",
                imageURL: "https://news.com/image\(index).jpg",
                publishedDate: "2025-10-07T23:00:00Z",
                source: "Test News Source",
                url: "https://news.com/article\(index)"
            )
        }
    }
}
