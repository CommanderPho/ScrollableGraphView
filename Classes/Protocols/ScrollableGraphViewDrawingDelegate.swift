
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
    func intervalForActivePoints() -> CountableRange<Int>
    func rangeForActivePoints() -> (min: Double, max: Double)
    func paddingForPoints() -> (leftmostPointPadding: CGFloat, rightmostPointPadding: CGFloat)
    func calculatePosition(atIndex index: Int, value: Double) -> CGPoint
    func currentViewport() -> CGRect
    func updatePaths()
}
