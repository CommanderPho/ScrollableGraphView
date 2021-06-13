//
//  InterfaceBuilder-ScrollableGraphViewDataSource.swift
//  ScrollableGraphView
//
//  Created by Pho Hale on 9/2/18.
//  Copyright © 2018 SGV. All rights reserved.
//

import Foundation


// We have to be our own data source for interface builder.
#if TARGET_INTERFACE_BUILDER
extension ScrollableGraphView : ScrollableGraphViewDataSource {

    var numberOfDisplayItems: Int {
        get {
            return 30
        }
    }

    var linePlotData: [Double] {
        get {
            return self.generateRandomData(numberOfDisplayItems, max: 100, shouldIncludeOutliers: false)
        }
    }

    public func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double? {
        return linePlotData[pointIndex]
    }

    public func label(atIndex pointIndex: Int) -> String {
        return "\(pointIndex)"
    }

    public func numberOfPoints() -> Int {
        return numberOfDisplayItems
    }

    private func generateRandomData(_ numberOfItems: Int, max: Double, shouldIncludeOutliers: Bool = true) -> [Double] {
        var data = [Double]()
        for _ in 0 ..< numberOfItems {
            var randomNumber = Double(arc4random()).truncatingRemainder(dividingBy: max)

            if(shouldIncludeOutliers) {
                if(arc4random() % 100 < 10) {
                    randomNumber *= 3
                }
            }

            data.append(randomNumber)
        }
        return data
    }

    public func isVisible(forPlot plot: Plot, atIndex pointIndex: Int) -> Bool {
        return true
    }

    public func valueColor(forPlot plot: Plot, atIndex pointIndex: Int) -> ScrollableGraphViewNSUI.NSUIColor? {
        return nil
    }


    public func labelColor(atIndex pointIndex: Int) -> ScrollableGraphViewNSUI.NSUIColor? {
        return nil
    }
}
#endif
