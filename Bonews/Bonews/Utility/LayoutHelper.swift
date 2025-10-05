//
//  LayoutHelper.swift
//  Bonews
//
//  Created by vijayesha on 05.10.25.
//

import SwiftUI

final class LayoutHelper {
    
    // MARK: - Screen Dimensions
    class func screenDimensions(from geometry: GeometryProxy) -> (width: CGFloat, height: CGFloat, isLandscape: Bool) {
        let width = geometry.size.width
        let height = geometry.size.height
        let isLandscape = width > height
        return (width, height, isLandscape)
    }

    // MARK: - Dynamic Image Width
    class func dynamicImageWidth(
        screenWidth: CGFloat,
        isFullWidth: Bool,
        isLandscape: Bool
    ) -> CGFloat {
        if isFullWidth {
            return screenWidth * 0.7
        } else {
            let baseWidth = screenWidth * 0.3
            let minWidth: CGFloat = 120
            let maxWidth: CGFloat = isLandscape ? 200 : 180
            return max(minWidth, min(baseWidth, maxWidth))
        }
    }

    // MARK: - Dynamic Image Height
    class func dynamicImageHeight(
        screenHeight: CGFloat,
        dynamicImageWidth: CGFloat,
        isFullWidth: Bool,
        isLandscape: Bool
    ) -> CGFloat {
        if isFullWidth {
            let baseHeight = screenHeight * 0.25
            return baseHeight
        } else {
            let aspectRatio: CGFloat = isLandscape ? 0.6 : 0.8
            return dynamicImageWidth * aspectRatio
        }
    }

    // MARK: - Font Sizes
    class func fontSizes(
        screenWidth: CGFloat,
        dynamicTypeSize: DynamicTypeSize
    ) -> (title: CGFloat, summary: CGFloat, caption: CGFloat) {
        let isAccessibilitySize = dynamicTypeSize >= .accessibility1

        let titleBase = screenWidth * 0.04
        let summaryBase = screenWidth * 0.032
        let captionBase = screenWidth * 0.025

        let title = max(isAccessibilitySize ? 18 : 14, min(titleBase, isAccessibilitySize ? 24 : 20))
        let summary = max(isAccessibilitySize ? 16 : 12, min(summaryBase, isAccessibilitySize ? 20 : 16))
        let caption = max(isAccessibilitySize ? 14 : 10, min(captionBase, isAccessibilitySize ? 16 : 12))

        return (title, summary, caption)
    }

    // MARK: - Dynamic Fonts
    class func dynamicTitleFont(
        titleSize: CGFloat,
        isFullWidth: Bool
    ) -> Font {
        let weight: Font.Weight = isFullWidth ? .bold : .semibold
        let size = isFullWidth ? titleSize : titleSize * 0.9
        return .system(size: size, weight: weight, design: .default)
    }

    class func dynamicSummaryFont(summarySize: CGFloat) -> Font {
        .system(size: summarySize, weight: .regular, design: .default)
    }

    class func dynamicCaptionFont(captionSize: CGFloat) -> Font {
        .system(size: captionSize, weight: .regular, design: .default)
    }

    // MARK: - Line Limits
    class func lineLimits(
        screenHeight: CGFloat,
        isFullWidth: Bool,
        dynamicTypeSize: DynamicTypeSize
    ) -> (title: Int, summary: Int) {
        if dynamicTypeSize >= .accessibility1 {
            return (isFullWidth ? 2 : 1, isFullWidth ? 2 : 1)
        } else {
            let heightMultiplier = screenHeight > 800 ? 1 : 0
            let titleLines = (isFullWidth ? 3 : 2) + heightMultiplier
            let summaryLines = (isFullWidth ? 4 : 3) + heightMultiplier
            return (titleLines, summaryLines)
        }
    }
}
