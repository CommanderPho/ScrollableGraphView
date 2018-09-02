//
//  ScreenshotFunctionality.swift
//  ScrollableGraphView
//
//  Created by Pho Hale on 9/2/18.
//  Copyright © 2018 SGV. All rights reserved.
//

import Foundation
import UIKit


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
