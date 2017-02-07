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
    let textEditButton = UIButton()
    let slider = LabelledSlider()
    let vectorSlider = VectorSlider()
    let imagesSegmentedControl = UISegmentedControl(items: assetLabels)
    
    let titleLabel = UILabel()
    
    let shapeLayer: CAShapeLayer =
    {
        let layer = CAShapeLayer()
        
        layer.strokeColor = UIColor.lightGray.cgColor
        layer.fillColor = nil
        layer.lineWidth = 0.5
        
        return layer
    }()
    
    let descriptionLabel: UILabel =
    {
        let label = UILabel()
        
        label.numberOfLines = 2
        label.font = UIFont.italicSystemFont(ofSize: 12)
        
        return label
    }()
    
    let stackView: UIStackView =
    {
        let stackView = UIStackView()
        
        stackView.axis = UILayoutConstraintAxis.vertical
        
        return stackView
    }()
    
    weak var delegate: FilterInputItemRendererDelegate?
    fileprivate(set) var inputKey: String = ""
    
    var detail: (inputKey: String, attribute: [String : AnyObject], filterParameterValues: [String: AnyObject]) = ("", [String: AnyObject](), [String: AnyObject]())
    {
        didSet
        {
            filterParameterValues = detail.filterParameterValues
            inputKey = detail.inputKey
            attribute = detail.attribute
        }
    }
   
    fileprivate var title: String = ""
    fileprivate var filterParameterValues = [String: AnyObject]()
    
    fileprivate(set) var attribute = [String : AnyObject]()
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
 
    fileprivate(set) var value: AnyObject?
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
        
        textEditButton.layer.cornerRadius = 5
        textEditButton.layer.backgroundColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        textEditButton.setTitleColor(UIColor.blue, for: UIControlState())
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(slider)
        stackView.addArrangedSubview(imagesSegmentedControl)
        stackView.addArrangedSubview(vectorSlider)
        stackView.addArrangedSubview(textEditButton)
      
        slider.addTarget(self,
            action: #selector(FilterInputItemRenderer.sliderChangeHandler),
            for: UIControlEvents.valueChanged)
        
        vectorSlider.addTarget(self,
            action: #selector(FilterInputItemRenderer.vectorSliderChangeHandler),
            for: UIControlEvents.valueChanged)
        
        imagesSegmentedControl.addTarget(self,
            action: #selector(FilterInputItemRenderer.imagesSegmentedControlChangeHandler),
            for: UIControlEvents.valueChanged)
        
        textEditButton.addTarget(self,
            action: #selector(FilterInputItemRenderer.textEditClicked),
            for: .touchDown)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Change handlers
    
    func sliderChangeHandler()
    {
        value = slider.value as AnyObject?
    }
    
    func vectorSliderChangeHandler()
    {
        guard let attributeType = attribute[kCIAttributeClass] as? String,
            let vector = vectorSlider.vector else
        {
            return
        }
        
        if attributeType == "CIColor"
        {
            value = CIColor(red: vector.x,
                green: vector.y,
                blue: vector.z,
                alpha: vector.w)
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
    
    func textEditClicked()
    {
        guard let rootController = UIApplication.shared.keyWindow!.rootViewController else
        {
            return
        }
        
        let editTextController = UIAlertController(title: "Filterpedia", message: nil, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
            (_: UIAlertAction) in
            
            if let updatedText = editTextController.textFields?.first?.text
            {
                self.value = updatedText as AnyObject?
                
                self.textEditButton.setTitle(updatedText, for: UIControlState())
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        editTextController.addTextField
        {
            (textField: UITextField) in
            
            textField.text = self.value as? String
        }
        
        editTextController.addAction(okAction)
        editTextController.addAction(cancelAction)
        
        rootController.present(editTextController, animated: false, completion: nil)
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
            slider.isHidden = false
            imagesSegmentedControl.isHidden = true
            vectorSlider.isHidden = true
            textEditButton.isHidden = true
     
            slider.min = attribute[kCIAttributeSliderMin] as? Float ?? 0
            slider.max = attribute[kCIAttributeSliderMax] as? Float ?? 1
            slider.value = filterParameterValues[inputKey] as? Float ??
                attribute[kCIAttributeDefault] as? Float ??
                attribute[kCIAttributeSliderMin] as? Float ?? 0
            
            sliderChangeHandler()
            
        case "CIImage":
            slider.isHidden = true
            imagesSegmentedControl.isHidden = false
            vectorSlider.isHidden = true
            textEditButton.isHidden = true
            
            imagesSegmentedControl.selectedSegmentIndex = assets.index(where: { $0.ciImage == filterParameterValues[inputKey] as? CIImage}) ?? 0
            
            imagesSegmentedControlChangeHandler()
            
        case "CIVector":
            slider.isHidden = true
            imagesSegmentedControl.isHidden = true
            vectorSlider.isHidden = false
            textEditButton.isHidden = true
         
            let max: CGFloat? = (attribute[kCIAttributeType] as? String == kCIAttributeTypePosition) ? 640 : nil
            let vector = filterParameterValues[inputKey] as? CIVector ?? attribute[kCIAttributeDefault] as? CIVector
            
            vectorSlider.vectorWithMaximumValue = (vector, max)
            
            vectorSliderChangeHandler()
            
        case "CIColor":
            slider.isHidden = true
            imagesSegmentedControl.isHidden = true
            vectorSlider.isHidden = false
            textEditButton.isHidden = true
            
            if let color = filterParameterValues[inputKey] as? CIColor ?? attribute[kCIAttributeDefault] as? CIColor
            {
                let colorVector = CIVector(x: color.red, y: color.green, z: color.blue, w: color.alpha)
                vectorSlider.vectorWithMaximumValue = (colorVector, nil)
            }
            
            vectorSliderChangeHandler()
            
        case "NSString":
            slider.isHidden = true
            imagesSegmentedControl.isHidden = true
            vectorSlider.isHidden = true
            textEditButton.isHidden = false
      
            let text = filterParameterValues[inputKey] as? NSString ?? attribute[kCIAttributeDefault] as? NSString ?? ""
            
            value = text
            textEditButton.setTitle(String(text), for: UIControlState())
            
        default:
            slider.isHidden = true
            imagesSegmentedControl.isHidden = true
            vectorSlider.isHidden = true
            textEditButton.isHidden = true
            
        }
    }
    
    override func layoutSubviews()
    {
        stackView.frame = contentView.bounds.insetBy(dx: 5, dy: 5)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 5, y: contentView.bounds.height))
        path.addLine(to: CGPoint(x: contentView.bounds.width, y: contentView.bounds.height))
        
        shapeLayer.path = path.cgPath
        
    }
}

// MARK: FilterInputItemRendererDelegate

protocol FilterInputItemRendererDelegate: class
{
    func filterInputItemRenderer(_ filterInputItemRenderer: FilterInputItemRenderer, didChangeValue: AnyObject?, forKey: String?)
}
