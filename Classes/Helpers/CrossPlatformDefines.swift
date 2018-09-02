//
//  CrossPlatformDefines.swift
//  Dose
//
//  Created by Pho Hale on 5/2/18.
//  Copyright © 2018 Pho Hale. All rights reserved.
//

import Foundation

// Frameworks
import QuartzCore
#if os(OSX)
    import Cocoa
#else
    import UIKit
#endif
//import CGRectExtensions

open class ScrollableGraphViewNSUI {
    // UIKit/Cocoa Classes
    #if os(OSX)
    public typealias NSUIView = NSView
    public typealias NSUIFont = NSFont
    public typealias NSUIColor = NSColor
    public typealias NSUIImage = NSImage
    public typealias NSUIBezierPath = NSBezierPath
    public typealias NSUIViewController = NSViewController
    public typealias NSUITextView = NSTextView
    public typealias NSUITextField = NSTextField
    public typealias NSUIScreen = NSScreen
    public typealias NSUIButton = NSButton
    public typealias NSUILabel = NSTextField
    public typealias NSUIImageView = NSImageView
    public typealias NSUIStoryboardSegue = NSStoryboardSegue

    //MARK: Sizing/Positioning
    public typealias NSUISize = NSSize
    public typealias NSUIRect = NSRect
    public typealias NSUIPoint = NSPoint

    //MARK: Table
    public typealias NSUITableView = NSTableView
    public typealias NSUITableViewCell = NSTableCellView
    public typealias NSUITableViewDataSource = NSTableViewDataSource
    public typealias NSUITableViewDelegate = NSTableViewDelegate

    //MARK: Containers
    public typealias NSUIStackView = NSStackView

    #else
    public typealias NSUIView = UIView
    public typealias NSUIFont = UIFont
    public typealias NSUIColor = UIColor
    public typealias NSUIImage = UIImage
    public typealias NSUIBezierPath = UIBezierPath
    public typealias NSUIViewController = UIViewController
    public typealias NSUITextView = UITextView
    public typealias NSUITextField = UITextField
    public typealias NSUIScreen = UIScreen
    public typealias NSUIButton = UIButton
    public typealias NSUILabel = UILabel
    public typealias NSUIImageView = UIImageView
    public typealias NSUIStoryboardSegue = UIStoryboardSegue

    //MARK: Sizing/Positioning
    public typealias NSUISize = CGSize
    public typealias NSUIRect = CGRect
    public typealias NSUIPoint = CGPoint

    //MARK: Table
    public typealias NSUITableView = UITableView
    public typealias NSUITableViewCell = UITableViewCell
    public typealias NSUITableViewDataSource = UITableViewDataSource
    public typealias NSUITableViewDelegate = UITableViewDelegate

    //MARK: Containers
    public typealias NSUIStackView = UIStackView

    #endif
}




//MARK: -
//MARK: - Compatibility classes
#if os(OSX)

public extension NSColor {

    @available(OSX 10.13, *)
    public convenience init?(named: String) {
        self.init(named: NSColor.Name.init(named))
    }
}

public extension NSView {

    func setNeedsDisplay() {
        self.needsDisplay = true
    }

    func setNeedsLayout() {
        self.needsLayout = true
    }


    func setSubViewsEnabled(enabled: Bool) {
        for (index, currentView) in self.subviews.enumerated() {
            guard let currentControl = currentView as? NSControl else { continue }
            currentControl.isEnabled = enabled
            // Recurse down to this subview's children
            currentView.setSubViewsEnabled(enabled: enabled)
            currentView.display()
        }
    }

    func disableSubViews() {
        self.setSubViewsEnabled(enabled: false)
    }

    func enableSubViews() {
        self.setSubViewsEnabled(enabled: true)
    }

}

public extension NSButton {

//    public var image: NSImage {
//        get {
//            return self.setImage(
//        }
//    }

}

public struct Corners: OptionSet {
    public let rawValue: Int

    public init(rawValue: Corners.RawValue) {
        self.rawValue = rawValue
    }

