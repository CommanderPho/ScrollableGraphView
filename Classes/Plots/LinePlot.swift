
#if os(OSX)
    import Cocoa
#else
    import UIKit
#endif

open class LinePlot : Plot {
    
    // Public settings for the LinePlot
    // ################################
    
    /// Specifies how thick the graph of the line is. In points.
    open var lineWidth: CGFloat = 2
    
    /// The color of the graph line. ScrollableGraphViewNSUI.NSUIColor.
    open var lineColor: ScrollableGraphViewNSUI.NSUIColor = ScrollableGraphViewNSUI.NSUIColor.black
    
    /// Whether the line is straight or curved.
    open var lineStyle_: Int {
        get { return lineStyle.rawValue }
        set {
            if let enumValue = ScrollableGraphViewLineStyle(rawValue: newValue) {
                lineStyle = enumValue
            }
        }
    }

    /// Whether or not the line should be rendered using bezier curves are straight lines.
    open var lineStyle = ScrollableGraphViewLineStyle.straight
    
    /// How each segment in the line should connect. Takes any of the Core Animation LineJoin values.
    open var lineJoin: String = kCALineJoinRound
    
    /// The line caps. Takes any of the Core Animation LineCap values.
    open var lineCap: String = kCALineCapRound
    open var lineCurviness: CGFloat = 0.5


    //[nil, [2,3], [10, 5, 5, 5]]
    open var lineDashPattern: [NSNumber]? = nil
//    open var disconnectByZeros: Bool = false

    
    // Fill Settings
    // #############
    
    /// Specifies whether or not the plotted graph should be filled with a colour or gradient.
    open var shouldFill: Bool = false
    
    var fillType_: Int {
        get { return fillType.rawValue }
        set {
            if let enumValue = ScrollableGraphViewFillType(rawValue: newValue) {
                fillType = enumValue
            }
        }
    }
    
    /// Specifies whether to fill the graph with a solid colour or gradient.
    open var fillType = ScrollableGraphViewFillType.solid
    
    /// If fillType is set to .Solid then this colour will be used to fill the graph.
    open var fillColor: ScrollableGraphViewNSUI.NSUIColor = ScrollableGraphViewNSUI.NSUIColor.black
    
    /// If fillType is set to .Gradient then this will be the starting colour for the gradient.
    open var fillGradientStartColor: ScrollableGraphViewNSUI.NSUIColor = ScrollableGraphViewNSUI.NSUIColor.white
    
    /// If fillType is set to .Gradient, then this will be the ending colour for the gradient.
    open var fillGradientEndColor: ScrollableGraphViewNSUI.NSUIColor = ScrollableGraphViewNSUI.NSUIColor.black
    
    open var fillGradientType_: Int {
        get { return fillGradientType.rawValue }
        set {
            if let enumValue = ScrollableGraphViewGradientType(rawValue: newValue) {
                fillGradientType = enumValue
            }
        }
    }
    
    /// If fillType is set to .Gradient, then this defines whether the gradient is rendered as a linear gradient or radial gradient.
    open var fillGradientType = ScrollableGraphViewGradientType.linear

    open var fillGradientOrientation: ScrollableGraphViewLinearGradientOrientation = ScrollableGraphViewLinearGradientOrientation.TopToBottom

    open var fillGradientComplexity: ScrollableGraphViewGradientComplexity = ScrollableGraphViewGradientComplexity.Simple

    // Private State
    // #############
    
    private var lineLayer: LineDrawingLayer?
    private var fillLayer: FillDrawingLayer?
    private var gradientLayer: GradientDrawingLayer?

    public init(identifier: String) {
        super.init()
        self.identifier = identifier
    }
    
    override func layers(forViewport viewport: CGRect) -> [ScrollableGraphViewDrawingLayer?] {
        createLayers(viewport: viewport)
        return [lineLayer, fillLayer, gradientLayer]
    }
    
    private func createLayers(viewport: CGRect) {
        
        // Create the line drawing layer.
        lineLayer = LineDrawingLayer(frame: viewport, lineWidth: lineWidth, lineColor: lineColor, lineStyle: lineStyle, lineJoin: lineJoin, lineCap: lineCap, shouldFill: shouldFill, lineCurviness: lineCurviness, lineDashPattern: lineDashPattern)
        lineLayer?.name = "\(self.identifier).lineLayer"
        // Depending on whether we want to fill with solid or gradient, create the layer accordingly.
        
        // Gradient and Fills
        switch (self.fillType) {
            
        case .solid:
            if(shouldFill) {
                // Setup fill
                fillLayer = FillDrawingLayer(frame: viewport, fillColor: fillColor, lineDrawingLayer: lineLayer!)
                fillLayer?.name = "\(self.identifier).fillLayer"
            }
            
        case .gradient:
            if(shouldFill) {
                gradientLayer = GradientDrawingLayer(frame: viewport, startColor: fillGradientStartColor, endColor: fillGradientEndColor, gradientType: fillGradientType, gradientOrientation: self.fillGradientOrientation, gradientColorComplexity: self.fillGradientComplexity, lineDrawingLayer: lineLayer!)
                gradientLayer?.name = "\(self.identifier).gradientFillLayer"
            }
        }
        
        lineLayer?.owner = self
        fillLayer?.owner = self
        gradientLayer?.owner = self
    }
}

@objc public enum ScrollableGraphViewLineStyle : Int {
    case straight
    case smooth
}

@objc public enum ScrollableGraphViewFillType : Int {
    case solid
    case gradient
}

@objc public enum ScrollableGraphViewGradientType : Int {
    case linear
    case radial
}

@objc public enum ScrollableGraphViewLinearGradientOrientation : Int {
    case TopToBottom // Default: maps (startPoint = top, endPoint = bottom)
    case BottomToTop // maps (startPoint = bottom, endPoint = top)
    case RightToLeft // maps (startPoint = right, endPoint = left)
    case LeftToRight // maps (startPoint = left, endPoint = right)
}

@objc public enum ScrollableGraphViewGradientComplexity : Int {
    case Simple // Default: Simple two color gradient
    case DatasourceProvidedColors // Uses the colors provided by the DataSource
}
