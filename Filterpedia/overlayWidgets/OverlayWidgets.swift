//
//  OverlayWidgets.swift
//  Filterpedia
//
//  Created by Simon Gladman on 20/01/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import UIKit

protocol FilterAttributesDisplayable
{
    func setFilter(_ filter: CIFilter)
}

class OverlayWidgets
{
    static func getOverlayWidgetForFilter(_ filterName: String) -> FilterAttributesDisplayable?
    {
        switch filterName
        {
        case "RGBChannelToneCurve":
            return RGBChannelToneCurveWidget()
            
        case "CIToneCurve":
            return ToneCurveWidget()
            
        case "CMYKToneCurves":
            return CMYKChannelToneCurveWidget()
            
        default:
            return nil
        }
    }
}

// MARK: ToneCurveWidget

class ToneCurveWidget: UIView, FilterAttributesDisplayable
{
    let toneCurveLayer = curveLayer(strokeColor: UIColor.white.cgColor)
    
    func setFilter(_ filter: CIFilter)
    {
        if let inputPoint0 = filter.value(forKey: "inputPoint0") as? CIVector,
            let inputPoint1 = filter.value(forKey: "inputPoint1") as? CIVector,
            let inputPoint2 = filter.value(forKey: "inputPoint2") as? CIVector,
            let inputPoint3 = filter.value(forKey: "inputPoint3") as? CIVector,
            let inputPoint4 = filter.value(forKey: "inputPoint4") as? CIVector
        {
            let points =  [inputPoint0, inputPoint1, inputPoint2, inputPoint3, inputPoint4].map
            {
                CGPoint(x: $0.x * frame.width, y: (1 - $0.y) * frame.height)
            }
            
            let path = UIBezierPath()
            path.interpolatePointsWithHermite(points)
         
            toneCurveLayer.path = path.cgPath
        }
        else
        {
            toneCurveLayer.path = nil
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    
        layer.addSublayer(toneCurveLayer)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        toneCurveLayer.frame = bounds
    }
}

// MARK: RGBChannelToneCurveWidget

class RGBChannelToneCurveWidget: UIView, FilterAttributesDisplayable
{
    let redLayer: CAShapeLayer
    let greenLayer: CAShapeLayer
    let blueLayer: CAShapeLayer
    
    fileprivate var rgbChannelToneCurve: RGBChannelToneCurve?
    {
        didSet
        {
            guard let rgbChannelToneCurve = rgbChannelToneCurve else
            {
                return
            }
            
            redLayer.path = RGBChannelToneCurveWidget.pathForValues(rgbChannelToneCurve.inputRedValues, frame: frame)
            greenLayer.path = RGBChannelToneCurveWidget.pathForValues(rgbChannelToneCurve.inputGreenValues, frame: frame)
            blueLayer.path = RGBChannelToneCurveWidget.pathForValues(rgbChannelToneCurve.inputBlueValues, frame: frame)
        }
    }
    
    static func pathForValues(_ values: CIVector, frame: CGRect) -> CGPath
    {
        let xValues: [CGFloat] = [0, 0.25, 0.5, 0.75, 1.0]
        
        let points = zip(xValues, values.toArray()).map
        {
            CGPoint(x: $0 * frame.width, y: (1 - $1) * frame.height)
        }
        
        let path = UIBezierPath()
        path.interpolatePointsWithHermite(points)
        
        return path.cgPath
    }
    
    func setFilter(_ filter: CIFilter)
    {
        if let rgbChannelToneCurve =  filter as? RGBChannelToneCurve
        {
            self.rgbChannelToneCurve = rgbChannelToneCurve
        }
    }
    
    override init(frame: CGRect)
    {
        redLayer = curveLayer(strokeColor: UIColor.red.cgColor)
        greenLayer = curveLayer(strokeColor: UIColor.green.cgColor)
        blueLayer = curveLayer(strokeColor: UIColor.blue.cgColor)
        
        super.init(frame: frame)
    
        layer.addSublayer(redLayer)
        layer.addSublayer(greenLayer)
        layer.addSublayer(blueLayer)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        redLayer.frame = bounds
        greenLayer.frame = bounds
        blueLayer.frame = bounds
    }
}

// MARK: RGBChannelToneCurveWidget

class CMYKChannelToneCurveWidget: UIView, FilterAttributesDisplayable
{
    let cyanLayer: CAShapeLayer
    let magentaLayer: CAShapeLayer
    let yellowLayer: CAShapeLayer
    let blackLayer: CAShapeLayer
    
    fileprivate var cmykToneCurves: CMYKToneCurves?
    {
        didSet
        {
            guard let cmykToneCurves = cmykToneCurves else
            {
                return
            }
            
            cyanLayer.path = RGBChannelToneCurveWidget.pathForValues(cmykToneCurves.inputCyanValues, frame: frame)
            magentaLayer.path = RGBChannelToneCurveWidget.pathForValues(cmykToneCurves.inputMagentaValues, frame: frame)
            yellowLayer.path = RGBChannelToneCurveWidget.pathForValues(cmykToneCurves.inputYellowValues, frame: frame)
            blackLayer.path = RGBChannelToneCurveWidget.pathForValues(cmykToneCurves.inputBlackValues, frame: frame)
        }
    }
    
    static func pathForValues(_ values: CIVector, frame: CGRect) -> CGPath
    {
        let xValues: [CGFloat] = [0, 0.25, 0.5, 0.75, 1.0]
        
        let points = zip(xValues, values.toArray()).map
        {
            CGPoint(x: $0 * frame.width, y: (1 - $1) * frame.height)
        }
        
        let path = UIBezierPath()
        path.interpolatePointsWithHermite(points)
        
        return path.cgPath
    }
    
    func setFilter(_ filter: CIFilter)
    {
        if let cmykToneCurves = filter as? CMYKToneCurves
        {
            self.cmykToneCurves = cmykToneCurves
        }
    }
    
    override init(frame: CGRect)
    {
        cyanLayer = curveLayer(strokeColor: UIColor.cyan.cgColor)
        magentaLayer = curveLayer(strokeColor: UIColor.magenta.cgColor)
        yellowLayer = curveLayer(strokeColor: UIColor.yellow.cgColor)
        blackLayer = curveLayer(strokeColor: UIColor.black.cgColor)
        
        super.init(frame: frame)
    
        layer.addSublayer(cyanLayer)
        layer.addSublayer(magentaLayer)
        layer.addSublayer(yellowLayer)
        layer.addSublayer(blackLayer)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        cyanLayer.frame = bounds
        magentaLayer.frame = bounds
        yellowLayer.frame = bounds
        blackLayer.frame = bounds
    }
}

// MARK: Helper functions

func curveLayer(strokeColor color: CGColor) -> CAShapeLayer
{
    let layer = CAShapeLayer()
    
    layer.drawsAsynchronously = true
    
    layer.strokeColor = color
    layer.fillColor = nil
    layer.lineWidth = 3
    
    layer.shadowColor = UIColor.gray.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 0)
    layer.shadowOpacity = 1
    layer.shadowRadius = 3
    
    layer.masksToBounds = true
    
    return layer
}
