//
//  NewsArticle.swift
//  Bonews
//
//  Created by vijayesha on 05.10.25.
//

import Foundation
import UIKit
import SwiftData

@Model
final class NewsArticle: Identifiable {
    var id: String
    var title: String?
    var summary: String?
    var imageURL: String?
    var publishedDate: String?
    var source: String?
    var url: String?
    var imageData: Data?
    var cachedAt: Date
    
    var loadedImage: UIImage? {
        get {
            guard let imageData = imageData else { return nil }
            return UIImage(data: imageData)
        }
        set {
            imageData = newValue?.jpegData(compressionQuality: 0.8)
        }
    }
    
    init(id: String = UUID().uuidString, title: String, summary: String, imageURL: String? = nil, publishedDate: String? = nil, source: String? = nil, url: String? = nil, loadedImage: UIImage? = nil, cachedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.summary = summary
        self.imageURL = imageURL
        self.publishedDate = publishedDate
        self.source = source
        self.url = url
        self.cachedAt = cachedAt
        self.imageData = loadedImage?.jpegData(compressionQuality: 0.8)
    }
}
