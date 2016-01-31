//
//  CustomFilters.swift
//  Filterpedia
//
//  Created by Simon Gladman on 15/01/2016.
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

let CategoryCustomFilters = "Custom Filters"

class CustomFiltersVendor: NSObject, CIFilterConstructor
{
    static func registerFilters()
    {
        CIFilter.registerFilterName("ThresholdFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName("ThresholdToAlphaFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName("CRTFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName("VignetteNoirFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName("MercurializeFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName("VintageVignette",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName("RGBChannelCompositing",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName("RGBChannelGaussianBlur",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName("RGBChannelToneCurve",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName("PseudoColorFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName("KuwaharaFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName("MetalPixellateFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName("MetalKuwaharaFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName("MetalPerlinNoise",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
        ])
        
        CIFilter.registerFilterName("StarBurstFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
    }
    
    func filterWithName(name: String) -> CIFilter?
    {
        switch name
        {
        case "ThresholdFilter":
            return ThresholdFilter()
            
        case "ThresholdToAlphaFilter":
            return ThresholdToAlphaFilter()
            
        case "CRTFilter":
            return CRTFilter()
            
        case "VignetteNoirFilter":
            return VignetteNoirFilter()
            
        case "MercurializeFilter":
            return MercurializeFilter()
            
        case "VintageVignette":
            return VintageVignette()
            
        case "RGBChannelCompositing":
            return RGBChannelCompositing()
            
        case "RGBChannelGaussianBlur":
            return RGBChannelGaussianBlur()

        case "RGBChannelToneCurve":
            return RGBChannelToneCurve()
            
        case "PseudoColorFilter":
            return PseudoColorFilter()
            
        case "KuwaharaFilter":
            return KuwaharaFilter()
            
        case "MetalPixellateFilter":
            return MetalPixellateFilter()
            
        case "MetalKuwaharaFilter":
            return MetalKuwaharaFilter()
            
        case "MetalPerlinNoise":
            return MetalPerlinNoise()
            
        case "StarBurstFilter":
            return StarBurstFilter()
            
        default:
            return nil
        }
    }
}

// MARK: PseudoColor

/// This filter isn't dissimilar to Core Image's own False Color filter
/// but it accepts five input colors and uses mix() to transition
/// between them based on an image's luminance

class PseudoColorFilter: CIFilter
{
    var inputImage: CIImage?
    
    var inputColor0 = CIColor(red: 1, green: 0, blue: 0)
    var inputColor1 = CIColor(red: 0, green: 0, blue: 0)
    var inputColor2 = CIColor(red: 0, green: 1, blue: 0)
    var inputColor3 = CIColor(red: 1, green: 1, blue: 1)
    var inputColor4 = CIColor(red: 0, green: 0, blue: 1)
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Pseudo Color Filter",
            
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputColor0": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIColor",
                kCIAttributeDisplayName: "Color One",
                kCIAttributeDefault: CIColor(red: 1, green: 0, blue: 0),
                kCIAttributeType: kCIAttributeTypeColor],
            
            "inputColor1": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIColor",
                kCIAttributeDisplayName: "Color Two",
                kCIAttributeDefault: CIColor(red: 0, green: 0, blue: 0),
                kCIAttributeType: kCIAttributeTypeColor],
            
            "inputColor2": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIColor",
                kCIAttributeDisplayName: "Color Three",
                kCIAttributeDefault: CIColor(red: 0, green: 1, blue: 0),
                kCIAttributeType: kCIAttributeTypeColor],
            
            "inputColor3": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIColor",
                kCIAttributeDisplayName: "Color Four",
                kCIAttributeDefault: CIColor(red: 1, green: 1, blue: 1),
                kCIAttributeType: kCIAttributeTypeColor],
            
