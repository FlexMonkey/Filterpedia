//
//  FilterInputItemRenderer.swift
//  Filterpedia
//
//  Created by Simon Gladman on 30/12/2015.
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


class FilterInputItemRenderer: UITableViewCell
{
    let slider = LabelledSlider()
    let vectorSlider = VectorSlider()
    let imagesSegmentedControl = UISegmentedControl(items: assetLabels)
    
    let titleLabel = UILabel()
    
    let shapeLayer: CAShapeLayer =
    {
        let layer = CAShapeLayer()
        
        layer.strokeColor = UIColor.lightGrayColor().CGColor
        layer.fillColor = nil
        layer.lineWidth = 0.5
        
        return layer
    }()
    
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
    
    weak var delegate: FilterInputItemRendererDelegate?
    private(set) var inputKey: String = ""
    
    var detail: (inputKey: String, attribute: [String : AnyObject], filterParameterValues: [String: AnyObject]) = ("", [String: AnyObject](), [String: AnyObject]())
    {
        didSet
        {
            filterParameterValues = detail.filterParameterValues
            inputKey = detail.inputKey
            attribute = detail.attribute
        }
    }
   
    private var title: String = ""
    private var filterParameterValues = [String: AnyObject]()
    
    private(set) var attribute = [String : AnyObject]()
    {
        didSet
        {
            let displayName = attribute[kCIAttributeDisplayName] as? String ?? ""
            let className = attribute[kCIAttributeClass] as? String ?? ""
            
            title = "\(displayName) (\(inputKey): \(className))"
            
            titleLabel.text = "\(displayName) (\(inputKey): \(className))"
            
            descriptionLabel.text = attribute[kCIAttributeDescription] as? String ?? "[No description]"
        
            updateForAttribute()
        }
    }
 
    private(set) var value: AnyObject?
    {
        didSet
        {
            delegate?.filterInputItemRenderer(self, didChangeValue: value, forKey: inputKey)
            
            if let value = value
            {
                titleLabel.text = title + " = \(value)"
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.layer.addSublayer(shapeLayer)
        
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(slider)
        stackView.addArrangedSubview(imagesSegmentedControl)
        stackView.addArrangedSubview(vectorSlider)
      
        slider.addTarget(self,
            action: "sliderChangeHandler",
            forControlEvents: UIControlEvents.ValueChanged)
        
        vectorSlider.addTarget(self,
            action: "vectorSliderChangeHandler",
            forControlEvents: UIControlEvents.ValueChanged)
        
        imagesSegmentedControl.addTarget(self,
            action: "imagesSegmentedControlChangeHandler",
            forControlEvents: UIControlEvents.ValueChanged)
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
        guard let attributeType = attribute[kCIAttributeClass] as? String,
            vector = vectorSlider.vector else
        {
            return
        }
        
        if attributeType == "CIColor"
        {
            value = CIColor(red: vector.X,
                green: vector.Y,
                blue: vector.Z,
                alpha: vector.W)
        }
        else
        {
            value = vector
        }
    }
    
    func imagesSegmentedControlChangeHandler()
    {
        value = assets[imagesSegmentedControl.selectedSegmentIndex].ciImage
    }
    
    // MARK: Update user interface for attributes
    
    func updateForAttribute()
    {
        guard let attributeType = attribute[kCIAttributeClass] as? String else
        {
            return
        }
        
        switch attributeType
        {
        case "NSNumber":
            slider.hidden = false
            imagesSegmentedControl.hidden = true
            vectorSlider.hidden = true
     
            slider.min = attribute[kCIAttributeSliderMin] as? Float ?? 0
            slider.max = attribute[kCIAttributeSliderMax] as? Float ?? 1
            slider.value = filterParameterValues[inputKey] as? Float ??
                attribute[kCIAttributeDefault] as? Float ??
                attribute[kCIAttributeSliderMin] as? Float ?? 0
            
            sliderChangeHandler()
            
        case "CIImage":
            slider.hidden = true
            imagesSegmentedControl.hidden = false
            vectorSlider.hidden = true
            
            imagesSegmentedControl.selectedSegmentIndex = assets.indexOf({ $0.ciImage == filterParameterValues[inputKey] as? CIImage}) ?? 0
            
            imagesSegmentedControlChangeHandler()
            
        case "CIVector":
            slider.hidden = true
            imagesSegmentedControl.hidden = true
            vectorSlider.hidden = false
         
            let max: CGFloat? = (attribute[kCIAttributeType] as? String == kCIAttributeTypePosition) ? 640 : nil
            let vector = filterParameterValues[inputKey] as? CIVector ?? attribute[kCIAttributeDefault] as? CIVector
            
            vectorSlider.vectorWithMaximumValue = (vector, max)
            
            vectorSliderChangeHandler()
            
        case "CIColor":
            slider.hidden = true
            imagesSegmentedControl.hidden = true
            vectorSlider.hidden = false
            
            if let color = filterParameterValues[inputKey] as? CIColor ?? attribute[kCIAttributeDefault] as? CIColor
            {
                let colorVector = CIVector(x: color.red, y: color.green, z: color.blue, w: color.alpha)
                vectorSlider.vectorWithMaximumValue = (colorVector, nil)
            }
            
            vectorSliderChangeHandler()
            
        default:
            slider.hidden = true
            imagesSegmentedControl.hidden = true
            vectorSlider.hidden = true
            
        }
    }
    
    override func layoutSubviews()
    {
        stackView.frame = contentView.bounds.insetBy(dx: 5, dy: 5)
        
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 5, y: contentView.bounds.height))
        path.addLineToPoint(CGPoint(x: contentView.bounds.width, y: contentView.bounds.height))
        
        shapeLayer.path = path.CGPath
        
    }
}

// MARK: FilterInputItemRendererDelegate

protocol FilterInputItemRendererDelegate: class
{
    func filterInputItemRenderer(filterInputItemRenderer: FilterInputItemRenderer, didChangeValue: AnyObject?, forKey: String?)
}
