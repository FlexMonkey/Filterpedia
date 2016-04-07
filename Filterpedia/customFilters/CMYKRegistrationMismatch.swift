//
//  CMYKRegistrationMismatch.swift
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

import CoreImage

/// **CMYKLevels**
///
/// _Applies a multiplier to indivdual CMYK channels._
///
/// - Authors: Simon Gladman
/// - Date: April 2016
class CMYKLevels: CIFilter
{
    var inputImage: CIImage?
    
    var inputCyanMultiplier: CGFloat = 1
    var inputMagentaMultiplier: CGFloat = 1
    var inputYellowMultiplier: CGFloat = 1
    var inputBlackMultiplier: CGFloat = 1
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "CMYK Levels",
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputCyanMultiplier": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDisplayName: "Cyan Multiplier",
                kCIAttributeDefault: 1,
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 2,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputMagentaMultiplier": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDisplayName: "Magenta Multiplier",
                kCIAttributeDefault: 1,
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 2,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputYellowMultiplier": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDisplayName: "Yellow Multiplier",
                kCIAttributeDefault: 1,
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 2,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputBlackMultiplier": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDisplayName: "Black Multiplier",
                kCIAttributeDefault: 1,
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 2,
                kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
    
    let kernel = CIColorKernel(string:
        "vec4 rgbToCMYK(vec3 rgb)" +
        "{" +
        "   float k = 1.0 - max(max(rgb.r, rgb.g), rgb.b); \n" +
        "   float c = (1.0 - rgb.r - k) / (1.0 - k);  \n" +
        "   float m = (1.0 - rgb.g - k) / (1.0 - k); \n"  +
        "   float y = (1.0 - rgb.b - k) / (1.0 - k); \n"  +
        
        "   return vec4(c, m, y, k);" +
        "}" +
        
        "vec4 cmykToRGB(float c, float m, float y, float k)" +
        "{" +
        "    float r = (1.0 - c) * (1.0 - k);" +
        "    float g = (1.0 - m) * (1.0 - k);" +
        "    float b = (1.0 - y) * (1.0 - k);" +
        "    return vec4(r, g, b, 1.0);" +
        "}" +
    
        "kernel vec4 colorKernel(__sample pixel, float cyanMultiplier, float magentaMultiplier, float yellowMultiplier, float blackMultiplier)" +
        "{ " +
        "   vec4 cmyk = rgbToCMYK(pixel.rgb); " +
        "   cmyk.x *= cyanMultiplier;" +
        "   cmyk.y *= magentaMultiplier;" +
        "   cmyk.z *= yellowMultiplier;" +
        "   cmyk.w *= blackMultiplier;" +

        "   return cmykToRGB(cmyk.x, cmyk.y, cmyk.z, cmyk.w); " +
        "} "
    )
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage,
            kernel = kernel else
        {
            return nil
        }
        
        let extent = inputImage.extent
        let arguments = [inputImage, inputCyanMultiplier, inputMagentaMultiplier, inputYellowMultiplier, inputBlackMultiplier]
        
        return kernel.applyWithExtent(extent, arguments: arguments)
    }
}

/// **CMYKRegistrationMismatch**
///
/// _A filter for simulating registration mismatch of printed colors._
///
/// - Authors: Simon Gladman
/// - Date: April 2016
class CMYKRegistrationMismatch: CIFilter
{
    var inputImage: CIImage?
    var inputCyanOffset = CIVector(x: 5, y: 2)
    var inputMagentaOffset = CIVector(x: 1, y: 7)
    var inputYellowOffset = CIVector(x: 3, y: 4)
    var inputBlackOffset = CIVector(x: 7, y: 2)
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "CMYK Registration Mismatch",
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
 
            "inputCyanOffset": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Cyan Offset",
                kCIAttributeDefault: CIVector(x: 5, y: 2),
                kCIAttributeType: kCIAttributeTypeOffset],
            
            "inputMagentaOffset": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Magenta Offset",
                kCIAttributeDefault: CIVector(x: 1, y: 7),
                kCIAttributeType: kCIAttributeTypeOffset],
            
            "inputYellowOffset": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Yellow Offset",
                kCIAttributeDefault: CIVector(x: 3, y: 4),
                kCIAttributeType: kCIAttributeTypeOffset],
            
            "inputBlackOffset": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Black Offset",
                kCIAttributeDefault: CIVector(x: 7, y: 2),
                kCIAttributeType: kCIAttributeTypeOffset],
        ]
    }
    
    let kernel = CIKernel(string:

        "vec4 rgbToCMYK(vec3 rgb)" +
        "{" +
        "   float k = 1.0 - max(max(rgb.r, rgb.g), rgb.b); \n" +
        "   float c = (1.0 - rgb.r - k) / (1.0 - k);  \n" +
        "   float m = (1.0 - rgb.g - k) / (1.0 - k); \n"  +
        "   float y = (1.0 - rgb.b - k) / (1.0 - k); \n"  +
            
        "   return vec4(c, m, y, k);" +
        "}" +
            
        "vec4 cmykToRGB(float c, float m, float y, float k)" +
        "{" +
        "    float r = (1.0 - c) * (1.0 - k);" +
        "    float g = (1.0 - m) * (1.0 - k);" +
        "    float b = (1.0 - y) * (1.0 - k);" +
        "    return vec4(r, g, b, 1.0);" +
        "}" +
        
        "kernel vec4 coreImageKernel(sampler image, vec2 cyanOffset, vec2 magnetaOffset, vec2 yellowOffset, vec2 blackOffset)" +
        "{" +
        
        "   vec2 d = destCoord();" +

        "   vec3 cyanPixel = sample(image, samplerTransform(image, d + cyanOffset)).rgb;" +
        "   vec3 magentaPixel = sample(image, samplerTransform(image, d + magnetaOffset)).rgb;" +
        "   vec3 yellowPixel = sample(image, samplerTransform(image, d + yellowOffset)).rgb;" +
        "   vec3 blackPixel = sample(image, samplerTransform(image, d + blackOffset)).rgb;" +
            
        "   float cyan = rgbToCMYK(cyanPixel).x;" +
        "   float magenta = rgbToCMYK(magentaPixel).y;" +
        "   float yellow = rgbToCMYK(yellowPixel).z;" +
        "   float black = rgbToCMYK(blackPixel).w;" +
        
        "   return cmykToRGB(cyan, magenta, yellow, black);" +
            
        "}"
    )
    
    override var outputImage: CIImage?
    {
        guard let inputImage = inputImage, kernel = kernel else
        {
            return nil
        }
        
        let final = kernel.applyWithExtent(inputImage.extent,
                                           roiCallback:
            {
                (index, rect) in
                return rect.insetBy(dx: -1, dy: -1)
            },
                                           arguments: [inputImage, inputCyanOffset, inputMagentaOffset, inputYellowOffset, inputBlackOffset]
            )
        
        return final
    }
}
