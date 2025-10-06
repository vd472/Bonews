//
//  BonewsTests.swift
//  BonewsTests
//
//  Created by vijayesha on 06.10.25.
//

import XCTest
import UIKit
@testable import Bonews

@MainActor
final class ApiRequestTests: XCTestCase {
    
    var apiRequest: ApiRequest!
    
    override func setUp() {
        super.setUp()
        apiRequest = ApiRequest()
    }
    
    override func tearDown() {
        apiRequest = nil
        super.tearDown()
    }
    
    // MARK: - Essential Tests
    
    func testRequestWithInvalidURL() async {
        // Given
        let request = await MainActor.run { ApiRequestBuilder(rawURL: "invalid-url") }

        do {
            // When
            let _: NewsResponse = try await apiRequest.request(request, responseType: NewsResponse.self)
            
            // Then
            XCTFail("Should have thrown an error")
        } catch {
            // Just verify that some error was thrown for invalid URL
            XCTAssertTrue(true, "Error was thrown as expected: \(error)")
        }
    }
    
    func testRequestImageWithInvalidURL() async {
        // Given
        let request = await MainActor.run { ApiRequestBuilder(rawURL: "invalid-url") }
        
        do {
            // When
            let _ = try await apiRequest.requestImage(request)
            
            //Then
            XCTFail("Should have thrown an error")
        } catch {
            // Just verify that some error was thrown for invalid URL
            XCTAssertTrue(true, "Error was thrown as expected: \(error)")
        }
    }
    
    func testRequestBuilderWithValidParameters() async {
        // Given
        let apiKey = "test-key"
        let page = 1
        
        // When
        let request = await MainActor.run { ApiRequestBuilder(apiKey: apiKey, page: page) }
        
        // Then
        XCTAssertNotNil(request.url)
        XCTAssertEqual(request.method, .get)
    }
    
    func testRequestBuilderWithImageURL() async {
        // Given
        let imageURL = "https://example.com/image.jpg"
        
        // When
        let request = await MainActor.run { ApiRequestBuilder(rawURL: imageURL) }
        
        // Then
        XCTAssertNotNil(request.url)
        XCTAssertEqual(request.method, .get)
    }
}
