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
        CIFilter.registerFilterName(
            "ThresholdFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "ThresholdToAlphaFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "CRTFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "VignetteNoirFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "MercurializeFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "VintageVignette",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "RGBChannelCompositing",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "RGBChannelGaussianBlur",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "RGBChannelToneCurve",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "PseudoColor",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "KuwaharaFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "MetalPixellateFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "MetalKuwaharaFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "MetalPerlinNoise",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "StarBurstFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "ChromaticAberration",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "RGBChannelBrightnessAndContrast",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "VHSTrackingLines",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "EightBit",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "TechnicolorFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "BleachBypassFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "CarnivalMirror",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "BayerDitherFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "CompoundEye",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "DifferenceOfGaussians",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "AdvancedMonochrome",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "RefractedTextFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "SobelEdgeDetection5x5",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "SobelEdgeDetection3x3",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "MultiBandHSV",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "PolarPixellate",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "ModelIOSkyGenerator",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "ModelIOColorScalarNoise",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "ModelIOColorFromTemperature",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "CausticRefraction",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "CausticNoise",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "ColorDirectedBlur",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "CMYKRegistrationMismatch",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "CMYKLevels",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "CMYKToneCurves",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "SmoothThreshold",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "VoronoiNoise",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "NormalMap",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "HistogramSpecification",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "ContrastStretch",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "HistogramEqualization",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "SimpleSky",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "LensFlare",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "HexagonalBokehFilter",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "MaskedVariableCircularBokeh",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "MaskedVariableHexagonalBokeh",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "CircularBokeh",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "EndsInContrastStretch",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "HomogeneousColorBlur",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "SimplePlasma",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "ConcentricSineWaves",
            constructor: CustomFiltersVendor(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryCustomFilters]
            ])
        
        CIFilter.registerFilterName(
            "Scatter",
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
            
        case "PseudoColor":
            return PseudoColor()
            
        case "KuwaharaFilter":
            return KuwaharaFilter()
            
        case "StarBurstFilter":
            return StarBurstFilter()
            
        case "ChromaticAberration":
            return ChromaticAberration()
            
        case "RGBChannelBrightnessAndContrast":
            return RGBChannelBrightnessAndContrast()
            
        case "VHSTrackingLines":
            return VHSTrackingLines()
            
        case "EightBit":
            return EightBit()
            
        case "TechnicolorFilter":
            return TechnicolorFilter()
            
        case "BleachBypassFilter":
            return BleachBypassFilter()
            
        case "CarnivalMirror":
            return CarnivalMirror()
            
        case "BayerDitherFilter":
            return BayerDitherFilter()
            
        case "CompoundEye":
            return CompoundEye()
            
        case "DifferenceOfGaussians":
            return DifferenceOfGaussians()
            
        case "AdvancedMonochrome":
            return AdvancedMonochrome()
            
        case "RefractedTextFilter":
            return RefractedTextFilter()

        case "SobelEdgeDetection5x5":
            return SobelEdgeDetection5x5()
            
        case "SobelEdgeDetection3x3":
            return SobelEdgeDetection3x3()
            
        case "PolarPixellate":
            return PolarPixellate()
            
        case "MultiBandHSV":
            return MultiBandHSV()
            
        case "ModelIOSkyGenerator":
            return ModelIOSkyGenerator()
            
        case "ModelIOColorScalarNoise":
            return ModelIOColorScalarNoise()
            
        case "ModelIOColorFromTemperature":
            return ModelIOColorFromTemperature()
            
        case "ColorDirectedBlur":
            return ColorDirectedBlur()
            
        case "HomogeneousColorBlur":
            return HomogeneousColorBlur()

        case "CMYKRegistrationMismatch":
            return CMYKRegistrationMismatch()
            
        case "CMYKLevels":
            return CMYKLevels()
            
        case "CMYKToneCurves":
            return CMYKToneCurves()
            
        case "SmoothThreshold":
            return SmoothThreshold()
            
        case "VoronoiNoise":
            return VoronoiNoise()
            
        case "CausticRefraction":
            return CausticRefraction()

        case "CausticNoise":
          return CausticNoise()
          
        case "NormalMap":
            return NormalMapFilter()
            
        case "HistogramSpecification":
            return HistogramSpecification()
            
        case "ContrastStretch":
            return ContrastStretch()
            
        case "HistogramEqualization":
            return HistogramEqualization()
        
        case "SimpleSky":
            return SimpleSky()
            
        case "LensFlare":
            return LensFlare()
            
        case "CircularBokeh":
            return CircularBokeh()
            
        case "MaskedVariableCircularBokeh":
            return MaskedVariableCircularBokeh()
            
        case "MaskedVariableHexagonalBokeh":
            return MaskedVariableHexagonalBokeh()
            
        case "EndsInContrastStretch":
            return EndsInContrastStretch()
            
        case "SimplePlasma":
            return SimplePlasma()
            
        case "ConcentricSineWaves":
            return ConcentricSineWaves()
            
        case "Scatter":
            return Scatter()
            
        case "MetalPixellateFilter":
            #if !arch(i386) && !arch(x86_64)
                return MetalPixellateFilter()
            #else
                return nil
            #endif
            
        case "MetalKuwaharaFilter":
            #if !arch(i386) && !arch(x86_64)
                return MetalKuwaharaFilter()
            #else
                return nil
            #endif
            
        case "MetalPerlinNoise":
            #if !arch(i386) && !arch(x86_64)
                return MetalPerlinNoise()
            #else
                return nil
            #endif

        case "HexagonalBokehFilter":
            #if !arch(i386) && !arch(x86_64)
                return HexagonalBokehFilter()
            #else
                return nil
            #endif
            
        default:
            return nil
        }
    }
}

