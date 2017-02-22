//
//  SimplePlasma.swift
//  Filterpedia
//
//  Created by Simon Gladman on 16/05/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//
// Based on https://www.shadertoy.com/view/XsVSzW


import CoreImage

class SimplePlasma: CIFilter
{
    var inputSize = CIVector(x: 640, y: 640)
    var inputTime: CGFloat = 0
    var inputSharpness: CGFloat = 0.5
    var inputIterations: CGFloat = 7
    var inputScale: CGFloat = 100
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "Simple Plasma",
            
            "inputSize": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIVector",
                kCIAttributeDisplayName: "Size",
                kCIAttributeDefault: CIVector(x: 640, y: 640),
                kCIAttributeType: kCIAttributeTypeOffset],
            
            "inputTime": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0,
                kCIAttributeDisplayName: "Time",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1024,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputSharpness": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.5,
                kCIAttributeDisplayName: "Sharpness",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputIterations": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 7,
                kCIAttributeDisplayName: "Iterations",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 7,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputScale": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 100,
                kCIAttributeDisplayName: "Scale",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 1000,
                kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
    
    let kernel = CIColorKernel(string:
        "kernel vec4 colorkernel(float time, float iterations, float sharpness, float scale)" +
            "{" +
            "   vec2 uv = destCoord() / scale; " +
            "   vec2 uv0=uv; " +
            "   vec4 i = vec4(1.0, 1.0, 1.0, 0.0);" +
            
            "   for(int s = 0;s < int(iterations); s++) " +
            "   { " +
            "       vec2 r=vec2(cos(uv.y * i.x - i.w + time / i.y),sin(uv.x * i.x - i.w + time / i.y)) / i.z; " +
            "       r+=vec2(-r.y,r.x) * 0.3; " +
            "       uv.xy+=r; " +
            "       i *= vec4(1.93, 1.15, (2.25 - sharpness), time * i.y); " +
            "   } " +
            "   float r=sin(uv.x-time)*0.5+0.5; " +
            "   float b=sin(uv.y+time)*0.5+0.5; " +
            "   float g=sin((uv.x+uv.y+sin(time))*0.5)*0.5+0.5; " +
            "   return vec4(r,g,b,1.0);" +
        "}")
    
    override var outputImage: CIImage?
    {
        guard let kernel = kernel else
        {
            return nil
        }
        
        let extent = CGRect(origin: CGPoint.zero, size: CGSize(width: inputSize.x, height: inputSize.y))
        
        return kernel.apply(
            withExtent: extent,
            arguments: [inputTime / 10, inputIterations, inputSharpness, inputScale])
    }
    
    
}
