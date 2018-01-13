//
//  UIBezierPath+Hermite.swift
//  Drawy
//
//  Created by Gal Orlanczyk on 13/01/2018.
//  Copyright © 2018 GO. All rights reserved.
//

import UIKit

extension UIBezierPath {
    
    func interpolatePointsWithHermite(interpolationPoints : [Point], alpha : CGFloat = 1.0/3.0) {
        guard !interpolationPoints.isEmpty else { return }
        self.removeAllPoints()
        self.move(to: interpolationPoints[0].cgPoint)
        
        let n = interpolationPoints.count - 1
        
        for index in 0..<n {
            var currentPoint = interpolationPoints[index].cgPoint
            var nextIndex = (index + 1) % interpolationPoints.count
            var prevIndex = index == 0 ? interpolationPoints.count - 1 : index - 1
            var previousPoint = interpolationPoints[prevIndex].cgPoint
            var nextPoint = interpolationPoints[nextIndex].cgPoint
            let endPoint = nextPoint
            var mx : CGFloat
            var my : CGFloat
            
            if index > 0
            {
                mx = (nextPoint.x - previousPoint.x) / 2.0
                my = (nextPoint.y - previousPoint.y) / 2.0
            } else {
                mx = (nextPoint.x - currentPoint.x) / 2.0
                my = (nextPoint.y - currentPoint.y) / 2.0
            }
            
            let controlPoint1 = CGPoint(x: currentPoint.x + mx * alpha, y: currentPoint.y + my * alpha)
            currentPoint = interpolationPoints[nextIndex].cgPoint
            nextIndex = (nextIndex + 1) % interpolationPoints.count
            prevIndex = index
            previousPoint = interpolationPoints[prevIndex].cgPoint
            nextPoint = interpolationPoints[nextIndex].cgPoint
            
            if index < n - 1
            {
                mx = (nextPoint.x - previousPoint.x) / 2.0
                my = (nextPoint.y - previousPoint.y) / 2.0
            } else {
                mx = (currentPoint.x - previousPoint.x) / 2.0
                my = (currentPoint.y - previousPoint.y) / 2.0
            }
            
            let controlPoint2 = CGPoint(x: currentPoint.x - mx * alpha, y: currentPoint.y - my * alpha)
            
            self.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
    }
}
