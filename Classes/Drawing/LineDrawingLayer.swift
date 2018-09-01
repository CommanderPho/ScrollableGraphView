
import UIKit

internal class LineDrawingLayer : ScrollableGraphViewDrawingLayer {
    
    private var currentLinePath = UIBezierPath()

    struct ColoredLineSegment {
        var currentLinePath: UIBezierPath = UIBezierPath()
        var lineColor: CGColor?
        var lineWidth: CGFloat
        var lineDashPattern: [NSNumber]? = nil
    }

    private var coloredCurrentLinePaths: [ColoredLineSegment] = []
    
    private var lineStyle: ScrollableGraphViewLineStyle
    private var shouldFill: Bool
    private var lineCurviness: CGFloat
    
    init(frame: CGRect, lineWidth: CGFloat, lineColor: UIColor, lineStyle: ScrollableGraphViewLineStyle, lineJoin: String, lineCap: String, shouldFill: Bool, lineCurviness: CGFloat, lineDashPattern: [NSNumber]? = nil) {
        
        self.lineStyle = lineStyle
        self.shouldFill = shouldFill
        self.lineCurviness = lineCurviness
        
        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)
        
        self.lineWidth = lineWidth
        self.strokeColor = lineColor.cgColor
        self.lineDashPattern = lineDashPattern
        
        self.lineJoin = lineJoin
        self.lineCap = lineCap

        var newLineSegment: ColoredLineSegment = ColoredLineSegment.init(currentLinePath: self.currentLinePath, lineColor: self.strokeColor, lineWidth: self.lineWidth, lineDashPattern: self.lineDashPattern)
        self.coloredCurrentLinePaths.append(newLineSegment)
        
