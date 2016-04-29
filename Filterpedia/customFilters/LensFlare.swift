//
//  LensFlare.swift
//  Filterpedia
//
//  Created by Simon Gladman on 29/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import CoreImage

class LensFlare: CIFilter
{
    var inputOrigin = CIVector(x: 150, y: 150)
    var inputSize = CIVector(x: 640, y: 640)
    
    var inputColor = CIVector(x: 0.5, y: 0.2, z: 0.3)
    var inputReflectionBrightness: CGFloat = 0.25
    
    var inputPositionOne: CGFloat = 0.15
    var inputPositionTwo: CGFloat = 0.3
    var inputPositionThree: CGFloat = 0.4
    var inputPositionFour: CGFloat = 0.45
    var inputPositionFive: CGFloat = 0.6
    var inputPositionSix: CGFloat = 0.75
    var inputPositionSeven: CGFloat = 0.8
    
    var inputReflectionSizeZero: CGFloat = 20
    var inputReflectionSizeOne: CGFloat = 25
    var inputReflectionSizeTwo: CGFloat = 12.5
    var inputReflectionSizeThree: CGFloat = 5
    var inputReflectionSizeFour: CGFloat = 20
    var inputReflectionSizeFive: CGFloat = 35
    var inputReflectionSizeSix: CGFloat = 40
    var inputReflectionSizeSeven: CGFloat = 20
    
    override var attributes: [String : AnyObject]
    {
        let positions: [String : AnyObject] = [
            "inputPositionOne": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.15,
                kCIAttributeDisplayName: "Position One",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputPositionTwo": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.3,
                kCIAttributeDisplayName: "Position Two",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputPositionThree": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.4,
                kCIAttributeDisplayName: "Position Three",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputPositionFour": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.45,
                kCIAttributeDisplayName: "Position Four",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputPositionFive": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.6,
                kCIAttributeDisplayName: "Position Five",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputPositionSix": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.75,
                kCIAttributeDisplayName: "Position Six",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputPositionSeven": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.8,
                kCIAttributeDisplayName: "Position Seven",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
        ]
        
        let sizes: [String : AnyObject] = [
            "inputReflectionSizeZero": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 20,
                kCIAttributeDisplayName: "Size Zero",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputReflectionSizeOne": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 25,
                kCIAttributeDisplayName: "Size One",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputReflectionSizeTwo": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 12.5,
                kCIAttributeDisplayName: "Size Two",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputReflectionSizeThree": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 5,
                kCIAttributeDisplayName: "Size Three",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputReflectionSizeFour": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 20,
                kCIAttributeDisplayName: "Size Four",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputReflectionSizeFive": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 35,
                kCIAttributeDisplayName: "Size Five",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputReflectionSizeSix": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 40,
                kCIAttributeDisplayName: "Size Six",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputReflectionSizeSeven": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 20,
                kCIAttributeDisplayName: "Size Seven",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputSize": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Image Size",
                kCIAttributeDefault: CIVector(x: 640, y: 640),
                kCIAttributeType: kCIAttributeTypeOffset]
        ]
        
        let attributes: [String : AnyObject] = [
            kCIAttributeFilterDisplayName: "Lens Flare",
            
            "inputOrigin": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Light Origin",
                kCIAttributeDefault: CIVector(x: 150, y: 150),
                kCIAttributeType: kCIAttributeTypePosition],
            
