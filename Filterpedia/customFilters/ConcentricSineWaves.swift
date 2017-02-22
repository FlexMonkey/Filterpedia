//
//  ConcentricSineWaves.swift
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

class ConcentricSineWaves: CIFilter
{
    var inputWidth: CGFloat = 40
    var inputAmplitude: CGFloat = 80
    var inputFrequency: CGFloat = 6
    
    var inputColor0 = CIColor(red: 0.6, green: 0.6, blue: 0.1)
    var inputColor1 = CIColor(red: 0.1, green: 0.1, blue: 0.8)
    
    var inputSize = CIVector(x: 640, y: 640)
    var inputCenter = CIVector(x: 320, y: 320)
    
    override func setDefaults()
    {
        inputCenter = CIVector(x: 320, y: 320)
    }
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "Concentric Sine Waves",
            
            "inputWidth": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 40,
                kCIAttributeDisplayName: "Width",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputAmplitude": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 80,
                kCIAttributeDisplayName: "Amplitude",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputFrequency": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 6,
                kCIAttributeDisplayName: "Frequency",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 64,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputColor0": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIColor",
                kCIAttributeDisplayName: "Color One",
                kCIAttributeDefault: CIColor(red: 0.6, green: 0.6, blue: 0.1),
                kCIAttributeType: kCIAttributeTypeColor],
            
            "inputColor1": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIColor",
                kCIAttributeDisplayName: "Color Two",
                kCIAttributeDefault: CIColor(red: 0.1, green: 0.1, blue: 0.8),
                kCIAttributeType: kCIAttributeTypeColor],
            
            "inputSize": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Size",
                kCIAttributeDefault: CIVector(x: 640, y: 640),
                kCIAttributeType: kCIAttributeTypeOffset],
            
            "inputCenter": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Center",
                kCIAttributeDefault: CIVector(x: 320, y: 320),
                kCIAttributeType: kCIAttributeTypePosition],
        ]
    }
    
    let kernel = CIColorKernel(string:
        "kernel vec4 concentricSineWaves(float ringWidth, vec2 center, float amplitude, float frequency, vec4 color0, vec4 color1)" +
            "{" +

            "   vec2 position = destCoord() - center; " +
            "   float angle = atan(position.x, position.y) * frequency; " +
            
            "   float distance = (mod(length(position) + (sin_(angle) * amplitude), ringWidth)) / ringWidth; " +
            
            "   vec4 color = mix(color0, color1, distance); " +
            
            "   return color;" +
        "}")
    
    override var outputImage: CIImage?
    {
        guard let kernel = kernel else
        {
            return nil
        }
        
        let extent = CGRect(
            origin: CGPoint.zero,
            size: CGSize(width: inputSize.x, height: inputSize.y))

        return kernel.apply(
            withExtent: extent,
            arguments: [inputWidth, inputCenter, inputAmplitude, Int(inputFrequency), inputColor0, inputColor1])
    }
}
