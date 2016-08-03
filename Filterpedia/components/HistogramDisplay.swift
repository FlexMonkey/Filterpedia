//
//  HistogramDisplay.swift
//  Filterpedia
//
//  Created by Simon Gladman on 06/05/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>

import UIKit
import Accelerate.vImage

/// HistogramDisplay displays the RGB histogram of a given CGImage
/// The vertical scale can be changed with touch movement. 

class HistogramDisplay: UIView
{
    var format = vImage_CGImageFormat(
        bitsPerComponent: 8,
        bitsPerPixel: 32,
        colorSpace: nil,
        bitmapInfo: CGBitmapInfo(
            rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
        version: 0,
        decode: nil,
        renderingIntent: .defaultIntent)
    
    func histogramCalculation(_ imageRef: CGImage) -> (red: [UInt], green: [UInt], blue: [UInt])
    {
        var inBuffer: vImage_Buffer = vImage_Buffer()

        vImageBuffer_InitWithCGImage(
            &inBuffer,
            &format,
            nil,
            imageRef,
            UInt32(kvImageNoFlags))

        let red = [UInt](repeating: 0, count: 256)
        let green = [UInt](repeating: 0, count: 256)
        let blue = [UInt](repeating: 0, count: 256)
        let alpha = [UInt](repeating: 0, count: 256)
        
        let redPtr = UnsafeMutablePointer<vImagePixelCount>(red)
        let greenPtr = UnsafeMutablePointer<vImagePixelCount>(green)
        let bluePtr = UnsafeMutablePointer<vImagePixelCount>(blue)
        let alphaPtr = UnsafeMutablePointer<vImagePixelCount>(alpha)
        
        let rgba = [redPtr, greenPtr, bluePtr, alphaPtr]

        let histogram = UnsafeMutablePointer<UnsafeMutablePointer<vImagePixelCount>?>(rgba)
        
        vImageHistogramCalculation_ARGB8888(&inBuffer, histogram, UInt32(kvImageNoFlags))

        free(inBuffer.data)
        
        return (red, green, blue)
    }
    
    let scaleLabel: UILabel =
    {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 22, weight: UIFontWeightRegular)
        label.textAlignment = .right
        label.text = "100%"
        label.alpha = 0
        
        return label
    }()
    
    let redLayer = HistogramDisplay.createLayerForColor(UIColor.red)
    let greenLayer = HistogramDisplay.createLayerForColor(UIColor.green)
    let blueLayer = HistogramDisplay.createLayerForColor(UIColor.blue)
    
    var scale: CGFloat = 1
    {
        didSet
        {
            scale = max(scale, 1)
            scaleLabel.text = "\(Int(scale * 100))%"
        }
    }
    
    static func createLayerForColor(_ color: UIColor) -> CAShapeLayer
    {
        let layer = CAShapeLayer()
        
        layer.strokeColor = color.cgColor
        layer.fillColor = color.withAlphaComponent(0.5).cgColor
        layer.masksToBounds = true
        layer.lineJoin = kCALineJoinRound
        
        return layer
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        backgroundColor = UIColor.lightGray
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 1
        
        layer.addSublayer(redLayer)
        layer.addSublayer(greenLayer)
        layer.addSublayer(blueLayer)
        
        addSubview(scaleLabel)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    var imageRef: CGImage?
    {
        didSet
        {
            drawHistogram()
        }
    }
    
    override func layoutSubviews()
    {
        redLayer.frame = bounds
        greenLayer.frame = bounds
        blueLayer.frame = bounds
        
        scaleLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: frame.width,
            height: scaleLabel.intrinsicContentSize.height)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        UIView.animate(withDuration: 0.25)
        {
            self.scaleLabel.alpha = 1
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch = touches.first else
        {
            return
        }
      
        let direction = touch.location(in: self).y - touch.previousLocation(in: self).y
        
        scale -= direction / 20
        drawHistogram()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        UIView.animate(withDuration: 0.25)
        {
            self.scaleLabel.alpha = 0
        }
    }
    
    func drawHistogram()
    {
        guard let imageRef = imageRef else
        {
            redLayer.path = nil
            greenLayer.path = nil
            blueLayer.path = nil
            return
        }
        
        let histogram = histogramCalculation(imageRef)
        
        let maximum = max(
            histogram.red.max() ?? 0,
            histogram.green.max() ?? 0,
            histogram.blue.max() ?? 0)
        
        drawChannel(histogram.red, maximum: maximum, layer: redLayer)
        drawChannel(histogram.green, maximum: maximum, layer: greenLayer)
        drawChannel(histogram.blue, maximum: maximum, layer: blueLayer)
    }
    
    func drawChannel(_ data: [UInt], maximum: UInt, layer: CAShapeLayer)
    {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: frame.height))

        let interpolationPoints: [CGPoint] = data.enumerated().map
        {
            (index, element) in
            
            let y = frame.height - (CGFloat(element) / CGFloat(maximum) * frame.height) * scale
            let x = CGFloat(index) / CGFloat(data.count) * frame.width

            return CGPoint(x: x, y: y)
        }
        
        let curves = UIBezierPath()
        curves.interpolatePointsWithHermite(interpolationPoints)
        
        path.append(curves)
        
        path.addLine(to: CGPoint(x: frame.width, y: frame.height))
        path.addLine(to: CGPoint(x: 0, y: frame.height))
        
        layer.path = path.cgPath
    }
}

extension UIBezierPath
{
    func interpolatePointsWithHermite(_ interpolationPoints : [CGPoint], alpha : CGFloat = 1.0/3.0)
    {
        guard !interpolationPoints.isEmpty else { return }
        self.move(to: interpolationPoints[0])
        
        let n = interpolationPoints.count - 1
        
        for index in 0..<n
        {
            var currentPoint = interpolationPoints[index]
            var nextIndex = (index + 1) % interpolationPoints.count
            var prevIndex = index == 0 ? interpolationPoints.count - 1 : index - 1
            var previousPoint = interpolationPoints[prevIndex]
            var nextPoint = interpolationPoints[nextIndex]
            let endPoint = nextPoint
            var mx : CGFloat
            var my : CGFloat
            
            if index > 0
            {
                mx = (nextPoint.x - previousPoint.x) / 2.0
                my = (nextPoint.y - previousPoint.y) / 2.0
            }
            else
            {
                mx = (nextPoint.x - currentPoint.x) / 2.0
                my = (nextPoint.y - currentPoint.y) / 2.0
            }
            
            let controlPoint1 = CGPoint(x: currentPoint.x + mx * alpha, y: currentPoint.y + my * alpha)
            currentPoint = interpolationPoints[nextIndex]
            nextIndex = (nextIndex + 1) % interpolationPoints.count
            prevIndex = index
            previousPoint = interpolationPoints[prevIndex]
            nextPoint = interpolationPoints[nextIndex]
            
            if index < n - 1
            {
                mx = (nextPoint.x - previousPoint.x) / 2.0
                my = (nextPoint.y - previousPoint.y) / 2.0
            }
            else
            {
                mx = (currentPoint.x - previousPoint.x) / 2.0
                my = (currentPoint.y - previousPoint.y) / 2.0
            }
            
            let controlPoint2 = CGPoint(x: currentPoint.x - mx * alpha, y: currentPoint.y - my * alpha)
            
            self.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
    }
}
