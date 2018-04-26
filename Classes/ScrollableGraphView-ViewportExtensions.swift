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
