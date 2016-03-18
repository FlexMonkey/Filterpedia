//
//  SobelEdgeDetection.swift
//  Filterpedia
//
//  Created by Simon Gladman on 18/03/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import CoreImage

class SobelEdgeDetection: CIFilter
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
    
    
    var inputImage : CIImage?
    var inputBias: CGFloat = 1
    var inputWeight: CGFloat = 1

    override func setDefaults()
    {
        inputBias = 1
        inputWeight = 1
    }
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Sobel Edge Detection",
            
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
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        let final = inputImage
            .imageByApplyingFilter("CIConvolution5X5",
                withInputParameters: [
                    kCIInputWeightsKey: horizontalSobel.multiply(inputWeight),
                    kCIInputBiasKey: inputBias])
            .imageByApplyingFilter("CIConvolution5X5",
                withInputParameters: [
                    kCIInputWeightsKey: verticalSobel.multiply(inputWeight),
                    kCIInputBiasKey: inputBias])
            .imageByCroppingToRect(inputImage.extent)
        
        return final
    }
}


extension CIVector
{
    func multiply(value: CGFloat) -> CIVector
    {
        let n = self.count
        var targetArray = [CGFloat]()
        
        for i in 0 ..< n
        {
            targetArray.append(self.valueAtIndex(i) * value)
        }
        
        return CIVector(values: targetArray, count: n)
    }
}