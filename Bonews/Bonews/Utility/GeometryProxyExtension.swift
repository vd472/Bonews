//
//  GeometryReaderExtension.swift
//  Bonews
//
//  Created by vijayesha on 05.10.25.
//

import SwiftUI

extension GeometryProxy {
    func isLandscape() -> Bool {
        return self.size.width > self.size.height
    }
}
