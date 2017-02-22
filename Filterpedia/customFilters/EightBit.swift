//
//  EightBit.swift
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

import CoreImage

class EightBit: CIFilter
{
    var inputImage: CIImage?
    var inputPaletteIndex: CGFloat = 4
    var inputScale: CGFloat = 8
    
    override func setDefaults()
    {
        inputPaletteIndex = 4
        inputScale = 8
    }
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "Eight Bit",
            
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputPaletteIndex": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 4,
                kCIAttributeDescription: "0: Spectrum (Dim). 1: Spectrum (Bright). 2: VIC-20. 3: C-64. 4: Apple II ",
                kCIAttributeDisplayName: "Palette Index",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 4,
                kCIAttributeType: kCIAttributeTypeInteger],
            
            "inputScale": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 8,
                kCIAttributeDisplayName: "Scale",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    override var outputImage: CIImage?
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        let paletteIndex = max(min(EightBit.palettes.count - 1, Int(inputPaletteIndex)), 0)
        
        let palette = EightBit.palettes[paletteIndex]
        
        var kernelString = "kernel vec4 thresholdFilter(__sample image)"
        kernelString += "{ \n"
        kernelString += "   vec2 uv = samplerCoord(image); \n"
        kernelString += "   float dist = distance(image.rgb, \(palette.first!.toVectorString())); \n"
        kernelString += "   vec3 returnColor = \(palette.first!.toVectorString());\n "
        
        for paletteColor in palette where paletteColor != palette.first!
        {
            kernelString += "if (distance(image.rgb, \(paletteColor.toVectorString())) < dist) \n"
            kernelString += "{ \n"
            kernelString += "   dist = distance(image.rgb, \(paletteColor.toVectorString())); \n"
            kernelString += "   returnColor = \(paletteColor.toVectorString()); \n"
            kernelString += "} \n"
        }
        
        kernelString += "   return vec4(returnColor, 1.0) ; \n"
        kernelString += "} \n"
        
        guard let kernel = CIColorKernel(string: kernelString) else
        {
            return nil
        }

        let extent = inputImage.extent
        
        
        let final = kernel.apply(withExtent: extent,
            arguments: [inputImage.applyingFilter("CIPixellate", withInputParameters: [kCIInputScaleKey: inputScale])])
        
        return final
    }

    // MARK: Palettes

    // ZX Spectrum Dim
    
    static let dimSpectrumColors = [
        RGB(r: 0x00, g: 0x00, b: 0x00),
        RGB(r: 0x00, g: 0x00, b: 0xCD),
        RGB(r: 0xCD, g: 0x00, b: 0x00),
        RGB(r: 0xCD, g: 0x00, b: 0xCD),
        RGB(r: 0x00, g: 0xCD, b: 0x00),
        RGB(r: 0x00, g: 0xCD, b: 0xCD),
        RGB(r: 0xCD, g: 0xCD, b: 0x00),
        RGB(r: 0xCD, g: 0xCD, b: 0xCD)]
    
    // ZX Spectrum Bright
    
    static let brightSpectrumColors = [
        RGB(r: 0x00, g: 0x00, b: 0x00),
        RGB(r: 0x00, g: 0x00, b: 0xFF),
        RGB(r: 0xFF, g: 0x00, b: 0x00),
        RGB(r: 0xFF, g: 0x00, b: 0xFF),
        RGB(r: 0x00, g: 0xFF, b: 0x00),
        RGB(r: 0x00, g: 0xFF, b: 0xFF),
        RGB(r: 0xFF, g: 0xFF, b: 0x00),
        RGB(r: 0xFF, g: 0xFF, b: 0xFF)]
    
    
    // VIC-20
    static let vic20Colors = [
        RGB(r: 0, g: 0, b: 0),
        RGB(r: 255, g: 255, b: 255),
        RGB(r: 141, g: 62, b: 55),
        RGB(r: 114, g: 193, b: 200),
        RGB(r: 128, g: 52, b: 139),
        RGB(r: 85, g: 160, b: 73),
        RGB(r: 64, g: 49, b: 141),
        RGB(r: 170, g: 185, b: 93),
        RGB(r: 139, g: 84, b: 41),
        RGB(r: 213, g: 159, b: 116),
        RGB(r: 184, g: 105, b: 98),
        RGB(r: 135, g: 214, b: 221),
        RGB(r: 170, g: 95, b: 182),
        RGB(r: 148, g: 224, b: 137),
        RGB(r: 128, g: 113, b: 204),
        RGB(r: 191, g: 206, b: 114)
    ]
    
    
    // C-64
    
    static let c64Colors = [
        RGB(r: 0, g: 0, b: 0),
        RGB(r: 255, g: 255, b: 255),
        RGB(r: 136, g: 57, b: 50),
        RGB(r: 103, g: 182, b: 189),
        RGB(r: 139, g: 63, b: 150),
        RGB(r: 85, g: 160, b: 73),
        RGB(r: 64, g: 49, b: 141),
        RGB(r: 191, g: 206, b: 114),
        RGB(r: 139, g: 84, b: 41),
        RGB(r: 87, g: 66, b: 0),
        RGB(r: 184, g: 105, b: 98),
        RGB(r: 80, g: 80, b: 80),
        RGB(r: 120, g: 120, b: 120),
        RGB(r: 148, g: 224, b: 137),
        RGB(r: 120, g: 105, b: 196),
        RGB(r: 159, g: 159, b: 159)
    ]
    
    
    // Apple II
    static let appleIIColors = [
        RGB(r: 0, g: 0, b: 0),
        RGB(r: 114, g: 38, b: 64),
        RGB(r: 64, g: 51, b: 127),
        RGB(r: 228, g: 52, b: 254),
        RGB(r: 14, g: 89, b: 64),
        RGB(r: 128, g: 128, b: 128),
        RGB(r: 27, g: 154, b: 254),
        RGB(r: 191, g: 179, b: 255),
        RGB(r: 64, g: 76, b: 0),
        RGB(r: 228, g: 101, b: 1),
        RGB(r: 128, g: 128, b: 128),
        RGB(r: 241, g: 166, b: 191),
        RGB(r: 27, g: 203, b: 1),
        RGB(r: 191, g: 204, b: 128),
        RGB(r: 141, g: 217, b: 191),
        RGB(r: 255, g: 255, b: 255)
    ]
    
    static let palettes = [dimSpectrumColors, brightSpectrumColors, vic20Colors, c64Colors, appleIIColors]
}

struct RGB: Equatable
{
    let r:UInt8
    let g:UInt8
    let b:UInt8
    
    func toVectorString() -> String
    {
        return "vec3(\(Double(self.r) / 255), \(Double(self.g) / 255), \(Double(self.b) / 255))"
    }
}

func ==(lhs: RGB, rhs: RGB) -> Bool
{
    return lhs.toVectorString() == rhs.toVectorString()
}

