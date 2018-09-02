
#if os(OSX)
    import Cocoa
#else
    import UIKit
#endif

internal class GradientDrawingLayer : ScrollableGraphViewDrawingLayer {
    
    private var startColor: ScrollableGraphViewNSUI.NSUIColor
    private var endColor: ScrollableGraphViewNSUI.NSUIColor
    private var gradientType: ScrollableGraphViewGradientType
    private var gradientOrientation: ScrollableGraphViewLinearGradientOrientation
    
    // Gradient fills are only used with lineplots and we need 
    // to know what the line looks like.
    private var lineDrawingLayer: LineDrawingLayer
    
    lazy private var gradientMask: CAShapeLayer = ({
        let mask = CAShapeLayer()
        
        mask.frame = CGRect(x: 0, y: 0, width: self.viewportWidth, height: self.viewportHeight)
        mask.fillRule = kCAFillRuleEvenOdd
        mask.lineJoin = self.lineJoin
        
        return mask
    })()

    init(frame: CGRect, startColor: ScrollableGraphViewNSUI.NSUIColor, endColor: ScrollableGraphViewNSUI.NSUIColor, gradientType: ScrollableGraphViewGradientType, gradientOrientation: ScrollableGraphViewLinearGradientOrientation, lineJoin: String = kCALineJoinRound, lineDrawingLayer: LineDrawingLayer) {
        self.startColor = startColor
        self.endColor = endColor
        self.gradientType = gradientType
        //self.lineJoin = lineJoin
        self.gradientOrientation = gradientOrientation
        
        self.lineDrawingLayer = lineDrawingLayer

        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)
        
        addMaskLayer()
        self.setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addMaskLayer() {
        self.mask = gradientMask
    }
    
    override func updatePath() {
        gradientMask.path = lineDrawingLayer.createLinePath().cgPath
    }
    
    override func draw(in ctx: CGContext) {
        
        let colors = [startColor.cgColor, endColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [0.0, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)
        
        let verticalDisplacement = ((viewportWidth / viewportHeight) / 2.5) * self.bounds.height

        let horizontalDisplacement = ((viewportHeight / viewportWidth) / 2.5) * self.bounds.width

        // Note: horizontalCenterOffset used to be "offset + self.bounds.width / 2"
        let horizontalCenterOffset: CGFloat = offset + (self.bounds.width / 2.0) // The horizontal offset plus the offset to reach the center of frame
        let verticalCenterOffset: CGFloat = (self.bounds.height / 2.0)

        let topCentre = CGPoint(x: horizontalCenterOffset, y: -verticalDisplacement)
        let bottomCentre = CGPoint(x: horizontalCenterOffset, y: self.bounds.height)

        switch(gradientType) {
        case .linear:

            let leftCenter = CGPoint(x: offset, y: verticalCenterOffset)
            let rightCenter = CGPoint(x: (offset + self.bounds.width), y: verticalCenterOffset)

            let startPoint: CGPoint
            let endPoint: CGPoint

            switch self.gradientOrientation {
            case .TopToBottom:
                startPoint = topCentre
                endPoint = bottomCentre
            case .BottomToTop:
                startPoint = bottomCentre
                endPoint = topCentre
            case .LeftToRight:
                startPoint = leftCenter
                endPoint = rightCenter
            case .RightToLeft:
                startPoint = rightCenter
                endPoint = leftCenter
            }
            ctx.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: .drawsAfterEndLocation)

        case .radial:
            let startRadius: CGFloat = 0
            let endRadius: CGFloat = self.bounds.width
            ctx.drawRadialGradient(gradient!, startCenter: topCentre, startRadius: startRadius, endCenter: topCentre, endRadius: endRadius, options: .drawsAfterEndLocation)
        }
    }
}
