//
//  RefractedTextFilter.swift
//  Filterpedia
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

import UIKit
import CoreImage

class RefractedTextFilter: CIFilter
{
    var inputImage: CIImage?
    {
        didSet
        {
            if inputImage?.extent != refractingImage?.extent
            {
                refractingImage = nil
            }
        }
    }
    
    var inputText: NSString = "Filterpedia"
    {
        didSet
        {
            refractingImage = nil
        }
    }
    
    var inputRefractiveIndex: CGFloat = 4.0
    var inputLensScale: CGFloat = 50
    var inputLightingAmount: CGFloat = 1.5
    
    var inputLensBlur: CGFloat = 0
    var inputBackgroundBlur: CGFloat = 2
    
    var inputRadius: CGFloat = 15
    {
        didSet
        {
            if oldValue != inputRadius
            {
                refractingImage = nil
            }
        }
    }
    
    private var refractingImage: CIImage?
    private var rawTextImage: CIImage?
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "Refracted Text",
            
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
        
            "inputText": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSString",
                kCIAttributeDisplayName: "Text",
                kCIAttributeDefault: "Filterpedia",
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputRefractiveIndex": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 4.0,
                kCIAttributeDisplayName: "Refractive Index",
                kCIAttributeMin: -4.0,
                kCIAttributeSliderMin: -10.0,
                kCIAttributeSliderMax: 10,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputLensScale": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 50,
                kCIAttributeDisplayName: "Lens Scale",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputLightingAmount": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1.5,
                kCIAttributeDisplayName: "Lighting Amount",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 5,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputRadius": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 15,
                kCIAttributeDisplayName: "Edge Radius",
                kCIAttributeMin: 5,
                kCIAttributeSliderMin: 5,
                kCIAttributeSliderMax: 50,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputLensBlur": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0,
                kCIAttributeDisplayName: "Lens Blur",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 20,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputBackgroundBlur": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 2,
                kCIAttributeDisplayName: "Background Blur",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 20,
                kCIAttributeType: kCIAttributeTypeScalar]
        
        ]
    }
    
    override func setDefaults()
    {
        inputText = "Filterpedia"
        inputRefractiveIndex = 4.0
        inputLensScale = 50
        inputLightingAmount = 1.5
        inputRadius = 15
        inputLensBlur = 0
        inputBackgroundBlur = 2
    }
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage,
            let refractingKernel = refractingKernel else
        {
            return nil
        }
        
        if refractingImage == nil
        {
            generateRefractingImage()
        }
        
        let extent = inputImage.extent
        let arguments = [inputImage,
            refractingImage!,
            inputRefractiveIndex,
            inputLensScale,
            inputLightingAmount] as [Any]
        
        let blurMask = rawTextImage?.applyingFilter("CIColorInvert", withInputParameters: nil)
        
        return refractingKernel.apply(withExtent: extent,
                roiCallback:
                {
                    (index, rect) in
                    return rect
                },
                arguments: arguments)!
            .applyingFilter("CIMaskedVariableBlur", withInputParameters: [
                kCIInputRadiusKey: inputBackgroundBlur,
                "inputMask": blurMask!])
            .applyingFilter("CIMaskedVariableBlur", withInputParameters: [
                kCIInputRadiusKey: inputLensBlur,
                "inputMask": rawTextImage!])
    }
    
    func generateRefractingImage()
    {
        let label = UILabel(frame: inputImage!.extent)
        
        label.text = String(inputText)
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 300)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.textColor = UIColor.white
        
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: label.frame.width,
                height: label.frame.height), true, 1)
        
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let textImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        rawTextImage = CIImage(image: textImage!)!

        refractingImage = CIFilter(name: "CIHeightFieldFromMask",
            withInputParameters: [
                kCIInputRadiusKey: inputRadius,
                kCIInputImageKey: rawTextImage!])?.outputImage?
            .cropping(to: inputImage!.extent)
    }
    
    let refractingKernel = CIKernel(string:
        "float lumaAtOffset(sampler source, vec2 origin, vec2 offset)" +
        "{" +
        " vec3 pixel = sample(source, samplerTransform(source, origin + offset)).rgb;" +
        " float luma = dot(pixel, vec3(0.2126, 0.7152, 0.0722));" +
        " return luma;" +
        "}" +
        
        
        "kernel vec4 lumaBasedRefract(sampler image, sampler refractingImage, float refractiveIndex, float lensScale, float lightingAmount) \n" +
        "{ " +
        " vec2 d = destCoord();" +
        
        " float northLuma = lumaAtOffset(refractingImage, d, vec2(0.0, -1.0));" +
        " float southLuma = lumaAtOffset(refractingImage, d, vec2(0.0, 1.0));" +
        " float westLuma = lumaAtOffset(refractingImage, d, vec2(-1.0, 0.0));" +
        " float eastLuma = lumaAtOffset(refractingImage, d, vec2(1.0, 0.0));" +
        
        " vec3 lensNormal = normalize(vec3((eastLuma - westLuma), (southLuma - northLuma), 1.0));" +

        " vec3 refractVector = refract(vec3(0.0, 0.0, 1.0), lensNormal, refractiveIndex) * lensScale; " +
        
        " vec3 outputPixel = sample(image, samplerTransform(image, d + refractVector.xy)).rgb;" +
        
        " outputPixel += (northLuma - southLuma) * lightingAmount ;" +
        " outputPixel += (eastLuma - westLuma) * lightingAmount ;" +
        
        " return vec4(outputPixel, 1.0);" +
        "}"
    )
}
