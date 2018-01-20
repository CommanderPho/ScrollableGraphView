
import UIKit

public class ScrollableGraphViewDrawingLayer : CAShapeLayer {
    
    public var offset: CGFloat = 0 {
        didSet {
            offsetDidChange()
        }
    }
    
    public var viewportWidth: CGFloat = 0
    public var viewportHeight: CGFloat = 0
    public var zeroYPosition: CGFloat = 0
    
    public weak var owner: Plot?
    
    public var active = true
    
    public init(viewportWidth: CGFloat, viewportHeight: CGFloat, offset: CGFloat = 0) {
        super.init()
        
        self.viewportWidth = viewportWidth
        self.viewportHeight = viewportHeight
        
        self.frame = CGRect(origin: CGPoint(x: offset, y: 0), size: CGSize(width: self.viewportWidth, height: self.viewportHeight))
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        // Get rid of any animations.
        self.actions = ["position" : NSNull(), "bounds" : NSNull()]
    }
    
    private func offsetDidChange() {
        self.frame.origin.x = offset
        self.bounds.origin.x = offset
    }
    
    public func updatePath() {
        fatalError("updatePath needs to be implemented by the subclass")
    }
}

