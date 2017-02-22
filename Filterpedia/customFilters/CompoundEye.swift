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
    
    override var attributes: [String : Any]
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
                kCIAttributeSliderMax: 32,
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
        "kernel vec4 color(float width, float halfWidth, float height, float diameter)" +
        "{" +
        " float y = float(int(destCoord().y / height)) * height;  " +
        
        " int yIndex = int(mod(destCoord().y / height, 2.0)); " +
        
        " float xOffset = (yIndex == 0) ? halfWidth : 0.0; " +
        
        " float x = float(int((destCoord().x + xOffset) / width)) * width;  " +
        
        " float dist = distance(vec2(x + halfWidth, y + (height / 2.0)), vec2(destCoord().x + xOffset, destCoord().y) ); " +
            
        " return dist < diameter  ? vec4(0.0, 0.0, 0.0, 0.0) : vec4(1.0, 1.0, 1.0, 1.0); " +
        "}"
    )
    
    let warpKernel = CIWarpKernel(string:
        "kernel vec2 warp(float width, float halfWidth, float height, float diameter, float bend)" +
        "{ " +
        
        " float y = float(int(destCoord().y / height)) * height;  " +
        
        " int yIndex = int(mod(destCoord().y / height, 2.0)); " +
        
        " float xOffset = (yIndex == 0) ? halfWidth : 0.0; " +
        
        " float x = float(int((destCoord().x + xOffset) / width)) * width;  " +
        
        " vec2 cellCenter = vec2(x + halfWidth, y + (height / 2.0)); " +
        " vec2 offsetDestCoord = vec2(destCoord().x + xOffset, destCoord().y);" +
        
        " float dist = distance(cellCenter, offsetDestCoord); " +
        
        " vec2 sphereNormalXY = vec2(offsetDestCoord - cellCenter); " +
        
        " vec3 sphereNormal = vec3(sphereNormalXY, dist / bend); " +
        " vec3 reflectVector = reflect(vec3(0.0, 0.0, -1.0), sphereNormal); " +

        " return offsetDestCoord + reflectVector.xy; " +
        "}"
    )
    
    override var outputImage : CIImage!
    {
        if let inputImage = inputImage,
            let warpKernel = warpKernel,
            let colorKernel = colorKernel
        {
            let halfWidth = inputWidth / 2
            let height = sqrt(3.0) / 2.0 * inputWidth
            let diameter = sqrt(height * height) / 2.0
            
            let extent = inputImage.extent
            
            let warpedImage = warpKernel.apply(withExtent: extent,
                roiCallback:
                {
                    (index, rect) in
                    return rect
                },
                inputImage: inputImage,
                arguments: [inputWidth, halfWidth, height, diameter, inputBend])!
            
            let maskImage =  colorKernel.apply(withExtent: extent,
                arguments: [inputWidth, halfWidth, height, diameter])!
            
            let backgroundImage = CIImage(color: inputBackgroundColor)
                .cropping(to: extent)
            
            return CIFilter(name: "CIBlendWithMask",
                withInputParameters: [
                kCIInputBackgroundImageKey: warpedImage,
                kCIInputImageKey: backgroundImage,
                kCIInputMaskImageKey: maskImage])?.outputImage
        }
        return nil
    }
}
