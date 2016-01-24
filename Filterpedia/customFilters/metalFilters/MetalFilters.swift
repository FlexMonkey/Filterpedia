//
//  MetalFilters.swift
//  Filterpedia
//
//  Created by Simon Gladman on 24/01/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import CoreImage
import Metal
import MetalKit

// MARK: MetalPixellateFilter

class MetalPixellateFilter: MetalFilter
{
    init()
    {
        super.init(functionName: "pixellate")
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    var inputPixelWidth: CGFloat = 50
    var inputPixelHeight: CGFloat = 25
    
    override func setDefaults()
    {
        inputPixelWidth = 50
        inputPixelHeight = 25
    }
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Metal Pixellate",
        
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputPixelWidth": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 50,
                kCIAttributeDisplayName: "Pixel Width",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputPixelHeight": [kCIAttributeIdentity: 1,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 25,
                kCIAttributeDisplayName: "Pixel Height",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
}

// MARK: MetalKuwaharaFilter

    class MetalKuwaharaFilter: MetalFilter
    {
        init()
        {
            super.init(functionName: "kuwahara")
        }
        
        required init?(coder aDecoder: NSCoder)
        {
            fatalError("init(coder:) has not been implemented")
        }
        
        var inputRadius: CGFloat = 15
        
        override func setDefaults()
        {
            inputRadius = 15
        }
        
        override var attributes: [String : AnyObject]
        {
            return [
                kCIAttributeFilterDisplayName: "Metal Kuwahara",
                
                "inputImage": [kCIAttributeIdentity: 0,
                    kCIAttributeClass: "CIImage",
                    kCIAttributeDisplayName: "Image",
                    kCIAttributeType: kCIAttributeTypeImage],
                
                "inputRadius": [kCIAttributeIdentity: 0,
                    kCIAttributeClass: "NSNumber",
                    kCIAttributeDefault: 15,
                    kCIAttributeDisplayName: "Radius",
                    kCIAttributeMin: 0,
                    kCIAttributeSliderMin: 0,
                    kCIAttributeSliderMax: 30,
                    kCIAttributeType: kCIAttributeTypeScalar],
            ]
        }
    }

// MARK: Base class

/// `MetalFilter` is a Core Image filter that uses a Metal compute function as its engine.
/// This version supports a single input image and an arbritrary number of `NSNumber`
/// parameters. Numeric parameters require a properly set `kCIAttributeIdentity` which
/// defines their buffer index into the Metal kernel.
class MetalFilter: CIFilter
{
    let device: MTLDevice = MTLCreateSystemDefaultDevice()!
    let colorSpace = CGColorSpaceCreateDeviceRGB()!
    
    lazy var ciContext: CIContext =
    {
        [unowned self] in
        
        return CIContext(MTLDevice: self.device)
    }()
    
    lazy var commandQueue: MTLCommandQueue =
    {
        [unowned self] in
        
        return self.device.newCommandQueue()
    }()
    
    lazy var defaultLibrary: MTLLibrary =
    {
        [unowned self] in
        
        return self.device.newDefaultLibrary()!
    }()
    
    lazy var pipelineState: MTLComputePipelineState =
    {
        [unowned self] in
        
        let kernelFunction = self.defaultLibrary.newFunctionWithName(self.functionName)!
        
        do
        {
            let pipelineState = try self.device.newComputePipelineStateWithFunction(kernelFunction)
            return pipelineState
        }
        catch
        {
            fatalError("Unable to create pipeline state for kernel function \(self.functionName)")
        }
    }()
    
    let functionName: String
    
    let threadsPerThreadgroup = MTLSize(width:16,
        height:16,
        depth:1)
    
    var threadgroupsPerGrid: MTLSize?
    
    var textureDescriptor: MTLTextureDescriptor?
    var kernelInputTexture: MTLTexture?
    var kernelOutputTexture: MTLTexture?
    
    var inputImage: CIImage?
    {
        didSet
        {
            if let textureDescriptor = textureDescriptor, inputImage = inputImage where
                textureDescriptor.width != Int(inputImage.extent.width)  ||
                textureDescriptor.height != Int(inputImage.extent.height)
            {
                self.textureDescriptor = nil
            }
        }
    }
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage else
        {
            return nil
        }

        return imageFromComputeShader(inputImage)
    }
    
    init(functionName: String)
    {
        self.functionName = functionName
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func imageFromComputeShader(inputImage: CIImage) -> CIImage
    {
        if textureDescriptor == nil
        {
            textureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(.RGBA8Unorm,
                width: Int(inputImage.extent.width),
                height: Int(inputImage.extent.height),
                mipmapped: false)
            
            kernelInputTexture = device.newTextureWithDescriptor(textureDescriptor!)
            kernelOutputTexture = device.newTextureWithDescriptor(textureDescriptor!)
            
            threadgroupsPerGrid = MTLSizeMake(
                textureDescriptor!.width / threadsPerThreadgroup.width,
                textureDescriptor!.height / threadsPerThreadgroup.height, 1)
        }

        let commandBuffer = commandQueue.commandBuffer()

        ciContext.render(inputImage,
            toMTLTexture: kernelInputTexture!,
            commandBuffer: commandBuffer,
            bounds: inputImage.extent,
            colorSpace: colorSpace)
        
        let commandEncoder = commandBuffer.computeCommandEncoder()
        
        commandEncoder.setComputePipelineState(pipelineState)
        
        // populate float buffers using kCIAttributeIdentity as buffer index
        for inputKey in inputKeys where attributes[inputKey]?[kCIAttributeClass] == "NSNumber"
        {
            if let bufferIndex = (attributes[inputKey] as! [String:AnyObject])[kCIAttributeIdentity] as? Int,
                var bufferValue = valueForKey(inputKey) as? Float
            {
                let buffer = device.newBufferWithBytes(&bufferValue,
                    length: sizeof(Float),
                    options: MTLResourceOptions.CPUCacheModeDefaultCache)
                
                commandEncoder.setBuffer(buffer, offset: 0, atIndex: bufferIndex)
            }
        }

        commandEncoder.setTexture(kernelInputTexture, atIndex: 0)
        commandEncoder.setTexture(kernelOutputTexture, atIndex: 1)

        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid!,
            threadsPerThreadgroup: threadsPerThreadgroup)
        
        commandEncoder.endEncoding()
        
        commandBuffer.commit()
        
        return CIImage(MTLTexture: kernelOutputTexture!,
            options: [kCIImageColorSpace: colorSpace])
    }
}

