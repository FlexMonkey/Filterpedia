//
//  FilterDetail.swift
//  Filterpedia
//
//  Created by Simon Gladman on 29/12/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit
import GLKit

class FilterDetail: UIView
{
    let eaglContext = EAGLContext(API: .OpenGLES2)
    
    let shapeLayer: CAShapeLayer =
    {
        let layer = CAShapeLayer()
        
        layer.strokeColor = UIColor.lightGrayColor().CGColor
        layer.fillColor = nil
        layer.lineWidth = 0.5
        
        return layer
    }()
    
    let tableView: UITableView =
    {
        let tableView = UITableView(frame: CGRectZero,
            style: UITableViewStyle.Plain)
        
        tableView.registerClass(FilterInputItemRenderer.self,
            forCellReuseIdentifier: "FilterInputItemRenderer")
        
        return tableView
    }()
    
    lazy var imageView: GLKView =
    {
        [unowned self] in
        
        let imageView = GLKView()
        
        imageView.layer.borderColor = UIColor.grayColor().CGColor
        imageView.layer.borderWidth = 1
        imageView.layer.shadowOffset = CGSize(width: 0, height: 0)
        imageView.layer.shadowOpacity = 0.75
        imageView.layer.shadowRadius = 5
        
        imageView.context = self.eaglContext
        imageView.delegate = self
        
        return imageView
    }()
    
    lazy var ciContext: CIContext =
    {
        [unowned self] in
        
        return CIContext(EAGLContext: self.eaglContext,
            options: [kCIContextWorkingColorSpace: NSNull()])
    }()

    var filterName: String?
    {
        didSet
        {
            updateFromFilterName()
        }
    }
    
    private var currentFilter: CIFilter?
    
    /// User defined filter parameter values
    private var filterParameterValues: [String: AnyObject] = [kCIInputImageKey: assets.first!.ciImage]
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        tableView.dataSource = self
        tableView.delegate = self
 
        addSubview(tableView)
        addSubview(imageView)
        
        layer.addSublayer(shapeLayer)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateFromFilterName()
    {
        guard let filter = CIFilter(name: filterName ?? "") else
        {
            return
        }
        
        currentFilter = filter
        fixFilterParameterValues()
        
        tableView.reloadData()
        
        imageView.setNeedsDisplay()
    }
    
    /// Assign a default image if required and ensure existing
    /// filterParameterValues won't break the new filter.
    func fixFilterParameterValues()
    {
        guard let currentFilter = currentFilter else
        {
            return
        }
        
        let attributes = currentFilter.attributes
        
        for inputKey in currentFilter.inputKeys
        {
            if let attribute = attributes[inputKey] as? [String : AnyObject]
            {
                // default image
                if let className = attribute[kCIAttributeClass] as? String
                    where className == "CIImage" && filterParameterValues[inputKey] == nil
                {
                    filterParameterValues[inputKey] = assets.first!.ciImage
                }
                
                // ensure previous values don't exceed kCIAttributeSliderMax for this filter
                if let maxValue = attribute[kCIAttributeSliderMax] as? Float,
                    filterParameterValue = filterParameterValues[inputKey] as? Float
                    where filterParameterValue > maxValue
                {
                    filterParameterValues[inputKey] = maxValue
                }
                
                // ensure vector is correct length
                if let defaultVector = attribute[kCIAttributeDefault] as? CIVector,
                    filterParameterValue = filterParameterValues[inputKey] as? CIVector
                    where defaultVector.count != filterParameterValue.count
                {
                    filterParameterValues[inputKey] = defaultVector
                }
            }
        }
    }
    
    override func layoutSubviews()
    {
        let halfWidth = frame.width * 0.5
        let thirdHeight = frame.height * 0.333
        let twoThirdHeight = frame.height * 0.666
        
        imageView.frame = CGRect(x: halfWidth - thirdHeight,
            y: 0,
            width: twoThirdHeight,
            height: twoThirdHeight)
        
        tableView.frame = CGRect(x: 0,
            y: twoThirdHeight,
            width: frame.width,
            height: thirdHeight)
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0))
        path.addLineToPoint(CGPoint(x: 0, y: frame.height))
        
        shapeLayer.path = path.CGPath
    }
}

// MARK: UITableViewDelegate extension

extension FilterDetail: UITableViewDelegate
{
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 85
    }
}

// MARK: UITableViewDataSource extension

extension FilterDetail: UITableViewDataSource
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return currentFilter?.inputKeys.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("FilterInputItemRenderer",
            forIndexPath: indexPath) as! FilterInputItemRenderer
 
        let inputKey = currentFilter?.inputKeys[indexPath.row] ?? ""
        
        if let attribute = currentFilter?.attributes[inputKey] as? [String : AnyObject]
        {
            cell.detail = (inputKey: inputKey,
                attribute: attribute,
                filterParameterValues: filterParameterValues)
        }
        
        cell.delegate = self
        
        return cell
    }
}

// MARK: FilterInputItemRendererDelegate extension

extension FilterDetail: FilterInputItemRendererDelegate
{
    func filterInputItemRenderer(filterInputItemRenderer: FilterInputItemRenderer, didChangeValue: AnyObject?, forKey: String?)
    {
        if let key = forKey, value = didChangeValue
        {
            filterParameterValues[key] = value
            
            imageView.setNeedsDisplay()
        }
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return false
    }
}

// MARK: GLKViewDelegate extension

extension FilterDetail: GLKViewDelegate
{
    func glkView(view: GLKView, drawInRect rect: CGRect)
    {
        guard let currentFilter = currentFilter else
        {
            return
        }

        for (key, value) in filterParameterValues where currentFilter.inputKeys.contains(key)
        {
            currentFilter.setValue(value, forKey: key)
        }
        
        let outputImage = currentFilter.outputImage!
        
        // if a filter's output image is smaller than 640x640 (e.g. circular wrap or lenticular 
        // halo), composite the output over a black background)
        if outputImage.extent.width < 640 || outputImage.extent.height < 640
        {
            let black = CIFilter(name: "CIConstantColorGenerator",
                withInputParameters: [kCIInputColorKey: CIColor(color: UIColor.blackColor())])!
            let composite = CIFilter(name: "CISourceAtopCompositing",
                withInputParameters: [kCIInputBackgroundImageKey: black.outputImage!])!
            
            composite.setValue(outputImage, forKey: kCIInputImageKey)
            
            ciContext.drawImage(composite.outputImage!,
                inRect: CGRect(x: 0, y: 0,
                    width: imageView.drawableWidth,
                    height: imageView.drawableHeight),
                fromRect: CGRect(x: 0, y: 0, width: 640, height: 640))
        }
        else
        {
            ciContext.drawImage(outputImage,
                inRect: CGRect(x: 0, y: 0,
                    width: imageView.drawableWidth,
                    height: imageView.drawableHeight),
                fromRect: CGRect(x: 0, y: 0, width: 640, height: 640))
        }
    }
}
