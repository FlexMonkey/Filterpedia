//
//  CompoundEye.swift
//  Filterpedia
//
//  Created by Simon Gladman on 21/02/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//
//  Created by Simon Gladman on 07/02/2016.
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

class CompoundEye: CIFilter
{
    var inputImage: CIImage?
    
    var inputWidth: CGFloat = 32
    var inputBend: CGFloat = 4.0
    var inputBackgroundColor = CIColor(red: 0.2, green: 0.2, blue: 0.2)
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Compound Eye",
            
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputWidth": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 32,
                kCIAttributeDisplayName: "Width",
                kCIAttributeMin: 10,
                kCIAttributeSliderMin: 10,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputBend": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 4,
                kCIAttributeDisplayName: "Bend",
                kCIAttributeMin: 2,
                kCIAttributeSliderMin: 2,
                kCIAttributeSliderMax: 8,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputBackgroundColor": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIColor",
                kCIAttributeDisplayName: "Background Color",
                kCIAttributeDefault: CIColor(red: 0.2, green: 0.2, blue: 0.2),
                kCIAttributeType: kCIAttributeTypeColor]
        ]
    }
    
    override func setDefaults()
    {
        inputWidth = 32
        inputBend = 4
        inputBackgroundColor = CIColor(red: 0.2, green: 0.2, blue: 0.2)
    }
    
    let colorKernel = CIColorKernel(string:
        "kernel vec4 color(__sample pixel, float width, float halfWidth, float height)" +
        "{" +
        " vec2 coord = samplerCoord(pixel);" +
            
        " float y = float(int(coord.y / height)) * height;  " +
        
        " int yIndex = int(mod(coord.y / height, 2.0)); " +
        
        " float xOffset = (yIndex == 0) ? halfWidth : 0.0; " +
        
        " float x = float(int((coord.x + xOffset) / width)) * width;  " +
        
        " float dist = distance(vec2(x + halfWidth, y + (height / 2.0)), vec2(coord.x + xOffset, coord.y) ); " +
            
        " return dist < (sqrt(height * height) / 2.0)  ? vec4(0.0, 0.0, 0.0, 0.0) : vec4(1.0, 1.0, 1.0, 1.0); " +
        "}"
    )
    
    let warpKernel = CIWarpKernel(string:
        "kernel vec2 warp(float width, float halfWidth, float height, float bend)" +
        "{ " +
        
        " float y = float(int(destCoord().y / height)) * height;  " +
        
        " int yIndex = int(mod(destCoord().y / height, 2.0)); " +
        
        " float xOffset = (yIndex == 0) ? halfWidth : 0.0; " +
        
        " float x = float(int((destCoord().x + xOffset) / width)) * width;  " +
        
        " float dist = distance(vec2(x + halfWidth, y + (height / 2.0)), vec2(destCoord().x + xOffset, destCoord().y) ); " +
        
        " float xx = destCoord().x + xOffset + pow((destCoord().x + xOffset - x) / bend, 2.0);" +
        " float yy = destCoord().y + pow((destCoord().y - y) / bend, 2.0);" +
        
        " return dist < (sqrt(height * height) / 2.0)  ? vec2(xx - width, yy - height) : vec2(-1.0, -1.0); " +
        "}"
    )
    
    override var outputImage : CIImage!
    {
        if let inputImage = inputImage,
            warpKernel = warpKernel,
            colorKernel = colorKernel
        {
            let halfWidth = inputWidth / 2
            let height = sqrt(3.0) / 2.0 * inputWidth
            
            let extent = inputImage.extent
            
            let warpedImage = warpKernel.applyWithExtent(extent,
                roiCallback:
                {
                    (index, rect) in
                    return rect
                },
                inputImage: inputImage,
                arguments: [inputWidth, halfWidth, height, inputBend])!
            
            let maskImage =  colorKernel.applyWithExtent(extent,
                arguments: [inputImage, inputWidth, halfWidth, height])!
            
            let backgroundImage = CIImage(color: inputBackgroundColor)
                .imageByCroppingToRect(extent)
            
            return CIFilter(name: "CIBlendWithMask",
                withInputParameters: [
                kCIInputBackgroundImageKey: warpedImage,
                kCIInputImageKey: backgroundImage,
                kCIInputMaskImageKey: maskImage])?.outputImage
        }
        return nil
    }
}
