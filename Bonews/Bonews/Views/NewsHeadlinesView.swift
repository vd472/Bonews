//
//  ContentView.swift
//  Bonews
//
//  Created by vijayesha on 03.10.25.
//

import SwiftUI

struct NewsHeadlinesView: View {
    @StateObject private var viewModel = NewsHeadlinesViewModel()
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @State private var selectedArticle: NewsArticle?
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading news...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.articles.isEmpty {
                    VStack(spacing: 16) {
                        Text("No news available")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: dynamicSpacing) {
                            ForEach(viewModel.articles.indices, id: \.self) { index in
                                let article = viewModel.articles[index]
                                
                                if index % 7 == 0 {
                                    // Full width article (every 1st out of 7)
                                    NewsArticleCardView(article: article, isFullWidth: true, geometry: geometry)
                                        .padding(.horizontal)
                                        .onTapGesture {
                                            selectedArticle = article
                                        }
                                        .onAppear {
                                           // Load more articles when reaching the last few items
                                           paginate(index: index)
                                        }
                                } else if index == 1 || (index > 1 && (index - 1) % 7 == 0) {
                                    let batchStart = index
                                    let batchEnd = min(batchStart + 6, viewModel.articles.count)
                                    let batchArticles = Array(viewModel.articles[batchStart..<batchEnd])
                                    
                                    LazyVGrid(columns: gridColumns(for: geometry), spacing: dynamicSpacing) {
                                        ForEach(batchArticles, id: \.id) { article in
                                            NewsArticleCardView(article: article, isFullWidth: false, geometry: geometry)
                                                .onTapGesture {
                                                    selectedArticle = article
                                                }
                                                .onAppear {
                                                    // Load more articles when reaching the last few items
                                                    paginate(index: index)
                                                }
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, dynamicSpacing * 0.5)
                                }
                            }
                        }
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
            .task {
                await viewModel.fetchHeadlines()
            }
            .refreshable {
                Task.detached {
                    await viewModel.refresh()
                }
               
            }
            .navigationTitle("News Headlines")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.refresh()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(item: $selectedArticle) { article in
                NavigationStack {
                    NewsDetailView(article: article)
                }
            }
        }
    }
    
    private func paginate(index: Int) {
        // Load more articles when reaching the last few items
        if index >= viewModel.articles.count - 4
            && viewModel.hasMoreArticles
            && !viewModel.isLoadingMore {
            Task{
                await viewModel.loadMoreArticles()
            }
        }
    }
    
    private func gridColumns(for geometry: GeometryProxy) -> [GridItem] {
        let isLandscape = geometry.isLandscape()
        
        let columnCount: Int
        
        if isLandscape {
            columnCount = 3 // 3 columns in landscape
        } else {
            columnCount = 2 // 2 columns in portrait
        }
        
        return Array(repeating: GridItem(.flexible(), spacing: dynamicSpacing), count: max(1, columnCount))
    }
    
    private var dynamicSpacing: CGFloat {
        // Adjust spacing based on dynamic type size
        let baseSpacing: CGFloat = 20
        let typeSizeMultiplier: CGFloat = dynamicTypeSize >= .accessibility1 ? 1.5 : 1.0
        return baseSpacing * typeSizeMultiplier
    }
}



#Preview {
    NavigationStack {
        NewsHeadlinesView()
    }
}


