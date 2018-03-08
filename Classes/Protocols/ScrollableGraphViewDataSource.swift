
import UIKit

public protocol ScrollableGraphViewDataSource {
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double
    func label(atIndex pointIndex: Int) -> String
    func numberOfPoints() -> Int // This now forces the same number of points in each plot.

    // Optional Methods:
    func isVisible(forPlot plot: Plot, atIndex pointIndex: Int) -> Bool
    func valueColor(forPlot plot: Plot, atIndex pointIndex: Int) -> UIColor?

    func labelColor(atIndex pointIndex: Int) -> UIColor?
}


// Optional Protocol Methods Extension



// Optional Protocol Implementations
extension ScrollableGraphViewDataSource {
    func isVisible(forPlot plot: Plot, atIndex pointIndex: Int) -> Bool {
        return true
    }

    func valueColor(forPlot plot: Plot, atIndex pointIndex: Int) -> UIColor? {
        return nil
    }


    func labelColor(atIndex pointIndex: Int) -> UIColor? {
        return nil
    }
}