        // Setup
        self.fillColor = UIColor.clear.cgColor // This is handled by the fill drawing layer.
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    internal func createLinePaths() -> [ColoredLineSegment] {

        guard let owner = owner else {
            return []
        }

        // Can't really do anything without the delegate.
        guard let delegate = self.owner?.graphViewDrawingDelegate else {
            return []
        }

        currentLinePath.removeAllPoints()
        self.coloredCurrentLinePaths.removeAll(keepingCapacity: true)

        let pathSegmentAdder: ((CGPoint, CGPoint, UIBezierPath) -> ()) = lineStyle == .straight ? addStraightLineSegment : addCurvedLineSegment

        let activePointsInterval = delegate.intervalForActivePoints()

        let pointPadding = delegate.paddingForPoints()

        let min = delegate.rangeForActivePoints().min
        zeroYPosition = delegate.calculatePosition(atIndex: 0, value: min).y

        let viewport = delegate.currentViewport()
        let viewportWidth = viewport.width
        let viewportHeight = viewport.height

        let firstDataPoint = owner.graphPoint(forIndex: activePointsInterval.lowerBound)
        var firstLineSegment: ColoredLineSegment = ColoredLineSegment.init(currentLinePath: UIBezierPath.init(), lineColor: firstDataPoint.colorOverride?.cgColor, lineWidth: self.lineWidth, lineDashPattern: self.lineDashPattern)

        // Connect the line to the starting edge if we are filling it.
        if(shouldFill) {
            // Add a line from the base of the graph to the first data point.
            let viewportLeftZero = CGPoint(x: firstDataPoint.location.x - (pointPadding.leftmostPointPadding), y: zeroYPosition)
            let leftFarEdgeTop = CGPoint(x: firstDataPoint.location.x - (pointPadding.leftmostPointPadding + viewportWidth), y: zeroYPosition)
            let leftFarEdgeBottom = CGPoint(x: firstDataPoint.location.x - (pointPadding.leftmostPointPadding + viewportWidth), y: viewportHeight)

            currentLinePath.move(to: leftFarEdgeBottom)
            pathSegmentAdder(leftFarEdgeBottom, leftFarEdgeTop, currentLinePath)
            pathSegmentAdder(leftFarEdgeTop, viewportLeftZero, currentLinePath)
            pathSegmentAdder(viewportLeftZero, CGPoint(x: firstDataPoint.location.x, y: firstDataPoint.location.y), currentLinePath)

            // Colors Segment
            firstLineSegment.currentLinePath.move(to: leftFarEdgeBottom)
            pathSegmentAdder(leftFarEdgeBottom, leftFarEdgeTop, firstLineSegment.currentLinePath)
            pathSegmentAdder(leftFarEdgeTop, viewportLeftZero, firstLineSegment.currentLinePath)
            pathSegmentAdder(viewportLeftZero, CGPoint(x: firstDataPoint.location.x, y: firstDataPoint.location.y), firstLineSegment.currentLinePath)

        }
        else {
            currentLinePath.move(to: firstDataPoint.location)
            // Colors Segment
            firstLineSegment.currentLinePath.move(to: firstDataPoint.location)
        }
        // Add the first color segment
        self.coloredCurrentLinePaths.append(firstLineSegment)

        // Connect each point on the graph with a segment.
        for i in activePointsInterval.lowerBound ..< activePointsInterval.upperBound - 1 {

            let startPoint = owner.graphPoint(forIndex: i)
            let endPoint = owner.graphPoint(forIndex: i+1)

            // Get the active colored path
            let mostRecentColoredLinePath = self.coloredCurrentLinePaths.last!

            // Skip the invisible points, just move to the next one
            if (!(startPoint.isVisible || endPoint.isVisible)) {
                currentLinePath.move(to: endPoint.location)
                mostRecentColoredLinePath.currentLinePath.move(to: endPoint.location)
                continue
            }

            // Check for changes from the current line path color:
//            let didStartColorChange = (mostRecentColoredLinePath.lineColor != startPoint.colorOverride?.cgColor)

            // Determine if the current pair is continuing the same color
            let didActivePairColorChange = (startPoint.colorOverride?.cgColor != startPoint.colorOverride?.cgColor)


//            if (didStartColorChange) {
//                var newLineSegment: ColoredLineSegment = ColoredLineSegment.init(currentLinePath: self.currentLinePath, lineColor: startPoint.colorOverride?.cgColor, lineWidth: self.lineWidth, lineDashPattern: self.lineDashPattern)
//                self.coloredCurrentLinePaths.append(newLineSegment)
//            }
//            else {
//                pathSegmentAdder(startPoint.location, endPoint.location, mostRecentColoredLinePath.currentLinePath)
//            }

             // In this case, the last line was the last of that color
            if (didActivePairColorChange) {
                // Need to create a new line color.
                var newLineSegment: ColoredLineSegment = ColoredLineSegment.init(currentLinePath: UIBezierPath.init(), lineColor: endPoint.colorOverride?.cgColor, lineWidth: self.lineWidth, lineDashPattern: self.lineDashPattern)
                newLineSegment.currentLinePath.move(to: endPoint.location)
                // Add the segment
                self.coloredCurrentLinePaths.append(newLineSegment)
            }
            else {
                // If the same color is just continued, update the most recentColoredLinePath
                pathSegmentAdder(startPoint.location, endPoint.location, mostRecentColoredLinePath.currentLinePath)
            }


//            // Check the color overrides
//            if let validStartOverride = startPoint.colorOverride?.cgColor {
//
//            }
//            if let validEndOverride = endPoint.colorOverride?.cgColor {
//
//            }

            pathSegmentAdder(startPoint.location, endPoint.location, currentLinePath)

        }

        // Connect the line to the ending edge if we are filling it.
        if(shouldFill) {
            // Add a line from the last data point to the base of the graph.
            let lastDataPoint = owner.graphPoint(forIndex: activePointsInterval.upperBound - 1).location

            let viewportRightZero = CGPoint(x: lastDataPoint.x + (pointPadding.rightmostPointPadding), y: zeroYPosition)
            let rightFarEdgeTop = CGPoint(x: lastDataPoint.x + (pointPadding.rightmostPointPadding + viewportWidth), y: zeroYPosition)
            let rightFarEdgeBottom = CGPoint(x: lastDataPoint.x + (pointPadding.rightmostPointPadding + viewportWidth), y: viewportHeight)

            pathSegmentAdder(lastDataPoint, viewportRightZero, currentLinePath)
            pathSegmentAdder(viewportRightZero, rightFarEdgeTop, currentLinePath)
            pathSegmentAdder(rightFarEdgeTop, rightFarEdgeBottom, currentLinePath)
        }

        return self.coloredCurrentLinePaths
    }


