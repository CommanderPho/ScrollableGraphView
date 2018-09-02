
#if os(OSX)
    import Cocoa
#else
    import UIKit
#endif

internal class LabelPool {
    
    var labels = [ScrollableGraphViewNSUI.NSUILabel]()
    var relations = [Int : Int]()
    var unused = [Int]()
    
    func deactivateLabel(forPointIndex pointIndex: Int){
        
        if let unusedLabelIndex = relations[pointIndex] {
            unused.append(unusedLabelIndex)
        }
        relations[pointIndex] = nil
    }
    
    @discardableResult
    func activateLabel(forPointIndex pointIndex: Int) -> ScrollableGraphViewNSUI.NSUILabel {
        var label: ScrollableGraphViewNSUI.NSUILabel
        
        if(unused.count >= 1) {
            let unusedLabelIndex = unused.first!
            unused.removeFirst()
            
            label = labels[unusedLabelIndex]
            relations[pointIndex] = unusedLabelIndex
        }
        else {
            label = ScrollableGraphViewNSUI.NSUILabel()
            labels.append(label)
            let newLabelIndex = labels.index(of: label)!
            relations[pointIndex] = newLabelIndex
        }
        
        return label
    }
    
    var activeLabels: [ScrollableGraphViewNSUI.NSUILabel] {
        get {
            
            var currentlyActive = [ScrollableGraphViewNSUI.NSUILabel]()
            let numberOfLabels = labels.count
            
            for i in 0 ..< numberOfLabels {
                if(!unused.contains(i)) {
                    currentlyActive.append(labels[i])
                }
            }
            return currentlyActive
        }
    }
}