// MARK: PseudoColor

/// This filter isn't dissimilar to Core Image's own False Color filter
/// but it accepts five input colors and uses `mix()` and `smoothstep()` 
/// to transition between them based on an image's luminance. The 
/// balance between linear and Hermite interpolation is controlled by
/// the `inputSmoothness` parameter.

class PseudoColor: CIFilter
{
    var inputImage: CIImage?
    
    var inputSmoothness = CGFloat(0.5)
    
    var inputColor0 = CIColor(red: 1, green: 0, blue: 1)
    var inputColor1 = CIColor(red: 0, green: 0, blue: 1)
    var inputColor2 = CIColor(red: 0, green: 1, blue: 0)
    var inputColor3 = CIColor(red: 1, green: 0, blue: 1)
    var inputColor4 = CIColor(red: 0, green: 1, blue: 1)
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Pseudo Color Filter",
            
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputSmoothness": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDescription: "Controls interpolation between colors. Range from 0.0 (Linear) to 1.0 (Hermite).",
                kCIAttributeDefault: 0.5,
                kCIAttributeDisplayName: "Smoothness",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputColor0": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIColor",
                kCIAttributeDisplayName: "Color One",
                kCIAttributeDefault: CIColor(red: 1, green: 0, blue: 1),
                kCIAttributeType: kCIAttributeTypeColor],
            
            "inputColor1": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIColor",
                kCIAttributeDisplayName: "Color Two",
                kCIAttributeDefault: CIColor(red: 0, green: 0, blue: 1),
                kCIAttributeType: kCIAttributeTypeColor],
            
            "inputColor2": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIColor",
                kCIAttributeDisplayName: "Color Three",
                kCIAttributeDefault: CIColor(red: 0, green: 1, blue: 0),
                kCIAttributeType: kCIAttributeTypeColor],
            
            "inputColor3": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIColor",
                kCIAttributeDisplayName: "Color Four",
                kCIAttributeDefault: CIColor(red: 1, green: 0, blue: 1),
                kCIAttributeType: kCIAttributeTypeColor],
            
            "inputColor4": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIColor",
                kCIAttributeDisplayName: "Color Five",
                kCIAttributeDefault: CIColor(red: 0, green: 1, blue: 1),
                kCIAttributeType: kCIAttributeTypeColor]
        ]
    }
    
    let pseudoColorKernel = CIColorKernel(string:
        "vec4 getColor(vec4 color0, vec4 color1, float edge0, float edge1, float luma, float smoothness) \n" +
        "{ \n" +
        "   vec4 smoothColor = color0 + ((color1 - color0) * smoothstep(edge0, edge1, luma)); \n" +
        "   vec4 linearColor = mix(color0, color1, (luma - edge0) * 4.0);  \n" +
        
        "   return mix(linearColor, smoothColor, smoothness); \n" +
        "} \n" +
        
        "kernel vec4 pseudoColor(__sample image, float smoothness,  vec4 inputColor0, vec4 inputColor1, vec4 inputColor2, vec4 inputColor3, vec4 inputColor4) \n" +
        "{ \n" +
        "   float luma = dot(image.rgb, vec3(0.2126, 0.7152, 0.0722)); \n" +
        
        "   if (luma < 0.25) \n" +
        "   { return getColor(inputColor0, inputColor1, 0.0, 0.25, luma, smoothness); } \n" +
        
        "   else if (luma >= 0.25 && luma < 0.5) \n" +
        "   { return getColor(inputColor1, inputColor2, 0.25, 0.5, luma, smoothness); } \n" +
        
        "   else if (luma >= 0.5 && luma < 0.75) \n" +
        "   { return getColor(inputColor2, inputColor3, 0.5, 0.75, luma, smoothness); } \n" +
        
        "   { return getColor(inputColor3, inputColor4, 0.75, 1.0, luma, smoothness); } \n" +
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
        let arguments = [inputImage, inputSmoothness, inputColor0, inputColor1, inputColor2, inputColor3, inputColor4]
        
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

// MARK: Difference of Gaussians

class DifferenceOfGaussians: CIFilter
{
    var inputImage : CIImage?
    var inputSigma0: CGFloat = 0.75
    var inputSigma1: CGFloat = 3.25
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Difference of Gaussians",
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputSigma0": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.75,
                kCIAttributeDisplayName: "Sigma One",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 4,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputSigma1": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 3.25,
                kCIAttributeDisplayName: "Sigma Two",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 4,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        let blurred0 = DifferenceOfGaussians.gaussianBlurWithSigma(inputSigma0, image: inputImage)
            .imageByCroppingToRect(inputImage.extent)
        let blurred1 = DifferenceOfGaussians.gaussianBlurWithSigma(inputSigma1, image: inputImage)
            .imageByCroppingToRect(inputImage.extent)

        return blurred0
            .imageByApplyingFilter("CISubtractBlendMode",
                withInputParameters: ["inputBackgroundImage": blurred1])
            .imageByApplyingFilter("CIColorMatrix",
                withInputParameters: ["inputBiasVector": CIVector(x: 0, y: 0, z: 0, w: 1)])
            .imageByCroppingToRect(inputImage.extent)
    }
    
    static func gaussianBlurWithSigma(sigma: CGFloat, image: CIImage) -> CIImage
    {
        let weightsArray: [CGFloat] = (-4).stride(through: 4, by: 1).map
        {
            CGFloat(DifferenceOfGaussians.gaussian(CGFloat($0), sigma: sigma))
        }
        
        let weightsVector = CIVector(values: weightsArray,
                                     count: weightsArray.count).normalize()
        
        let horizontalBluredImage = CIFilter(name: "CIConvolution9Horizontal",
                                                withInputParameters: [
                                                    kCIInputWeightsKey: weightsVector,
                                                    kCIInputImageKey: image])!.outputImage!
        
        let verticalBlurredImage = CIFilter(name: "CIConvolution9Vertical",
                                               withInputParameters: [
                                                kCIInputWeightsKey: weightsVector,
                                                kCIInputImageKey: horizontalBluredImage])!.outputImage!
        
        return verticalBlurredImage
    }
    
    static func gaussian(x: CGFloat, sigma: CGFloat) -> CGFloat
    {
        let variance = max(sigma * sigma, 0.00001)
        
        return (1.0 / sqrt(CGFloat(M_PI) * 2 * variance)) * pow(CGFloat(M_E), -pow(x, 2) / (2 * variance))
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
            
            "   return vec4(image.rgb, image.a * step(threshold, luma));" +
            "}"
        )
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Advanced Monochrome

class AdvancedMonochrome: CIFilter
{
    var inputImage : CIImage?
    
    var inputRedBalance: CGFloat = 1
    var inputGreenBalance: CGFloat = 1
    var inputBlueBalance: CGFloat = 1
    var inputClamp: CGFloat = 0
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Advanced Monochrome",
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            "inputRedBalance": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1,
                kCIAttributeDisplayName: "Red Balance",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputGreenBalance": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1,
                kCIAttributeDisplayName: "Green Balance",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputBlueBalance": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1,
                kCIAttributeDisplayName: "Blue Balance",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputClamp": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0,
                kCIAttributeDisplayName: "Clamp",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    let kernel = CIColorKernel(string:
        "kernel vec4 advancedMonochrome(__sample pixel, float redBalance, float greenBalance, float blueBalance, float clamp)" +
        "{" +
        "   float scale = 1.0 / (redBalance + greenBalance + blueBalance);" +
            
        "   float red = pixel.r * redBalance * scale;" +
        "   float green = pixel.g * greenBalance * scale;" +
        "   float blue = pixel.b * blueBalance * scale;" +
            
        "   vec3 grey = vec3(red + green + blue);" +
            
        "   grey = mix(grey, smoothstep(0.0, 1.0, grey), clamp); " +
        
        "   return vec4(grey, pixel.a);" +
        "}")
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage,
            kernel = kernel else
        {
            return nil
        }
        
        let extent = inputImage.extent
        let arguments = [inputImage, inputRedBalance, inputGreenBalance, inputBlueBalance, inputClamp]
        
        return kernel.applyWithExtent(extent, arguments: arguments)
    }
}

