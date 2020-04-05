//
//  ThirdPartyFilters.swift
//  Filterpedia
//
//  Created by Simon Gladman on 10/02/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//
//  Guest filters live here!

import CoreImage


// MARK: BayerDitherFilter
// Created by African Swift on 09/02/2016.
// https://twitter.com/SwiftAfricanus

class BayerDitherFilter: CIFilter
{
    @objc var inputImage: CIImage?
    @objc var inputIntensity = CGFloat(5.0)
    @objc var inputMatrix = CGFloat(8.0)
    @objc var inputPalette = CGFloat(0.0)
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "Bayer Dither Filter" as AnyObject,
            
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            "inputIntensity": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDescription: "Intensity: Range from 0.0 to 10.0",
                kCIAttributeDefault: 5.0,
                kCIAttributeDisplayName: "Intensity",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 10,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputMatrix": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDescription: "Matrix: 2, 3, 4, 8",
                kCIAttributeDefault: 8,
                kCIAttributeDisplayName: "Matrix",
                kCIAttributeMin: 2,
                kCIAttributeSliderMin: 2,
                kCIAttributeSliderMax: 8,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputPalette": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDescription: "Palette: 0 = Binary, 1 = Commodore 64, 2 = Vic-20, 3 = Apple II, 4 = ZX Spectrum Bright, 5 = ZX Spectrum Dim, 6 = RGB",
                kCIAttributeDefault: 0.0,
                kCIAttributeDisplayName: "Palette",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 6,
                kCIAttributeType: kCIAttributeTypeScalar]]
    }
    
    override var outputImage: CIImage!
    {
        let CIKernel_DitherBayer = Bundle.main.path(forResource: "DitherBayer", ofType: "cikernel")
        
        guard let path = CIKernel_DitherBayer,
            let code = try? String(contentsOfFile: path),
            let ditherKernel = CIColorKernel(source: code) else { return nil }
        guard let inputImage = inputImage else { return nil }
        
        let extent = inputImage.extent
        let arguments = [inputImage, inputIntensity, inputMatrix, inputPalette] as [Any]
        
        return ditherKernel.apply(extent: extent, arguments: arguments)
    }
}
