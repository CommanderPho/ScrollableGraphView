import UIKit

// MARK: - ScrollableGraphView
@IBDesignable
@objc open class ScrollableGraphView: UIScrollView, UIScrollViewDelegate, ScrollableGraphViewDrawingDelegate {
    
    // MARK: - Public Properties
    // Use these to customise the graph.
    // #################################
    
    // Fill Styles
    // ###########
    
    /// The background colour for the entire graph view, not just the plotted graph.
    @IBInspectable open var backgroundFillColor: UIColor = UIColor.white
    
    // Spacing
    // #######
    
    /// How far the "maximum" reference line is from the top of the view's frame. In points.
    @IBInspectable open var topMargin: CGFloat = 10
    /// How far the "minimum" reference line is from the bottom of the view's frame. In points.
    @IBInspectable open var bottomMargin: CGFloat = 10
    /// How far the first point on the graph should be placed from the left hand side of the view.
    @IBInspectable open var leftmostPointPadding: CGFloat = 50
    /// How far the final point on the graph should be placed from the right hand side of the view.
    @IBInspectable open var rightmostPointPadding: CGFloat = 50
    /// How much space should be between each data point.
    @IBInspectable open var dataPointSpacing: CGFloat = 40
    
    @IBInspectable var direction_: Int {
        get { return direction.rawValue }
        set {
            if let enumValue = ScrollableGraphViewDirection(rawValue: newValue) {
                direction = enumValue
            }
        }
    }
    /// Which side of the graph the user is expected to scroll from.
    open var direction = ScrollableGraphViewDirection.leftToRight
    
    // Graph Range
    // ###########
    
    /// Forces the graph's minimum to always be zero. Used in conjunction with shouldAutomaticallyDetectRange or shouldAdaptRange, if you want to force the minimum to stay at 0 rather than the detected minimum.
    @IBInspectable open var shouldRangeAlwaysStartAtZero: Bool = false
    /// The minimum value for the y-axis. This is ignored when shouldAutomaticallyDetectRange or shouldAdaptRange = true
    @IBInspectable open var rangeMin: Double = 0
    /// The maximum value for the y-axis. This is ignored when shouldAutomaticallyDetectRange or shouldAdaptRange = true
    @IBInspectable open var rangeMax: Double = 100
    
    // Adapting & Animations
    // #####################
    
    /// Whether or not the y-axis' range should adapt to the points that are visible on screen. This means if there are only 5 points visible on screen at any given time, the maximum on the y-axis will be the maximum of those 5 points. This is updated automatically as the user scrolls along the graph.
    @IBInspectable open var shouldAdaptRange: Bool = false
    /// If shouldAdaptRange is set to true then this specifies whether or not the points on the graph should animate to their new positions. Default is set to true.
    @IBInspectable open var shouldAnimateOnAdapt: Bool = true
    
    /// Whether or not the graph should animate to their positions when the graph is first displayed.
    @IBInspectable open var shouldAnimateOnStartup: Bool = true
    
    // Reference Line Settings
    // #######################
    
    var referenceLines: ReferenceLines? = nil
    
    // MARK: - Private State
    // #####################
    
    private var isInitialSetup = true
    private var isCurrentlySettingUp = false
    
    internal var viewportWidth: CGFloat = 0 {
        didSet { if(oldValue != viewportWidth) { viewportDidChange() }}
    }
    internal var viewportHeight: CGFloat = 0 {
        didSet { if(oldValue != viewportHeight) { viewportDidChange() }}
    }
    
    internal var totalGraphWidth: CGFloat = 0
    internal var offsetWidth: CGFloat = 0
    
    // Graph Line
    internal var zeroYPosition: CGFloat = 0
    
    // Graph Drawing
    private var drawingView = UIView()
    private var plots: [Plot] = [Plot]()
    
    // Reference Lines
    private var referenceLineView: ReferenceLineDrawingView?
    
    // Labels
    private var labelsView = UIView()
    private var labelPool = LabelPool()
    
    // Data Source
    weak open var dataSource: ScrollableGraphViewDataSource? {
        didSet {
            if(plots.count > 0) {
                reload()
            }
        }
    }


    // Returns the current size and offset of the viewport
    open var viewportInfo: ViewportInfo {
        return ViewportInfo(width: self.viewportWidth, height: self.viewportHeight, offset: (self.offsetWidth, 0.0), totalGraphWidth: self.totalGraphWidth)
    }

    public func getDrawingView() -> UIView {
        return self.drawingView
    }
    public func getReferenceLinesView() -> UIView? {
        return self.referenceLineView
    }
    public func getLabelsView() -> UIView {
        return self.labelsView
    }

    // Delegate
    open var graphViewDelegate: ScrollableGraphViewDelegate? = nil
    
    // Active Points & Range Calculation
    internal var previousActivePointsInterval: CountableRange<Int> = -1 ..< -1
    internal var activePointsInterval: CountableRange<Int> = -1 ..< -1 {
        didSet {
            if(oldValue.lowerBound != activePointsInterval.lowerBound || oldValue.upperBound != activePointsInterval.upperBound) {
                if !isCurrentlySettingUp { activePointsDidChange() }
            }
        }
    }
    
