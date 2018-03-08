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
        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)

        self.annotationWidth = barWidth
        self.lineWidth = barLineWidth
        self.strokeColor = barLineColor.cgColor
        self.fillColor = barColor.cgColor
        self.shouldRoundCorners = shouldRoundCorners
        self.shouldDrawDayBoxes = shouldDrawDayBoxes
        self.lineJoin = lineJoin
        self.lineCap = lineCap
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        guard let
            activePointsInterval = self.owner?.graphViewDrawingDelegate?.intervalForActivePoints()
            else {
                return annotationPath
        }

        for i in activePointsInterval {

            var location = CGPoint.zero

            if let pointLocation = owner?.graphPoint(forIndex: i).location {
                location = pointLocation
            }

            let pointPath = createBarPath(centre: location)
            annotationPath.append(pointPath)
        }
        return annotationPath
    }

    override func updatePath() {
        self.path = createPath().cgPath
    }
}

