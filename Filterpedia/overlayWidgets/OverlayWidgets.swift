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
    func setFilter(filter: CIFilter)
}

class OverlayWidgets
{
    static func getOverlayWidgetForFilter(filterName: String) -> FilterAttributesDisplayable?
    {
        switch filterName
        {
        case "RGBChannelToneCurve":
            return RGBChannelToneCurveWidget()
            
        default:
            return nil
        }
    }
}

class RGBChannelToneCurveWidget: UIView, FilterAttributesDisplayable
{
    let redLayer: CAShapeLayer
    let greenLayer: CAShapeLayer
    let blueLayer: CAShapeLayer
    
    private var rgbChannelToneCurve: RGBChannelToneCurve?
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
    
    static func pathForValues(values: CIVector, frame: CGRect) -> CGPathRef
    {
        let xValues: [CGFloat] = [0, 0.25, 0.5, 0.75, 1.0]
        
        let points = zip(xValues, values.toArray()).map
        {
            CGPoint(x: $0 * frame.width, y: (1 - $1) * frame.height)
        }
        
        let path = UIBezierPath()
        path.interpolatePointsWithHermite(points)
        
        return path.CGPath
    }
    
    static func curveLayer(strokeColor color: CGColorRef) -> CAShapeLayer
    {
        let layer = CAShapeLayer()
        
        layer.drawsAsynchronously = true
        
        layer.strokeColor = color
        layer.fillColor = nil
        layer.lineWidth = 3
        
        layer.shadowColor = UIColor.grayColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 1
        layer.shadowRadius = 3
        
        layer.masksToBounds = true
        
        return layer
    }
    
    func setFilter(filter: CIFilter)
    {
        if let rgbChannelToneCurve =  filter as? RGBChannelToneCurve
        {
            self.rgbChannelToneCurve = rgbChannelToneCurve
        }
    }
    
    override init(frame: CGRect)
    {
        redLayer = RGBChannelToneCurveWidget.curveLayer(strokeColor: UIColor.redColor().CGColor)
        greenLayer = RGBChannelToneCurveWidget.curveLayer(strokeColor: UIColor.greenColor().CGColor)
        blueLayer = RGBChannelToneCurveWidget.curveLayer(strokeColor: UIColor.blueColor().CGColor)
        
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
