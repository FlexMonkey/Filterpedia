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

let tau = CGFloat(M_PI * 2)

/// `RGBChannelCompositing` filter takes three input images and composites them together
/// by their color channels, the output RGB is `(inputRed.r, inputGreen.g, inputBlue.b)`

class RGBChannelCompositing: CIFilter
{
    var inputRedImage : CIImage?
    var inputGreenImage : CIImage?
    var inputBlueImage : CIImage?
    
    let rgbChannelCompositingKernel = CIColorKernel(string:
        "kernel vec4 rgbChannelCompositing(__sample red, __sample green, __sample blue)" +
        "{" +
        "   return vec4(red.r, green.g, blue.b, 1.0);" +
        "}"
    )
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "RGB Compositing",
            
            "inputRedImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Red Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputGreenImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Green Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputBlueImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Blue Image",
                kCIAttributeType: kCIAttributeTypeImage]
        ]
    }
    
    override var outputImage: CIImage!
    {
        guard let inputRedImage = inputRedImage,
            let inputGreenImage = inputGreenImage,
            let inputBlueImage = inputBlueImage,
            let rgbChannelCompositingKernel = rgbChannelCompositingKernel else
        {
            return nil
        }
        
        let extent = inputRedImage.extent.union(inputGreenImage.extent.union(inputBlueImage.extent))
        let arguments = [inputRedImage, inputGreenImage, inputBlueImage]
        
        return rgbChannelCompositingKernel.apply(withExtent: extent, arguments: arguments)
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
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "RGB Tone Curve",
            
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

        let red = inputImage.applyingFilter("CIToneCurve",
            withInputParameters: [
                "inputPoint0": CIVector(x: 0.0, y: inputRedValues.value(at: 0)),
                "inputPoint1": CIVector(x: 0.25, y: inputRedValues.value(at: 1)),
                "inputPoint2": CIVector(x: 0.5, y: inputRedValues.value(at: 2)),
                "inputPoint3": CIVector(x: 0.75, y: inputRedValues.value(at: 3)),
                "inputPoint4": CIVector(x: 1.0, y: inputRedValues.value(at: 4))
            ])
        
        let green = inputImage.applyingFilter("CIToneCurve",
            withInputParameters: [
                "inputPoint0": CIVector(x: 0.0, y: inputGreenValues.value(at: 0)),
                "inputPoint1": CIVector(x: 0.25, y: inputGreenValues.value(at: 1)),
                "inputPoint2": CIVector(x: 0.5, y: inputGreenValues.value(at: 2)),
                "inputPoint3": CIVector(x: 0.75, y: inputGreenValues.value(at: 3)),
                "inputPoint4": CIVector(x: 1.0, y: inputGreenValues.value(at: 4))
            ])
        
        let blue = inputImage.applyingFilter("CIToneCurve",
            withInputParameters: [
                "inputPoint0": CIVector(x: 0.0, y: inputBlueValues.value(at: 0)),
                "inputPoint1": CIVector(x: 0.25, y: inputBlueValues.value(at: 1)),
                "inputPoint2": CIVector(x: 0.5, y: inputBlueValues.value(at: 2)),
                "inputPoint3": CIVector(x: 0.75, y: inputBlueValues.value(at: 3)),
                "inputPoint4": CIVector(x: 1.0, y: inputBlueValues.value(at: 4))
            ])
        
        rgbChannelCompositing.inputRedImage = red
        rgbChannelCompositing.inputGreenImage = green
        rgbChannelCompositing.inputBlueImage = blue
        
        return rgbChannelCompositing.outputImage
    }
}

/// `RGBChannelBrightnessAndContrast` controls brightness & contrast per color channel

class RGBChannelBrightnessAndContrast: CIFilter
{
    var inputImage: CIImage?
    
    var inputRedBrightness: CGFloat = 0
    var inputRedContrast: CGFloat = 1
    
    var inputGreenBrightness: CGFloat = 0
    var inputGreenContrast: CGFloat = 1
    
    var inputBlueBrightness: CGFloat = 0
    var inputBlueContrast: CGFloat = 1
    
    let rgbChannelCompositing = RGBChannelCompositing()
    