    internal var range: (min: Double, max: Double) = (0, 100) {
        didSet {
            if(oldValue.min != range.min || oldValue.max != range.max) {
                if !isCurrentlySettingUp { rangeDidChange() }
            }
        }
    }
    
    // MARK: - INIT, SETUP & VIEWPORT RESIZING
    // #######################################
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public init(frame: CGRect, dataSource: ScrollableGraphViewDataSource) {
        self.dataSource = dataSource
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        for plot in plots {
            plot.invalidate()
        }
    }
    
    // You can change how you want the graph to appear in interface builder here.
    // This ONLY changes how it appears in interface builder, you will still need
    // to setup the graph properly in your view controller for it to change in the
    // actual application.
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        self.dataSource = self as? ScrollableGraphViewDataSource
        self.shouldAnimateOnStartup = false
        
        // Customise how the reference lines look in IB
        let referenceLines = ReferenceLines()
        self.addReferenceLines(referenceLines: referenceLines)
    }


    public func reset() {
        self.stopAnimations()
        self.graphViewDelegate = nil
        self.plots.removeAll()
        self.referenceLineView?.removeFromSuperview()
        self.labelsView.removeFromSuperview()
        self.drawingView.removeFromSuperview()

        self.referenceLines = nil

        self.isInitialSetup = true
        self.isCurrentlySettingUp = false

        self.viewportWidth = 0
        self.viewportHeight = 0
        self.totalGraphWidth = 0
        self.offsetWidth = 0
        // Graph Line
        self.zeroYPosition = 0
        // Graph Drawing
        self.drawingView = UIView()
        self.plots = [Plot]()

        // Reference Lines
        self.referenceLineView = nil

        // Labels
        self.labelsView = UIView()
        self.labelPool = LabelPool()

        // Data Source
        self.dataSource = nil
        // Active Points & Range Calculation
        self.previousActivePointsInterval = -1 ..< -1
        self.activePointsInterval = -1 ..< -1
        self.range = (0, 100)
    }

    private func setup() {
        clipsToBounds = true
        isCurrentlySettingUp = true
        
        // 0.
        // Save the viewport, that is, the size of the rectangle through which we view the graph.
        
        self.viewportWidth = self.frame.width
        self.viewportHeight = self.frame.height
        
        let viewport = CGRect(x: 0, y: 0, width: viewportWidth, height: viewportHeight)
        
        // 1.
        // Add the subviews we will use to draw everything.
        
        // Add the drawing view in which we draw all the plots.
        self.drawingView = UIView(frame: viewport)
        self.drawingView.backgroundColor = backgroundFillColor
        self.drawingView.accessibilityIdentifier = "drawingView"
        self.addSubview(drawingView)
        
        // Add the x-axis labels view.
        self.labelsView.accessibilityIdentifier = "labelsView"
        self.drawingView.accessibilityIdentifier = "drawingView"
        self.insertSubview(labelsView, aboveSubview: drawingView)
        
        // 2.
        // Calculate the total size of the graph, need to know this for the scrollview.
        
        // Calculate the drawing frames
        let numberOfDataPoints = dataSource?.numberOfPoints() ?? 0
        self.totalGraphWidth = graphWidth(forNumberOfDataPoints: numberOfDataPoints)
        self.contentSize = CGSize(width: self.totalGraphWidth, height: self.viewportHeight)
        
        // Scrolling direction.
        
        #if TARGET_INTERFACE_BUILDER
            self.offsetWidth = 0
        #else
            if (direction == .rightToLeft) {
                self.offsetWidth = self.contentSize.width - viewportWidth
            }
                // Otherwise start of all the way to the left.
            else {
                self.offsetWidth = 0
            }
        #endif
        
        // Set the scrollview offset.
        self.contentOffset.x = self.offsetWidth
        
        // 3.
        // Calculate the points that we will be able to see when the view loads.
        
        let initialActivePointsInterval = calculateActivePointsInterval()
        self.graphViewDelegate?.scrollableGraphView(self, batchUpdateActivePoints: initialActivePointsInterval.map{$0})

        // 4.
        // Add the plots to the graph, we need these to calculate the range.
        
        while(self.queuedPlots.count > 0) {
            if let plot = self.queuedPlots.dequeue() {
                self.addPlotToGraph(plot: plot, activePointsInterval: initialActivePointsInterval)
            }
        }
        
        // 5.
        // Calculate the range for the points we can actually see.
        
        #if TARGET_INTERFACE_BUILDER
            self.range = (min: rangeMin, max: rangeMax)
        #else
            // Need to calculate the range across all plots to get the min and max for all plots.
            if (shouldAdaptRange) { // This overwrites anything specified by rangeMin and rangeMax
                let range = calculateRange(forActivePointsInterval: initialActivePointsInterval)
                self.range = range
            }
            else {
                self.range = (min: rangeMin, max: rangeMax) // just use what the user specified instead.
            }
        #endif
        
        // If the graph was given all 0s as data, we can't use a range of 0->0, so make sure we have a sensible range at all times.
        if (self.range.min == 0 && self.range.max == 0) {
            self.range = (min: 0, max: rangeMax)
        }
        
        // 6.
        // Add the reference lines, can only add this once we know the range.

        if(referenceLines != nil) {
            addReferenceViewDrawingView()
        }
        
        // 7.
        // We're now done setting up, update the offsets and change the flag.
        
        updateOffsetWidths()
        isCurrentlySettingUp = false
        
        // Set the first active points interval. These are the points that are visible when the view loads.
        self.activePointsInterval = initialActivePointsInterval
    }
    
    // TODO in 4.1: Plot layer ordering.
    // TODO in 4.1: Plot removal.
    private func addDrawingLayersForPlots(inViewport viewport: CGRect) {
        for plot in plots {
            addSubLayers(layers: plot.layers(forViewport: viewport))
        }
    }
    
    private func addSubLayers(layers: [ScrollableGraphViewDrawingLayer?]) {
        for layer in layers {
            if let layer = layer {
                drawingView.layer.addSublayer(layer)
            }
        }
    }
    
    private func addReferenceViewDrawingView() {
        
        guard let referenceLines = self.referenceLines else {
            // We can want to add this if the settings arent nil.
            return
        }
        
        if(referenceLines.shouldShowReferenceLines) {
            let viewport = CGRect(x: 0, y: 0, width: viewportWidth, height: viewportHeight)
            var referenceLineBottomMargin = bottomMargin
            
            // Have to adjust the bottom line if we are showing data point labels (x-axis).
            if(referenceLines.shouldShowLabels && referenceLines.dataPointLabelFont != nil) {
                referenceLineBottomMargin += (referenceLines.dataPointLabelFont!.pointSize + referenceLines.dataPointLabelTopMargin + referenceLines.dataPointLabelBottomMargin)
            }
            
            referenceLineView?.removeFromSuperview()
            referenceLineView = ReferenceLineDrawingView(
                frame: viewport,
                topMargin: topMargin,
                bottomMargin: referenceLineBottomMargin,
                referenceLineColor: referenceLines.referenceLineColor,
                referenceLineThickness: referenceLines.referenceLineThickness,
                referenceLineSettings: referenceLines)

            self.referenceLineView?.accessibilityIdentifier = "referenceLineView"
            referenceLineView?.set(range: self.range)

            self.addSubview(referenceLineView!)
        }
    }
    
    // If the view has changed we have to make sure we're still displaying the right data.
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        // while putting the view on the IB, we may get calls with frame too small
        // if frame height is too small we won't be able to calculate zeroYPosition
        // so make sure to proceed only if there is enough space
        var availableGraphHeight = frame.height
        availableGraphHeight = availableGraphHeight - topMargin - bottomMargin
        
        if let referenceLines = referenceLines {
            if(referenceLines.shouldShowLabels && referenceLines.dataPointLabelFont != nil) {
                availableGraphHeight -= (referenceLines.dataPointLabelFont!.pointSize + referenceLines.dataPointLabelTopMargin + referenceLines.dataPointLabelBottomMargin)
            }
        }
        
        if availableGraphHeight > 0 {
            updateUI()
        }
    }
    
    private func updateUI() {
        
        // Make sure we have data, if don't, just get out. We can't do anything without any data.
        guard let dataSource = dataSource else {
            return
        }
        
        guard dataSource.numberOfPoints() > 0 else {
            return
        }
        
        if (isInitialSetup) {
            setup()
            
            if(shouldAnimateOnStartup) {
                startAnimations(withStaggerValue: 0.15)
            }
            
            // We're done setting up.
            isInitialSetup = false
        }
            // Otherwise, the user is just scrolling and we just need to update everything.
        else {
            // Needs to update the viewportWidth and viewportHeight which is used to calculate which
            // points we can actually see.
            viewportWidth = self.frame.width
            viewportHeight = self.frame.height
            
            // If the scrollview has scrolled anywhere, we need to update the offset
            // and move around our drawing views.
            self.offsetWidth = self.contentOffset.x
            updateOffsetWidths()
            
            // Recalculate active points for this size.
            // Recalculate range for active points.
            let newActivePointsInterval = calculateActivePointsInterval()
            self.previousActivePointsInterval = self.activePointsInterval
            self.activePointsInterval = newActivePointsInterval
            self.graphViewDelegate?.scrollableGraphView(self, batchUpdateActivePoints: newActivePointsInterval.map{$0})

            // If adaption is enabled we want to
            if(shouldAdaptRange) {
                // TODO: This is currently called every single frame...
                // We need to only calculate the range if the active points interval has changed!
                #if !TARGET_INTERFACE_BUILDER
                    let newRange = calculateRange(forActivePointsInterval: newActivePointsInterval)
                    self.range = newRange
                #endif
            }
        }
    }
    
    private func updateOffsetWidths() {
        drawingView.frame.origin.x = offsetWidth
        drawingView.bounds.origin.x = offsetWidth

        self.graphViewDelegate?.scrollableGraphView(self, didUpdateViewportOffset: (self.offsetWidth/self.totalGraphWidth))

        updateOffsetsForGradients(offsetWidth: offsetWidth)
        
        referenceLineView?.frame.origin.x = offsetWidth
    }
    
    private func updateOffsetsForGradients(offsetWidth: CGFloat) {
        guard let sublayers = drawingView.layer.sublayers else {
            return
        }
        
        for layer in sublayers {
            switch(layer) {
            case let layer as GradientDrawingLayer:
                layer.offset = offsetWidth
            default: break
            }
        }
    }
    
    private func updateFrames() {
        // Drawing view needs to always be the same size as the scrollview.
        drawingView.frame.size.width = viewportWidth
        drawingView.frame.size.height = viewportHeight
        
        // Gradient should extend over the entire viewport
        updateFramesForGradientLayers(viewportWidth: viewportWidth, viewportHeight: viewportHeight)
        
        // Reference lines should extend over the entire viewport
        referenceLineView?.set(viewportWidth: viewportWidth, viewportHeight: viewportHeight)
        
        self.contentSize.height = viewportHeight
    }
    
    private func updateFramesForGradientLayers(viewportWidth: CGFloat, viewportHeight: CGFloat) {
        
        guard let sublayers = drawingView.layer.sublayers else {
            return
        }
        
        for layer in sublayers {
            switch(layer) {
            case let layer as GradientDrawingLayer:
                layer.frame.size.width = viewportWidth
                layer.frame.size.height = viewportHeight
            default: break
            }
        }
    }
    
    // MARK: - Public Methods
    // ######################
    
    public func addPlot(plot: Plot) {
        // If we aren't setup yet, save the plot to be added during setup.
        if(self.isInitialSetup) {
            enqueuePlot(plot)
        }
        // Otherwise, just add the plot directly.
        else {
            self.addPlotToGraph(plot: plot, activePointsInterval: self.activePointsInterval)
        }
    }
    
    public func addReferenceLines(referenceLines: ReferenceLines) {
        
        // If we aren't setup yet, just save the reference lines and the setup will take care of it.
        if(isInitialSetup) {
            self.referenceLines = referenceLines
        }
        // Otherwise, add the reference lines, reload everything.
        else {
            addReferenceLinesToGraph(referenceLines: referenceLines)
        }
    }


    // Limitation: Can only be used when reloading the same number of data points!
    public func reload() {
        stopAnimations()
        rangeDidChange()
        updateUI()
        updatePaths()
        updateLabelsForCurrentInterval()
    }
    
    // The functions for adding plots and reference lines need to be able to add plots
    // both before and after the graph knows its viewport/size. 
    // This needs to be the case so we can use it in interface builder as well as 
    // just adding it programatically.
    // These functions add the plots and reference lines to the graph.
    // The public functions will either save the plots and reference lines (in the case
    // don't have the required viewport information) or add it directly to the graph
    // (the case where we already know the viewport information).
    private func addPlotToGraph(plot: Plot, activePointsInterval: CountableRange<Int>) {
        plot.graphViewDrawingDelegate = self
        self.plots.append(plot)
        initPlot(plot: plot, activePointsInterval: activePointsInterval)
        startAnimations(withStaggerValue: 0.15)
    }


