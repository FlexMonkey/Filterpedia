//
//  LabelledSlider.swift
//  Filterpedia
//
//  Created by Simon Gladman on 29/12/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//


import UIKit

class LabelledSlider: UIControl
{
    let minValueLabel = UILabel()
    let maxValueLabel = UILabel()
    
    let slider = UISlider()
    
    var max: Float = 0
    {
        didSet
        {
            slider.maximumValue = max
            maxValueLabel.text = String(format: "%.2f", max)
        }
    }
    
    var min: Float = 0
    {
        didSet
        {
            slider.minimumValue = min
            minValueLabel.text = String(format: "%.2f", min)
        }
    }
    
    var value: Float = 0
    {
        didSet
        {
            slider.value = value
        }
    }

    override init(frame: CGRect)
    {
        super.init(frame: frame)

        minValueLabel.textAlignment = .Right
        
        addSubview(minValueLabel)
        addSubview(maxValueLabel)
        
        addSubview(slider)
 
        slider.addTarget(self, action: "sliderChangeHandler", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func sliderChangeHandler()
    {
        value = slider.value

        sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
    override func layoutSubviews()
    {
        let valueLabelWidth: CGFloat = 75
        
        minValueLabel.frame = CGRect(x: 0,
            y: 0,
            width: valueLabelWidth,
            height: frame.height)
        
        maxValueLabel.frame = CGRect(x: frame.width - valueLabelWidth,
            y: 0,
            width: valueLabelWidth,
            height: frame.height)
        
        slider.frame = CGRect(x: valueLabelWidth + 5,
            y: 0,
            width: frame.width - valueLabelWidth - valueLabelWidth - 10,
            height: frame.height)
    }
    
}
