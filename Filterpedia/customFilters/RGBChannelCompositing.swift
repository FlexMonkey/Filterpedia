//
//  RGBChannelCompositing.swift
//  Filterpedia
//
//  Created by Simon Gladman on 20/01/2016.
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

/// `RGBChannelCompositing` filter takes three input images and composites them together
/// by their color channels, the output RGB is `(inputRed.r, inputGreen.g, inputBlue.b)`

class RGBChannelCompositing: CIFilter
{
    var inputRedImage : CIImage?
    var inputGreenImage : CIImage?
    var inputBlueImage : CIImage?
    
    let rgbChannelCompositingKernel = CIColorKernel(string:
        "kernel vec4 thresholdFilter(__sample red, __sample green, __sample blue)" +
        "{" +
        "   return vec4(red.r, green.g, blue.b, 1.0);" +
        "}"
    )
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "RGB Channel Compositing",
            
            "inputRedImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputGreenImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputBlueImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage]
        ]
    }
    
    override var outputImage: CIImage!
    {
        guard let inputRedImage = inputRedImage,
            inputGreenImage = inputGreenImage,
            inputBlueImage = inputBlueImage,
            rgbChannelCompositingKernel = rgbChannelCompositingKernel else
        {
            return nil
        }
        
        let extent = inputRedImage.extent.union(inputGreenImage.extent.union(inputBlueImage.extent))
        let arguments = [inputRedImage, inputGreenImage, inputBlueImage]
        
        return rgbChannelCompositingKernel.applyWithExtent(extent, arguments: arguments)
    }
}

/// `RGBChannelToneCurve` allows individual tone curves to be applied to each channel.
/// The `x` values of each tone curve are locked to `[0.0, 0.25, 0.5, 0.75, 1.0]`, the
/// supplied vector for each channel defines the `y` positions.
///
/// For example, if the `redValues` vector is `[0.2, 0.4, 0.6, 0.8, 0.9]`, the points
/// passed to the `CIToneCurve` filter will be:
/// ```
/// [(0.0, 0.2), (0.25, 0.4), (0.5, 0.6), (0.75, 0.8), (1.0, 0.9)]
/// ```
class RGBChannelToneCurve: CIFilter
{
    var inputImage: CIImage?
    
    var inputRedValues = CIVector(values: [0.0, 0.25, 0.5, 0.75, 1.0], count: 5)
    var inputGreenValues = CIVector(values: [0.0, 0.25, 0.5, 0.75, 1.0], count: 5)
    var inputBlueValues = CIVector(values: [0.0, 0.25, 0.5, 0.75, 1.0], count: 5)
    
    let rgbChannelCompositing = RGBChannelCompositing()
    
