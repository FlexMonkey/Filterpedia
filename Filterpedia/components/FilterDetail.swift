//
//  FilterDetail.swift
//  Filterpedia
//
//  Created by Simon Gladman on 29/12/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

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
    
    var filterName: String?
    {
        didSet
        {
            updateFromFilterName()
        }
    }
    
    var currentFilter: CIFilter?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        addSubview(tableView)
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
        
//        print(CIFilter.localizedDescriptionForFilterName(filterName!))
        
//        let attributes = filter.attributes
//        
//        let displayName = attributes[kCIAttributeFilterDisplayName]
//        
//        print(displayName)
//        
//        let inputs = filter.inputKeys
//        
//        for input in inputs
//        {
//            let xxx = attributes[input]
//            
//            print(input )
//            print(xxx)
//        }
    }
    
    override func layoutSubviews()
    {
        tableView.frame = CGRect(x: 0,
            y: frame.height * 0.666,
            width: frame.width,
            height: frame.height * 0.333)
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
}

// MARK: UITableViewDelegate extension

extension FilterDetail: UITableViewDelegate
{
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 80
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
            cell.attributes = attributes
        
        }
        
        return cell
    }
}

// MARK: Filter input item renderer

class FilterInputItemRenderer: UITableViewCell
{
    let slider = LabelledSlider()
    let imagesSegmentedControl = UISegmentedControl(items: ["Sunflower", "Landscape", "Night"])
    
    let titleLabel = UILabel()
    
    let descriptionLabel: UILabel =
    {
        let label = UILabel()
        
        label.numberOfLines = 2
        label.font = UIFont.italicSystemFontOfSize(12)
        
        return label
    }()
    
    let stackView: UIStackView =
    {
        let stackView = UIStackView()
        
        stackView.axis = UILayoutConstraintAxis.Vertical
        
        return stackView
    }()
    
    let vectorSlider = VectorSlider()
    
    var attributes: [String : AnyObject] = ["": ""]
    {
        didSet
        {
            titleLabel.text = (attributes[kCIAttributeDisplayName] as? String ?? "") + ": " + (attributes[kCIAttributeClass] as? String ?? "")
            
            descriptionLabel.text = attributes[kCIAttributeDescription] as? String ?? "[No description]"
            
            slider.min = attributes[kCIAttributeSliderMin] as? Float ?? 0
            slider.max = attributes[kCIAttributeSliderMax] as? Float ?? 1
            slider.value = attributes[kCIAttributeDefault] as? Float ?? 0
        
            updateForAttribute()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(slider)
        stackView.addArrangedSubview(imagesSegmentedControl)
        stackView.addArrangedSubview(vectorSlider)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateForAttribute()
    {
        guard let attributeType = attributes[kCIAttributeClass] as? String else
        {
            // clear UI
            return
        }
        
        switch attributeType // CIColor
        {
        case "NSNumber":
            slider.hidden = false
            imagesSegmentedControl.hidden = true
            vectorSlider.hidden = true
            
        case "CIImage":
            slider.hidden = true
            imagesSegmentedControl.hidden = false
            vectorSlider.hidden = true
            
        case "CIVector":
            slider.hidden = true
            imagesSegmentedControl.hidden = true
            vectorSlider.hidden = false
            
            // CIAttributeType = CIAttributeTypePosition - use max value of image extent
            // CIAttributeType = CIAttributeTypeOffset; - use max value of 1
            
            vectorSlider.vector = attributes[kCIAttributeDefault] as? CIVector
            
        case "CIColor":
            slider.hidden = true
            imagesSegmentedControl.hidden = true
            vectorSlider.hidden = false
            
            if let color = attributes[kCIAttributeDefault] as? CIColor
            {
                vectorSlider.vector = CIVector(x: color.red, y: color.green, z: color.blue, w: color.alpha)
            }
            
        default:
            slider.hidden = true
            imagesSegmentedControl.hidden = true
            vectorSlider.hidden = true
            
        }
    }
    
    override func layoutSubviews()
    {
        stackView.frame = contentView.bounds.insetBy(dx: 5, dy: 5)
        
    }
}