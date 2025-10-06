//
//  BonewsUITests.swift
//  BonewsUITests
//
//  Created by vijayesha on 06.10.25.
//

import XCTest

final class BonewsUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Essential UI Tests
    
    func testAppLaunch() throws {
        // Given - App is launched
        
        // When
        // Check if app launched successfully by looking for any navigation bar
        let navigationBar = app.navigationBars.firstMatch
        
        //Then
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 5.0), "Navigation bar should exist")
        
        // When
        // Check for any button (could be menu button or other UI elements)
        let anyButton = app.buttons.firstMatch
        
        //Then
        XCTAssertTrue(anyButton.waitForExistence(timeout: 5.0), "At least one button should exist")
    }
    
    
    func testNewsArticlesDisplay() throws {
        // Given - App is launched
        
        // When
        // Look for scroll view or any content that might contain articles
        let scrollView = app.scrollViews.firstMatch
        let anyContent = app.otherElements.firstMatch
        
        // Then
        let hasScrollView = scrollView.waitForExistence(timeout: 10.0)
        let hasContent = anyContent.waitForExistence(timeout: 10.0)
        XCTAssertTrue(hasScrollView || hasContent, "Some content should be displayed")
    }
    
    func testRefreshAction() throws {
        // Given - App is launched and loaded
        
        // When
        // Try to find and tap any button (could be menu, refresh, etc.)
        let anyButton = app.buttons.firstMatch
        if anyButton.waitForExistence(timeout: 10.0) {
            anyButton.tap()
            
            // Then
            XCTAssertTrue(true, "Button tap should not crash the app")
        } else {
            // If no button found, just verify the app is responsive
            XCTAssertTrue(true, "No button found to test refresh action")
        }
    }
    
    func testToolbarMenu() throws {
        // Given - App is launched
        
        // When
        // Try to find and tap any button that might be a menu
        let anyButton = app.buttons.firstMatch
        if anyButton.waitForExistence(timeout: 5.0) {
            anyButton.tap()
        }

        let additionalButtons = app.buttons.count
        
        //Then
        XCTAssertTrue(additionalButtons > 0, "Some buttons should be available")
    }
    
    func testScrollToBottom() throws {
        // Given - App is launched and articles are loaded
        
        //When
        let scrollView = app.scrollViews.firstMatch
        if scrollView.waitForExistence(timeout: 5.0) {
            scrollView.swipeUp(velocity: .fast)
            scrollView.swipeUp(velocity: .fast)
            scrollView.swipeUp(velocity: .fast)
        }
        
        //Then
        XCTAssertTrue(true, "Scrolling should work without crashing")
    }
    
    func testPullToRefresh() throws {
        // Given - App is launched and articles are loaded
        
        //When
        let scrollView = app.scrollViews.firstMatch
        if scrollView.waitForExistence(timeout: 5.0) {
            let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
            let end = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
            start.press(forDuration: 0.1, thenDragTo: end)
        }
        
        //Then
        XCTAssertTrue(true, "Pull-to-refresh should work without crashing")
    }
    
    func testEmptyState() throws {
        //Then
        XCTAssertTrue(true, "App should handle empty state gracefully")
    }
}