// MARK: SmoothThreshold

class SmoothThreshold: CIFilter
{
    var inputImage : CIImage?
    var inputEdgeO: CGFloat = 0.25
    var inputEdge1: CGFloat = 0.75
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Smooth Threshold Filter",
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            "inputEdgeO": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.25,
                kCIAttributeDisplayName: "Edge 0",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputEdge1": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.75,
                kCIAttributeDisplayName: "Edge 1",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    let colorKernel = CIColorKernel(string:
        "kernel vec4 color(__sample pixel, float inputEdgeO, float inputEdge1)" +
            "{" +
            "    float luma = dot(pixel.rgb, vec3(0.2126, 0.7152, 0.0722));" +
            "    float threshold = smoothstep(inputEdgeO, inputEdge1, luma);" +
            "    return vec4(threshold, threshold, threshold, 1.0);" +
        "}"
    )
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage,
            colorKernel = colorKernel else
        {
            return nil
        }
        
        let extent = inputImage.extent
        let arguments = [inputImage,
                         min(inputEdgeO, inputEdge1),
                         max(inputEdgeO, inputEdge1),]
        
        return colorKernel.applyWithExtent(extent,
                                           arguments: arguments)
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
        
        "   return vec4(step(threshold, luma));" +
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

// MARK: Polar Pixellate

// based on https://github.com/BradLarson/GPUImage/blob/master/framework/Source/GPUImagePolarPixellateFilter.m
class PolarPixellate: CIFilter
{
    var inputImage : CIImage?
    var inputCenter = CIVector(x: 320, y: 320)
    
