//
//  ActivePointsGradient.swift
//  ScrollableGraphView
//
//  Created by Pho Hale on 9/2/18.
//  Copyright © 2018 SGV. All rights reserved.
//

import Foundation
#if os(OSX)
import Cocoa
#else
import UIKit
#endif

struct ActivePointsGradient {
    var colors: [CGColor] = []
    var locations: [CGFloat] = []
    var size: Int = 0

    init() {
        self.colors = []
        self.locations = []
    }

    init(withSize: Int) {
        self.size = withSize
        self.colors = [CGColor].init(repeating: ScrollableGraphViewNSUI.NSUIColor.clear.cgColor, count: withSize)
        self.locations = [CGFloat].init(repeating: 0.0, count: withSize)
    }

    mutating func update(index: Int, location: CGFloat, color: ScrollableGraphViewNSUI.NSUIColor) {
        self.colors[index] = color.cgColor
        self.locations[index] = location
    }

    // Auto-computes the position based on the provided size and index
    mutating func update(index: Int, color: ScrollableGraphViewNSUI.NSUIColor) {
        if (size == 0) { fatalError() }
        self.colors[index] = color.cgColor
        let computedLocation: CGFloat = CGFloat((index / (self.size - 1)))
        self.locations[index] = computedLocation
    }
}

