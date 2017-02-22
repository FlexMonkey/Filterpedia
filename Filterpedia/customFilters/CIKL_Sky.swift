//
//  CIKL_Sky.swift
//  Filterpedia
//
//  Created by Simon Gladman on 28/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import CoreImage

class SimpleSky: CIFilter
{
    var inputSunDiameter: CGFloat = 0.01
    var inputAlbedo: CGFloat = 0.2
    var inputSunAzimuth: CGFloat = 0.0
    var inputSunAlitude: CGFloat = 1.0
    var inputSkyDarkness: CGFloat = 1.25
    var inputScattering: CGFloat = 10.0
    var inputWidth: CGFloat = 640
    var inputHeight: CGFloat = 640
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "Simple Sky",
            
            "inputSunDiameter": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.01,
                kCIAttributeDisplayName: "Sun Diameter",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputAlbedo": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.2,
                kCIAttributeDisplayName: "Albedo",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputSunAzimuth": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0,
                kCIAttributeDisplayName: "Sun Azimuth",
                kCIAttributeMin: -1,
                kCIAttributeSliderMin: -1,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputSunAlitude": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1,
                kCIAttributeDisplayName: "Sun Alitude",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 10,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputSkyDarkness": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1.25,
                kCIAttributeDisplayName: "Sky Darkness",
                kCIAttributeMin: 0.1,
                kCIAttributeSliderMin: 0.1,
                kCIAttributeSliderMax: 2,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputScattering": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 10,
                kCIAttributeDisplayName: "Scattering",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 20,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputWidth": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 640,
                kCIAttributeDisplayName: "Width",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 1280,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputHeight": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 640,
                kCIAttributeDisplayName: "Height",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 1280,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    let skyKernel: CIColorKernel =
    {
        let shaderPath = Bundle.main.path(forResource: "cikl_sky", ofType: "cikernel")
        
        guard let path = shaderPath,
            let code = try? String(contentsOfFile: path),
            let kernel = CIColorKernel(string: code) else
        {
            fatalError("Unable to build Sky shader")
        }
        
        return kernel
    }()
    
    override var outputImage: CIImage?
    {
        let extent = CGRect(x: 0, y: 0, width: inputWidth, height: inputHeight)
        
        let arguments = [inputWidth, inputHeight, inputSunDiameter, inputAlbedo, inputSunAzimuth, inputSunAlitude, inputSkyDarkness, inputScattering]
        
        let final = skyKernel.apply(withExtent: extent, arguments: arguments)?.cropping(to: extent)
        
        return final
    }
    
}
