//
//  CompositeOverBlackFilter.swift
//  Filterpedia
//
//  Created by Simon Gladman on 01/01/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import UIKit
import CoreImage

class CompositeOverBlackFilter: CIFilter
{
    let black: CIFilter
    let composite: CIFilter
    
    @objc var inputImage : CIImage?
    
    override init()
    {
        black = CIFilter(name: "CIConstantColorGenerator",
            parameters: [kCIInputColorKey: CIColor(color: UIColor.black)])!
        
        composite = CIFilter(name: "CISourceAtopCompositing",
            parameters: [kCIInputBackgroundImageKey: black.outputImage!])!
        
        super.init()
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        composite.setValue(inputImage, forKey: kCIInputImageKey)
        
        return composite.outputImage
    }
}
