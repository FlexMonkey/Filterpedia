//
//  Extensions.swift
//  Filterpedia
//
//  Created by Simon Gladman on 05/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import UIKit


extension UIBezierPath
{
    func interpolatePointsWithHermite(_ interpolationPoints : [CGPoint])
    {
        let n = interpolationPoints.count - 1
        
        for ii in 0 ..< n
        {
            var currentPoint = interpolationPoints[ii]
            
            if ii == 0
            {
                self.move(to: interpolationPoints[0])
            }
            
            var nextii = (ii + 1) % interpolationPoints.count
            var previi = (ii - 1 < 0 ? interpolationPoints.count - 1 : ii-1);
            var previousPoint = interpolationPoints[previi]
            var nextPoint = interpolationPoints[nextii]
            let endPoint = nextPoint;
            var mx : CGFloat = 0.0
            var my : CGFloat = 0.0
            
            if ii > 0
            {
                mx = (nextPoint.x - currentPoint.x) * 0.5 + (currentPoint.x - previousPoint.x) * 0.5;
                my = (nextPoint.y - currentPoint.y) * 0.5 + (currentPoint.y - previousPoint.y) * 0.5;
            }
            else
            {
                mx = (nextPoint.x - currentPoint.x) * 0.5;
                my = (nextPoint.y - currentPoint.y) * 0.5;
            }
            
            let controlPoint1 = CGPoint(x: currentPoint.x + mx / 3.0, y: currentPoint.y + my / 3.0)
            
            currentPoint = interpolationPoints[nextii]
            nextii = (nextii + 1) % interpolationPoints.count
            previi = ii;
            previousPoint = interpolationPoints[previi]
            nextPoint = interpolationPoints[nextii]
            
            if ii < n - 1
            {
                mx = (nextPoint.x - currentPoint.x) * 0.5 + (currentPoint.x - previousPoint.x) * 0.5;
                my = (nextPoint.y - currentPoint.y) * 0.5 + (currentPoint.y - previousPoint.y) * 0.5;
            }
            else
            {
                mx = (currentPoint.x - previousPoint.x) * 0.5;
                my = (currentPoint.y - previousPoint.y) * 0.5;
            }
            
            let controlPoint2 = CGPoint(x: currentPoint.x - mx / 3.0, y: currentPoint.y - my / 3.0)
            
            self.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
    }
}


extension CGFloat
{
    func toFloat() -> Float
    {
        return Float(self)
    }
}

extension CIVector
{
    func toArray() -> [CGFloat]
    {
        var returnArray = [CGFloat]()
        
        for i in 0 ..< self.count
        {
            returnArray.append(self.value(at: i))
        }
        
        return returnArray
    }
    
    func normalize() -> CIVector
    {
        var sum: CGFloat = 0
        
        for i in 0 ..< self.count
        {
            sum += self.value(at: i)
        }
        
        if sum == 0
        {
            return self
        }
        
        var normalizedValues = [CGFloat]()
        
        for i in 0 ..< self.count
        {
            normalizedValues.append(self.value(at: i) / sum)
        }
        
        return CIVector(values: normalizedValues,
                        count: normalizedValues.count)
    }
    
    func multiply(_ value: CGFloat) -> CIVector
    {
        let n = self.count
        var targetArray = [CGFloat]()
        
        for i in 0 ..< n
        {
            targetArray.append(self.value(at: i) * value)
        }
        
        return CIVector(values: targetArray, count: n)
    }
    
    func interpolateTo(_ target: CIVector, value: CGFloat) -> CIVector
    {
        return CIVector(
            x: self.x + ((target.x - self.x) * value),
            y: self.y + ((target.y - self.y) * value))
    }
}


extension UIColor
{
    func hue()-> CGFloat
    {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getHue(&hue,
                    saturation: &saturation,
                    brightness: &brightness,
                    alpha: &alpha)
        
        return hue
    }
}

