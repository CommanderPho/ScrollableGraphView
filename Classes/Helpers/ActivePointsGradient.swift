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

class ActivePointsGradient: NSObject {
    var colors: [CGColor] = []
    var locations: [CGFloat] = []
    var size: Int = 0

    var mostRecentColor: CGColor? { return self.colors.last }
    var mostRecentColorPosition: CGFloat? { return self.locations.last }

    // mostRecentContiguousColorPosition: the last position that contained the lastColor
    var mostRecentContiguousColorPosition: CGFloat? = nil


    override init() {
        super.init()
        self.colors = []
        self.locations = []
    }

    init(withSize: Int) {
        super.init()
        self.size = withSize
//        self.colors = [CGColor].init(repeating: ScrollableGraphViewNSUI.NSUIColor.clear.cgColor, count: withSize)
//        self.locations = [CGFloat].init(repeating: 0.0, count: withSize)
        self.colors = [CGColor]()
        self.locations = [CGFloat]()
    }

//    func update(index: Int, location: CGFloat, color: ScrollableGraphViewNSUI.NSUIColor) {
//        self.colors[index] = color.cgColor
//        self.locations[index] = location
//    }

    // Auto-computes the position based on the provided size and index
//    func update(index: Int, color: ScrollableGraphViewNSUI.NSUIColor) {
//        if ((size == 0) || (index >= size)) { fatalError() }
//        self.colors[index] = color.cgColor
//        let computedLocation: CGFloat = CGFloat((index / (self.size - 1)))
//        self.locations[index] = computedLocation
//    }
    func update(index: Int, color: ScrollableGraphViewNSUI.NSUIColor) {
        if ((self.size == 0) || (index >= self.size)) { fatalError() }
        let computedLocation: CGFloat = CGFloat((index / (self.size - 1)))

        guard let validLastColor = self.mostRecentColor,
              let validLastColorPosition = self.mostRecentColorPosition,
              let validLastContiguousColorPosition = self.mostRecentContiguousColorPosition else {
            self.colors.append(color.cgColor)
            self.locations.append(computedLocation)
            self.mostRecentContiguousColorPosition = computedLocation
            return
        }
        // Check and see if the mostRecent color is the same as this one.
        if (validLastColor == color.cgColor) {
            // If the color is the same, just update the mostRecentContiguousColorPosition
            self.mostRecentContiguousColorPosition = computedLocation
        }
        else {
            // mostRecentContiguousColorPosition has ended
            // Create the stop for the mostRecent color at the mostRecentContiguousColorPosition
            if (validLastColorPosition != self.mostRecentContiguousColorPosition) {
                // Create the stop
                self.locations.append(validLastContiguousColorPosition)
                self.colors.append(validLastColor)
            }
            // Create the start for the new color
            self.colors.append(color.cgColor)
            self.locations.append(computedLocation)
            self.mostRecentContiguousColorPosition = computedLocation
        }
    }

}

