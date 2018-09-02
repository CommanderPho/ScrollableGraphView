
#if os(OSX)
    import Cocoa
#else
    import UIKit
#endif

internal class DotDrawingLayer: ScrollableGraphViewDrawingLayer {
    
    private var dataPointPath = ScrollableGraphViewNSUI.NSUIBezierPath()
    private var dataPointSize: CGFloat = 5
    private var dataPointType: ScrollableGraphViewDataPointType = .circle
    
    private var customDataPointPath: ((_ centre: CGPoint, _ isVisible: Bool , _ colorOverride: ScrollableGraphViewNSUI.NSUIColor?) -> ScrollableGraphViewNSUI.NSUIBezierPath)?
    
    init(frame: CGRect, fillColor: ScrollableGraphViewNSUI.NSUIColor, dataPointType: ScrollableGraphViewDataPointType, dataPointSize: CGFloat, customDataPointPath: ((_ centre: CGPoint, _ isVisible: Bool , _ colorOverride: ScrollableGraphViewNSUI.NSUIColor?) -> ScrollableGraphViewNSUI.NSUIBezierPath)? = nil) {
        
        self.dataPointType = dataPointType
        self.dataPointSize = dataPointSize
        self.customDataPointPath = customDataPointPath
        
        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)
        
        self.fillColor = fillColor.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createDataPointPath() -> ScrollableGraphViewNSUI.NSUIBezierPath {
        
        dataPointPath.removeAllPoints()
        
        // We can only move forward if we can get the data we need from the delegate.
        guard let activePointsInterval = self.owner?.graphViewDrawingDelegate?.intervalForActivePoints() else {
                return dataPointPath
        }
        
        let pointPathCreator = getPointPathCreator()
        
        for i in activePointsInterval {
            
            var location = CGPoint.zero
            var isVisible: Bool = true
            var colorOveride: ScrollableGraphViewNSUI.NSUIColor? = nil

            if let point = owner?.graphPoint(forIndex: i) {
                location = point.location
                isVisible = point.isVisible
                colorOveride = point.colorOverride
            }
            let pointPath: ScrollableGraphViewNSUI.NSUIBezierPath
            if (isVisible) {
                pointPath = pointPathCreator(location, isVisible, colorOveride)
                dataPointPath.append(pointPath)
            }
            // otherwise just skip it
        }
        
        return dataPointPath
    }
    
    private func createCircleDataPoint(centre: CGPoint, isVisible: Bool, colorOverride: ScrollableGraphViewNSUI.NSUIColor?) -> ScrollableGraphViewNSUI.NSUIBezierPath {
        if(!isVisible) { return ScrollableGraphViewNSUI.NSUIBezierPath() }
        return ScrollableGraphViewNSUI.NSUIBezierPath(arcCenter: centre, radius: dataPointSize, startAngle: 0, endAngle: CGFloat(2.0 * Double.pi), clockwise: true)
    }
    
    private func createSquareDataPoint(centre: CGPoint, isVisible: Bool, colorOverride: ScrollableGraphViewNSUI.NSUIColor?) -> ScrollableGraphViewNSUI.NSUIBezierPath {
        if(!isVisible) { return ScrollableGraphViewNSUI.NSUIBezierPath() }

        let squarePath = ScrollableGraphViewNSUI.NSUIBezierPath()
        
        squarePath.move(to: centre)
        
        let topLeft = CGPoint(x: centre.x - dataPointSize, y: centre.y - dataPointSize)
        let topRight = CGPoint(x: centre.x + dataPointSize, y: centre.y - dataPointSize)
        let bottomLeft = CGPoint(x: centre.x - dataPointSize, y: centre.y + dataPointSize)
        let bottomRight = CGPoint(x: centre.x + dataPointSize, y: centre.y + dataPointSize)
        
        squarePath.move(to: topLeft)
        squarePath.addLine(to: topRight)
        squarePath.addLine(to: bottomRight)
        squarePath.addLine(to: bottomLeft)
        squarePath.addLine(to: topLeft)
        
        return squarePath
    }
    
    private func getPointPathCreator() -> (_ centre: CGPoint, _ isVisible: Bool, _ colorOverride: ScrollableGraphViewNSUI.NSUIColor?) -> ScrollableGraphViewNSUI.NSUIBezierPath {
        switch(self.dataPointType) {
        case .circle:
            return createCircleDataPoint
        case .square:
            return createSquareDataPoint
        case .custom:
            if let customCreator = self.customDataPointPath {
                return customCreator
            }
            else {
                // We don't have a custom path, so just return the default.
                fallthrough
            }
        default:
            return createCircleDataPoint
        }
    }
    
    override func updatePath() {
        self.path = createDataPointPath().cgPath
    }
}