//    private func removePlotFromGraph(plot: Plot, activePointsInterval: CountableRange<Int>) {
//        plot.graphViewDrawingDelegate = nil
//        if let validIndex = self.plots.index(where: {return ($0.identifier == plot.identifier)}) {
//            self.plots.remove(at: validIndex)
//        }
//        initPlot(plot: plot, activePointsInterval: activePointsInterval)
////        startAnimations(withStaggerValue: 0.15)
//    }

    private func addReferenceLinesToGraph(referenceLines: ReferenceLines) {
        self.referenceLines = referenceLines
        addReferenceViewDrawingView()
        
        updateLabelsForCurrentInterval()
    }
    
    private func initPlot(plot: Plot, activePointsInterval: CountableRange<Int>) {
        
        #if !TARGET_INTERFACE_BUILDER
            plot.setup() // Only init the animations for plots if we are not in IB
        #endif
        
        plot.createPlotPoints(numberOfPoints: dataSource!.numberOfPoints(), range: range) // TODO: removed forced unwrap
        
        // If we are not animating on startup then just set all the plot positions to their respective values
        if(!shouldAnimateOnStartup) {
            let dataForInitialPoints = getData(forPlot: plot, andActiveInterval: activePointsInterval)
            plot.setPlotPointDataValues(forNewlyActivatedPoints: activePointsInterval, withData: dataForInitialPoints)
        }
        
        addSubLayers(layers: plot.layers(forViewport: currentViewport()))
    }

    private var queuedPlots: SGVQueue<Plot> = SGVQueue<Plot>()
    
    private func enqueuePlot(_ plot: Plot) {
        queuedPlots.enqueue(element: plot)
    }

    
    // MARK: - Private Methods
    // #######################
    
    // MARK: Layout Calculations
    // #########################
    
    private func calculateActivePointsInterval() -> CountableRange<Int> {
        
        // Calculate the "active points"
        let min = Int((offsetWidth) / dataPointSpacing)
        let max = Int(((offsetWidth + viewportWidth)) / dataPointSpacing)
        
        // Add and minus two so the path goes "off the screen" so we can't see where it ends.
        let minPossible = 0
        var maxPossible = 0
        
        if let numberOfPoints = dataSource?.numberOfPoints() {
            maxPossible = numberOfPoints - 1
        }
        
        let numberOfPointsOffscreen = 2
        
        let actualMin = clamp(value: min - numberOfPointsOffscreen, min: minPossible, max: maxPossible)
        let actualMax = clamp(value: max + numberOfPointsOffscreen, min: minPossible, max: maxPossible)
        
        return actualMin..<actualMax.advanced(by: 1)
    }
    
    // Calculate the range across all plots.
    private func calculateRange(forActivePointsInterval interval: CountableRange<Int>) -> (min: Double, max: Double) {
        
        // This calculates the range across all plots for the active points.
        // So the maximum will be the max of all plots, same goes for min.
        var ranges = [(min: Double, max: Double)]()
        
        for plot in plots {
            let rangeForPlot = calculateRange(forPlot: plot, forActivePointsInterval: interval)
            ranges.append(rangeForPlot)
        }
        
        let minOfRanges = min(ofAllRanges: ranges)
        let maxOfRanges = max(ofAllRanges: ranges)
        
        return (min: minOfRanges, max: maxOfRanges)
    }
    
    private func max(ofAllRanges ranges: [(min: Double, max: Double)]) -> Double {
        
        var max: Double = ranges[0].max
        
        for range in ranges {
            if(range.max > max) {
                max = range.max
            }
        }
        
        return max
    }
    
    private func min(ofAllRanges ranges: [(min: Double, max: Double)]) -> Double {
        var min: Double = ranges[0].min
        
        for range in ranges {
            if(range.min < min) {
                min = range.min
            }
        }
        
        return min
    }
    
    // Calculate the range for a single plot.
    private func calculateRange(forPlot plot: Plot, forActivePointsInterval interval: CountableRange<Int>) -> (min: Double, max: Double) {
        
        let dataForActivePoints = getData(forPlot: plot, andActiveInterval: interval)
        
        // We don't have any active points, return defaults.
        if(dataForActivePoints.count == 0) {
            return (min: self.rangeMin, max: self.rangeMax)
        }
        else {
            
            let range = calculateRange(for: dataForActivePoints.map({$0.value}))
            //TODO: perhaps use isVisible to modify the range (like cutting out invisible values)
            return clean(range: range)
        }
    }
    
    private func calculateRange<T: Collection>(for data: T) -> (min: Double, max: Double) where T.Iterator.Element == Double? {
        
        var rangeMin: Double = Double(Int.max)
        var rangeMax: Double = Double(Int.min)
        
        for dataPoint in data {
            if let validDataPoint = dataPoint {
                if (validDataPoint > rangeMax) {
                    rangeMax = validDataPoint
                }
                if (validDataPoint < rangeMin) {
                    rangeMin = validDataPoint
                }
            }
        }
        return (min: rangeMin, max: rangeMax)
    }
    
    private func clean(range: (min: Double, max: Double)) -> (min: Double, max: Double){
        if(range.min == range.max) {
            
            let min = shouldRangeAlwaysStartAtZero ? 0 : range.min
            let max = range.max + 1
            
            return (min: min, max: max)
        }
        else if (shouldRangeAlwaysStartAtZero) {
            
            let min: Double = 0
            var max: Double = range.max
            
            // If we have all negative numbers and the max happens to be 0, there will cause a division by 0. Return the default height.
            if(range.max == 0) {
                max = rangeMax
            }
            
            return (min: min, max: max)
        }
        else {
            return range
        }
    }
    
    private func graphWidth(forNumberOfDataPoints numberOfPoints: Int) -> CGFloat {
        let width: CGFloat = (CGFloat(numberOfPoints - 1) * self.dataPointSpacing) + (leftmostPointPadding + rightmostPointPadding)
        return width
    }

    // Basically does the inverse of private func graphWidth(forNumberOfDataPoints numberOfPoints: Int) -> CGFloat
    // For a given GRAPH width, and a fixed number of datapoints, it determines that datapoint spacing required to satisfy these conditions.
    private func getDatapointSpacing(forDesiredGraphWidth desiredGraphWidth: CGFloat, forNumberOfDataPoints numberOfPoints: Int) -> CGFloat {
        let desiredDatapointSpacing: CGFloat = ((desiredGraphWidth - (self.leftmostPointPadding + self.rightmostPointPadding)) / CGFloat(numberOfPoints - 1))
        return desiredDatapointSpacing
    }


    private func clamp<T: Comparable>(value:T, min:T, max:T) -> T {
        if (value < min) {
            return min
        }
        else if (value > max) {
            return max
        }
        else {
            return value
        }
    }


    private func getData(forPlot plot: Plot, andActiveInterval activeInterval: CountableRange<Int>) -> [PlotPointData] {
        var dataForInterval = [PlotPointData]()
        for i in activeInterval.startIndex ..< activeInterval.endIndex {
            var dataForIndexI = PlotPointData()
            dataForIndexI.value = dataSource?.value(forPlot: plot, atIndex: i)
            dataForIndexI.isVisible = dataSource?.isVisible(forPlot: plot, atIndex: i) ?? false
            dataForIndexI.colorOverride = dataSource?.valueColor(forPlot: plot, atIndex: i)
            dataForInterval.append(dataForIndexI)
        }
        return dataForInterval
    }
    
    private func getData(forPlot plot: Plot, andNewlyActivatedPoints activatedPoints: [Int]) -> [PlotPointData] {
        var dataForActivatedPoints = [PlotPointData]()
        for activatedPoint in activatedPoints {
            var dataForActivatedPoint = PlotPointData()
            dataForActivatedPoint.value = dataSource?.value(forPlot: plot, atIndex: activatedPoint)
            dataForActivatedPoint.isVisible = dataSource?.isVisible(forPlot: plot, atIndex: activatedPoint) ?? false
            dataForActivatedPoint.colorOverride = dataSource?.valueColor(forPlot: plot, atIndex: activatedPoint)
            dataForActivatedPoints.append(dataForActivatedPoint)
        }
        return dataForActivatedPoints
    }

    // MARK: Events
    // ############
    
    // If the active points (the points we can actually see) change, then we need to update the path.
    private func activePointsDidChange() {
        
        let deactivatedPoints = determineDeactivatedPoints()
        let activatedPoints = determineActivatedPoints()
        
        // The plots need to know which points became active and what their values
        // are so the plots can display them properly.
        if(!isInitialSetup) {
            for plot in plots {
                let newData = getData(forPlot: plot, andNewlyActivatedPoints: activatedPoints)
                plot.setPlotPointDataValues(forNewlyActivatedPoints: activatedPoints, withData: newData)
                if let validGraphDelegate = self.graphViewDelegate {
                    for aDeactivatedPoint in deactivatedPoints {
                        validGraphDelegate.scrollableGraphView(self, didEndDisplaying: aDeactivatedPoint, forPlot: plot)
                    }
                    for anActivatedPoint in activatedPoints {
                        validGraphDelegate.scrollableGraphView(self, didEndDisplaying: anActivatedPoint, forPlot: plot)
                    }
                }
            }
        }
        
        updatePaths()
        
        if let ref = self.referenceLines {
            if(ref.shouldShowLabels) {
                let deactivatedLabelPoints = filterPointsForLabels(fromPoints: deactivatedPoints)
                let activatedLabelPoints = filterPointsForLabels(fromPoints: activatedPoints)
                updateLabels(deactivatedPoints: deactivatedLabelPoints, activatedPoints: activatedLabelPoints)
            }
        }
    }
    
    private func rangeDidChange() {
        
        // If shouldAnimateOnAdapt is enabled it will kickoff any animations that need to occur.
        if(shouldAnimateOnAdapt) {
            startAnimations()
        }
        else {
            // Otherwise we should simple just move the data to their positions.
            for plot in plots {
                let newData = getData(forPlot: plot, andActiveInterval: activePointsInterval)
                plot.setPlotPointDataValues(forNewlyActivatedPoints: intervalForActivePoints(), withData: newData)
            }
        }
        
        referenceLineView?.set(range: range)
    }
    
    private func viewportDidChange() {
        
        // We need to make sure all the drawing views are the same size as the viewport.
        updateFrames()
        
        // Basically this recreates the paths with the new viewport size so things are in sync, but only
        // if the viewport has changed after the initial setup. Because the initial setup will use the latest
        // viewport anyway.
        if(!isInitialSetup) {
            updatePaths()
            
            // Need to update the graph points so they are in their right positions for the new viewport.
            // Animate them into position if animation is enabled, but make sure to stop any current animations first.
            #if !TARGET_INTERFACE_BUILDER
                stopAnimations()
            #endif
            startAnimations()
            
            // The labels will also need to be repositioned if the viewport has changed.
            repositionActiveLabels()
        }
    }
    
    // Returns the indices of any points that became inactive (that is, "off screen"). (No order)
    private func determineDeactivatedPoints() -> [Int] {
        let prevSet = Set(previousActivePointsInterval)
        let currSet = Set(activePointsInterval)
        
        let deactivatedPoints = prevSet.subtracting(currSet)
        
        return Array(deactivatedPoints)
    }
    
    // Returns the indices of any points that became active (on screen). (No order)
    private func determineActivatedPoints() -> [Int] {
        let prevSet = Set(previousActivePointsInterval)
        let currSet = Set(activePointsInterval)
        
        let activatedPoints = currSet.subtracting(prevSet)
        
        return Array(activatedPoints)
    }
    
    // Animations
    
    private func startAnimations(withStaggerValue stagger: Double = 0) {
        var pointsToAnimate = 0 ..< 0
        
        #if !TARGET_INTERFACE_BUILDER
            if (shouldAnimateOnAdapt || (isInitialSetup && shouldAnimateOnStartup)) {
                pointsToAnimate = activePointsInterval
            }
        #endif
        
        for plot in plots {
            let dataForPointsToAnimate = getData(forPlot: plot, andActiveInterval: pointsToAnimate)
            plot.startAnimations(forPoints: pointsToAnimate, withData: dataForPointsToAnimate, withStaggerValue: stagger)

            //TODO: Visibility
        }
    }
    
    private func stopAnimations() {
        for plot in plots {
            plot.dequeueAllAnimations()
        }
    }
    
    // Labels
    // TODO in 4.1: refactor all label adding & positioning code.
    
    // Update any labels for any new points that have been activated and deactivated.
    private func updateLabels(deactivatedPoints: [Int], activatedPoints: [Int]) {
        
        guard let ref = self.referenceLines else {
            return
        }
        
        // Disable any labels for the deactivated points.
        for point in deactivatedPoints {
            labelPool.deactivateLabel(forPointIndex: point)
        }
        
        // Grab an unused label and update it to the right position for the newly activated poitns
        for point in activatedPoints {
            let label = labelPool.activateLabel(forPointIndex: point)
            
//            label.text = (dataSource?.label(atIndex: point) ?? "")

            if let validDataSource  = self.dataSource {
                // Required Datasource Methods
                label.text = validDataSource.label(atIndex: point)

                // Optional Datasource Methods
                if let specifiedLabelColor = validDataSource.labelColor(atIndex: point) {
                    label.textColor = specifiedLabelColor
                }
                else {
                    label.textColor = ref.dataPointLabelColor
                }
            }
            else {
                // No datasource
                label.text = ""
                label.textColor = ref.dataPointLabelColor
            }

            label.font = ref.dataPointLabelFont
            
            label.sizeToFit()
            
            // self.range.min is the current ranges minimum that has been detected
            // self.rangeMin is the minimum that should be used as specified by the user
            let rangeMin = (shouldAdaptRange) ? self.range.min : self.rangeMin
            let position = calculatePosition(atIndex: point, value: rangeMin)
            
            label.frame = CGRect(origin: CGPoint(x: position.x - label.frame.width / 2, y: position.y + ref.dataPointLabelTopMargin), size: label.frame.size)
            
            let _ = labelsView.subviews.filter { $0.frame == label.frame }.map { $0.removeFromSuperview() }
            
            labelsView.addSubview(label)
        }
    }
    
    private func updateLabelsForCurrentInterval() {
        // Have to ensure that the labels are added if we are supposed to be showing them.
        if let ref = self.referenceLines {
            if(ref.shouldShowLabels) {
                
                var activatedPoints: [Int] = []
                for i in activePointsInterval {
                    activatedPoints.append(i)
                }
                
                let filteredPoints = filterPointsForLabels(fromPoints: activatedPoints)
                updateLabels(deactivatedPoints: filteredPoints, activatedPoints: filteredPoints)
            }
        }
    }
    
    private func repositionActiveLabels() {
        
        guard let ref = self.referenceLines else {
            return
        }
        
        for label in labelPool.activeLabels {
            
            let rangeMin = (shouldAdaptRange) ? self.range.min : self.rangeMin
            let position = calculatePosition(atIndex: 0, value: rangeMin)
            
            label.frame.origin.y = position.y + ref.dataPointLabelTopMargin
        }
    }
    
    private func filterPointsForLabels(fromPoints points:[Int]) -> [Int] {
        
        guard let ref = self.referenceLines else {
            return points
        }
        
        if(ref.dataPointLabelsSparsity == 1) {
            return points
        }
        return points.filter({ $0 % ref.dataPointLabelsSparsity == 0 })
    }
    
    // MARK: - Drawing Delegate
    // ########################
    
    internal func calculatePosition(atIndex index: Int, value: Double) -> CGPoint {
        
        // Set range defaults based on settings:
        
        // self.range.min/max is the current ranges min/max that has been detected
        // self.rangeMin/Max is the min/max that should be used as specified by the user
        let rangeMax = (shouldAdaptRange) ? self.range.max : self.rangeMax
        let rangeMin = (shouldAdaptRange) ? self.range.min : self.rangeMin
        
        //                                                     y = the y co-ordinate in the view for the value in the graph
        //                                                     value = the value on the graph for which we want to know its
        //     ( ( value - max )               )                        corresponding location on the y axis in the view
        // y = ( ( ----------- ) * graphHeight ) + topMargin   t = the top margin
        //     ( (  min - max  )               )               h = the height of the graph space without margins
        //                                                     min = the range's current mininum
        //                                                     max = the range's current maximum
        
        // Calculate the position on in the view for the value specified.
        var graphHeight = viewportHeight - topMargin - bottomMargin
        
        if let ref = self.referenceLines {
            if(ref.shouldShowLabels && ref.dataPointLabelFont != nil) {
                graphHeight -= (ref.dataPointLabelFont!.pointSize + ref.dataPointLabelTopMargin + ref.dataPointLabelBottomMargin)
            }
        }
        
        let x = (CGFloat(index) * dataPointSpacing) + leftmostPointPadding
        let y = (CGFloat((value - rangeMax) / (rangeMin - rangeMax)) * graphHeight) + topMargin
        
        return CGPoint(x: x, y: y)
    }
    
    internal func intervalForActivePoints() -> CountableRange<Int> {
        return activePointsInterval
    }
    
    internal func rangeForActivePoints() -> (min: Double, max: Double) {
        return range
    }
    
    internal func paddingForPoints() -> (leftmostPointPadding: CGFloat, rightmostPointPadding: CGFloat) {
        return (leftmostPointPadding: leftmostPointPadding, rightmostPointPadding: rightmostPointPadding)
    }
    
    internal func currentViewport() -> CGRect {
        return CGRect(x: 0, y: 0, width: viewportWidth, height: viewportHeight)
    }
    
    // Update any paths with the new path based on visible data points.
    internal func updatePaths() {
        
        zeroYPosition = calculatePosition(atIndex: 0, value: self.range.min).y
        
        if let drawingLayers = drawingView.layer.sublayers {
            for layer in drawingLayers {
                if let layer = layer as? ScrollableGraphViewDrawingLayer {
                    // The bar layer needs the zero Y position to set the bottom of the bar
                    layer.zeroYPosition = zeroYPosition
                    // Need to make sure this is set in createLinePath
                    assert (layer.zeroYPosition > 0);
                    layer.updatePath()
                }
            }
        }
    }

    public func captureGraphScreenshot() -> UIImage? {
        // Reduce the datapoint spacing to achieve unit width: meaning the entire graph fits exactly in the viewport window with all points rendered.
        let previousDatapointSpacing: CGFloat = self.dataPointSpacing
        let previousDelegate: ScrollableGraphViewDelegate? = self.graphViewDelegate
        let numberOfDataPoints = dataSource?.numberOfPoints() ?? 0
//        totalGraphWidth = graphWidth(forNumberOfDataPoints: numberOfDataPoints)
//        self.contentSize = CGSize(width: totalGraphWidth, height: viewportHeight)

        // Determines the datapoint spacing required to exactly fill the width of the viewport
        let newRequiredDatapointSpacing: CGFloat = self.getDatapointSpacing(forDesiredGraphWidth: self.viewportWidth, forNumberOfDataPoints: numberOfDataPoints)

        // Remove the delegate so we don't get callbacks during the screenshot
        self.graphViewDelegate = nil
        // Reload with the new dataPoint spacing
        self.dataPointSpacing = newRequiredDatapointSpacing
        // Reload the graph with new datapoint spacing
        self.reload()

        //Screenshot here
//        self.drawingView.snapshotView(afterScreenUpdates: true)
        let validScreenshot: UIImage? = self.screenshot()

        //Revert the graph to the user's settings
        self.dataPointSpacing = previousDatapointSpacing
        self.reload()
        // Restore the delegate once the screenshot is done
        self.graphViewDelegate = previousDelegate

        return validScreenshot
    }
}

