//
//  VectorSlider.swift
//  Filterpedia
//
//  Created by Simon Gladman on 29/12/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class VectorSlider: UIControl
{
    let stackView: UIStackView =
    {
        let stackView = UIStackView()
        
        stackView.distribution = UIStackViewDistribution.FillEqually
        stackView.axis = UILayoutConstraintAxis.Horizontal
        
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
    
    var vector: CIVector?
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

            for (index, slider) in stackView.arrangedSubviews.enumerate() where slider is UISlider
            {
                if let slider = slider as? UISlider
                {
                    slider.value = Float(vector.valueAtIndex(index))
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
   
        let sliderMax = vector.sliderMax
        
        for _ in 0 ..< vector.count
        {
            let slider = UISlider()
          
             slider.maximumValue = Float(sliderMax)
            slider.addTarget(self, action: "sliderChangeHandler", forControlEvents: UIControlEvents.ValueChanged)
            
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
        
        sendActionsForControlEvents(UIControlEvents.ValueChanged)
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
                self.valueAtIndex(i) > 1 ? self.valueAtIndex(i) * 2 : 1)
        }
        
        return maxValue
    }
}