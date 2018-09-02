//
//  PlotPointData.swift
//  ScrollableGraphView
//
//  Created by Pho Hale on 1/20/18.
//  Copyright © 2018 SGV. All rights reserved.
//

import Foundation


internal struct PlotPointData {

    var value: Double? = nil

    private var _isVisible: Bool = false
    var isVisible: Bool {
        get {
            return (self._isVisible && (self.value != nil))
        }
        set {
            self._isVisible = newValue
        }
    }
    var colorOverride: ScrollableGraphViewNSUI.NSUIColor? = nil
}
