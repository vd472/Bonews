//
//  NewsArticleCard.swift
//  Bonews
//
//  Created by vijayesha on 05.10.25.
//

import SwiftUI

struct NewsArticleCardView: View {
    let article: NewsArticle
    let isFullWidth: Bool
    let geometry: GeometryProxy
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
        
    var body: some View {
        // Load beforehand all the required dynamic font, image height and width.
        let (width, height, isLandscape) = LayoutHelper.screenDimensions(from: geometry)
        let imageWidth = LayoutHelper.dynamicImageWidth(screenWidth: width, isFullWidth: isFullWidth, isLandscape: isLandscape)
        let imageHeight = LayoutHelper.dynamicImageHeight(screenHeight: height, dynamicImageWidth: imageWidth, isFullWidth: isFullWidth, isLandscape: isLandscape)
        let fonts = LayoutHelper.fontSizes(screenWidth: width, dynamicTypeSize: dynamicTypeSize)
        let lines = LayoutHelper.lineLimits(screenHeight: height, isFullWidth: isFullWidth, dynamicTypeSize: dynamicTypeSize)
        let dynamicTitleFont = LayoutHelper.dynamicTitleFont(titleSize: fonts.title, isFullWidth: isFullWidth)
        let dynamicSummaryFont = LayoutHelper.dynamicSummaryFont(summarySize: fonts.summary)
        let dynamicCaptionFont = LayoutHelper.dynamicCaptionFont(captionSize: fonts.caption)
        
        VStack(alignment: .leading, spacing: 12) {
            // Image is loaded from the NewArticle object
            if let loadedImage = article.loadedImage {
                Image(uiImage: loadedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageWidth, height: imageHeight)
                    .clipped()
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: imageWidth, height: imageHeight)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            // Title, description, source and time is fetched here
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(article.title ?? "")
                        .font(dynamicTitleFont)
                        .lineLimit(lines.title)
                    
                    Spacer()
                    
                    Text(relativeTimeString)
                        .font(dynamicCaptionFont)
                        .foregroundColor(.secondary)
                }
                
                Text(article.summary ?? "")
                    .font(dynamicSummaryFont)
                    .foregroundColor(.secondary)
                    .lineLimit(lines.summary)
                
                Text("From: \(article.source ?? "")")
                    .font(dynamicCaptionFont)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: isFullWidth ? .infinity : 280, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
    
    private var relativeTimeString: String {
        let now = Date()
        guard let publishedAt = article.publishedDate else { return ""}
        guard let publishedDate = ISO8601DateFormatter().date(from: publishedAt) else { return ""}
        return now.timeIntervalSince(publishedDate).relativeTimeString()
    }
}
