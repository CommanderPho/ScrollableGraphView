
#if os(OSX)
    import Cocoa
#else
    import UIKit
#endif

// Delegate definition that provides the data required by the drawing layers.
// This is only conformed to by the main ScrollableGraphView class.
// Each Plot object has a ScrollableGraphViewDrawingDelegate typed instance variable called delegate
// This variable is used both directly by the Plot object, and by the child DrawingLayers through the owner.delegate property.
internal protocol ScrollableGraphViewDrawingDelegate {

    // intervalForActivePoints() returns the CountableRange<Int> that represent the indicies of the currently activePoints in the range of all points.
    func intervalForActivePoints() -> CountableRange<Int>
     // rangeForActivePoints() returns the (minimum, maximum) y-axis values for the active points.
    func rangeForActivePoints() -> (min: Double, max: Double)

    func paddingForPoints() -> (leftmostPointPadding: CGFloat, rightmostPointPadding: CGFloat)

    // calculatePosition(...) takes an index and value and returns a CGPoint for the co-ordinates in the view, taking into account the margins, range, and user options.
    func calculatePosition(atIndex index: Int, value: Double) -> CGPoint

    // currentViewport() returns the CGRect representing the current viewport
    func currentViewport() -> CGRect

    // updatePaths() finds all ScrollableGraphViewDrawingLayer sublayers of the drawingView, and updates their zeroYPosition then calls updatPath() on them:
    func updatePaths()
}
