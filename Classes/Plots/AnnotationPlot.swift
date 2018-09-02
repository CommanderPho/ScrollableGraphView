//
//  AnnotationPlot.swift
//  ScrollableGraphView
//
//  Created by Pho Hale on 1/20/18.
//  Copyright © 2018 SGV. All rights reserved.
//

#if os(OSX)
    import Cocoa
#else
    import UIKit
#endif

open class AnnotationPlot : Plot {

    // Customisation
    // #############

    /// The width of an individual bar on the graph.
    open var barWidth: CGFloat = 25;
    /// The actual colour of the bar.
    open var barColor: ScrollableGraphViewNSUI.NSUIColor = ScrollableGraphViewNSUI.NSUIColor.gray
    /// The width of the outline of the bar
    open var barLineWidth: CGFloat = 1
    /// The colour of the bar outline
    open var barLineColor: ScrollableGraphViewNSUI.NSUIColor = ScrollableGraphViewNSUI.NSUIColor.darkGray
    /// Whether the bars should be drawn with rounded corners
    open var shouldRoundBarCorners: Bool = false

    open var shouldDrawDayBoxes: Bool = false

    // Private State
    // #############

    private var annotationLayer: AnnotationDrawingLayer?

    public init(identifier: String) {
        super.init()
        self.identifier = identifier
    }

    override func layers(forViewport viewport: CGRect) -> [ScrollableGraphViewDrawingLayer?] {
        self.createLayers(viewport: viewport)
        return [self.annotationLayer]
    }

    private func createLayers(viewport: CGRect) {
        self.annotationLayer = AnnotationDrawingLayer(
            frame: viewport,
            barWidth: barWidth,
            barColor: barColor,
            barLineWidth: barLineWidth,
            barLineColor: barLineColor,
            shouldRoundCorners: shouldRoundBarCorners,
            shouldDrawDayBoxes: shouldDrawDayBoxes)

        self.annotationLayer?.owner = self
    }
}
