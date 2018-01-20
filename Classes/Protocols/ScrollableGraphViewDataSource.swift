
import UIKit

public protocol ScrollableGraphViewDataSource {
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double
    func label(atIndex pointIndex: Int) -> String
    func isVisible(forPlot plot: Plot, atIndex pointIndex: Int) -> Bool
    func numberOfPoints() -> Int // This now forces the same number of points in each plot.
}
