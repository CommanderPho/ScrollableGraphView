//
//  ScrollableGraphViewDelegate.swift
//  ScrollableGraphView
//
//  Created by Pho Hale on 2/11/18.
//  Copyright © 2018 SGV. All rights reserved.
//

import Foundation

// ScrollableGraphViewDelegate recieves information about changes to the ScrollableGraphView, such as scroll position and visible elements
public protocol ScrollableGraphViewDelegate: class {
    // Called
    func scrollableGraphView(_ scrollableGraphView: ScrollableGraphView, willDisplay pointIndex: Int, forPlot plot: Plot)
    func scrollableGraphView(_ scrollableGraphView: ScrollableGraphView, didEndDisplaying pointIndex: Int, forPlot plot: Plot)

    // doesn't have a plot variable because it's shared among all plots
    func scrollableGraphView(_ scrollableGraphView: ScrollableGraphView, batchUpdateActivePoints pointIndicies: [Int])


    // Optional
    func scrollableGraphView(_ scrollableGraphView: ScrollableGraphView, didUpdateViewportOffset newPercentOffset: CGFloat)
}



extension ScrollableGraphViewDelegate {

    func scrollableGraphView(_ scrollableGraphView: ScrollableGraphView, didUpdateViewportOffset newPercentOffset: CGFloat) {
        return
    }
}