    public static let topLeft = Corners(rawValue: 1 << 0)
    public static let bottomLeft = Corners(rawValue: 1 << 1)
    public static let topRight = Corners(rawValue: 1 << 2)
    public static let bottomRight = Corners(rawValue: 1 << 3)

    public func flipped() -> Corners {
        var flippedCorners: Corners = []

        if contains(.bottomRight) {
            flippedCorners.insert(.topRight)
        }

        if contains(.topRight) {
            flippedCorners.insert(.bottomRight)
        }

        if contains(.bottomLeft) {
            flippedCorners.insert(.topLeft)
        }

        if contains(.topLeft) {
            flippedCorners.insert(.bottomLeft)
        }

        return flippedCorners
    }
}

public extension NSTextField {
    public var text: String {
        get {
            return self.stringValue
        }
        set {
            self.stringValue = newValue
        }
    }
}

public extension NSTextView {

    public convenience init(string stringValue: String, initialSize: CGSize) {
        let fittingFrame: NSRect = NSRect(origin: .zero, size: initialSize)
        self.init(frame: fittingFrame)
        self.string = stringValue
        self.sizeToFit()
    }

    public var text: String {
        get {
            return self.string
        }
        set {
            self.string = newValue
        }
    }
}


public extension NSImage {
    // Compatibility for iOS's init(named: String) initializer
    public convenience init?(named: String) {
        self.init(imageLiteralResourceName: named)
    }


    func withSize(size: CGSize = CGSize(width: 30, height: 30)) -> NSImage {
        return ImageRenderer(size: size).image(actions: { _ in
            self.draw(in: NSRect(x: 0, y: 0, width: size.width, height: size.height))
        })
    }

    // Compatability wth UIKit's withRenderingMode(_ renderingMode: UIImageRenderingMode) -> UIImage
    func withRenderingMode(_ renderingMode: ImageRenderingMode) -> NSImage {
        switch renderingMode {
        case .automatic:
            return self
        case .alwaysOriginal:
            if (!self.isTemplate) { return self }
            guard let newCopy = self.copy() as? NSImage else { fatalError() }
            newCopy.isTemplate = false
            return newCopy
        case .alwaysTemplate:
            if (self.isTemplate) { return self }
            guard let newCopy = self.copy() as? NSImage else { fatalError() }
            newCopy.isTemplate = true
            return newCopy
        }
    }

}

public extension NSBezierPath {

