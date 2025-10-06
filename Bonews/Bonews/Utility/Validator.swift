//
//  URLExtension.swift
//  Bonews
//
//  Created by vijayesha on 06.10.25.
//

import Foundation

class Validator {
    static func isValidURL(_ string: String?) -> Bool {
        guard let string = string,
              let url = URL(string: string)
        else { return false }

        // Basic scheme and host validation
        return url.scheme != nil && url.host != nil
    }

}
