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

// MARK: Perlin Noise

class MetalPerlinNoise: MetalFilter
{
    init()
    {
        super.init(functionName: "perlin")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    var inputReciprocalScale = CGFloat(50)
    var inputOctaves = CGFloat(2)
    var inputPersistence = CGFloat(0.5)
    
    var inputColor0 = CIColor(red: 0.5, green: 0.25, blue: 0)
    var inputColor1 = CIColor(red: 0, green: 0, blue: 0.15)
    
    var inputZ = CGFloat(0)
    
    override func setDefaults()
    {
        inputReciprocalScale = 50
        inputOctaves = 2
        inputPersistence = 0.5
        
        inputColor0 = CIColor(red: 0.5, green: 0.25, blue: 0)
        inputColor1 = CIColor(red: 0, green: 0, blue: 0.15)
    }
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Metal Perlin Noise",
            
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputReciprocalScale": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 50,
                kCIAttributeDisplayName: "Scale",
                kCIAttributeMin: 10,
                kCIAttributeSliderMin: 10,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputOctaves": [kCIAttributeIdentity: 1,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 2,
                kCIAttributeDisplayName: "Octaves",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 16,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputPersistence": [kCIAttributeIdentity: 2,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.5,
                kCIAttributeDisplayName: "Persistence",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputColor0": [kCIAttributeIdentity: 3,
                kCIAttributeClass: "CIColor",
                kCIAttributeDefault: CIColor(red: 0.5, green: 0.25, blue: 0),
                kCIAttributeDisplayName: "Color One",
                kCIAttributeType: kCIAttributeTypeColor],
            
            "inputColor1": [kCIAttributeIdentity: 4,
                kCIAttributeClass: "CIColor",
                kCIAttributeDefault: CIColor(red: 0, green: 0, blue: 0.15),
                kCIAttributeDisplayName: "Color Two",
                kCIAttributeType: kCIAttributeTypeColor],
            
            "inputZ": [kCIAttributeIdentity: 5,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 1,
                kCIAttributeDisplayName: "Z Position",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1024,
                kCIAttributeType: kCIAttributeTypeScalar],
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
///
/// Note that `MetalFilter` generators (e.g. `MetalPerlinNoise`) require an input image which
/// is used to define the extent of the final output
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
        
        // populate color buffers using kCIAttributeIdentity as buffer index
        for inputKey in inputKeys where attributes[inputKey]?[kCIAttributeClass] == "CIColor"
        {
            if let bufferIndex = (attributes[inputKey] as! [String:AnyObject])[kCIAttributeIdentity] as? Int,
                bufferValue = valueForKey(inputKey) as? CIColor
            {
                var color = float4(Float(bufferValue.red),
                    Float(bufferValue.green),
                    Float(bufferValue.blue),
                    Float(bufferValue.alpha))
                
                let buffer = device.newBufferWithBytes(&color,
                    length: sizeof(float4),
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

