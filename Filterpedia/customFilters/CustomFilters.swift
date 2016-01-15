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
        
        CIFilter.registerFilterName("CRTFilter",
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

        case "CRTFilter":
            return CRTFilter()
            
        default:
            return nil
        }
    }
}

// MARK: Threshold
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

// MARK: Cathode ray Tube Simulation

class CRTFilter: CIFilter
{
    var inputImage : CIImage?
    var inputPixelWidth: CGFloat = 8
    var inputPixelHeight: CGFloat = 12
    var inputBend: CGFloat = 3.2
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "CRT Filter",
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            "inputPixelWidth": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 8,
                kCIAttributeDisplayName: "Pixel Width",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 20,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputPixelHeight": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 12,
                kCIAttributeDisplayName: "Pixel Height",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 20,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputBend": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 3.2,
                kCIAttributeDisplayName: "Bend",
                kCIAttributeMin: 0.5,
                kCIAttributeSliderMin: 0.5,
                kCIAttributeSliderMax: 10,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    let crtWarpFilter = CRTWarpFilter()
    let crtColorFilter = CRTColorFilter()
    
    let vignette = CIFilter(name: "CIVignette",
        withInputParameters: [
            kCIInputIntensityKey: 1.5,
            kCIInputRadiusKey: 2])!
    
    override func setDefaults()
    {
        inputPixelWidth = 8
        inputPixelHeight = 12
        inputBend = 3.2
    }
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        crtColorFilter.pixelHeight = inputPixelHeight
        crtColorFilter.pixelWidth = inputPixelWidth
        crtWarpFilter.bend =  inputBend
        
        crtColorFilter.inputImage = inputImage
        vignette.setValue(crtColorFilter.outputImage,
            forKey: kCIInputImageKey)
        crtWarpFilter.inputImage = vignette.outputImage!
        
        return crtWarpFilter.outputImage
    }
    
    class CRTColorFilter: CIFilter
    {
        var inputImage : CIImage?
        
        var pixelWidth: CGFloat = 8.0
        var pixelHeight: CGFloat = 12.0
        
        let crtColorKernel = CIColorKernel(string:
            "kernel vec4 crtColor(__sample image, float pixelWidth, float pixelHeight) \n" +
            "{ \n" +
            
            "   int columnIndex = int(mod(samplerCoord(image).x / pixelWidth, 3.0)); \n" +
            "   int rowIndex = int(mod(samplerCoord(image).y, pixelHeight)); \n" +
            
            "   float scanlineMultiplier = (rowIndex == 0 || rowIndex == 1) ? 0.3 : 1.0;" +
            
            "   float red = (columnIndex == 0) ? image.r : image.r * ((columnIndex == 2) ? 0.3 : 0.2); " +
            "   float green = (columnIndex == 1) ? image.g : image.g * ((columnIndex == 2) ? 0.3 : 0.2); " +
            "   float blue = (columnIndex == 2) ? image.b : image.b * 0.2; " +
            
            "   return vec4(red * scanlineMultiplier, green * scanlineMultiplier, blue * scanlineMultiplier, 1.0); \n" +
            "}"
        )
        
        
        override var outputImage : CIImage!
        {
            if let inputImage = inputImage,
                crtColorKernel = crtColorKernel
            {
                let dod = inputImage.extent
                let args = [inputImage, pixelWidth, pixelHeight]
                return crtColorKernel.applyWithExtent(dod, arguments: args)
            }
            return nil
        }
    }
    
    class CRTWarpFilter: CIFilter
    {
        var inputImage : CIImage?
        var bend: CGFloat = 3.2
        
        let crtWarpKernel = CIWarpKernel(string:
            "kernel vec2 crtWarp(vec2 extent, float bend)" +
            "{" +
            "   vec2 coord = ((destCoord() / extent) - 0.5) * 2.0;" +
            
            "   coord.x *= 1.0 + pow((abs(coord.y) / bend), 2.0);" +
            "   coord.y *= 1.0 + pow((abs(coord.x) / bend), 2.0);" +
            
            "   coord  = ((coord / 2.0) + 0.5) * extent;" +
            
            "   return coord;" +
            "}"
        )
        
        override var outputImage : CIImage!
        {
            if let inputImage = inputImage,
                crtWarpKernel = crtWarpKernel
            {
                let arguments = [CIVector(x: inputImage.extent.size.width, y: inputImage.extent.size.height), bend]
                let extent = inputImage.extent.insetBy(dx: -1, dy: -1)
                
                return crtWarpKernel.applyWithExtent(extent,
                    roiCallback:
                    {
                        (index, rect) in
                        return rect
                    },
                    inputImage: inputImage,
                    arguments: arguments)
            }
            return nil
        }
    }
}



