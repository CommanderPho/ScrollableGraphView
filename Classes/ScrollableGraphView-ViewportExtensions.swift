//
//  ScrollableGraphView-ViewportExtensions.swift
//  ScrollableGraphView
//
//  Created by Pho Hale on 4/25/18.
//  Copyright © 2018 SGV. All rights reserved.
//

import Foundation
import UIKit


public extension ScrollableGraphView {

    public struct ViewportInfo {
        public let width: CGFloat
        public let height: CGFloat
        public let offset: (x: CGFloat, y: CGFloat)
        public let totalGraphWidth: CGFloat

        public var percentGraphDisplayed: CGFloat {
            return (self.width / self.totalGraphWidth)
        }
        public var percentContentXOffset: CGFloat {
            return (self.offset.x / self.totalGraphWidth)
        }

    }

    public enum RangeLocation {
        case Min, Center, Max
    }

    public func calculatePosition(forPlot plot: Plot, atIndex index: Int) -> CGPoint {
        let position: CGPoint

        guard let validValue = dataSource?.value(forPlot: plot, atIndex: index) else {
            // self.range.min is the current ranges minimum that has been detected
            // self.rangeMin is the minimum that should be used as specified by the user
            let rangeMin = (shouldAdaptRange) ? self.range.min : self.rangeMin
            position = self.calculatePosition(atIndex: index, value: rangeMin)
            return position
        }
        position = self.calculatePosition(atIndex: index, value: validValue)
        //        CGRect(origin: CGPoint(x: position.x - label.frame.width / 2, y: position.y + ref.dataPointLabelTopMargin), size: label.frame.size)
        return position
    }





    public func calculateLocation(ofRangePosition position: RangeLocation, atIndex index: Int) -> CGPoint {
        let value: Double

        switch position {
        case .Min:
            // self.range.min is the current ranges minimum that has been detected
            // self.rangeMin is the minimum that should be used as specified by the user
            let rangeMin = (shouldAdaptRange) ? self.range.min : self.rangeMin
            value = rangeMin

        case .Center:
            let rangeMin = (shouldAdaptRange) ? self.range.min : self.rangeMin
            let rangeMax = (shouldAdaptRange) ? self.range.max : self.rangeMax
            let rangeMagnitude = (rangeMax - rangeMin)
            let rangeCenterOffsetY = (rangeMagnitude / 2.0)
            value = rangeMin + rangeCenterOffsetY

        case .Max:
            // self.range.max is the current ranges maximum that has been detected
            // self.rangeMax is the maximum that should be used as specified by the user
            let rangeMax = (shouldAdaptRange) ? self.range.max : self.rangeMax
            value = rangeMax

        }

        let position = self.calculatePosition(atIndex: index, value: rangeMin)
//        CGRect(origin: CGPoint(x: position.x - label.frame.width / 2, y: position.y + ref.dataPointLabelTopMargin), size: label.frame.size)
        //self.calculatePosition(atIndex: index, value: )
        return position
    }





    // quantaIndex
    // absoluteXOffset
    // absolutePercentOffset

    // absolutePercentOffset -> quantaIndex
    func nearestQuantaIndex(absolutePercentOffset: CGFloat) -> Int {
        let totalNumberOfQuanta: Int = self.dataSource?.numberOfPoints() ?? 0
        return ScrollableGraphView.nearestQuantaIndex(absolutePercentOffset: absolutePercentOffset, totalNumberOfQuanta: totalNumberOfQuanta)
    }


    // absoluteXOffset -> quantaIndex
    // Returns the nearest quanta index to an absoluteXOffset
    public func nearestQuantaIndex(atAbsoluteXOffset absoluteXOffset: CGFloat) -> Int {
        let fractionalQuanta: CGFloat = (absoluteXOffset - self.leftmostPointPadding) / self.dataPointSpacing
        return Int(round(fractionalQuanta))
    }



    // quantaIndex -> absolutePercentOffset
    // Returns the percent offset of a given index
    public func absolutePercentOffset(atIndex index: Int) -> CGFloat {
        return ScrollableGraphView.absolutePercentOffset(absoluteXOffset: self.absoluteXOffset(atIndex: index), totalGraphWidth: self.totalGraphWidth)
    }

    // absoluteXOffset -> absolutePercentOffset
    func absolutePercentOffset(absoluteXOffset: CGFloat) -> CGFloat {
        return ScrollableGraphView.absolutePercentOffset(absoluteXOffset: absoluteXOffset, totalGraphWidth: self.totalGraphWidth)
    }




    // quantaIndex -> absoluteXOffset
    // Returns the absolute position offset of a given index.
    //NOTE: extracted from func calculatePosition(atIndex index: Int, value: Double) -> CGPoint
    public func absoluteXOffset(atIndex index: Int) -> CGFloat {
        return (CGFloat(index) * self.dataPointSpacing) + self.leftmostPointPadding
    }


    // absolutePercentOffset -> absoluteXOffset
    func absoluteXOffset(absolutePercentOffset: CGFloat) -> CGFloat {
        return ScrollableGraphView.absoluteXOffset(absolutePercentOffset: absolutePercentOffset, totalGraphWidth: self.totalGraphWidth)
    }










    public static func absolutePercentOffset(absoluteXOffset: CGFloat, totalGraphWidth: CGFloat) -> CGFloat {
        return (absoluteXOffset / totalGraphWidth)
    }

    public static func absoluteXOffset(absolutePercentOffset: CGFloat, totalGraphWidth: CGFloat) -> CGFloat {
        return (absolutePercentOffset * totalGraphWidth)
    }

    public static func nearestQuantaIndex(absolutePercentOffset: CGFloat, totalNumberOfQuanta: Int) -> Int {
        let fractionalQuanta: CGFloat = CGFloat(totalNumberOfQuanta - 1) * absolutePercentOffset
        return Int(round(fractionalQuanta))
    }


}
