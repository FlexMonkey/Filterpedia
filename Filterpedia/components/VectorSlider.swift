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
            stackView.arrangedSubviews.forEach
            {
                $0.removeFromSuperview()
            }
          
            guard let vector = vector else
            {
                return
            }
            
            
            for i in 0 ..< vector.count
            {
                let slider = UISlider()
                
                slider.value = Float(vector.valueAtIndex(i))
                
                stackView.addArrangedSubview(slider)
            }
        }
    }
    
    override func layoutSubviews()
    {
        stackView.frame = bounds
        stackView.spacing = 5
    }
}