            "inputColor4": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIColor",
                kCIAttributeDisplayName: "Color Five",
                kCIAttributeDefault: CIColor(red: 0, green: 0, blue: 1),
                kCIAttributeType: kCIAttributeTypeColor]
        ]
    }
    
    let pseudoColorKernel = CIColorKernel(string:
        "kernel vec4 thresholdFilter(__sample image, vec4 inputColor0, vec4 inputColor1, vec4 inputColor2, vec4 inputColor3, vec4 inputColor4) \n" +
            "{ \n" +
            "   vec4 luma = vec4(dot(image.rgb, vec3(0.2126, 0.7152, 0.0722))); \n" +
            
            "   if (luma.x < 0.25) \n" +
            "   { return mix(inputColor0, inputColor1, luma * 4.0); } \n" +
            
            "   else if (luma.x >= 0.25 && luma.x < 0.5) \n" +
            "   { return mix(inputColor1, inputColor2, (luma - 0.25) * 4.0); } \n" +
            
            "   else if (luma.x >= 0.5 && luma.x < 0.75) \n" +
            "   { return mix(inputColor2, inputColor3, (luma - 0.5) * 4.0) ; } \n" +
            
            "   return mix(inputColor3, inputColor4, (luma - 0.75) * 4.0) ; \n" +
        "}"
    )
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage,
            pseudoColorKernel = pseudoColorKernel else
        {
            return nil
        }
        
        let extent = inputImage.extent
        let arguments = [inputImage, inputColor0, inputColor1, inputColor2, inputColor3, inputColor4]
        
        return pseudoColorKernel.applyWithExtent(extent, arguments: arguments)
    }
}

// MARK: Vintage vignette

/// This is the VintageVignette filter from my book, Core Image for Swift,
/// and is an example of a very simple composite custom filter.

class VintageVignette: CIFilter
{
    var inputImage : CIImage?
    
    var inputVignetteIntensity: CGFloat = 1
    var inputVignetteRadius: CGFloat = 1
    var inputSepiaToneIntensity: CGFloat = 1
    
override var attributes: [String : AnyObject]
{
    return [
        kCIAttributeFilterDisplayName: "Vintage Vignette",
        
        "inputImage": [kCIAttributeIdentity: 0,
            kCIAttributeClass: "CIImage",
            kCIAttributeDisplayName: "Image",
            kCIAttributeType: kCIAttributeTypeImage],
        
        "inputVignetteIntensity": [kCIAttributeIdentity: 0,
            kCIAttributeClass: "NSNumber",
            kCIAttributeDefault: 1,
            kCIAttributeDisplayName: "Vignette Intensity",
            kCIAttributeMin: 0,
            kCIAttributeSliderMin: 0,
            kCIAttributeSliderMax: 2,
            kCIAttributeType: kCIAttributeTypeScalar],
        
        "inputVignetteRadius": [kCIAttributeIdentity: 0,
            kCIAttributeClass: "NSNumber",
            kCIAttributeDefault: 1,
            kCIAttributeDisplayName: "Vignette Radius",
            kCIAttributeMin: 0,
            kCIAttributeSliderMin: 0,
            kCIAttributeSliderMax: 2,
            kCIAttributeType: kCIAttributeTypeScalar],
        
        "inputSepiaToneIntensity": [kCIAttributeIdentity: 0,
            kCIAttributeClass: "NSNumber",
            kCIAttributeDefault: 1,
            kCIAttributeDisplayName: "Sepia Tone Intensity",
            kCIAttributeMin: 0,
            kCIAttributeSliderMin: 0,
            kCIAttributeSliderMax: 1,
            kCIAttributeType: kCIAttributeTypeScalar]
    ]
}
    
    override func setDefaults()
    {
        inputVignetteIntensity = 1
        inputVignetteRadius = 1
        inputSepiaToneIntensity = 1
    }
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        let finalImage = inputImage
            .imageByApplyingFilter("CIVignette",
                withInputParameters: [
                    kCIInputIntensityKey: inputVignetteIntensity,
                    kCIInputRadiusKey: inputVignetteRadius])
            .imageByApplyingFilter("CISepiaTone",
                withInputParameters: [
                    kCIInputIntensityKey: inputSepiaToneIntensity])
        
        return finalImage
    }
    
}

// MARK: Starburst

class StarBurstFilter: CIFilter
{
    var inputImage : CIImage?
    var inputThreshold: CGFloat = 0.9
    var inputRadius: CGFloat = 20
    var inputAngle: CGFloat = 0
    var inputBeamCount: Int = 3
    var inputStarburstBrightness: CGFloat = 0
    
