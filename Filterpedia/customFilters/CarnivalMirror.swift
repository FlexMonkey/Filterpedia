//
//  CarnivalMirror.swift
//  Filterpedia
//
//  Created by Simon Gladman on 09/02/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
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

import CoreImage

class CarnivalMirror: CIFilter
{
    var inputImage : CIImage?
    
    var inputHorizontalWavelength: CGFloat = 10
    var inputHorizontalAmount: CGFloat = 20
    
    var inputVerticalWavelength: CGFloat = 10
    var inputVerticalAmount: CGFloat = 20
    
    override func setDefaults()
    {
        inputHorizontalWavelength = 10
        inputHorizontalAmount = 20
        
        inputVerticalWavelength = 10
        inputVerticalAmount = 20
    }
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "Carnival Mirror",
            
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputHorizontalWavelength": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 10,
                kCIAttributeDisplayName: "Horizontal Wavelength",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputHorizontalAmount": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 20,
                kCIAttributeDisplayName: "Horizontal Amount",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputVerticalWavelength": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 10,
                kCIAttributeDisplayName: "Vertical Wavelength",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputVerticalAmount": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 20,
                kCIAttributeDisplayName: "Vertical Amount",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
        
        
    }
    
    let carnivalMirrorKernel = CIWarpKernel(string:
        "kernel vec2 carnivalMirror(float xWavelength, float xAmount, float yWavelength, float yAmount)" +
        "{" +
        "   float y = destCoord().y + sin(destCoord().y / yWavelength) * yAmount; " +
        "   float x = destCoord().x + sin(destCoord().x / xWavelength) * xAmount; " +
        "   return vec2(x, y); " +
        "}"
    )
    
    override var outputImage : CIImage!
    {
        if let inputImage = inputImage,
            let kernel = carnivalMirrorKernel
        {
            let arguments = [
                inputHorizontalWavelength, inputHorizontalAmount,
                inputVerticalWavelength, inputVerticalAmount]
            
            let extent = inputImage.extent
            
            return kernel.apply(withExtent: extent,
                roiCallback:
                {
                    (index, rect) in
                    return rect
                },
                inputImage: inputImage,
                arguments: arguments)
        }
        return nil
    }
}
