//
//  ModelIOGenerators.swift
//  Filterpedia
//
//  Created by Simon Gladman on 25/03/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import ModelIO
import CoreImage



class ModelIOSkyGenerator: CIFilter
{
    private var textureInvalid = true
    
    var inputSize = CIVector(x: 640, y: 640)
    {
        didSet
        {
            textureInvalid = inputSize != oldValue
        }
    }

    var inputTurbidity:CGFloat = 0.75
    var inputSunElevation: CGFloat = 0.70
    var inputUpperAtmosphereScattering: CGFloat = 0.2
    var inputGroundAlbedo: CGFloat = 0.5
    var inputContrast: CGFloat = 1
    var inputExposure: CGFloat = 0.5
    
    var sky: MDLSkyCubeTexture!
    
    override var outputImage: CIImage!
    {
        if textureInvalid
        {
            sky = MDLSkyCubeTexture(name: nil,
                channelEncoding: MDLTextureChannelEncoding.UInt8,
                textureDimensions: [Int32(inputSize.X), Int32(inputSize.Y)],
                turbidity: inputTurbidity.toFloat(),
                sunElevation: inputSunElevation.toFloat(),
                upperAtmosphereScattering: inputUpperAtmosphereScattering.toFloat(),
                groundAlbedo: inputGroundAlbedo.toFloat())
            
            textureInvalid = false
        }
        else
        {
            sky.turbidity = inputTurbidity.toFloat()
            sky.sunElevation = inputSunElevation.toFloat()
            sky.upperAtmosphereScattering = inputUpperAtmosphereScattering.toFloat()
            sky.groundAlbedo = inputGroundAlbedo.toFloat()
        }
        
        sky.contrast = inputContrast.toFloat()
        sky.exposure = inputExposure.toFloat()
        
        sky.updateTexture()
        
        let skyImage = sky.imageFromTexture()!.takeUnretainedValue() as CGImage
        
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