//
//  HTTPMethod.swift
//  Bonews
//
//  Created by vijayesha on 03.10.25.
//

import Foundation

// MARK: - HTTP method
public enum HTTPMethod: String {
    case get
    case head
    case post
    case put
    case delete

    var stringValue: String {
        rawValue.uppercased()
    }
}
