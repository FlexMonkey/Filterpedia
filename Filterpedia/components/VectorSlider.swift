//
//  VectorSlider.swift
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

class VectorSlider: UIControl
{
    var maximumValue: CGFloat?
    
    let stackView: UIStackView =
    {
        let stackView = UIStackView()
        
        stackView.distribution = UIStackViewDistribution.fillEqually
        stackView.axis = UILayoutConstraintAxis.horizontal
        
        return stackView
    }()

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        addSubview(stackView)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    var vectorWithMaximumValue: (vector: CIVector?, maximumValue: CGFloat?)?
    {
        didSet
        {
            maximumValue = vectorWithMaximumValue?.maximumValue
            vector = vectorWithMaximumValue?.vector
        }
    }
    
    fileprivate(set) var vector: CIVector?
    {
        didSet
        {
            if (vector?.count ?? 0) != oldValue?.count
            {
                rebuildUI()
            }
            
            guard let vector = vector else
            {
                return
            }

            for (index, slider) in stackView.arrangedSubviews.enumerated() where slider is UISlider
            {
                if let slider = slider as? UISlider
                {
                    slider.value = Float(vector.value(at: index))
                }
            }
        }
    }
    
    func rebuildUI()
    {
        stackView.arrangedSubviews.forEach
        {
            $0.removeFromSuperview()
        }
        
        guard let vector = vector else
        {
            return
        }
   
        let sliderMax = maximumValue ?? vector.sliderMax
        
        for _ in 0 ..< vector.count
        {
            let slider = UISlider()
          
            slider.maximumValue = Float(sliderMax)
            slider.addTarget(self, action: #selector(VectorSlider.sliderChangeHandler), for: UIControlEvents.valueChanged)
            
            stackView.addArrangedSubview(slider)
        }
    }
    
    func sliderChangeHandler()
    {
        let values = stackView.arrangedSubviews
            .filter({ $0 is UISlider })
            .map({ CGFloat(($0 as! UISlider).value) })
        
        vector = CIVector(values: values,
            count: values.count)
        
        sendActions(for: UIControlEvents.valueChanged)
    }
    
    override func layoutSubviews()
    {
        stackView.frame = bounds
        stackView.spacing = 5
    }
}


extension CIVector
{
    /// If the maximum of any of the vector's values is greater than one,
    /// return double that, otherwise, return 1.
    ///
    /// `CIVector(x: 10, y: 12, z: 9, w: 11).sliderMax` = 24
    /// `CIVector(x: 0, y: 1, z: 1, w: 0).sliderMax` = 1
    
    var sliderMax: CGFloat
    {
        var maxValue: CGFloat = 1
        
        for i in 0 ..< self.count
        {
            maxValue = max(maxValue,
                self.value(at: i) > 1 ? self.value(at: i) * 2 : 1)
        }
        
        return maxValue
    }
}