    // Compatibility bewteen NSBezierPath and UIBezierPath
    public convenience init(roundedRect rect: CGRect, byRoundingCorners roundedCorners: Corners, cornerRadii: CGSize) {
        self.init()
        let corners = roundedCorners
        let maxX: CGFloat = rect.size.width
        let minX: CGFloat = 0
        let maxY: CGFloat = rect.size.height
        let minY: CGFloat =  0
        let topLeftCorner = CGPoint(x: minX, y: maxY)
        let bottomRightCorner = CGPoint(x: maxX, y: minY)
        let topRightCorner = CGPoint(x: maxX, y: maxY)
        let bottomLeftCorner = CGPoint(x: minX, y: minY)

        //// Rectangle Drawing
        move(to: bottomRightCorner)

        if corners.contains(.bottomRight) {
            line(to: CGPoint(x: maxX - cornerRadii.width, y: minY))
            curve(to: CGPoint(x: maxX, y: minY + cornerRadii.height), controlPoint1: bottomRightCorner, controlPoint2: bottomRightCorner)
        }
        else {
            line(to: bottomRightCorner)
        }

        if corners.contains(.topRight) {
            line(to: CGPoint(x: maxX, y: maxY - cornerRadii.height))
            curve(to: CGPoint(x: maxX - cornerRadii.width, y: maxY), controlPoint1: topRightCorner, controlPoint2: topRightCorner)
        }
        else {
            line(to: topRightCorner)
        }

        if corners.contains(.topLeft) {
            line(to: CGPoint(x: minX + cornerRadii.width, y: maxY))
            curve(to: CGPoint(x: minX, y: maxY - cornerRadii.height), controlPoint1: topLeftCorner, controlPoint2: topLeftCorner)
        }
        else {
            line(to: topLeftCorner)
        }

        if corners.contains(.bottomLeft) {
            line(to: CGPoint(x: minX, y: minY + cornerRadii.height))
            curve(to: CGPoint(x: minX + cornerRadii.width, y: minY), controlPoint1: bottomLeftCorner, controlPoint2: bottomLeftCorner)
        }
        else {
            line(to: bottomLeftCorner)
        }

    }

//    public convenience init(rect: CGRect, roundedCorners: Corners, cornerRadius: CGFloat) {
//        self.init()
//
//        // On iOS & tvOS, we need to flip the corners
//        #if os(iOS) || os(tvOS)
//        let corners = roundedCorners.flipped()
//        #elseif os(macOS)
//        let corners = roundedCorners
//        #endif
//
//        let maxX: CGFloat = rect.size.width
//        let minX: CGFloat = 0
//        let maxY: CGFloat = rect.size.height
//        let minY: CGFloat =  0
//
//        let bottomRightCorner = CGPoint(x: maxX, y: minY)
//
//        move(to: bottomRightCorner)
//
//        if corners.contains(.bottomRight) {
//            line(to: CGPoint(x: maxX - cornerRadius, y: minY))
//            curve(to: CGPoint(x: maxX, y: minY + cornerRadius), controlPoint1: bottomRightCorner, controlPoint2: bottomRightCorner)
//        }
//        else {
//            line(to: bottomRightCorner)
//        }
//
//        let topRightCorner = CGPoint(x: maxX, y: maxY)
//
//        if corners.contains(.topRight) {
//            line(to: CGPoint(x: maxX, y: maxY - cornerRadius))
//            curve(to: CGPoint(x: maxX - cornerRadius, y: maxY), controlPoint1: topRightCorner, controlPoint2: topRightCorner)
//        }
//        else {
//            line(to: topRightCorner)
//        }
//
//        let topLeftCorner = CGPoint(x: minX, y: maxY)
//
//        if corners.contains(.topLeft) {
//            line(to: CGPoint(x: minX + cornerRadius, y: maxY))
//            curve(to: CGPoint(x: minX, y: maxY - cornerRadius), controlPoint1: topLeftCorner, controlPoint2: topLeftCorner)
//        }
//        else {
//            line(to: topLeftCorner)
//        }
//
//        let bottomLeftCorner = CGPoint(x: minX, y: minY)
//
//        if corners.contains(.bottomLeft) {
//            line(to: CGPoint(x: minX, y: minY + cornerRadius))
//            curve(to: CGPoint(x: minX + cornerRadius, y: minY), controlPoint1: bottomLeftCorner, controlPoint2: bottomLeftCorner)
//        }
//        else {
//            line(to: bottomLeftCorner)
//        }
//    }


    /// Appends a straight line to the receiver’s path.
    public func addLine(to point: CGPoint) {
        self.line(to: point)
    }

    /// Adds a Bezier cubic curve to the receiver’s path.
    public func addCurve(to point: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
        self.curve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }

    /// Appends a quadratic Bézier curve to the receiver’s path.
    public func addQuadCurve(to point: CGPoint, controlPoint: CGPoint) {
        let (d1x, d1y) = (controlPoint.x - currentPoint.x, controlPoint.y - currentPoint.y)
        let (d2x, d2y) = (point.x - controlPoint.x, point.y - controlPoint.y)
        let cp1 = CGPoint(x: controlPoint.x - d1x / 3.0, y: controlPoint.y - d1y / 3.0)
        let cp2 = CGPoint(x: controlPoint.x + d2x / 3.0, y: controlPoint.y + d2y / 3.0)
        self.curve(to: point, controlPoint1: cp1, controlPoint2: cp2)
    }

