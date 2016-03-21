//
//  MultiBandHSV.swift
//  MuseCamFilter
//
//  Created by Simon Gladman on 21/03/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import CoreImage
import UIKit

class MultiBandHSV: CIFilter
{
    let multiBandHSVKernel: CIColorKernel =
    {
        let red = CGFloat(0) // UIColor(red: 0.901961, green: 0.270588, blue: 0.270588, alpha: 1).hue()
        let orange = UIColor(red: 0.901961, green: 0.584314, blue: 0.270588, alpha: 1).hue()
        let yellow = UIColor(red: 0.901961, green: 0.901961, blue: 0.270588, alpha: 1).hue()
        let green = UIColor(red: 0.270588, green: 0.901961, blue: 0.270588, alpha: 1).hue()
        let aqua = UIColor(red: 0.270588, green: 0.901961, blue: 0.901961, alpha: 1).hue()
        let blue = UIColor(red: 0.270588, green: 0.270588, blue: 0.901961, alpha: 1).hue()
        let purple = UIColor(red: 0.584314, green: 0.270588, blue: 0.901961, alpha: 1).hue()
        let magenta = UIColor(red: 0.901961, green: 0.270588, blue: 0.901961, alpha: 1).hue()
        
        var shaderString = ""
        
        shaderString += "#define red \(red) \n"
        shaderString += "#define orange \(orange) \n"
        shaderString += "#define yellow \(yellow) \n"
        shaderString += "#define green \(green) \n"
        shaderString += "#define aqua \(aqua) \n"
        shaderString += "#define blue \(blue) \n"
        shaderString += "#define purple \(purple) \n"
        shaderString += "#define magenta \(magenta) \n"
        
        shaderString += "vec3 rgb2hsv(vec3 c)"
        shaderString += "{"
        shaderString += "    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);"
        shaderString += "    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));"
        shaderString += "    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));"
        
        shaderString += "    float d = q.x - min(q.w, q.y);"
        shaderString += "    float e = 1.0e-10;"
        shaderString += "    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);"
        shaderString += "}"
        
        shaderString += "vec3 hsv2rgb(vec3 c)"
        shaderString += "{"
        shaderString += "    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);"
        shaderString += "    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);"
        shaderString += "    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);"
        shaderString += "}"
        
        shaderString += "kernel vec4 kernelFunc(__sample pixel,"
        shaderString += "  vec3 redShift, vec3 orangeShift, vec3 yellowShift, vec3 greenShift,"
        shaderString += "  vec3 aquaShift, vec3 blueShift, vec3 purpleShift, vec3 magentaShift)"
        
        shaderString += "{"
        shaderString += " vec3 hsv = rgb2hsv(pixel.rgb); \n"
        
        shaderString += " if (hsv.x < orange){ hsv.x += redShift.x; hsv.yz *= redShift.yz;} \n"
        shaderString += " else if (hsv.x >= orange && hsv.x < yellow){ hsv.x += orangeShift.x; hsv.yz *= orangeShift.yz;} \n"
        shaderString += " else if (hsv.x >= yellow && hsv.x < green){ hsv.x += yellowShift.x; hsv.yz *= yellowShift.yz; } \n"
        shaderString += " else if (hsv.x >= green && hsv.x < aqua){ hsv.x += greenShift.x; hsv.yz *= greenShift.yz; } \n"
        shaderString += " else if (hsv.x >= aqua && hsv.x < blue){ hsv.x += aquaShift.x; hsv.yz *= aquaShift.yz;} \n"
        shaderString += " else if (hsv.x >= blue && hsv.x < purple){ hsv.x += blueShift.x; hsv.yz *= blueShift.yz;} \n"
        shaderString += " else if (hsv.x >= purple && hsv.x < magenta){ hsv.x += purpleShift.x; hsv.yz *= purpleShift.yz;} \n"
        shaderString += " else { hsv.x += magentaShift.x; hsv.yz *= magentaShift.yz; }; \n"
        
        shaderString += "return vec4(hsv2rgb(hsv), 1.0);"
        shaderString += "}"

        return CIColorKernel(string: shaderString)!
    }()
    
