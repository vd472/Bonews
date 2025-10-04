//
//  AppEnvironment.swift
//  Bonews
//
//  Created by vijayesha on 03.10.25.
//

import Foundation

// MARK: - AppEnviroment
enum AppEnvironment {
    case development
    case staging
    case production
    
    var baseURL: String {
        switch self {
        case .development:
            return  "https://newsapi.org/v2/top-headlines?"
        case .staging:
            return  "https://newsapi.org/v2/top-headlines?"
        case .production:
            return  "https://newsapi.org/v2/top-headlines?"
        }
    }
}
