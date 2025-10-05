//
//  NewsArticle.swift
//  Bonews
//
//  Created by vijayesha on 05.10.25.
//

import Foundation
import UIKit

struct NewsArticle: Identifiable {
    let id: String
    let title: String?
    let summary: String?
    let imageURL: String?
    let publishedDate: String?
    let source: String?
    let url: String?
    var loadedImage: UIImage?
    
    init(id: String = UUID().uuidString, title: String, summary: String, imageURL: String? = nil, publishedDate: String? = nil, source: String? = nil, url: String? = nil, loadedImage: UIImage? = nil) {
        self.id = id
        self.title = title
        self.summary = summary
        self.imageURL = imageURL
        self.publishedDate = publishedDate
        self.source = source
        self.url = url
        self.loadedImage = loadedImage
    }
}