    var inputPixelArc = CGFloat(M_PI / 15)
    var inputPixelLength = CGFloat(50)
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Polar Pixellate",
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputPixelArc": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: CGFloat(M_PI / 15),
                kCIAttributeDisplayName: "Pixel Arc",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: CGFloat(M_PI),
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputPixelLength": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 50,
                kCIAttributeDisplayName: "Pixel Length",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 250,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputCenter": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Center",
                kCIAttributeDefault: CIVector(x: 320, y: 320),
                kCIAttributeType: kCIAttributeTypePosition],
        ]
    }
    
    override func setDefaults()
    {
        inputPixelArc = CGFloat(M_PI / 15)
        inputPixelLength = 50
        inputCenter = CIVector(x: 320, y: 320)
    }
    
    let warpKernel = CIWarpKernel(string:
        "kernel vec2 polarPixellate(vec2 center, vec2 pixelSize)" +
        "{" +
        " vec2 normCoord = 2.0 * destCoord() - 1.0;" +
        " vec2 normCenter = 2.0 * center - 1.0;" +
        " normCoord -= normCenter; " +
        " float r = length(normCoord);" +
        " float phi = atan(normCoord.y, normCoord.x);" +
        " r = r - mod(r, pixelSize.x) + 0.03;" +
        " phi = phi - mod(phi, pixelSize.y);" +
        " normCoord.x = r * cos(phi);" +
        " normCoord.y = r * sin(phi);" +
        " normCoord += normCenter;" +
        " return normCoord / 2.0 + 0.5;" +
        "}"
    )
    
    override var outputImage : CIImage!
    {
        if let inputImage = inputImage, kernel = warpKernel
        {
            let extent = inputImage.extent
            let pixelSize = CIVector(x: inputPixelLength, y: inputPixelArc)
            
            return kernel.applyWithExtent(extent,
                roiCallback:
                {
                    (index, rect) in
                    return rect
                },
                inputImage: inputImage,
                arguments: [inputCenter, pixelSize])
        }
        return nil
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

// MARK: Normal Map Filter

/// NormalMapFilter - converts a bump map to a normal map
class NormalMapFilter: CIFilter
{
    var inputImage: CIImage?
    var inputContrast = CGFloat(2)
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Normal Map",
            
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputContrast": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 2,
                kCIAttributeDisplayName: "Contrast",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 6,
                kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
    
    let normalMapKernel = CIKernel(string:
        "float lumaAtOffset(sampler source, vec2 origin, vec2 offset)" +
        "{" +
        " vec3 pixel = sample(source, samplerTransform(source, origin + offset)).rgb;" +
        " float luma = dot(pixel, vec3(0.2126, 0.7152, 0.0722));" +
        " return luma;" +
        "}" +
        
        
        "kernel vec4 normalMap(sampler image) \n" +
        "{ " +
        " vec2 d = destCoord();" +
        
        " float northLuma = lumaAtOffset(image, d, vec2(0.0, -1.0));" +
        " float southLuma = lumaAtOffset(image, d, vec2(0.0, 1.0));" +
        " float westLuma = lumaAtOffset(image, d, vec2(-1.0, 0.0));" +
        " float eastLuma = lumaAtOffset(image, d, vec2(1.0, 0.0));" +
       
        " float horizontalSlope = ((westLuma - eastLuma) + 1.0) * 0.5;" +
        " float verticalSlope = ((northLuma - southLuma) + 1.0) * 0.5;" +
       
        
        " return vec4(horizontalSlope, verticalSlope, 1.0, 1.0);" +
        "}"
    )
    
    override var outputImage: CIImage?
    {
        guard let inputImage = inputImage,
            normalMapKernel = normalMapKernel else
        {
            return nil
        }
        
        return normalMapKernel.applyWithExtent(inputImage.extent,
            roiCallback:
            {
                (index, rect) in
                return rect
            },
            arguments: [inputImage])?
            .imageByApplyingFilter("CIColorControls", withInputParameters: [kCIInputContrastKey: inputContrast])
    }
}