    var inputImage: CIImage?
    
    var inputRedShift = CIVector(x: 0, y: 1, z: 1)
    var inputOrangeShift = CIVector(x: 0, y: 1, z: 1)
    var inputYellowShift = CIVector(x: 0, y: 1, z: 1)
    var inputGreenShift = CIVector(x: 0, y: 1, z: 1)
    var inputAquaShift = CIVector(x: 0, y: 1, z: 1)
    var inputBlueShift = CIVector(x: 0, y: 1, z: 1)
    var inputPurpleShift = CIVector(x: 0, y: 1, z: 1)
    var inputMagentaShift = CIVector(x: 0, y: 1, z: 1)
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "MultiBandHSV",
            
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputRedShift": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Red Shift (HSL)",
                kCIAttributeDescription: "Set the hue, saturation and lightness for this color band.",
                kCIAttributeDefault: CIVector(x: 0, y: 1, z: 1),
                kCIAttributeType: kCIAttributeTypePosition3],
            
            "inputOrangeShift": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Orange Shift (HSL)",
                kCIAttributeDescription: "Set the hue, saturation and lightness for this color band.",
                kCIAttributeDefault: CIVector(x: 0, y: 1, z: 1),
                kCIAttributeType: kCIAttributeTypePosition3],
            
            "inputYellowShift": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Yellow Shift (HSL)",
                kCIAttributeDescription: "Set the hue, saturation and lightness for this color band.",
                kCIAttributeDefault: CIVector(x: 0, y: 1, z: 1),
                kCIAttributeType: kCIAttributeTypePosition3],
            
            "inputGreenShift": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Green Shift (HSL)",
                kCIAttributeDescription: "Set the hue, saturation and lightness for this color band.",
                kCIAttributeDefault: CIVector(x: 0, y: 1, z: 1),
                kCIAttributeType: kCIAttributeTypePosition3],
            
            "inputAquaShift": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Aqua Shift (HSL)",
                kCIAttributeDescription: "Set the hue, saturation and lightness for this color band.",
                kCIAttributeDefault: CIVector(x: 0, y: 1, z: 1),
                kCIAttributeType: kCIAttributeTypePosition3],
            
            "inputBlueShift": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Blue Shift (HSL)",
                kCIAttributeDescription: "Set the hue, saturation and lightness for this color band.",
                kCIAttributeDefault: CIVector(x: 0, y: 1, z: 1),
                kCIAttributeType: kCIAttributeTypePosition3],
            
            "inputPurpleShift": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Purple Shift (HSL)",
                kCIAttributeDescription: "Set the hue, saturation and lightness for this color band.",
                kCIAttributeDefault: CIVector(x: 0, y: 1, z: 1),
                kCIAttributeType: kCIAttributeTypePosition3],
            
            "inputMagentaShift": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Magenta Shift (HSL)",
                kCIAttributeDescription: "Set the hue, saturation and lightness for this color band.",
                kCIAttributeDefault: CIVector(x: 0, y: 1, z: 1),
                kCIAttributeType: kCIAttributeTypePosition3],
            ]
    }
    
    override var outputImage: CIImage?
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        return multiBandHSVKernel.applyWithExtent(inputImage.extent,
            arguments: [inputImage,
                inputRedShift,
                inputOrangeShift,
                inputYellowShift,
                inputGreenShift,
                inputAquaShift,
                inputBlueShift,
                inputPurpleShift,
                inputMagentaShift])
    }
}

extension UIColor
{
    func hue()-> CGFloat
    {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getHue(&hue,
            saturation: &saturation,
            brightness: &brightness,
            alpha: &alpha)
        
        return hue
    }
}
