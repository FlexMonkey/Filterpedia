//
//  CustomFilters.swift
//  Filterpedia
//
//  Created by Simon Gladman on 15/01/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import CoreImage

let CategoryCustomFilters = "Custom Filters"

class CustomFiltersVendor: NSObject, CIFilterConstructor
{
    static func registerFilters()
    {
        CIFilter.registerFilterName("ThresholdFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters,
                    kCICategoryVideo,
                    kCICategoryStillImage,
                    kCICategoryNonSquarePixels,
                    kCICategoryInterlaced]
            ])
    }
    
    @objc func filterWithName(name: String) -> CIFilter?
    {
        switch name
        {
        case "ThresholdFilter":
            return ThresholdFilter()

        default:
            return nil
        }
    }
}


class ThresholdFilter: CIFilter
{
    var inputImage : CIImage?
    var inputThreshold: CGFloat = 0.75

    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Threshold Filter",
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            "inputThreshold": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.75,
                kCIAttributeDisplayName: "Threshold",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    override func setDefaults()
    {
        inputThreshold = 0.75
    }
    
    let thresholdKernel = CIColorKernel(string:
        "kernel vec4 thresholdFilter(__sample image, float threshold)" +
            "{" +
            "   float luma = (image.r * 0.2126) + (image.g * 0.7152) + (image.b * 0.0722);" +
            
            "   return (luma > threshold) ? vec4(1.0, 1.0, 1.0, 1.0) : vec4(0.0, 0.0, 0.0, 0.0);" +
        "}"
    )
    
    override var outputImage : CIImage!
    {
        guard let inputImage = inputImage,
            thresholdKernel = thresholdKernel else
        {
            return nil
        }
        
        let extent = inputImage.extent
        let arguments = [inputImage, inputThreshold]
        
        return thresholdKernel.applyWithExtent(extent, arguments: arguments)
    }
}