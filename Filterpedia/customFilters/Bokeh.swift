//
//  Bokeh.swift
//  Filterpedia
//
//  Created by Simon Gladman on 30/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import CoreImage

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

