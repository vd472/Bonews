//
//  NetworkRequestType.swift
//  Bonews
//
//  Created by vijayesha on 04.10.25.
//

import Foundation
import UIKit

// MARK: - ApiServiceProtocol
protocol ApiServiceProtocol {
    func request<T: Codable>(_ request: ApiRequestType, responseType: T.Type) async throws -> T
    func requestImage(_ request: ApiRequestType) async throws -> UIImage
}


// MARK: ApiRequest class
final class ApiRequest: ApiServiceProtocol {
    
    init() {}
    
    // MARK: - Common method for request of image and news
    private func executeRequest(_ request: ApiRequestType) async throws -> Data {
        
        guard let _ = request.url else {
            throw ApiError.invalidURL
        }
        
        guard var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) else {
            throw ApiError.invalidURL
        }
        
        if let queryItems = request.queryItems {
            components.queryItems = (components.queryItems ?? []) + queryItems
        }
        
        guard let finalURL = components.url else {
            throw ApiError.invalidURL
        }
        
        var urlRequest = URLRequest(url: finalURL, timeoutInterval: request.timeout)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        urlRequest.httpBody = request.body
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.requestError(underlyingError: URLError(.badServerResponse))
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw ApiError.httpError(statusCode: httpResponse.statusCode)
        }
        
        guard !data.isEmpty else {
            throw ApiError.noData
        }
        
        return data
    }

}

// MARK: - Extension of ApiRequest confirming the protocol ApiServiceProtocol
extension ApiRequest {
    // MARK: - request headlines
    nonisolated func request<T: Codable>(_ request: ApiRequestType, responseType: T.Type) async throws -> T {
        let data = try await executeRequest(request)
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            if let isNewsResponseError = await checkForNewsResponseError(data: data, decoder: decoder) {
                throw isNewsResponseError
            }
            throw ApiError.decodingError(underlyingError: error)
       }
    }
    
    @MainActor
    private func checkForNewsResponseError(data: Data, decoder: JSONDecoder) -> ApiError? {
        guard let newsResponse = try? decoder.decode(NewsResponse.self, from: data) else {
            return nil
        }
        if newsResponse.status == "error" {
            if newsResponse.code == "rateLimited" {
                return ApiError.rateLimited(message: "Rate limit exceeded")
            } else {
                return ApiError.httpError(statusCode: 400)
            }
        }
        return nil
    }

    // MARK: - request image
    nonisolated func requestImage(_ request: ApiRequestType) async throws -> UIImage {
        let data = try await executeRequest(request)
        guard let image = UIImage(data: data) else {
            throw ApiError.requestError(underlyingError: URLError(.cannotDecodeContentData))
        }
        return image
    }
}
