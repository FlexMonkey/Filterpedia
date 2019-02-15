//
//  SobelEdgeDetection.swift
//  Filterpedia
//
//  Created by Simon Gladman on 18/03/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import CoreImage

class SobelEdgeDetection3x3: SobelEdgeDetectionBase
{
    let horizontalSobel = CIVector(values: [
        -1, 0, 1,
        -2, 0, 2,
        -1, 0, 1], count: 9)
    
    let verticalSobel = CIVector(values: [
        -1, -2, -1,
        0,  0,  0,
        1,  2,  1], count: 9)
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        let final = sobel(inputImage,
            filterName: "CIConvolution3X3",
            horizontalWeights: horizontalSobel,
            verticalWeights: verticalSobel)
        
        return makeOpaqueKernel?.apply(extent: inputImage.extent, arguments: [final])
    }
    
    override func displayName() -> String
    {
        return "Sobel Edge Detection 3x3 "
    }
}

class SobelEdgeDetection5x5: SobelEdgeDetectionBase
{
    let horizontalSobel = CIVector(values: [
        -1, -2, 0, 2, 1,
        -4, -8, 0, 8, 4,
        -6, -12, 0, 12, 6,
        -4, -8, 0, 8, 4,
        -1, -2, 0, 2, 1], count: 25)
    
    let verticalSobel = CIVector(values: [
        -1, -4, -6, -4, -1,
        -2, -8, -12, -8, -2,
        0, 0, 0, 0, 0,
        2, 8, 12, 8, 2,
        1, 4, 6, 4, 1], count: 25)
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        let final = sobel(inputImage,
            filterName: "CIConvolution5X5",
            horizontalWeights: horizontalSobel,
            verticalWeights: verticalSobel)

        return makeOpaqueKernel?.apply(extent: inputImage.extent, arguments: [final])
    }
    
    override func displayName() -> String
    {
        return "Sobel Edge Detection 5x5 "
    }
}

class SobelEdgeDetectionBase: CIFilter
{
    let makeOpaqueKernel = CIColorKernel(source: "kernel vec4 xyz(__sample pixel) { return vec4(pixel.rgb, 1.0); }")
    
    fileprivate func sobel(_ sourceImage: CIImage, filterName: String, horizontalWeights: CIVector, verticalWeights: CIVector) -> CIImage
    {
        return sourceImage
            .applyingFilter(filterName,
                parameters: [
                    kCIInputWeightsKey: horizontalWeights.multiply(inputWeight),
                    kCIInputBiasKey: inputBias])
            .applyingFilter(filterName,
                parameters: [
                    kCIInputWeightsKey: verticalWeights.multiply(inputWeight),
                    kCIInputBiasKey: inputBias])
            .cropped(to: sourceImage.extent)
    }
    
    @objc var inputImage : CIImage?
    @objc var inputBias: CGFloat = 1
    @objc var inputWeight: CGFloat = 1

    override func setDefaults()
    {
        inputBias = 1
        inputWeight = 1
    }
    
    func displayName() -> String
    {
        fatalError("SobelEdgeDetectionBase must be sublassed")
    }
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: displayName() as AnyObject,
            
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputBias": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1,
                kCIAttributeDisplayName: "Bias",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 2,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputWeight": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1,
                kCIAttributeDisplayName: "Weight",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 4,
                kCIAttributeType: kCIAttributeTypeScalar],
            ]
    }
    
}


