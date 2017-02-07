//
//  Flame.swift
//  Filterpedia
//
//  Created by Simon Gladman on 25/05/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//
// Based on https://www.shadertoy.com/view/XsXSWS

import CoreImage

class Flame: CIFilter
{
    var inputTime: CGFloat = 1
    
    var inputIterations: CGFloat = 5
    var inputAnisotropy: CGFloat = 4 // 1.0 = fat, default = 5, 10.0 = thin
    var inputEdgeDefinition: CGFloat = 20.0; // 5.0 = soft, 16.0 = default, 100 = sharp
    var inputHotspotExponent: CGFloat = 4.0; // 1.0 - cold, 4.0 - default, 10 = hotspots!
    var inputDensity: CGFloat = 1.0; // 0.5 -> 2.0 default 1.0
    var inputStrength: CGFloat = 2.0; // 1.0 -> 5.0 default 2.0
    
    var inputRedMultiplier: CGFloat = 1.5;
    var inputRedExponent: CGFloat = 1.0;
    var inputGreenMultiplier: CGFloat = 1.5;
    var inputGreenExponent: CGFloat = 3.0;
    var inputBlueMultiplier: CGFloat = 0.5;
    var inputBlueExponent: CGFloat = 2.0;
    
    var inputWidth: CGFloat = 640
    var inputHeight: CGFloat = 640
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Flame" as AnyObject,
            
            "inputTime": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1,
                kCIAttributeDisplayName: "Time",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 10000,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputIterations": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 5,
                kCIAttributeDisplayName: "Iterations",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 8,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputAnisotropy": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 4,
                kCIAttributeDisplayName: "Anisotropy",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 10,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputEdgeDefinition": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 20,
                kCIAttributeDisplayName: "Edge Definition",
                kCIAttributeMin: 5,
                kCIAttributeSliderMin: 5,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputHotspotExponent": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 4,
                kCIAttributeDisplayName: "Hotspot Exponent",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 10,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputDensity": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1,
                kCIAttributeDisplayName: "Density",
                kCIAttributeMin: 0.5,
                kCIAttributeSliderMin: 0.5,
                kCIAttributeSliderMax: 2,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputStrength": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 2.0,
                kCIAttributeDisplayName: "Strength",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 5,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputRedMultiplier": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1.5,
                kCIAttributeDisplayName: "Red Multiplier",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 5,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputRedExponent": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1,
                kCIAttributeDisplayName: "Red Exponent",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 5,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            
            "inputGreenMultiplier": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1.5,
                kCIAttributeDisplayName: "Green Multiplier",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 5,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputGreenExponent": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 3,
                kCIAttributeDisplayName: "Green Exponent",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 5,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputBlueMultiplier": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.5,
                kCIAttributeDisplayName: "Blue Multiplier",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 5,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputBlueExponent": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 2,
                kCIAttributeDisplayName: "Blue Exponent",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 5,
                kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
    
    let flameKernel: CIColorKernel =
    {
        let shaderPath = Bundle.main.path(forResource: "flame", ofType: "cikernel")
        
        guard let path = shaderPath,
            let code = try? String(contentsOfFile: path),
            let kernel = CIColorKernel(string: code) else
        {
            fatalError("Unable to build Flame shader")
        }
        
        return kernel
    }()
    
    override var outputImage: CIImage?
    {
        let arguments = [inputTime / 1000.0, CIVector(x: inputWidth, y: inputHeight),
                         inputIterations, inputAnisotropy, inputEdgeDefinition,
                         inputHotspotExponent, inputDensity,
                         inputRedMultiplier, inputRedExponent,
                         inputGreenMultiplier, inputGreenExponent,
                         inputBlueMultiplier, inputBlueExponent,
                         inputStrength] as [Any]
        
        return flameKernel.apply(
            withExtent: CGRect(origin: CGPoint.zero, size: CGSize(width: inputWidth, height: inputHeight)),
            arguments: arguments)
    }
    
}