    override func setDefaults()
    {
        inputRedValues = CIVector(values: [0.0, 0.25, 0.5, 0.75, 1.0], count: 5)
        inputGreenValues = CIVector(values: [0.0, 0.25, 0.5, 0.75, 1.0], count: 5)
        inputBlueValues = CIVector(values: [0.0, 0.25, 0.5, 0.75, 1.0], count: 5)
    }
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "RGB Channel Tone Curve",
            
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputRedValues": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDefault: CIVector(values: [0.0, 0.25, 0.5, 0.75, 1.0], count: 5),
                kCIAttributeDisplayName: "Red 'y' Values",
                kCIAttributeDescription: "Red tone curve 'y' values at 'x' positions [0.0, 0.25, 0.5, 0.75, 1.0].",
                kCIAttributeType: kCIAttributeTypeOffset],

            "inputGreenValues": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDefault: CIVector(values: [0.0, 0.25, 0.5, 0.75, 1.0], count: 5),
                kCIAttributeDisplayName: "Green 'y' Values",
                kCIAttributeDescription: "Green tone curve 'y' values at 'x' positions [0.0, 0.25, 0.5, 0.75, 1.0].",
                kCIAttributeType: kCIAttributeTypeOffset],
            
            "inputBlueValues": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDefault: CIVector(values: [0.0, 0.25, 0.5, 0.75, 1.0], count: 5),
                kCIAttributeDisplayName: "Blue 'y' Values",
                kCIAttributeDescription: "Blue tone curve 'y' values at 'x' positions [0.0, 0.25, 0.5, 0.75, 1.0].",
                kCIAttributeType: kCIAttributeTypeOffset]
        ]
    }
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage else
        {
            return nil
        }

        let red = inputImage.imageByApplyingFilter("CIToneCurve",
            withInputParameters: [
                "inputPoint0": CIVector(x: 0.0, y: inputRedValues.valueAtIndex(0)),
                "inputPoint1": CIVector(x: 0.25, y: inputRedValues.valueAtIndex(1)),
                "inputPoint2": CIVector(x: 0.5, y: inputRedValues.valueAtIndex(2)),
                "inputPoint3": CIVector(x: 0.75, y: inputRedValues.valueAtIndex(3)),
                "inputPoint4": CIVector(x: 1.0, y: inputRedValues.valueAtIndex(4))
            ])
        
        let green = inputImage.imageByApplyingFilter("CIToneCurve",
            withInputParameters: [
                "inputPoint0": CIVector(x: 0.0, y: inputGreenValues.valueAtIndex(0)),
                "inputPoint1": CIVector(x: 0.25, y: inputGreenValues.valueAtIndex(1)),
                "inputPoint2": CIVector(x: 0.5, y: inputGreenValues.valueAtIndex(2)),
                "inputPoint3": CIVector(x: 0.75, y: inputGreenValues.valueAtIndex(3)),
                "inputPoint4": CIVector(x: 1.0, y: inputGreenValues.valueAtIndex(4))
            ])
        
        let blue = inputImage.imageByApplyingFilter("CIToneCurve",
            withInputParameters: [
                "inputPoint0": CIVector(x: 0.0, y: inputBlueValues.valueAtIndex(0)),
                "inputPoint1": CIVector(x: 0.25, y: inputBlueValues.valueAtIndex(1)),
                "inputPoint2": CIVector(x: 0.5, y: inputBlueValues.valueAtIndex(2)),
                "inputPoint3": CIVector(x: 0.75, y: inputBlueValues.valueAtIndex(3)),
                "inputPoint4": CIVector(x: 1.0, y: inputBlueValues.valueAtIndex(4))
            ])
        
        rgbChannelCompositing.inputRedImage = red
        rgbChannelCompositing.inputGreenImage = green
        rgbChannelCompositing.inputBlueImage = blue
        
        return rgbChannelCompositing.outputImage
    }
}

/// `RGBChannelGaussianBlur` allows Gaussian blur on a per channel basis

class RGBChannelGaussianBlur: CIFilter
{
    var inputImage: CIImage?
    
    var inputRedRadius: CGFloat = 2
    var inputGreenRadius: CGFloat = 4
    var inputBlueRadius: CGFloat = 8
    
    let rgbChannelCompositing = RGBChannelCompositing()
    
    override func setDefaults()
    {
        inputRedRadius = 2
        inputGreenRadius = 4
        inputBlueRadius = 8
    }
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "RGB Channel Gaussian Blur",
            
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputRedRadius": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 2,
                kCIAttributeDisplayName: "Red Radius",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputGreenRadius": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 4,
                kCIAttributeDisplayName: "Green Radius",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputBlueRadius": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 8,
                kCIAttributeDisplayName: "Blue Radius",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        let red = inputImage
            .imageByApplyingFilter("CIGaussianBlur", withInputParameters: [kCIInputRadiusKey: inputRedRadius])
            .imageByClampingToExtent()
        
        let green = inputImage
            .imageByApplyingFilter("CIGaussianBlur", withInputParameters: [kCIInputRadiusKey: inputGreenRadius])
            .imageByClampingToExtent()
        
        let blue = inputImage
            .imageByApplyingFilter("CIGaussianBlur", withInputParameters: [kCIInputRadiusKey: inputBlueRadius])
            .imageByClampingToExtent()
        
        rgbChannelCompositing.inputRedImage = red
        rgbChannelCompositing.inputGreenImage = green
        rgbChannelCompositing.inputBlueImage = blue
        
        return rgbChannelCompositing.outputImage
    }
}