// MARK: - ScrollableGraphView Settings Enums
// ##########################################

@objc public enum ScrollableGraphViewDirection : Int {
    case leftToRight
    case rightToLeft
}

// Simple queue data structure for keeping track of which
// plots have been added.
fileprivate class SGVQueue<T> {
    
    var storage: [T]
    
    public var count: Int {
        get {
            return storage.count
        }
    }
    
    init() {
        storage = [T]()
    }
    
    public func enqueue(element: T) {
        storage.insert(element, at: 0)
    }
    
    public func dequeue() -> T? {
        return storage.popLast()
    }
}

// We have to be our own data source for interface builder.
#if TARGET_INTERFACE_BUILDER
extension ScrollableGraphView : ScrollableGraphViewDataSource {
    
    var numberOfDisplayItems: Int {
        get {
            return 30
        }
    }
    
    var linePlotData: [Double] {
        get {
            return self.generateRandomData(numberOfDisplayItems, max: 100, shouldIncludeOutliers: false)
        }
    }
    
    public func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double? {
        return linePlotData[pointIndex]
    }
    
    public func label(atIndex pointIndex: Int) -> String {
        return "\(pointIndex)"
    }
    
    public func numberOfPoints() -> Int {
        return numberOfDisplayItems
    }
    
    private func generateRandomData(_ numberOfItems: Int, max: Double, shouldIncludeOutliers: Bool = true) -> [Double] {
        var data = [Double]()
        for _ in 0 ..< numberOfItems {
            var randomNumber = Double(arc4random()).truncatingRemainder(dividingBy: max)
            
            if(shouldIncludeOutliers) {
                if(arc4random() % 100 < 10) {
                    randomNumber *= 3
                }
            }
            
            data.append(randomNumber)
        }
        return data
    }

    public func isVisible(forPlot plot: Plot, atIndex pointIndex: Int) -> Bool {
        return true
    }

    public func valueColor(forPlot plot: Plot, atIndex pointIndex: Int) -> UIColor? {
        return nil
    }


    public func labelColor(atIndex pointIndex: Int) -> UIColor? {
        return nil
    }
}
#endif


public extension UIScrollView {

    // Screenshots
    func screenshot() -> UIImage? {
        let savedContentOffset = self.contentOffset
        let savedFrame = self.frame

        UIGraphicsBeginImageContext(self.contentSize)
        self.contentOffset = .zero
        self.frame = CGRect(x: 0, y: 0, width: self.contentSize.width, height: self.contentSize.height)

        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();

        self.contentOffset = savedContentOffset
        self.frame = savedFrame

        return image
    }
}

public extension ScrollableGraphView {

}
