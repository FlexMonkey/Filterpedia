//
//  LensFlare.swift
//  Filterpedia
//
//  Created by Simon Gladman on 29/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//
// Thanks to: http://www.playchilla.com/how-to-check-if-a-point-is-inside-a-hexagon
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

class LensFlare: CIFilter
{
    @objc var inputOrigin = CIVector(x: 150, y: 150)
    @objc var inputSize = CIVector(x: 640, y: 640)
    
    @objc var inputColor = CIVector(x: 0.5, y: 0.2, z: 0.3)
    @objc var inputReflectionBrightness: CGFloat = 0.25
    
    @objc var inputPositionOne: CGFloat = 0.15
    @objc var inputPositionTwo: CGFloat = 0.3
    @objc var inputPositionThree: CGFloat = 0.4
    @objc var inputPositionFour: CGFloat = 0.45
    @objc var inputPositionFive: CGFloat = 0.6
    @objc var inputPositionSix: CGFloat = 0.75
    @objc var inputPositionSeven: CGFloat = 0.8
    
    @objc var inputReflectionSizeZero: CGFloat = 20
    @objc var inputReflectionSizeOne: CGFloat = 25
    @objc var inputReflectionSizeTwo: CGFloat = 12.5
    @objc var inputReflectionSizeThree: CGFloat = 5
    @objc var inputReflectionSizeFour: CGFloat = 20
    @objc var inputReflectionSizeFive: CGFloat = 35
    @objc var inputReflectionSizeSix: CGFloat = 40
    @objc var inputReflectionSizeSeven: CGFloat = 20
    
    override var attributes: [String : Any]
    {
        let positions: [String : Any] = [
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
        
        let sizes: [String : Any] = [
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
        
        let attributes: [String : Any] = [
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
    
    
    let sunbeamsFilter = CIFilter(name: "CISunbeamsGenerator", parameters: ["inputStriationStrength": 0])
    
    var colorKernel = CIColorKernel(source:
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
        
        let extent = CGRect(x: 0, y: 0, width: inputSize.x, height: inputSize.y)
        let center = CIVector(x: inputSize.x / 2, y: inputSize.y / 2)
        
        let localOrigin = CIVector(x: center.x - inputOrigin.x, y: center.y - inputOrigin.y)
        let reflectionZero = CIVector(x: center.x + localOrigin.x, y: center.y + localOrigin.y)

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
            inputColor, inputReflectionBrightness] as [Any]
        
        let lensFlareImage = colorKernel.apply(
            extent: extent,
            arguments: arguments)?.applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: 2])
        
        return lensFlareImage?.applyingFilter(
            "CIAdditionCompositing",
            parameters: [kCIInputBackgroundImageKey: sunbeamsImage]).cropped(to: extent)
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
