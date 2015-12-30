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
    let tableView: UITableView =
    {
        let tableView = UITableView(frame: CGRectZero,
            style: UITableViewStyle.Plain)
        
        tableView.registerClass(FilterInputItemRenderer.self,
            forCellReuseIdentifier: "FilterInputItemRenderer")
        
        return tableView
    }()
    
    lazy var ciContext: CIContext =
    {
        [unowned self] in
        
        return CIContext(EAGLContext: self.eaglContext,
            options: [kCIContextWorkingColorSpace: NSNull()])
    }()

    let eaglContext = EAGLContext(API: .OpenGLES2)
    let imageView = GLKView()
    
    var filterName: String?
    {
        didSet
        {
            filterParameterValues = [String: AnyObject]()
            
            updateFromFilterName()
        }
    }
    
    private var currentFilter: CIFilter?
    private var filterParameterValues = [String: AnyObject]()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        imageView.context = eaglContext
        imageView.delegate = self
        imageView.layer.borderColor = UIColor.grayColor().CGColor
        imageView.layer.borderWidth = 1
        
        addSubview(tableView)
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateFromFilterName()
    {
        guard let filter = CIFilter(name: filterName ?? "") else
        {
            print("clear UI")
            return
        }
        
        currentFilter = filter
        tableView.reloadData()
        
        imageView.setNeedsDisplay()
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
        
        if let attributes = currentFilter?.attributes[inputKey] as? [String : AnyObject]
        {
            cell.detail = (inputKey: inputKey, attributes: attributes)
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
        
        if currentFilter.inputKeys.contains(kCIInputImageKey) && filterParameterValues[kCIInputImageKey] == nil
        {
            currentFilter.setValue(assets.first!.ciImage, forKey: kCIInputImageKey)
        }
        
        for (key, value) in filterParameterValues where currentFilter.inputKeys.contains(key)
        {
            currentFilter.setValue(value, forKey: key)
        }
        
        let outputImage = currentFilter.outputImage!
        
        ciContext.drawImage(outputImage,
            inRect: CGRect(x: 0, y: 0,
                width: imageView.drawableWidth,
                height: imageView.drawableHeight),
            fromRect: CGRect(x: 0, y: 0, width: 640, height: 640))
    }
}
