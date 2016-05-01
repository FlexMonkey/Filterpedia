//
//  Bokeh.swift
//  Filterpedia
//
//  Created by Simon Gladman on 30/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//
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

// MARK: Core Image Kernel Languag based bokeh

class MaskedVariableHexagonalBokeh: MaskedVariableCircularBokeh
{
    override func displayName() -> String
    {
        return "Masked Variable Hexagonal Bokeh"
    }
    
    override func withinProbe() -> String
    {
        return "float withinProbe = ((xx > h || yy > v * 2.0) ? 1.0 : ((2.0 * v * h - v * xx - h * yy) >= 0.0) ? 0.0 : 1.0);"
    }
}

class MaskedVariableCircularBokeh: CIFilter
{
    var inputImage: CIImage?
    var inputBokehMask: CIImage?
    var inputMaxBokehRadius: CGFloat = 20
    var inputBlurRadius: CGFloat = 2
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: displayName(),
            
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputBokehMask": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputMaxBokehRadius": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 20,
                kCIAttributeDisplayName: "Bokeh Radius",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 50,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputBlurRadius": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 2,
                kCIAttributeDisplayName: "Blur Radius",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 5,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    lazy var maskedVariableBokeh: CIKernel =
    {
        return CIKernel(string:
            "kernel vec4 lumaVariableBlur(sampler image, sampler bokehMask, float maxBokehRadius) " +
                "{ " +
                "    vec2 d = destCoord(); " +
                "    vec3 bokehMaskPixel = sample(bokehMask, samplerCoord(bokehMask)).rgb; " +
                "    float bokehMaskPixelLuma = dot(bokehMaskPixel, vec3(0.2126, 0.7152, 0.0722)); " +
                "    int radius = int(bokehMaskPixelLuma * maxBokehRadius); " +
                "    vec3 brightestPixel = sample(image, samplerCoord(image)).rgb; " +
                "    float brightestLuma = 0.0;" +
                
                "    float v = float(radius) / 2.0;" +
                "    float h = v * sqrt(3.0);" +
                
                "    for (int x = -radius; x <= radius; x++)" +
                "    { " +
                "        for (int y = -radius; y <= radius; y++)" +
                "        { " +
                "            float xx = abs(float(x));" +
                "            float yy = abs(float(y));" +
                
                self.withinProbe() +
                
                "            vec2 workingSpaceCoordinate = d + vec2(x,y);" +
                "            vec2 imageSpaceCoordinate = samplerTransform(image, workingSpaceCoordinate); " +
                "            vec3 color = sample(image, imageSpaceCoordinate).rgb; " +
                "            float luma = dot(color, vec3(0.2126, 0.7152, 0.0722)); " +
                "            if (withinProbe == 0.0 && luma > brightestLuma) {brightestLuma = luma; brightestPixel = color; } "  +
                "        } " +
                "    } " +
                "    return vec4(brightestPixel, 1.0); " +
            "} ")!
    }()
    
    func displayName() -> String
    {
        return "Masked Variable Circular Bokeh"
    }
    
    func withinProbe() -> String
    {
        return "float withinProbe = length(vec2(xx, yy)) < float(radius) ? 0.0 : 1.0; "
    }
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage, inputBlurMask = inputBokehMask else
        {
            return nil
        }
        
        let extent = inputImage.extent
        
        let blur = maskedVariableBokeh.applyWithExtent(
            inputImage.extent,
            roiCallback:
            {
                (index, rect) in
                return rect
            },
            arguments: [inputImage, inputBlurMask, inputMaxBokehRadius])
        
        return blur!
            .imageByApplyingFilter("CIMaskedVariableBlur", withInputParameters: ["inputMask": inputBlurMask, "inputRadius": inputBlurRadius])
            .imageByCroppingToRect(extent)
    }
}

// MARK: Metal Performance Shaders based bokeh

