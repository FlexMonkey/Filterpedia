//
//  Scatter.swift
//  Filterpedia
//
//  Created by Simon Gladman on 17/05/2016.
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

// An alternative version of the scatter filter using a pseudo random number generator
// inside a warp kernel.
class ScatterWarp: CIFilter
{
    var inputImage: CIImage?
    var inputScatterRadius: CGFloat = 25
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Scatter (Warp Kernel)" as AnyObject,
            
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputScatterRadius": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 25,
                kCIAttributeDisplayName: "Scatter Radius",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 150,
                kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
    
    let kernel = CIWarpKernel(string:
        // based on https://www.shadertoy.com/view/ltB3zD - the additional seed
        // calculation prevents repetition when using destCoord() as the seed.
        "float noise(vec2 co)" +
            "{ " +
            "    vec2 seed = vec2(sin(co.x), cos(co.y)); " +
            "    return fract(sin(dot(seed ,vec2(12.9898,78.233))) * 43758.5453); " +
            "} " +
            
            "kernel vec2 scatter(float radius)" +
            "{" +
            "   float offsetX = radius * (-1.0 + noise(destCoord()) * 2.0); " +
            "   float offsetY = radius * (-1.0 + noise(destCoord().yx) * 2.0); " +
            "   return vec2(destCoord().x + offsetX, destCoord().y + offsetY); " +
        "}"
    )
    
    override var outputImage: CIImage?
    {
        guard let kernel = kernel, let inputImage = inputImage else
        {
            return nil
        }
        
        return  kernel.apply(
            withExtent: inputImage.extent,
            roiCallback:
            {
                (index, rect) in
                return rect
            },
            inputImage: inputImage,
            arguments: [inputScatterRadius])
    }
}

// Pixel scattering filter using CIRandomGenerator as its source. The output of the
// random generator can be blurred allowing for a smoothness attribute.
class Scatter: CIFilter
{
    var inputImage: CIImage?
    var inputScatterRadius: CGFloat = 25
    var inputScatterSmoothness: CGFloat = 1.0
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Scatter" as AnyObject,
            
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
        
            "inputScatterRadius": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 25,
                kCIAttributeDisplayName: "Scatter Radius",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 150,
                kCIAttributeType: kCIAttributeTypeScalar],
        
            "inputScatterSmoothness": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1,
                kCIAttributeDisplayName: "Scatter Smoothness",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 4,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    let kernel = CIKernel(string:
        "kernel vec4 scatter(sampler image, sampler noise, float radius)" +
        "{" +
        "   vec2 workingSpaceCoord = destCoord() + -radius + sample(noise, samplerCoord(noise)).xy * radius * 2.0; " +
        "   vec2 imageSpaceCoord = samplerTransform(image, workingSpaceCoord); " +
        "   return sample(image, imageSpaceCoord);" +
        "}")
    
    override var outputImage: CIImage?
    {
        guard let kernel = kernel, let inputImage = inputImage else
        {
            return nil
        }
        
        let noise = CIFilter(name: "CIRandomGenerator")!.outputImage!
            .applyingFilter("CIGaussianBlur", withInputParameters: [kCIInputRadiusKey: inputScatterSmoothness])
            .cropping(to: inputImage.extent)
        
        let arguments = [inputImage, noise, inputScatterRadius] as [Any]

        return kernel.apply(
            withExtent: inputImage.extent,
            roiCallback:
            {
                (index, rect) in
                return rect
            },
            arguments: arguments)

    }
}