    /// Appends an arc to the receiver’s path.
    public func addArc(withCenter center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) {
        let _startAngle = startAngle * 180.0 / CGFloat(M_PI)
        let _endAngle = endAngle * 180.0 / CGFloat(M_PI)
        appendArc(withCenter: .zero, radius: radius, startAngle: _startAngle, endAngle: _endAngle, clockwise: !clockwise)
    }

    /// Creates and returns a new BezierPath object initialized with a rounded rectangular path.
    public convenience init(roundedRect: CGRect, cornerRadius: CGFloat) {
        self.init(roundedRect: roundedRect, xRadius: cornerRadius, yRadius: cornerRadius)
    }

    /// Transforms all points in the path using the specified affine transform matrix.
    public func apply(_ theTransform: CGAffineTransform) {
        let t = NSAffineTransform()
        t.transformStruct = NSAffineTransformStruct(m11: theTransform.a, m12: theTransform.b, m21: theTransform.c, m22: theTransform.d, tX: theTransform.tx, tY: theTransform.ty)
        transform(using: t as AffineTransform)
    }

    /// Creates and returns a new UIBezierPath object initialized with the contents of a Core Graphics path.
    /// - Warning: To match UIKit, this cannot be a failable initializer
    public convenience init(cgPath: CGPath) {
        self.init(); var selfref = self
        cgPath.apply(info: &selfref, function: {
            (selfPtr, elementPtr: UnsafePointer<CGPathElement>) in
            guard let selfPtr = selfPtr else {
                fatalError("init(cgPath: CGPath): Unable to unwrap pointer to self")
            }
            let pathPtr = selfPtr.bindMemory(to: BezierPath.self, capacity: 1)
            let path = pathPtr.pointee
            let element = elementPtr.pointee
            switch element.type {
            case .moveToPoint: path.move(to: element.points[0])
            case .addLineToPoint: path.addLine(to: element.points[0])
            case .addQuadCurveToPoint: path.addQuadCurve(to: element.points[1], controlPoint: element.points[0])
            case .addCurveToPoint: path.addCurve(to: element.points[2], controlPoint1: element.points[0], controlPoint2: element.points[1])
            case .closeSubpath: path.close()
            }
        })
    }

}


public extension NSViewController {

    @objc func viewWillAppear(_ animated: Bool) {
        debugPrint("NSUI Compatibility Warning! viewWillAppear(animated) will not animate on MacOS!")
        self.viewWillAppear()
    }

}


public extension ScrollableGraphViewNSUI.NSUIStackView {
    #if os(OSX)
        public enum UILayoutConstraintAxis : Int {
            case horizontal, vertical
        }
        public enum UIStackViewAlignment : Int {
            case fill, leading, firstBaseline, center, trailing, lastBaseline
            static var top: UIStackViewAlignment = .leading
            static var bottom: UIStackViewAlignment = .trailing

            init?(layoutConstraint: NSLayoutConstraint.Attribute) {
                let equivResult: UIStackViewAlignment
                switch layoutConstraint {
                case .left, .leading:
                    equivResult = .leading
                case .centerX, .centerY:
                    equivResult = .center
                case .right, .trailing:
                    equivResult = .trailing
                case .firstBaseline:
                    equivResult = .firstBaseline
                case .lastBaseline:
                    equivResult = .lastBaseline
                case .top:
                    equivResult = UIStackViewAlignment.top
                case .bottom:
                    equivResult = UIStackViewAlignment.bottom
                default:
                    return nil
                }
                self.init(rawValue: equivResult.rawValue)
            }


        }

        var axis: UILayoutConstraintAxis {
            get {
                return UILayoutConstraintAxis(rawValue: self.orientation.rawValue)!
            }
            set {
                self.orientation = NSUserInterfaceLayoutOrientation(rawValue: newValue.rawValue)!
            }
        }

    #else
        public enum NSUserInterfaceLayoutOrientation: Int {
            case horizontal, vertical
        }


        var orientation: NSUserInterfaceLayoutOrientation {
            get {
                let axisOrientation = self.axis
                return NSUserInterfaceLayoutOrientation.init(rawValue: axisOrientation.rawValue)
            }
            set {
                self.axis = UILayoutConstraintAxis(rawValue: newValue.rawValue)!
            }
        }

