//
//  ModelIOGenerators.swift
//  Filterpedia
//
//  Created by Simon Gladman on 25/03/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import ModelIO
import CoreImage

// MARK: ModelIO Color from Temperature
// See: https://en.wikipedia.org/wiki/Color_temperature

class ModelIOColorFromTemperature: CIFilter
{
    var inputSize = CIVector(x: 640, y: 640)
    var inputTemperature: CGFloat = 1700
    
    override var outputImage: CIImage!
    {
        let swatch = MDLColorSwatchTexture(colorTemperatureGradientFrom: inputTemperature.toFloat(),
            toColorTemperature: inputTemperature.toFloat(),
            name: "",
            textureDimensions: [Int32(inputSize.X), Int32(inputSize.Y)])
        
        let swatchImage = swatch.imageFromTexture()!.takeUnretainedValue()
        
        return CIImage(CGImage: swatchImage)
    }
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "ModelIO Color From Temperature",

            "inputSize": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Size",
                kCIAttributeDefault: CIVector(x: 640, y: 640),
                kCIAttributeType: kCIAttributeTypeOffset],
            
            "inputTemperature": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1700,
                kCIAttributeDescription: "Black-body color temperature (°K)",
                kCIAttributeDisplayName: "Temperature",
                kCIAttributeMin: 1500,
                kCIAttributeSliderMin: 1500,
                kCIAttributeSliderMax: 15000,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
}

// MARK: ModelIO Color Scalar Noise

class ModelIOColorScalarNoise: CIFilter
{
    var inputSize = CIVector(x: 640, y: 640)
    var inputSmoothness: CGFloat = 0.5
    
    let makeOpaqueKernel = CIColorKernel(string: "kernel vec4 xyz(__sample pixel) { return vec4(pixel.rgb, 1.0); }")
    
    override var outputImage: CIImage!
    {
        let noise = MDLNoiseTexture(scalarNoiseWithSmoothness: inputSmoothness.toFloat(),
            name: "",
            textureDimensions: [Int32(inputSize.X), Int32(inputSize.Y)],
            channelCount: 4,
            channelEncoding: MDLTextureChannelEncoding.UInt8,
            grayscale: false)
        
        let noiseImage = noise.imageFromTexture()!.takeUnretainedValue()
        
        let final = CIImage(CGImage: noiseImage)
        
        return makeOpaqueKernel?.applyWithExtent(final.extent, arguments: [final])
    }
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "ModelIO Color Scalar Noise",

            "inputSize": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Size",
                kCIAttributeDefault: CIVector(x: 640, y: 640),
                kCIAttributeType: kCIAttributeTypeOffset],
            
            "inputSmoothness": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.5,
                kCIAttributeDisplayName: "Smoothness",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
}

// MARK: ModelIO Sky Generator

class ModelIOSkyGenerator: CIFilter
{
    var inputSize = CIVector(x: 640, y: 640)
    {
        didSet
        {
            sky = nil
        }
    }

    var inputTurbidity:CGFloat = 0.75
    var inputSunElevation: CGFloat = 0.70
    var inputUpperAtmosphereScattering: CGFloat = 0.2
    var inputGroundAlbedo: CGFloat = 0.5
    var inputContrast: CGFloat = 1
    var inputExposure: CGFloat = 0.5
    
    var sky: MDLSkyCubeTexture?
    
    override var outputImage: CIImage!
    {
        if let sky = sky
        {
            sky.turbidity = inputTurbidity.toFloat()
            sky.sunElevation = inputSunElevation.toFloat()
            sky.upperAtmosphereScattering = inputUpperAtmosphereScattering.toFloat()
            sky.groundAlbedo = inputGroundAlbedo.toFloat()
        }
        else
        {
            sky = MDLSkyCubeTexture(name: nil,
                channelEncoding: MDLTextureChannelEncoding.UInt8,
                textureDimensions: [Int32(inputSize.X), Int32(inputSize.Y)],
                turbidity: inputTurbidity.toFloat(),
                sunElevation: inputSunElevation.toFloat(),
                upperAtmosphereScattering: inputUpperAtmosphereScattering.toFloat(),
                groundAlbedo: inputGroundAlbedo.toFloat())
        }
        
        sky!.contrast = inputContrast.toFloat()
        sky!.exposure = inputExposure.toFloat()
        
        sky!.updateTexture()
        
        let skyImage = sky!.imageFromTexture()!.takeUnretainedValue()
        
        return  CIImage(CGImage: skyImage)
            .imageByCroppingToRect(CGRect(x: 0, y: 0, width: inputSize.X, height: inputSize.Y))
    }
    
        
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "ModelIO Sky Generator",

            "inputSize": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Size",
                kCIAttributeDefault: CIVector(x: 640, y: 640),
                kCIAttributeType: kCIAttributeTypeOffset],
            
            "inputTurbidity": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.75,
                kCIAttributeDisplayName: "Turbidity",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputSunElevation": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.75,
                kCIAttributeDisplayName: "Sun Elevation",
                kCIAttributeMin: 0.5,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputUpperAtmosphereScattering": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.2,
                kCIAttributeDisplayName: "Upper Atmosphere Scattering",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputGroundAlbedo": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.5,
                kCIAttributeDisplayName: "Ground Albedo",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputContrast": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1,
                kCIAttributeDisplayName: "Contrast",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 2,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputExposure": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.5,
                kCIAttributeDisplayName: "Exposure",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: -1,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
}

extension CGFloat
{
    func toFloat() -> Float
    {
        return Float(self)
    }
}