
#if os(OSX)
    import Cocoa
#else
    import UIKit
#endif

// MARK: Drawing the bars
internal class BarDrawingLayer: ScrollableGraphViewDrawingLayer {
    
    private var barPath = ScrollableGraphViewNSUI.NSUIBezierPath()
    private var barWidth: CGFloat = 4
    private var shouldRoundCorners = false
    
    init(frame: CGRect, barWidth: CGFloat, barColor: ScrollableGraphViewNSUI.NSUIColor, barLineWidth: CGFloat, barLineColor: ScrollableGraphViewNSUI.NSUIColor, shouldRoundCorners: Bool) {
        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)
        
        self.barWidth = barWidth
        self.lineWidth = barLineWidth
        self.strokeColor = barLineColor.cgColor
        self.fillColor = barColor.cgColor
        self.shouldRoundCorners = shouldRoundCorners
        
        self.lineJoin = lineJoin
        self.lineCap = lineCap
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createBarPath(centre: CGPoint) -> ScrollableGraphViewNSUI.NSUIBezierPath {
        
        let barWidthOffset: CGFloat = self.barWidth / 2
        
        let origin = CGPoint(x: centre.x - barWidthOffset, y: centre.y)
        let size = CGSize(width: barWidth, height: zeroYPosition - centre.y)
        let rect = CGRect(origin: origin, size: size)
        
        let barPath: ScrollableGraphViewNSUI.NSUIBezierPath = {
            if shouldRoundCorners {
                return ScrollableGraphViewNSUI.NSUIBezierPath(roundedRect: rect, cornerRadius: barWidthOffset)
            } else {
                return ScrollableGraphViewNSUI.NSUIBezierPath(rect: rect)
            }
        }()
        
        return barPath
    }
    
    private func createPath () -> ScrollableGraphViewNSUI.NSUIBezierPath {
        
        barPath.removeAllPoints()
        
        // We can only move forward if we can get the data we need from the delegate.
        guard let activePointsInterval = self.owner?.graphViewDrawingDelegate?.intervalForActivePoints() else {
                return barPath
        }
        
        for i in activePointsInterval {
            
            var location = CGPoint.zero
            var isVisible: Bool = false
            var colorOveride: ScrollableGraphViewNSUI.NSUIColor? = nil

            if let point = owner?.graphPoint(forIndex: i) {
                location = point.location
                isVisible = point.isVisible
                colorOveride = point.colorOverride
            }
            let pointPath: ScrollableGraphViewNSUI.NSUIBezierPath
            if (isVisible) {
                pointPath = createBarPath(centre: location)
                barPath.append(pointPath)
            }


//            if let pointLocation = owner?.graphPoint(forIndex: i).location {
//                location = pointLocation
//            }
//
//            let pointPath = createBarPath(centre: location)
//            barPath.append(pointPath)
        }
        
        return barPath
    }
    
    override func updatePath() {
        
        self.path = createPath ().cgPath
    }
}
