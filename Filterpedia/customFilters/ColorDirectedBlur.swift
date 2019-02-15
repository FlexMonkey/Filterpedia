//
//  ColorDirectedBlur.swift
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

/// **HomogeneousColorBlur**
///
/// _A filter that applies a box filter with circular kernel to similar colors based
/// on distance in a three dimensional  RGB configuration space_
///
/// - Authors: Simon Gladman
/// - Date: May 2016

class HomogeneousColorBlur: CIFilter
{
    @objc var inputImage: CIImage?
    @objc var inputColorThreshold: CGFloat = 0.2
    @objc var inputRadius: CGFloat = 10
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "Homogeneous Color Blur" as AnyObject,
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            "inputColorThreshold": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.2,
                kCIAttributeDisplayName: "Color Threshold",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputRadius": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 10,
                kCIAttributeDisplayName: "Radius",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 40,
                kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
    
    let kernel = CIKernel(source:
        "kernel vec4 colorDirectedBlurKernel(sampler image, float radius, float threshold)" +
            "{" +
            "   int r = int(radius);" +
            "   float n = 0.0;" +
            "   vec2 d = destCoord();" +
            "   vec3 thisPixel = sample(image, samplerCoord(image)).rgb;" +
            "   vec3 accumulator = vec3(0.0, 0.0, 0.0);" +
            "   for (int x = -r; x <= r; x++) " +
            "   { " +
            "       for (int y = -r; y <= r; y++) " +
            "       { " +
            "           vec3 offsetPixel = sample(image, samplerTransform(image, d + vec2(x ,y))).rgb; \n" +
            
            "           float distanceMultiplier = step(length(vec2(x,y)), radius); \n" +
            "           float colorMultiplier = step(distance(offsetPixel, thisPixel), threshold); \n" +
        
            "           accumulator += offsetPixel * distanceMultiplier * colorMultiplier; \n" +
            "           n += distanceMultiplier * colorMultiplier; \n" +
            "       }" +
            "   }" +
            "   return vec4(accumulator / n, 1.0); " +
    "}")
    
    override var outputImage: CIImage?
    {
        guard let inputImage = inputImage, let kernel = kernel else
        {
            return nil
        }
        
        let arguments = [inputImage, inputRadius, inputColorThreshold * sqrt(3.0)] as [Any]
        
        return kernel.apply(
            extent: inputImage.extent,
            roiCallback:
            {
            (index, rect) in
            return rect
            },
            arguments: arguments)
    }
}

/// **ColorDirectedBlur**
///
/// _A filter that applies a box blur based on a surrounding quadrant of the nearest color._
///
/// Uses a similar approach to Kuwahara Filter - creates averages of squares of pixels 
/// in the north east, north west, south east and south west of the current pixel and 
/// outputs the box blur of the quadrant with the closest color distance to the current
/// pixel. A threshold parameter prevents any blurring if the distances are too great.
///
/// The final effect blurs within areas of a similar color while keeeping edge detail.
///
/// - Authors: Simon Gladman
/// - Date: April 2016

class ColorDirectedBlur: CIFilter
{
    @objc var inputImage: CIImage?
    @objc var inputThreshold: CGFloat = 0.5
    @objc var inputIterations: CGFloat = 4
    @objc var inputRadius: CGFloat = 10
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "Color Directed Blur" as AnyObject,
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            "inputThreshold": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.5,
                kCIAttributeDisplayName: "Threshold",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputIterations": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 4,
                kCIAttributeDisplayName: "Iterations",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 10,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputRadius": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 10,
                kCIAttributeDisplayName: "Radius",
                kCIAttributeMin: 3,
                kCIAttributeSliderMin: 3,
                kCIAttributeSliderMax: 20,
                kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
    
    let kernel = CIKernel(source:
        "kernel vec4 colorDirectedBlurKernel(sampler image, float radius, float threshold)" +
        "{" +
        
        "   int r = int(radius);" +
        "   float n = 0.0;" +
        "   vec2 d = destCoord();" +
        "   vec3 thisPixel = sample(image, samplerCoord(image)).rgb;" +
        
        "   vec3 nwAccumulator = vec3(0.0, 0.0, 0.0);" +
        "   vec3 neAccumulator = vec3(0.0, 0.0, 0.0);" +
        "   vec3 swAccumulator = vec3(0.0, 0.0, 0.0);" +
        "   vec3 seAccumulator = vec3(0.0, 0.0, 0.0);" +
        
        "   for (int x = 0; x <= r; x++) " +
        "   { " +
        "       for (int y = 0; y <= r; y++) " +
        "       { " +
        "        nwAccumulator += sample(image, samplerTransform(image, d + vec2(-x ,-y))).rgb; " +
        "        neAccumulator += sample(image, samplerTransform(image, d + vec2(x ,-y))).rgb; " +
        "        swAccumulator += sample(image, samplerTransform(image, d + vec2(-x ,y))).rgb; " +
        "        seAccumulator += sample(image, samplerTransform(image, d + vec2(x ,y))).rgb; " +
        "        n = n + 1.0; " +
        "       } " +
        "   } " +
        
        "   nwAccumulator /= n;" +
        "   neAccumulator /= n;" +
        "   swAccumulator /= n;" +
        "   seAccumulator /= n;" +
        
        "   float nwDiff = distance(thisPixel, nwAccumulator); " +
        "   float neDiff = distance(thisPixel, neAccumulator); " +
        "   float swDiff = distance(thisPixel, swAccumulator); " +
        "   float seDiff = distance(thisPixel, seAccumulator); " +

        "   if (nwDiff >= threshold && neDiff >= threshold && swDiff >= threshold && seDiff >= threshold)" +
        "   {return vec4(thisPixel, 1.0);}" +
        
        "   if(nwDiff < neDiff && nwDiff < swDiff && nwDiff < seDiff) " +
        "   { return vec4 (nwAccumulator, 1.0 ); }" +
        
        "   if(neDiff < nwDiff && neDiff < swDiff && neDiff < seDiff) " +
        "   { return vec4 (neAccumulator, 1.0 ); }" +
        
        "   if(swDiff < nwDiff && swDiff < neDiff && swDiff < seDiff) " +
        "   { return vec4 (swAccumulator, 1.0 ); }" +
        
        "   if(seDiff < nwDiff && seDiff < neDiff && seDiff < swDiff) " +
        "   { return vec4 (seAccumulator, 1.0 ); }" +
        
        "   return vec4(thisPixel, 1.0); " +
        "}"
    )
    
    override var outputImage: CIImage?
    {
        guard let inputImage = inputImage, let kernel = kernel else
        {
            return nil
        }
        
        let accumulator = CIImageAccumulator(extent: inputImage.extent, format: CIFormat.ARGB8)
        
        accumulator?.setImage(inputImage)
        
        for _ in 0 ... Int(inputIterations)
        {
            let final = kernel.apply(extent: inputImage.extent,
                                               roiCallback:
                {
                    (index, rect) in
                    return rect
                },
                                               arguments: [accumulator?.image(), inputRadius, 1 - inputThreshold])
            
            accumulator?.setImage(final!)
        }
        
        return accumulator?.image()
    }
}
