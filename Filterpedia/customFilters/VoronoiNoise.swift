//
//  VoronoiNoise.swift
//  Filterpedia
//
//  Created by Simon Gladman on 09/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import CoreImage

class VoronoiNoise: CIFilter
{
    var inputSeed: CGFloat = 20
    var inputSize: CGFloat = 60
    var inputDensity: CGFloat = 0.75
    var inputWidth: CGFloat = 640
    var inputHeight: CGFloat = 640
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "Voronoi Noise",
            "inputSeed": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1,
                kCIAttributeDisplayName: "Seed",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1000,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputSize": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 60,
                kCIAttributeDisplayName: "Size",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 200,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputDensity": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.75,
                kCIAttributeDisplayName: "Density",
                kCIAttributeMin: 0.5,
                kCIAttributeSliderMin: 0.5,
                kCIAttributeSliderMax: 1.5,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputWidth": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 640,
                kCIAttributeDisplayName: "Width",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1280,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputHeight": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 640,
                kCIAttributeDisplayName: "Height",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1280,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    let voronoiKernel: CIColorKernel =
    {
        let shaderPath = Bundle.main.path(forResource: "Voronoi", ofType: "cikernel")
        
        guard let path = shaderPath,
            let code = try? String(contentsOfFile: path),
            let kernel = CIColorKernel(string: code) else
        {
            fatalError("Unable to build Voronoi shader")
        }
        
        return kernel
    }()
    
    override var outputImage: CIImage?
    {
        return voronoiKernel.apply(
            withExtent: CGRect(origin: CGPoint.zero, size: CGSize(width: inputWidth, height: inputHeight)),
            arguments: [inputSeed, inputSize, inputDensity])
    }
}
