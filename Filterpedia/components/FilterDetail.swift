//
//  FilterDetail.swift
//  Filterpedia
//
//  Created by Simon Gladman on 29/12/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
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

class FilterDetail: UIView
{
    let rect640x640 = CGRect(x: 0, y: 0, width: 640, height: 640)
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    let compositeOverBlackFilter = CompositeOverBlackFilter()
    
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
    
    let scrollView = UIScrollView()
    
    let imageView: UIImageView =
    {
        let imageView = UIImageView()
        
        imageView.backgroundColor = UIColor.blackColor()
        
        imageView.layer.borderColor = UIColor.grayColor().CGColor
        imageView.layer.borderWidth = 1
        imageView.layer.shadowOffset = CGSize(width: 0, height: 0)
        imageView.layer.shadowOpacity = 0.75
        imageView.layer.shadowRadius = 5
        
        return imageView
    }()
    
    let ciMetalContext = CIContext(MTLDevice: MTLCreateSystemDefaultDevice()!)
    let ciOpenGLESContext = CIContext()
  
    /// Whether the user has changed the filter whilst it's
    /// running in the background.
    var pending = false
    
    /// Whether a filter is currently running in the background
    var busy = false
    {
        didSet
        {
            if busy
            {
                activityIndicator.startAnimating()
            }
            else
            {
                activityIndicator.stopAnimating()
            }
        }
    }
    
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
        
        addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.delegate = self
        
        imageView.addSubview(activityIndicator)
        
        layer.addSublayer(shapeLayer)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func updateFromFilterName()
    {
        guard let filterName = filterName, filter = CIFilter(name: filterName) else
        {
            return
        }
        
        imageView.subviews
            .filter({ $0 is FilterAttributesDisplayable})
            .forEach({ $0.removeFromSuperview() })
        
        if let widget = OverlayWidgets.getOverlayWidgetForFilter(filterName) as? UIView
        {
            imageView.addSubview(widget)
            
            widget.frame = imageView.bounds
        }
        
        currentFilter = filter
        fixFilterParameterValues()
        
        tableView.reloadData()
        
        applyFilter()
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

    func applyFilter()
    {
        guard !busy else
        {
            pending = true
            return
        }
        
        guard let currentFilter = self.currentFilter else
        {
            return
        }
        
        busy = true
        
        imageView.subviews
            .filter({ $0 is FilterAttributesDisplayable})
            .forEach({ ($0 as? FilterAttributesDisplayable)?.setFilter(currentFilter) })
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        {
            let startTime = CFAbsoluteTimeGetCurrent()
            
            for (key, value) in self.filterParameterValues where currentFilter.inputKeys.contains(key)
            {
                currentFilter.setValue(value, forKey: key)
            }
            
            let outputImage = currentFilter.outputImage!
            let finalImage: CGImageRef
  
            let context = (currentFilter is MetalFilter) ? self.ciMetalContext : self.ciOpenGLESContext
            
            if outputImage.extent.width == 1 || outputImage.extent.height == 1
            {
                // if a filter's output image height or width is 1,
                // (e.g. a reduction filter) stretch to 640x640
                
                let stretch = CIFilter(name: "CIStretchCrop",
                    withInputParameters: ["inputSize": CIVector(x: 640, y: 640),
                        "inputCropAmount": 0,
                        "inputCenterStretchAmount": 1,
                        kCIInputImageKey: outputImage])!
                
                finalImage = context.createCGImage(stretch.outputImage!,
                    fromRect: self.rect640x640)
            }
            else if outputImage.extent.width < 640 || outputImage.extent.height < 640
            {
                // if a filter's output image is smaller than 640x640 (e.g. circular wrap or lenticular
                // halo), composite the output over a black background)
                
                self.compositeOverBlackFilter.setValue(outputImage,
                    forKey: kCIInputImageKey)
                
                finalImage = context.createCGImage(self.compositeOverBlackFilter.outputImage!,
                    fromRect: self.rect640x640)
            }
            else
            {
                finalImage = context.createCGImage(outputImage,
                    fromRect: self.rect640x640)
            }
            
            let endTime = (CFAbsoluteTimeGetCurrent() - startTime)
            print(self.filterName!, "execution time", endTime)
            
            dispatch_async(dispatch_get_main_queue())
            {
                self.imageView.image = UIImage(CGImage: finalImage)
                self.busy = false
                
                if self.pending
                {
                    self.pending = false
                    self.applyFilter()
                }
            }
        }
    }
    
    override func layoutSubviews()
    {
        let halfWidth = frame.width * 0.5
        let thirdHeight = frame.height * 0.333
        let twoThirdHeight = frame.height * 0.666
        
        scrollView.frame = CGRect(x: halfWidth - thirdHeight,
            y: 0,
            width: twoThirdHeight,
            height: twoThirdHeight)
        
        imageView.frame = CGRect(x: 0,
            y: 0,
            width: scrollView.frame.width,
            height: scrollView.frame.height)
        
        tableView.frame = CGRect(x: 0,
            y: twoThirdHeight,
            width: frame.width,
            height: thirdHeight)
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        activityIndicator.frame = imageView.bounds
        
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
 
        if let inputKey = currentFilter?.inputKeys[indexPath.row],
            attribute = currentFilter?.attributes[inputKey] as? [String : AnyObject]
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
            
            applyFilter()
        }
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return false
    }
}