    //ORIGINAL
    internal func createLinePath() -> UIBezierPath {
        
        guard let owner = owner else {
            return UIBezierPath()
        }
        
        // Can't really do anything without the delegate.
        guard let delegate = self.owner?.graphViewDrawingDelegate else {
            return currentLinePath
        }
        
        currentLinePath.removeAllPoints()
        
        let pathSegmentAdder: ((CGPoint, CGPoint, UIBezierPath) -> ()) = lineStyle == .straight ? addStraightLineSegment : addCurvedLineSegment
        
        let activePointsInterval = delegate.intervalForActivePoints()
        
        let pointPadding = delegate.paddingForPoints()
        
        let min = delegate.rangeForActivePoints().min
        zeroYPosition = delegate.calculatePosition(atIndex: 0, value: min).y
        
        let viewport = delegate.currentViewport()
        let viewportWidth = viewport.width
        let viewportHeight = viewport.height
        
        // Connect the line to the starting edge if we are filling it.
        if(shouldFill) {
            // Add a line from the base of the graph to the first data point.
            let firstDataPoint = owner.graphPoint(forIndex: activePointsInterval.lowerBound)
            
            let viewportLeftZero = CGPoint(x: firstDataPoint.location.x - (pointPadding.leftmostPointPadding), y: zeroYPosition)
            let leftFarEdgeTop = CGPoint(x: firstDataPoint.location.x - (pointPadding.leftmostPointPadding + viewportWidth), y: zeroYPosition)
            let leftFarEdgeBottom = CGPoint(x: firstDataPoint.location.x - (pointPadding.leftmostPointPadding + viewportWidth), y: viewportHeight)
            
            currentLinePath.move(to: leftFarEdgeBottom)
            pathSegmentAdder(leftFarEdgeBottom, leftFarEdgeTop, currentLinePath)
            pathSegmentAdder(leftFarEdgeTop, viewportLeftZero, currentLinePath)
            pathSegmentAdder(viewportLeftZero, CGPoint(x: firstDataPoint.location.x, y: firstDataPoint.location.y), currentLinePath)
        }
        else {
            let firstDataPoint = owner.graphPoint(forIndex: activePointsInterval.lowerBound)
            currentLinePath.move(to: firstDataPoint.location)
        }
        
        // Connect each point on the graph with a segment.
        for i in activePointsInterval.lowerBound ..< activePointsInterval.upperBound - 1 {
            
            let startPoint = owner.graphPoint(forIndex: i)
            let endPoint = owner.graphPoint(forIndex: i+1)

            // Skip the invisible points, just move to the next one
            if (!(startPoint.isVisible || endPoint.isVisible)) {
                currentLinePath.move(to: endPoint.location)
                continue
            }
            pathSegmentAdder(startPoint.location, endPoint.location, currentLinePath)

        }
        
        // Connect the line to the ending edge if we are filling it.
        if(shouldFill) {
            // Add a line from the last data point to the base of the graph.
            let lastDataPoint = owner.graphPoint(forIndex: activePointsInterval.upperBound - 1).location
            
            let viewportRightZero = CGPoint(x: lastDataPoint.x + (pointPadding.rightmostPointPadding), y: zeroYPosition)
            let rightFarEdgeTop = CGPoint(x: lastDataPoint.x + (pointPadding.rightmostPointPadding + viewportWidth), y: zeroYPosition)
            let rightFarEdgeBottom = CGPoint(x: lastDataPoint.x + (pointPadding.rightmostPointPadding + viewportWidth), y: viewportHeight)
            
            pathSegmentAdder(lastDataPoint, viewportRightZero, currentLinePath)
            pathSegmentAdder(viewportRightZero, rightFarEdgeTop, currentLinePath)
            pathSegmentAdder(rightFarEdgeTop, rightFarEdgeBottom, currentLinePath)
        }
        
        return currentLinePath
    }
    
    private func addStraightLineSegment(startPoint: CGPoint, endPoint: CGPoint, inPath path: UIBezierPath) {
        path.addLine(to: endPoint)
    }
    
    private func addCurvedLineSegment(startPoint: CGPoint, endPoint: CGPoint, inPath path: UIBezierPath) {
        // calculate control points
        let difference = endPoint.x - startPoint.x
        
        var x = startPoint.x + (difference * lineCurviness)
        var y = startPoint.y
        let controlPointOne = CGPoint(x: x, y: y)
        
        x = endPoint.x - (difference * lineCurviness)
        y = endPoint.y
        let controlPointTwo = CGPoint(x: x, y: y)
        
        // add curve from start to end
        currentLinePath.addCurve(to: endPoint, controlPoint1: controlPointOne, controlPoint2: controlPointTwo)
    }
    
    override func updatePath() {
        self.path = createLinePath().cgPath
    }
}
