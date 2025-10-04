//
//  NetworkError.swift
//  Bonews
//
//  Created by vijayesha on 03.10.25.
//

import Foundation

// MARK: - ApiError
enum ApiError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(underlyingError: Error)
    case noData
    case requestError(underlyingError: Error)
    case timeout

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)."
        case .decodingError(let underlyingError):
            return "Failed to decode the response: \(underlyingError.localizedDescription)"
        case .noData:
            return "No data was returned by the server."
        case .requestError(let underlyingError):
            return "An error occurred during the request: \(underlyingError.localizedDescription)"
        case .timeout:
            return "Timeout"
        }
    }
}
