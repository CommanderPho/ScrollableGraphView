import UIKit

internal class GraphPoint {
    
    var location = CGPoint(x: 0, y: 0)
    var currentlyAnimatingToPosition = false
    var isVisible: Bool = true
    var colorOverride: UIColor? = nil
    
    var x: CGFloat {
        get {
            return location.x
        }
        set {
            location.x = newValue
        }
    }
    
    var y: CGFloat {
        get {
            return location.y
        }
        set {
            location.y = newValue
        }
    }
    
    init(position: CGPoint = CGPoint.zero) {
        x = position.x
        y = position.y
    }

    convenience init(position: CGPoint = CGPoint.zero, data: PlotPointData = PlotPointData.init()) {
        self.init(position: position)
        self.isVisible = data.isVisible
        self.colorOverride = data.colorOverride
    }
}