    #endif
}

#else

    public extension ScrollableGraphViewNSUI.NSUIBezierPath {
        #if os(iOS) || os(tvOS)
            public func curve(to point: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
                addCurve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            }

            public func line(to point: CGPoint) {
                addLine(to: point)
            }
        #endif
    }

#endif

#if os(iOS)
    public extension UILabel {

        public convenience init(string stringValue: String) {
            self.init(frame: CGRect.zero)
            self.text = stringValue
            self.sizeToFit()
        }

        public convenience init(string stringValue: String, initialSize: CGSize) {
            let fittingFrame: CGRect = CGRect(origin: .zero, size: initialSize)
            self.init(frame: fittingFrame)
            self.text = stringValue
            self.sizeToFit()
        }

        public var string: String? {
            get {
                return self.text
            }
            set {
                self.text = newValue
            }
        }

        public var attributedString: NSAttributedString? {
            get {
                return self.attributedText
            }
            set {
                self.attributedText = newValue
            }
        }

        public func calcSize() {
            self.invalidateIntrinsicContentSize()
        }

    }



#endif

//MARK: -
//MARK: - Shared Extensions
public extension ScrollableGraphViewNSUI.NSUIColor {

    /**
     Returns the components that make up the color in the RGB color space as a tuple.

     - returns: The RGB components of the color or `nil` if the color could not be converted to RGBA color space.
     */
    func getRGBAComponents() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)?
    {
        var (red, green, blue, alpha) = (CGFloat(0.0), CGFloat(0.0), CGFloat(0.0), CGFloat(0.0))
        #if os(OSX)
            self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return (red, green, blue, alpha)
        #else
            if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            {
                return (red, green, blue, alpha)
            }
            else
            {
                return nil
            }
        #endif
    }

    /**
     Returns the components that make up the color in the HSB color space as a tuple.

     - returns: The HSB components of the color or `nil` if the color could not be converted to HSBA color space.
     */
    func getHSBAComponents() -> (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)?
    {
        var (hue, saturation, brightness, alpha) = (CGFloat(0.0), CGFloat(0.0), CGFloat(0.0), CGFloat(0.0))
        #if os(OSX)
            self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            return (hue, saturation, brightness, alpha)
        #else
            if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            {
                return (hue, saturation, brightness, alpha)
            }
            else
            {
                return nil
            }
        #endif
    }

    /**
     Returns the grayscale components of the color as a tuple.

     - returns: The grayscale components or `nil` if the color could not be converted to grayscale color space.
     */
    func getGrayscaleComponents() -> (white: CGFloat, alpha: CGFloat)?
    {
        var (white, alpha) = (CGFloat(0.0), CGFloat(0.0))
        #if os(OSX)
            self.getWhite(&white, alpha: &alpha)
            return (white, alpha)
        #else
            if self.getWhite(&white, alpha: &alpha)
            {
                return (white, alpha)
            }
            else
            {
                return nil
            }
        #endif
   }


    public var alphaComponent: CGFloat {
        get {
            if let validRGBAComponents = self.getRGBAComponents() {
                return validRGBAComponents.alpha
            }
            if let validGreyscaleComponents = self.getGrayscaleComponents() {
                return validGreyscaleComponents.alpha
            }
            if let validHSBAComponents = self.getHSBAComponents() {
                return validHSBAComponents.alpha
            }
            return 1.0
        }
    }


    public var hexValue: Int {
        var rF: CGFloat = 0
        var gF: CGFloat = 0
        var bF: CGFloat = 0
        getRed(&rF, green: &gF, blue: &bF, alpha: nil)
        let r = Int(rF*255)
        let g = Int(gF*255)
        let b = Int(bF*255)
        return r << 16 + g << 8 + b
    }

    public convenience init(hex value: Int, alpha: CGFloat = 1) {
        let r = (value & 0xFF0000) >> 16
        let g = (value & 0x00FF00) >> 8
        let b = value & 0x0000FF
        self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: alpha)
    }

    // Convert a hex string to a NSColor object.
    class func colorFromHex(hexString:String) -> ScrollableGraphViewNSUI.NSUIColor {

        func clean(hexString: String) -> String {
            var cleanedHexString = String()
            // Remove the leading "#"
            if(hexString[hexString.startIndex] == "#") {
                cleanedHexString = hexString.substring(from: hexString.characters.index(hexString.startIndex, offsetBy: 1))
            }
            // TODO: Other cleanup. Allow for a "short" hex string, i.e., "#fff"
            return cleanedHexString
        }

        let cleanedHexString = clean(hexString: hexString)
        // If we can get a cached version of the colour, get out early.
        if let cachedColor = ScrollableGraphViewNSUI.NSUIColor.getColorFromCache(hexString: cleanedHexString) { return cachedColor }
        // Else create the color, store it in the cache and return.
        let scanner = Scanner(string: cleanedHexString)
        var value:UInt32 = 0
        // We have the hex value, grab the red, green, blue and alpha values.
        // Have to pass value by reference, scanner modifies this directly as the result of scanning the hex string. The return value is the success or fail.
        if(scanner.scanHexInt32(&value)){
            // intValue = 01010101 11110111 11101010    // binary
            // intValue = 55       F7       EA          // hexadecimal

            //                     r
            //   00000000 00000000 01010101 intValue >> 16
            // & 00000000 00000000 11111111 mask
            //   ==========================
            // = 00000000 00000000 01010101 red

            //            r        g
            //   00000000 01010101 11110111 intValue >> 8
            // & 00000000 00000000 11111111 mask
            //   ==========================
            // = 00000000 00000000 11110111 green

            //   r        g        b
            //   01010101 11110111 11101010 intValue
            // & 00000000 00000000 11111111 mask
            //   ==========================
            // = 00000000 00000000 11101010 blue

            let intValue = UInt32(value)
            let mask:UInt32 = 0xFF

            let red = intValue >> 16 & mask
            let green = intValue >> 8 & mask
            let blue = intValue & mask

            // red, green, blue and alpha are currently between 0 and 255
            // We want to normalise these values between 0 and 1 to use with NSColor.
            let colors:[UInt32] = [red, green, blue]
            let normalised = normalise(colors: colors)

            let newColor = ScrollableGraphViewNSUI.NSUIColor(red: normalised[0], green: normalised[1], blue: normalised[2], alpha: 1)
            ScrollableGraphViewNSUI.NSUIColor.storeColorInCache(hexString: cleanedHexString, color: newColor)

            return newColor
        }
            // We couldn't get a value from a valid hex string.
        else {
            print("Error: Couldn't convert the hex string to a number, returning NSColor.whiteColor() instead.")
            return ScrollableGraphViewNSUI.NSUIColor.white
        }
    }


    // Takes an array of colours in the range of 0-255 and returns a value between 0 and 1.
    private class func normalise(colors: [UInt32]) -> [CGFloat]{
        var normalisedVersions = [CGFloat]()
        for color in colors{
            normalisedVersions.append(CGFloat(color % 256) / 255)
        }
        return normalisedVersions
    }

    // Caching
    // Store any colours we've gotten before. Colours don't change.
    private static var hexColorCache = [String : ScrollableGraphViewNSUI.NSUIColor]()

    private class func getColorFromCache(hexString: String) -> ScrollableGraphViewNSUI.NSUIColor? {
        guard let color = ScrollableGraphViewNSUI.NSUIColor.hexColorCache[hexString] else { return nil }
        return color
    }

    private class func storeColorInCache(hexString: String, color: ScrollableGraphViewNSUI.NSUIColor) {
        if ScrollableGraphViewNSUI.NSUIColor.hexColorCache.keys.contains(hexString) {
            return // No work to do if it is already there.
        }
        ScrollableGraphViewNSUI.NSUIColor.hexColorCache[hexString] = color
    }

    private class func clearColorCache() { ScrollableGraphViewNSUI.NSUIColor.hexColorCache.removeAll() }
}