    let thresholdFilter = ThresholdToAlphaFilter()
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Starburst Filter",
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputThreshold": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.9,
                kCIAttributeDisplayName: "Threshold",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputRadius": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 20,
                kCIAttributeDisplayName: "Radius",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputAngle": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0,
                kCIAttributeDisplayName: "Angle",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: M_PI,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputStarburstBrightness": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0,
                kCIAttributeDisplayName: "Starburst Brightness",
                kCIAttributeMin: -1,
                kCIAttributeSliderMin: -1,
                kCIAttributeSliderMax: 0.5,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputBeamCount": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 3,
                kCIAttributeDisplayName: "Beam Count",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 10,
                kCIAttributeType: kCIAttributeTypeInteger]
        ]
    }
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        thresholdFilter.inputThreshold = inputThreshold
        thresholdFilter.inputImage = inputImage
        
        let thresholdImage = thresholdFilter.outputImage!
     
        let starBurstAccumulator = CIImageAccumulator(extent: thresholdImage.extent,
            format: kCIFormatARGB8)
        
        for i in 0 ..< inputBeamCount
        {
            let angle = CGFloat((M_PI / Double(inputBeamCount)) * Double(i))
            
            let starburst = thresholdImage.imageByApplyingFilter("CIMotionBlur",
                    withInputParameters: [
                        kCIInputRadiusKey: inputRadius,
                        kCIInputAngleKey: inputAngle + angle])
                .imageByCroppingToRect(thresholdImage.extent)
                .imageByApplyingFilter("CIAdditionCompositing",
                    withInputParameters: [
                        kCIInputBackgroundImageKey: starBurstAccumulator.image()])
            
            starBurstAccumulator.setImage(starburst)
        }
        
        let adjustedStarBurst = starBurstAccumulator.image()
            .imageByApplyingFilter("CIColorControls",
                withInputParameters: [kCIInputBrightnessKey: inputStarburstBrightness])

        let final = inputImage.imageByApplyingFilter("CIAdditionCompositing",
            withInputParameters: [kCIInputBackgroundImageKey: adjustedStarBurst])
        
        return final
    }
    
}

// MARK: ThresholdToAlphaFilter

class ThresholdToAlphaFilter: ThresholdFilter
{
    override var attributes: [String : AnyObject]
    {
        var superAttributes = super.attributes
        
        superAttributes[kCIAttributeFilterDisplayName] = "Threshold To Alpha Filter"
        
        return superAttributes
    }
    
    override init()
    {
        super.init()
        
        thresholdKernel = CIColorKernel(string:
            "kernel vec4 thresholdFilter(__sample image, float threshold)" +
                "{" +
                "   float luma = dot(image.rgb, vec3(0.2126, 0.7152, 0.0722));" +
                
                "   return (luma > threshold) ? image : vec4(image.r, image.g, image.b, 0.0);" +
            "}"
        )
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
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
    
    override init()
    {
        super.init()
        
        thresholdKernel = CIColorKernel(string:
            "kernel vec4 thresholdFilter(__sample image, float threshold)" +
                "{" +
                "   float luma = dot(image.rgb, vec3(0.2126, 0.7152, 0.0722));" +
                
                "   return (luma > threshold) ? vec4(1.0) : vec4(0.0);" +
            "}"
        )

    }
 
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    var thresholdKernel: CIColorKernel?
    
    override var outputImage: CIImage!
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


// MARK: VignetteNoir

class VignetteNoirFilter: CIFilter
{
    var inputImage: CIImage?
    var inputRadius: CGFloat = 1
    var inputIntensity: CGFloat = 2
    var inputEdgeBrightness: CGFloat = -0.3
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Vignette Noir Filter",
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            "inputRadius": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1,
                kCIAttributeDisplayName: "Radius",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 2,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputIntensity": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 2,
                kCIAttributeDisplayName: "Intensity",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 10,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputEdgeBrightness": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: -0.3,
                kCIAttributeDisplayName: "Edge Brightness",
                kCIAttributeMin: -1,
                kCIAttributeSliderMin: -1,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    override func setDefaults()
    {
        inputRadius = 1
        inputIntensity = 2
        inputEdgeBrightness = -0.3
    }
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        let mask = CIImage(color: CIColor(red: 1, green: 1, blue: 1))
            .imageByCroppingToRect(inputImage.extent)
            .imageByApplyingFilter("CIVignette", withInputParameters: [
                kCIInputRadiusKey: inputRadius,
                kCIInputIntensityKey: inputIntensity])
        
        let noir = inputImage
            .imageByApplyingFilter("CIPhotoEffectNoir",withInputParameters: nil)
            .imageByApplyingFilter("CIColorControls", withInputParameters: [
                kCIInputBrightnessKey: inputEdgeBrightness])
        
        let blendWithMaskFilter = CIFilter(name: "CIBlendWithMask", withInputParameters: [
            kCIInputImageKey: inputImage,
            kCIInputBackgroundImageKey: noir,
            kCIInputMaskImageKey: mask])
        
        return blendWithMaskFilter?.outputImage
    }
}




