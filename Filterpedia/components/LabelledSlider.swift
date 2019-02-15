//
//  LabelledSlider.swift
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

        minValueLabel.textAlignment = .right
        
        addSubview(minValueLabel)
        addSubview(maxValueLabel)
        
        addSubview(slider)
 
        slider.addTarget(self, action: #selector(LabelledSlider.sliderChangeHandler), for: UIControl.Event.valueChanged)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func sliderChangeHandler()
    {
        value = slider.value

        sendActions(for: UIControl.Event.valueChanged)
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
