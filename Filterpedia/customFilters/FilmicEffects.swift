//
//  FilmicEffects.swift
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

// MARKL Bleach Bypass
// Based on http://developer.download.nvidia.com/shaderlibrary/webpages/shader_library.html#post_bleach_bypass

class BleachBypassFilter: CIFilter
{
    var inputImage : CIImage?
    var inputAmount = CGFloat(1)
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "Bleach Bypass Filter",
            
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputAmount": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1,
                kCIAttributeDisplayName: "Amount",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    override func setDefaults()
    {
        inputAmount = 1
    }
    
    let bleachBypassKernel = CIColorKernel(string:
        "kernel vec4 bleachBypassFilter(__sample image, float amount) \n" +
        "{ \n" +
        "   float luma = dot(image.rgb, vec3(0.2126, 0.7152, 0.0722));" +

        "   float l = min(1.0, max (0.0, 10.0 * (luma - 0.45))); \n" +
        "   vec3 result1 = vec3(2.0) * image.rgb * vec3(luma); \n" +
        "   vec3 result2 = 1.0 - 2.0 * (1.0 - luma) * (1.0 - image.rgb); \n" +
        "   vec3 newColor = mix(result1,result2,l); \n" +
            
         "   return mix(image, vec4(newColor.r, newColor.g, newColor.b, image.a), amount); \n" +
        "}"
    )
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage,
            let bleachBypassKernel = bleachBypassKernel else
        {
            return nil
        }
        
        let extent = inputImage.extent
        let arguments = [inputImage, inputAmount] as [Any]
        
        return bleachBypassKernel.apply(withExtent: extent, arguments: arguments)
    }
}

// MARK: 3 Strip TechnicolorFilter
// Based on shader code from http://001.vade.info/

class TechnicolorFilter: CIFilter
{
    var inputImage : CIImage?
    var inputAmount = CGFloat(1)
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "Technicolor Filter",
            
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputAmount": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1,
                kCIAttributeDisplayName: "Amount",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    override func setDefaults()
    {
        inputAmount = 1
    }

    let technicolorKernel = CIColorKernel(string:
        "kernel vec4 technicolorFilter(__sample image, float amount)" +
        "{" +
        "   vec3 redmatte = 1.0 - vec3(image.r - ((image.g + image.b)/2.0));" +
        "   vec3 greenmatte = 1.0 - vec3(image.g - ((image.r + image.b)/2.0));" +
        "   vec3 bluematte = 1.0 - vec3(image.b - ((image.r + image.g)/2.0)); " +
        
        "   vec3 red =  greenmatte * bluematte * image.r; " +
        "   vec3 green = redmatte * bluematte * image.g; " +
        "   vec3 blue = redmatte * greenmatte * image.b; " +
            
        "   return mix(image, vec4(red.r, green.g, blue.b, image.a), amount);" +
        "}"
    )
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage,
            let technicolorKernel = technicolorKernel else
        {
            return nil
        }
        
        let extent = inputImage.extent
        let arguments = [inputImage, inputAmount] as [Any]
        
        return technicolorKernel.apply(withExtent: extent, arguments: arguments)
    }
}
