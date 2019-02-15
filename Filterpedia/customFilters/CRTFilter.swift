//
//  CRTFilter.swift
//  Filterpedia
//
//  CRT filter and VHS Tracking Lines
//
//  Created by Simon Gladman on 20/01/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import CoreImage

class VHSTrackingLines: CIFilter
{
    @objc var inputImage: CIImage?
    @objc var inputTime: CGFloat = 0
    @objc var inputSpacing: CGFloat = 50
    @objc var inputStripeHeight: CGFloat = 0.5
    @objc var inputBackgroundNoise: CGFloat = 0.05
    
    override func setDefaults()
    {
        inputSpacing = 50
        inputStripeHeight = 0.5
        inputBackgroundNoise = 0.05
    }
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "VHS Tracking Lines" as AnyObject,
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            "inputTime": [kCIAttributeIdentity: 0,
                          kCIAttributeClass: "NSNumber",
                          kCIAttributeDefault: 8,
                          kCIAttributeDisplayName: "Time",
                          kCIAttributeMin: 0,
                          kCIAttributeSliderMin: 0,
                          kCIAttributeSliderMax: 2048,
                          kCIAttributeType: kCIAttributeTypeScalar],
            "inputSpacing": [kCIAttributeIdentity: 0,
                             kCIAttributeClass: "NSNumber",
                             kCIAttributeDefault: 50,
                             kCIAttributeDisplayName: "Spacing",
                             kCIAttributeMin: 20,
                             kCIAttributeSliderMin: 20,
                             kCIAttributeSliderMax: 200,
                             kCIAttributeType: kCIAttributeTypeScalar],
            "inputStripeHeight": [kCIAttributeIdentity: 0,
                                  kCIAttributeClass: "NSNumber",
                                  kCIAttributeDefault: 0.5,
                                  kCIAttributeDisplayName: "Stripe Height",
                                  kCIAttributeMin: 0,
                                  kCIAttributeSliderMin: 0,
                                  kCIAttributeSliderMax: 1,
                                  kCIAttributeType: kCIAttributeTypeScalar],
            "inputBackgroundNoise": [kCIAttributeIdentity: 0,
                                     kCIAttributeClass: "NSNumber",
                                     kCIAttributeDefault: 0.05,
                                     kCIAttributeDisplayName: "Background Noise",
                                     kCIAttributeMin: 0,
                                     kCIAttributeSliderMin: 0,
                                     kCIAttributeSliderMax: 0.25,
                                     kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    override var outputImage: CIImage?
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        let tx = NSValue(cgAffineTransform: CGAffineTransform(translationX: CGFloat(drand48() * 100), y: CGFloat(drand48() * 100)))
        
        let noise = CIFilter(name: "CIRandomGenerator")!.outputImage!
            .applyingFilter("CIAffineTransform",
                            parameters: [kCIInputTransformKey: tx])
            .applyingFilter("CILanczosScaleTransform",
                            parameters: [kCIInputAspectRatioKey: 5])
            .cropped(to: inputImage.extent)
        
        
        let kernel = CIColorKernel(source:
            "kernel vec4 thresholdFilter(__sample image, __sample noise, float time, float spacing, float stripeHeight, float backgroundNoise)" +
                "{" +
                "   vec2 uv = destCoord();" +
                
                "   float stripe = smoothstep(1.0 - stripeHeight, 1.0, sin((time + uv.y) / spacing)); " +
                
                "   return image + (noise * noise * stripe) + (noise * backgroundNoise);" +
            "}"
            )!
        
        
        let extent = inputImage.extent
        let arguments = [inputImage, noise, inputTime, inputSpacing, inputStripeHeight, inputBackgroundNoise] as [Any]
        
        let final = kernel.apply(extent: extent, arguments: arguments)?
            .applyingFilter("CIPhotoEffectNoir", parameters: [:])
        
        return final
    }
}

class CRTFilter: CIFilter
{
    @objc var inputImage : CIImage?
    @objc var inputPixelWidth: CGFloat = 8
    @objc var inputPixelHeight: CGFloat = 12
    @objc var inputBend: CGFloat = 3.2
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "CRT Filter" as AnyObject,
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
                            parameters: [
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
        @objc var inputImage : CIImage?
        
        var pixelWidth: CGFloat = 8.0
        var pixelHeight: CGFloat = 12.0
        
        let crtColorKernel = CIColorKernel(source:
            "kernel vec4 crtColor(__sample image, float pixelWidth, float pixelHeight) \n" +
                "{ \n" +
                "   vec2 coord = destCoord(); \n" +
                "   int columnIndex = int(mod(coord.x / pixelWidth, 3.0)); \n" +
                "   int rowIndex = int(mod(coord.y, pixelHeight)); \n" +
                
                "   float scanlineMultiplier = (rowIndex == 0 || rowIndex == 1) ? 0.3 : 1.0;" +
                
                "   float red = (columnIndex == 0) ? image.r : image.r * ((columnIndex == 2) ? 0.3 : 0.2); " +
                "   float green = (columnIndex == 1) ? image.g : image.g * ((columnIndex == 2) ? 0.3 : 0.2); " +
                "   float blue = (columnIndex == 2) ? image.b : image.b * 0.2; " +
                
                "   return vec4(red * scanlineMultiplier, green * scanlineMultiplier, blue * scanlineMultiplier, 1.0); \n" +
            "}"
        )
        
        
        override var outputImage: CIImage!
        {
            if let inputImage = inputImage,
                let crtColorKernel = crtColorKernel
            {
                let dod = inputImage.extent
                let args = [inputImage, pixelWidth, pixelHeight] as [Any]
                return crtColorKernel.apply(extent: dod, arguments: args)
            }
            return nil
        }
    }
    
    class CRTWarpFilter: CIFilter
    {
        @objc var inputImage : CIImage?
        var bend: CGFloat = 3.2
        
        let crtWarpKernel = CIWarpKernel(source:
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
                let crtWarpKernel = crtWarpKernel
            {
                let arguments = [CIVector(x: inputImage.extent.size.width, y: inputImage.extent.size.height), bend] as [Any]
                let extent = inputImage.extent.insetBy(dx: -1, dy: -1)
                
                return crtWarpKernel.apply(extent: extent,
                                           roiCallback:
                    {
                        (index, rect) in
                        return rect
                },
                                           image: inputImage,
                                           arguments: arguments)
            }
            return nil
        }
    }
}

