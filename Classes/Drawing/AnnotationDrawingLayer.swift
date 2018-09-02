//
//  AnnotationDrawingLayer.swift
//  ScrollableGraphView
//
//  Created by Pho Hale on 1/20/18.
//  Copyright © 2018 SGV. All rights reserved.
//

import UIKit

// MARK: Drawing the annotations
internal class AnnotationDrawingLayer: ScrollableGraphViewDrawingLayer {

    private var annotationPath = UIBezierPath()
    private var annotationWidth: CGFloat = 4
    private var shouldRoundCorners = false
    private var shouldDrawDayBoxes = false


    init(frame: CGRect, barWidth: CGFloat, barColor: UIColor, barLineWidth: CGFloat, barLineColor: UIColor, shouldRoundCorners: Bool, shouldDrawDayBoxes: Bool) {

        self.annotationWidth = barWidth
        self.shouldRoundCorners = shouldRoundCorners
        self.shouldDrawDayBoxes = shouldDrawDayBoxes

        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)

        self.lineWidth = barLineWidth
        self.strokeColor = barLineColor.cgColor
        self.fillColor = barColor.cgColor
        self.lineJoin = lineJoin
        self.lineCap = lineCap
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    override init(layer: Any) {
//        super.init(layer: layer)
//    }




    private func createBarPath(centre: CGPoint) -> UIBezierPath {

        let annotationWidthOffset: CGFloat = self.annotationWidth / 2

        let origin = CGPoint(x: centre.x - annotationWidthOffset, y: centre.y)
        let size = CGSize(width: annotationWidth, height: zeroYPosition - centre.y)
        let rect = CGRect(origin: origin, size: size)

        let annotationPath: UIBezierPath = {
            if shouldRoundCorners {
                return UIBezierPath(roundedRect: rect, cornerRadius: annotationWidthOffset)
            } else {
                return UIBezierPath(rect: rect)
            }
        }()

        return annotationPath
    }

    private func createPath () -> UIBezierPath {

        annotationPath.removeAllPoints()

        // We can only move forward if we can get the data we need from the delegate.
        guard let activePointsInterval = self.owner?.graphViewDrawingDelegate?.intervalForActivePoints() else {
                return annotationPath
        }

        for i in activePointsInterval {

            var location = CGPoint.zero
            var isVisible: Bool = false
            var colorOveride: UIColor? = nil

            if let point = owner?.graphPoint(forIndex: i) {
                location = point.location
                isVisible = point.isVisible
                colorOveride = point.colorOverride
            }
            let pointPath: UIBezierPath
            if (isVisible) {
                pointPath = createBarPath(centre: location)
                annotationPath.append(pointPath)
            }
//            if let pointVisibility = owner?.graphPoint(forIndex: i).isVisible {
//                if (pointVisibility) {
//                    if let pointLocation = owner?.graphPoint(forIndex: i).location {
//                        location = pointLocation
//                    }
//                    let pointPath = createBarPath(centre: location)
//                    annotationPath.append(pointPath)
//                }
//
//            }
        }
        return annotationPath
    }

    override func updatePath() {
        self.path = createPath().cgPath
    }
}

