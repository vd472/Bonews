//
//  ApiRequestBuilder.swift
//  Bonews
//
//  Created by vijayesha on 04.10.25.
//

import Foundation

// MARK: - ApiRequestType Protocol
protocol ApiRequestType {
    var url: URL? { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
    var queryItems: [URLQueryItem]? { get }
    var timeout: TimeInterval { get }
}

// MARK: - Extension of ApiRequestType Protocol
extension ApiRequestType {
    var headers: [String: String]? { nil }
    var body: Data? { nil }
    var queryItems: [URLQueryItem]? { nil }
    var timeout: TimeInterval { 30 }
}

// MARK: - ApiRequestBuilder
struct ApiRequestBuilder: ApiRequestType {
    let url: URL?
    let method: HTTPMethod = .get
      
    // MARK: - for fetching the headlines
    init(baseURL: String = AppEnvironment.development.baseURL,
         country: String = "us",
         apiKey: String,
         page: Int = 1,
         pageSize: Int = 21) {
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)")
        ]
        
        self.url = components?.url
    }
    
    // MARK: - Fetching the image
    init(rawURL: String) {
            self.url = URL(string: rawURL)
        }
}