    override func setDefaults()
    {
        inputRedBrightness = 0
        inputRedContrast = 1
        
        inputGreenBrightness = 0
        inputGreenContrast = 1
        
        inputBlueBrightness = 0
        inputBlueContrast = 1
    }
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "RGB Brightness And Contrast",
            
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputRedBrightness": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0,
                kCIAttributeDisplayName: "Red Brightness",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: -1,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputRedContrast": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1,
                kCIAttributeDisplayName: "Red Contrast",
                kCIAttributeMin: 0.25,
                kCIAttributeSliderMin: 0.25,
                kCIAttributeSliderMax: 4,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputGreenBrightness": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0,
                kCIAttributeDisplayName: "Green Brightness",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: -1,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputGreenContrast": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1,
                kCIAttributeDisplayName: "Green Contrast",
                kCIAttributeMin: 0.25,
                kCIAttributeSliderMin: 0.25,
                kCIAttributeSliderMax: 4,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputBlueBrightness": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0,
                kCIAttributeDisplayName: "Blue Brightness",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: -1,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputBlueContrast": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1,
                kCIAttributeDisplayName: "Blue Contrast",
                kCIAttributeMin: 0.25,
                kCIAttributeSliderMin: 0.25,
                kCIAttributeSliderMax: 4,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        let red = inputImage.applyingFilter("CIColorControls",
            withInputParameters: [
                kCIInputBrightnessKey: inputRedBrightness,
                kCIInputContrastKey: inputRedContrast])
        
        let green = inputImage.applyingFilter("CIColorControls",
            withInputParameters: [
                kCIInputBrightnessKey: inputGreenBrightness,
                kCIInputContrastKey: inputGreenContrast])
        
        let blue = inputImage.applyingFilter("CIColorControls",
            withInputParameters: [
                kCIInputBrightnessKey: inputBlueBrightness,
                kCIInputContrastKey: inputBlueContrast])
        
        rgbChannelCompositing.inputRedImage = red
        rgbChannelCompositing.inputGreenImage = green
        rgbChannelCompositing.inputBlueImage = blue
        
        let finalImage = rgbChannelCompositing.outputImage
        
        return finalImage
    }
}

/// `ChromaticAberration` offsets an image's RGB channels around an equilateral triangle

class ChromaticAberration: CIFilter
{
    var inputImage: CIImage?
    
    var inputAngle: CGFloat = 0
    var inputRadius: CGFloat = 2
    
    let rgbChannelCompositing = RGBChannelCompositing()
    
    override func setDefaults()
    {
        inputAngle = 0
        inputRadius = 2
    }
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "Chromatic Abberation",
            
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputAngle": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0,
                kCIAttributeDisplayName: "Angle",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: tau,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputRadius": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 2,
                kCIAttributeDisplayName: "Radius",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 25,
                kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        let redAngle = inputAngle + tau
        let greenAngle = inputAngle + tau * 0.333
        let blueAngle = inputAngle + tau * 0.666
        
        let redTransform = CGAffineTransform(translationX: sin(redAngle) * inputRadius, y: cos(redAngle) * inputRadius)
        let greenTransform = CGAffineTransform(translationX: sin(greenAngle) * inputRadius, y: cos(greenAngle) * inputRadius)
        let blueTransform = CGAffineTransform(translationX: sin(blueAngle) * inputRadius, y: cos(blueAngle) * inputRadius)
        
        let red = inputImage.applyingFilter("CIAffineTransform",
            withInputParameters: [kCIInputTransformKey: NSValue(cgAffineTransform: redTransform)])
            .cropping(to: inputImage.extent)
        
        let green = inputImage.applyingFilter("CIAffineTransform",
            withInputParameters: [kCIInputTransformKey: NSValue(cgAffineTransform: greenTransform)])
            .cropping(to: inputImage.extent)
        
        let blue = inputImage.applyingFilter("CIAffineTransform",
            withInputParameters: [kCIInputTransformKey: NSValue(cgAffineTransform: blueTransform)])
            .cropping(to: inputImage.extent)

        rgbChannelCompositing.inputRedImage = red
        rgbChannelCompositing.inputGreenImage = green
        rgbChannelCompositing.inputBlueImage = blue
        
        let finalImage = rgbChannelCompositing.outputImage
        
        return finalImage
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
    
    override var attributes: [String : Any]
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
            .applyingFilter("CIGaussianBlur", withInputParameters: [kCIInputRadiusKey: inputRedRadius])
            .clampingToExtent()
        
        let green = inputImage
            .applyingFilter("CIGaussianBlur", withInputParameters: [kCIInputRadiusKey: inputGreenRadius])
            .clampingToExtent()
        
        let blue = inputImage
            .applyingFilter("CIGaussianBlur", withInputParameters: [kCIInputRadiusKey: inputBlueRadius])
            .clampingToExtent()
        
        rgbChannelCompositing.inputRedImage = red
        rgbChannelCompositing.inputGreenImage = green
        rgbChannelCompositing.inputBlueImage = blue
        
        return rgbChannelCompositing.outputImage
    }
}
