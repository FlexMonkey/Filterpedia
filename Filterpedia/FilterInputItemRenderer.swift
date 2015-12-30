//
//  FilterInputItemRenderer.swift
//  Filterpedia
//
//  Created by Simon Gladman on 30/12/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit


class FilterInputItemRenderer: UITableViewCell
{
    let slider = LabelledSlider()
    let vectorSlider = VectorSlider()
    let imagesSegmentedControl = UISegmentedControl(items: assetLabels)
    
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
    
    var detail: (inputKey: String, attributes: [String : AnyObject]) = ("", ["": ""])
    {
        didSet
        {
            inputKey = detail.inputKey
            attributes = detail.attributes
        }
    }
    
    private(set) var inputKey: String = ""
    
    private(set) var attributes: [String : AnyObject] = ["": ""]
    {
        didSet
        {
            let displayName = attributes[kCIAttributeDisplayName] as? String ?? ""
            let className = attributes[kCIAttributeClass] as? String ?? ""
            
            titleLabel.text = "\(displayName) (\(inputKey): \(className))"
            
            descriptionLabel.text = attributes[kCIAttributeDescription] as? String ?? "[No description]"
            
            slider.min = attributes[kCIAttributeSliderMin] as? Float ?? 0
            slider.max = attributes[kCIAttributeSliderMax] as? Float ?? 1
            slider.value = attributes[kCIAttributeDefault] as? Float ?? 0
            
            updateForAttribute()
        }
    }
    
    weak var delegate: FilterInputItemRendererDelegate?

    private(set) var value: AnyObject?
    {
        didSet
        {
            delegate?.filterInputItemRenderer(self, didChangeValue: value, forKey: inputKey)
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
        
        slider.addTarget(self, action: "sliderChangeHandler", forControlEvents: UIControlEvents.ValueChanged)
        vectorSlider.addTarget(self, action: "vectorSliderChangeHandler", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Change handlers
    
    func sliderChangeHandler()
    {
        value = slider.value
    }
    
    func vectorSliderChangeHandler()
    {
        guard let attributeType = attributes[kCIAttributeClass] as? String, vector = vectorSlider.vector else
        {
            return
        }
        
        if attributeType == "CIColor"
        {
            value = CIColor(red: vector.X, green: vector.Y, blue: vector.Z, alpha: vector.W)
        }
        else
        {
            value = vector
        }
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

// MARK: FilterInputItemRendererDelegate

protocol FilterInputItemRendererDelegate: class
{
    func filterInputItemRenderer(filterInputItemRenderer: FilterInputItemRenderer, didChangeValue: AnyObject?, forKey: String?)
}