            "inputColor": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Color",
                kCIAttributeDefault: CIVector(x: 0.5, y: 0.2, z: 0.3),
                kCIAttributeType: kCIAttributeTypeColor],
            
            "inputReflectionBrightness": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.25,
                kCIAttributeDisplayName: "Reflection Brightness",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar]
            ]
        
        return attributes + positions + sizes
    }
    
    
    let sunbeamsFilter = CIFilter(name: "CISunbeamsGenerator", withInputParameters: ["inputStriationStrength": 0])
    
    var colorKernel = CIColorKernel(string:
        "float brightnessWithinHexagon(vec2 coord, vec2 center, float v)" +
        "{" +
        "   float h = v * sqrt(3.0);" +
        "   float x = abs(coord.x - center.x); " +
        "   float y = abs(coord.y - center.y); " +
        "   float brightness = (x > h || y > v * 2.0) ? 0.0 : smoothstep(0.5, 1.0, (distance(destCoord(), center) / (v * 2.0))); " +
        "   return ((2.0 * v * h - v * x - h * y) >= 0.0) ? brightness  : 0.0;" +
        "}" +
        
        "kernel vec4 lensFlare(vec2 center0, vec2 center1, vec2 center2, vec2 center3, vec2 center4, vec2 center5, vec2 center6, vec2 center7," +
        "   float size0, float size1, float size2, float size3, float size4, float size5, float size6, float size7, " +
        "   vec3 color, float reflectionBrightness) " +
        "{" +
        "   float reflectionO = brightnessWithinHexagon(destCoord(), center0, size0); " +
        "   float reflection1 = reflectionO + brightnessWithinHexagon(destCoord(), center1, size1); " +
        "   float reflection2 = reflection1 + brightnessWithinHexagon(destCoord(), center2, size2); " +
        "   float reflection3 = reflection2 + brightnessWithinHexagon(destCoord(), center3, size3); " +
        "   float reflection4 = reflection3 + brightnessWithinHexagon(destCoord(), center4, size4); " +
        "   float reflection5 = reflection4 + brightnessWithinHexagon(destCoord(), center5, size5); " +
        "   float reflection6 = reflection5 + brightnessWithinHexagon(destCoord(), center6, size6); " +
        "   float reflection7 = reflection6 + brightnessWithinHexagon(destCoord(), center7, size7); " +
            
        "   return vec4(color * reflection7 * reflectionBrightness, reflection7); " +
        "}"
    )

    
    override var outputImage: CIImage!
    {
        guard let
            colorKernel = colorKernel else
        {
            return nil
        }
        
        let extent = CGRect(x: 0, y: 0, width: inputSize.X, height: inputSize.Y)
        let center = CIVector(x: inputSize.X / 2, y: inputSize.Y / 2)
        
        let localOrigin = CIVector(x: center.X - inputOrigin.X, y: center.Y - inputOrigin.Y)
        let reflectionZero = CIVector(x: center.X + localOrigin.X, y: center.Y + localOrigin.Y)

        let reflectionOne = inputOrigin.interpolateTo(reflectionZero, value: inputPositionOne)
        let reflectionTwo = inputOrigin.interpolateTo(reflectionZero, value: inputPositionTwo)
        let reflectionThree = inputOrigin.interpolateTo(reflectionZero, value: inputPositionThree)
        let reflectionFour = inputOrigin.interpolateTo(reflectionZero, value: inputPositionFour)
        let reflectionFive = inputOrigin.interpolateTo(reflectionZero, value: inputPositionFive)
        let reflectionSix = inputOrigin.interpolateTo(reflectionZero, value: inputPositionSix)
        let reflectionSeven = inputOrigin.interpolateTo(reflectionZero, value: inputPositionSeven)
        
        sunbeamsFilter?.setValue(inputOrigin, forKeyPath: kCIInputCenterKey)
        sunbeamsFilter?.setValue(inputColor, forKey: kCIInputColorKey)
        
        let sunbeamsImage = sunbeamsFilter!.outputImage!
        
        let arguments = [
            reflectionZero, reflectionOne, reflectionTwo, reflectionThree, reflectionFour, reflectionFive, reflectionSix, reflectionSeven,
            inputReflectionSizeZero, inputReflectionSizeOne, inputReflectionSizeTwo, inputReflectionSizeThree, inputReflectionSizeFour,
            inputReflectionSizeFive, inputReflectionSizeSix, inputReflectionSizeSeven,
            inputColor, inputReflectionBrightness]
        
        let lensFlareImage = colorKernel.applyWithExtent(
            extent,
            arguments: arguments)?.imageByApplyingFilter("CIGaussianBlur", withInputParameters: [kCIInputRadiusKey: 2])
        
        return lensFlareImage?.imageByApplyingFilter(
            "CIAdditionCompositing",
            withInputParameters: [kCIInputBackgroundImageKey: sunbeamsImage]).imageByCroppingToRect(extent)
    }
}

func + <T, U>(left: Dictionary<T, U>, right: Dictionary<T, U>) -> Dictionary<T, U>
{
    var target = Dictionary<T, U>()
    
    for (key, value) in left
    {
        target[key] = value
    }
    
    for (key, value) in right
    {
        target[key] = value
    }
    
    return target
}