#if !arch(i386) && !arch(x86_64)
    
    import MetalPerformanceShaders
    
    class BokehFilter: CIFilter, MetalRenderable
    {
        override var attributes: [String : AnyObject]
        {
            return [
                kCIAttributeFilterDisplayName: "Bokeh",
                
                "inputImage": [kCIAttributeIdentity: 0,
                    kCIAttributeClass: "CIImage",
                    kCIAttributeDisplayName: "Image",
                    kCIAttributeType: kCIAttributeTypeImage],
                
                "inputBokehRadius": [kCIAttributeIdentity: 0,
                    kCIAttributeClass: "NSNumber",
                    kCIAttributeDefault: 20,
                    kCIAttributeDisplayName: "Bokeh Radius",
                    kCIAttributeMin: 1,
                    kCIAttributeSliderMin: 1,
                    kCIAttributeSliderMax: 50,
                    kCIAttributeType: kCIAttributeTypeScalar],
            
                "inputBlurSigma": [kCIAttributeIdentity: 0,
                    kCIAttributeClass: "NSNumber",
                    kCIAttributeDefault: 2,
                    kCIAttributeDisplayName: "Blur Sigma",
                    kCIAttributeMin: 1,
                    kCIAttributeSliderMin: 1,
                    kCIAttributeSliderMax: 5,
                    kCIAttributeType: kCIAttributeTypeScalar]
            ]
        }
            
        var inputImage: CIImage?
        {
            didSet
            {
                if let inputImage = inputImage
                {
                    let textureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(
                        .RGBA8Unorm,
                        width: Int(inputImage.extent.width),
                        height: Int(inputImage.extent.height),
                        mipmapped: false)
                    
                    sourceTexture = device.newTextureWithDescriptor(textureDescriptor)
                    destinationTexture = device.newTextureWithDescriptor(textureDescriptor)
                    intermediateTexture = device.newTextureWithDescriptor(textureDescriptor)
                }
            }
        }
        
        var inputBokehRadius: CGFloat = 15
        {
            didSet
            {
                if oldValue != inputBokehRadius
                {
                    dilate = nil
                }
            }
        }
        
        var inputBlurSigma: CGFloat = 2
        {
            didSet
            {
                if oldValue != inputBlurSigma
                {
                    blur = nil
                }
            }
        }
        
        lazy var device: MTLDevice =
        {
            return MTLCreateSystemDefaultDevice()!
        }()
        
        lazy var ciContext: CIContext =
        {
            [unowned self] in
            
            return CIContext(MTLDevice: self.device)
        }()
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()!
        
        private var probe = [Float]()
        
        private var dilate: MPSImageDilate?
        private var blur: MPSImageGaussianBlur?
        
        private var sourceTexture: MTLTexture?
        private var destinationTexture: MTLTexture?
        private var intermediateTexture: MTLTexture?
        
        override var outputImage: CIImage?
        {
            guard let inputImage = inputImage,
                inputTexture = sourceTexture,
                outputTexture = destinationTexture,
                intermediateTexture = intermediateTexture else
            {
                return nil
            }
            
            if dilate == nil
            {
                createDilate()
            }
            
            if blur == nil
            {
                createBlur()
            }
            
            let commandQueue = device.newCommandQueue()
            
            let commandBuffer = commandQueue.commandBuffer()
            
            ciContext.render(
                inputImage,
                toMTLTexture: inputTexture,
                commandBuffer: commandBuffer,
                bounds: inputImage.extent,
                colorSpace: colorSpace)
            
            dilate!.encodeToCommandBuffer(
                commandBuffer,
                sourceTexture: inputTexture,
                destinationTexture: intermediateTexture)
            
            blur!.encodeToCommandBuffer(
                commandBuffer,
                sourceTexture: intermediateTexture,
                destinationTexture: outputTexture)
            
            commandBuffer.commit()
            
            return CIImage(
                MTLTexture: outputTexture,
                options: [kCIImageColorSpace: colorSpace])
        }
        
        func createDilate()
        {
            var probe = [Float]()
            
            let size = Int(inputBokehRadius) * 2 + 1
            let v = Float(size / 4)
            let h = v * sqrt(3.0)
            let mid = Float(size) / 2
            
            for i in 0 ..< size
            {
                for j in 0 ..< size
                {
                    let x = abs(Float(i) - mid)
                    let y = abs(Float(j) - mid)
                    
                    let element = Float((x > h || y > v * 2.0) ?
                        1.0 :
                        ((2.0 * v * h - v * x - h * y) >= 0.0) ? 0.0 : 1.0)
                    
                    probe.append(element)
                }
            }
            
            let dilate = MPSImageDilate(
                device: device,
                kernelWidth: size,
                kernelHeight: size,
                values: probe)
            
            dilate.edgeMode = .Clamp
            
            self.dilate = dilate
        }
        
        func createBlur()
        {
            blur = MPSImageGaussianBlur(device: device, sigma: Float(inputBlurSigma))
        }
    }
    
#else
    
    class BokehFilter: CIFilter
    {
    }
    
#endif

