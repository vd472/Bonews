//
//  NewsDetailView.swift
//  Bonews
//
//  Created by vijayesha on 05.10.25.
//

import SwiftUI
import WebKit

struct NewsDetailView: View {
    let article: NewsArticle
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var loadError: Error? = nil

    var body: some View {
        ZStack {
            // MARK: - Web Content
            if let urlString = article.url, let url = URL(string: urlString) {
                WebView(url: url, isLoading: $isLoading, loadError: $loadError)
                    .ignoresSafeArea(edges: .bottom)
            } else {
                // MARK: - Fallback for missing URL
                VStack(spacing: 16) {
                    Text("Article URL not available")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    Text(article.summary ?? "")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            }

            // MARK: - Loading overlay
            if isLoading {
                Color(.systemBackground)
                    .opacity(0.8)
                    .ignoresSafeArea()
                VStack(spacing: 8) {
                    ProgressView()
                    Text("Loading article...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }

            // MARK: - Error overlay
            if let error = loadError {
                VStack(spacing: 12) {
                    Text("Failed to load article")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        if let url = URL(string: article.url ?? "") {
                            loadError = nil
                            isLoading = true
                            NotificationCenter.default.post(name: .reloadWebView, object: url)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .navigationTitle(article.source ?? "News")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if let url = URL(string: article.url ?? "") {
                    Button {
                        UIApplication.shared.open(url)
                    } label: {
                        Image(systemName: "safari")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}
