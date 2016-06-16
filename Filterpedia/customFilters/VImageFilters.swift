//
//  VImageFilters.swift
//  Filterpedia
//
//  Created by Simon Gladman on 21/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//
// These filters don't work nicely in background threads! Execute in dispatch_get_main_queue()!
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
import Accelerate

// Circular Bokeh

class CircularBokeh: CIFilter, VImageFilter
{
    var inputImage: CIImage?
    var inputBlurRadius: CGFloat = 2
    
    var inputBokehRadius: CGFloat = 15
    {
        didSet
        {
            probe = nil
        }
    }
    
    var inputBokehBias: CGFloat = 0.25
    {
        didSet
        {
            probe = nil
        }
    }
    
    private var probe: [UInt8]?
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Circular Bokeh",
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputBokehRadius": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 15,
                kCIAttributeDisplayName: "Bokeh Radius",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 20,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputBlurRadius": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 2,
                kCIAttributeDisplayName: "Blur Radius",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 10,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputBokehBias": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.25,
                kCIAttributeDisplayName: "Bokeh Bias",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
    
    lazy var ciContext: CIContext =
    {
        return CIContext()
    }()
    
    override var outputImage: CIImage?
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        let imageRef = ciContext.createCGImage(
            inputImage,
            fromRect: inputImage.extent)
        
        var imageBuffer = vImage_Buffer()
        
        vImageBuffer_InitWithCGImage(
            &imageBuffer,
            &format,
            nil,
            imageRef,
            UInt32(kvImageNoFlags))
        
        let pixelBuffer = malloc(CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef))
        
        var outBuffer = vImage_Buffer(
            data: pixelBuffer,
            height: UInt(CGImageGetHeight(imageRef)),
            width: UInt(CGImageGetWidth(imageRef)),
            rowBytes: CGImageGetBytesPerRow(imageRef))
        
        let probeValue = UInt8((1 - inputBokehBias) * 30)
        let radius = Int(inputBokehRadius)
        let diameter = (radius * 2) + 1
        
        if probe == nil
        {
            probe = 0.stride(to: (diameter * diameter), by: 1).map
            {
                let x = Float(($0 % diameter) - radius)
                let y = Float(($0 / diameter) - radius)
                let r = Float(radius)
                let length = hypot(Float(x), Float(y)) / r
                
                if length <= 1
                {
                    let distanceToEdge = 1 - length
                    
                    return UInt8(distanceToEdge * Float(probeValue))
                }
                
                return 255
            }
        }
        
        vImageDilate_ARGB8888(
            &imageBuffer,
            &outBuffer,
            0,
            0,
            probe!,
            UInt(diameter),
            UInt(diameter),
            UInt32(kvImageEdgeExtend + kvImageLeaveAlphaUnchanged))
        
        let outImage = CIImage(fromvImageBuffer: outBuffer)
        
        free(pixelBuffer)
        free(imageBuffer.data)
        
        return outImage!.imageByApplyingFilter(
            "CIGaussianBlur",
            withInputParameters: [kCIInputRadiusKey: inputBlurRadius])
    }
}

// Histogram Equalization

class HistogramEqualization: CIFilter, VImageFilter
{
    var inputImage: CIImage?
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Histogram Equalization",
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage]
        ]
    }
    
    lazy var ciContext: CIContext =
    {
        return CIContext()
    }()
    
    override var outputImage: CIImage?
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        let imageRef = ciContext.createCGImage(
            inputImage,
            fromRect: inputImage.extent)
        
        var imageBuffer = vImage_Buffer()
        
        vImageBuffer_InitWithCGImage(
            &imageBuffer,
            &format,
            nil,
            imageRef,
            UInt32(kvImageNoFlags))
        
        let pixelBuffer = malloc(CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef))
        
        var outBuffer = vImage_Buffer(
            data: pixelBuffer,
            height: UInt(CGImageGetHeight(imageRef)),
            width: UInt(CGImageGetWidth(imageRef)),
            rowBytes: CGImageGetBytesPerRow(imageRef))
        
        
        vImageEqualization_ARGB8888(
            &imageBuffer,
            &outBuffer,
            UInt32(kvImageLeaveAlphaUnchanged))
        
        let outImage = CIImage(fromvImageBuffer: outBuffer)
        
        free(imageBuffer.data)
        free(pixelBuffer)
        
        return outImage!
    }
}

// MARK: EndsInContrastStretch

class EndsInContrastStretch: CIFilter, VImageFilter
{
    var inputImage: CIImage?
    
    var inputPercentLowRed: CGFloat = 0
    var inputPercentLowGreen: CGFloat = 0
    var inputPercentLowBlue: CGFloat = 0
    
    var inputPercentHiRed: CGFloat = 0
    var inputPercentHiGreen: CGFloat = 0
    var inputPercentHiBlue: CGFloat = 0
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Ends In Contrast Stretch",
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputPercentLowRed": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0,
                kCIAttributeDisplayName: "Percent Low Red",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 49,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputPercentLowGreen": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0,
                kCIAttributeDisplayName: "Percent Low Green",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 49,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputPercentLowBlue": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0,
                kCIAttributeDisplayName: "Percent Low Blue",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 49,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputPercentHiRed": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0,
                kCIAttributeDisplayName: "Percent High Red",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 49,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputPercentHiGreen": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0,
                kCIAttributeDisplayName: "Percent High Green",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 49,
                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputPercentHiBlue": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0,
                kCIAttributeDisplayName: "Percent High Blue",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 49,
                kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
    
    lazy var ciContext: CIContext =
    {
        return CIContext()
    }()
    
    override var outputImage: CIImage?
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        let imageRef = ciContext.createCGImage(
            inputImage,
            fromRect: inputImage.extent)
        
        var imageBuffer = vImage_Buffer()
        
        vImageBuffer_InitWithCGImage(
            &imageBuffer,
            &format,
            nil,
            imageRef,
            UInt32(kvImageNoFlags))
        
        let pixelBuffer = malloc(CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef))
        
        var outBuffer = vImage_Buffer(
            data: pixelBuffer,
            height: UInt(CGImageGetHeight(imageRef)),
            width: UInt(CGImageGetWidth(imageRef)),
            rowBytes: CGImageGetBytesPerRow(imageRef))
        
        let low = [0, inputPercentLowRed, inputPercentLowGreen, inputPercentLowBlue].map { return UInt32($0) }
        let hi = [0, inputPercentHiRed, inputPercentHiGreen, inputPercentHiBlue].map { return UInt32($0) }

        vImageEndsInContrastStretch_ARGB8888(
            &imageBuffer,
            &outBuffer,
            low,
            hi,
            UInt32(kvImageLeaveAlphaUnchanged))
        
        let outImage = CIImage(fromvImageBuffer: outBuffer)
        
        free(imageBuffer.data)
        free(pixelBuffer)
        
        return outImage!
    }
}

// MARK: Contrast Stretch

class ContrastStretch: CIFilter, VImageFilter
{
    var inputImage: CIImage?
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Contrast Stretch",
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage]
        ]
    }
    
    lazy var ciContext: CIContext =
    {
        return CIContext()
    }()
    
    override var outputImage: CIImage?
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        let imageRef = ciContext.createCGImage(
            inputImage,
            fromRect: inputImage.extent)
        
        var imageBuffer = vImage_Buffer()
        
        vImageBuffer_InitWithCGImage(
            &imageBuffer,
            &format,
            nil,
            imageRef,
            UInt32(kvImageNoFlags))

        let pixelBuffer = malloc(CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef))
        
        var outBuffer = vImage_Buffer(
            data: pixelBuffer,
            height: UInt(CGImageGetHeight(imageRef)),
            width: UInt(CGImageGetWidth(imageRef)),
            rowBytes: CGImageGetBytesPerRow(imageRef))
        
        vImageContrastStretch_ARGB8888(
            &imageBuffer,
            &outBuffer,
            UInt32(kvImageLeaveAlphaUnchanged))
        
        let outImage = CIImage(fromvImageBuffer: outBuffer)
        
        free(imageBuffer.data)
        free(pixelBuffer)
        
        return outImage!
    }
}

// MARK: HistogramSpecification

class HistogramSpecification: CIFilter, VImageFilter
{
    var inputImage: CIImage?
    var inputHistogramSource: CIImage?
    
    override var attributes: [String : AnyObject]
    {
        return [
            kCIAttributeFilterDisplayName: "Histogram Specification",
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            "inputHistogramSource": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Histogram Source",
                kCIAttributeType: kCIAttributeTypeImage],
            ]
    }
    
    lazy var ciContext: CIContext =
    {
        return CIContext()
    }()
    
    override var outputImage: CIImage?
    {
        guard let inputImage = inputImage,
            inputHistogramSource = inputHistogramSource else
        {
            return nil
        }
        
        let imageRef = ciContext.createCGImage(
            inputImage,
            fromRect: inputImage.extent)
        
        var imageBuffer = vImageBufferFromCIImage(inputImage, ciContext: ciContext)
        var histogramSourceBuffer = vImageBufferFromCIImage(inputHistogramSource, ciContext: ciContext)
        
        let alpha = [UInt](count: 256, repeatedValue: 0)
        let red = [UInt](count: 256, repeatedValue: 0)
        let green = [UInt](count: 256, repeatedValue: 0)
        let blue = [UInt](count: 256, repeatedValue: 0)
        
        let alphaMutablePointer = UnsafeMutablePointer<vImagePixelCount>(alpha)
        let redMutablePointer = UnsafeMutablePointer<vImagePixelCount>(red)
        let greenMutablePointer = UnsafeMutablePointer<vImagePixelCount>(green)
        let blueMutablePointer = UnsafeMutablePointer<vImagePixelCount>(blue)
        
        let argb = [alphaMutablePointer, redMutablePointer, greenMutablePointer, blueMutablePointer]
        
        let histogram = UnsafeMutablePointer<UnsafeMutablePointer<vImagePixelCount>>(argb)
        
        vImageHistogramCalculation_ARGB8888(&histogramSourceBuffer, histogram, UInt32(kvImageLeaveAlphaUnchanged))
        
        let pixelBuffer = malloc(CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef))
        
        var outBuffer = vImage_Buffer(
            data: pixelBuffer,
            height: UInt(CGImageGetHeight(imageRef)),
            width: UInt(CGImageGetWidth(imageRef)),
            rowBytes: CGImageGetBytesPerRow(imageRef))

        let alphaPointer = UnsafePointer<vImagePixelCount>(alpha)
        let redPointer = UnsafePointer<vImagePixelCount>(red)
        let greenPointer = UnsafePointer<vImagePixelCount>(green)
        let bluePointer = UnsafePointer<vImagePixelCount>(blue)
        
        let argbMutablePointer = UnsafeMutablePointer<UnsafePointer<vImagePixelCount>>([alphaPointer, redPointer, greenPointer, bluePointer])
        
        vImageHistogramSpecification_ARGB8888(&imageBuffer, &outBuffer, argbMutablePointer, UInt32(kvImageLeaveAlphaUnchanged))
        
        let outImage = CIImage(fromvImageBuffer: outBuffer)
        
        free(imageBuffer.data)
        free(histogramSourceBuffer.data)
        free(pixelBuffer)

        return outImage!
    }
}

// MARK Support

protocol VImageFilter {
}

// The _ARGB8888 version of the vImage functions are used, so bitmapInfo should keep alpha channel before rgb channels (ARGB)
let bitmapInfo: CGBitmapInfo = CGBitmapInfo(
    rawValue: CGImageAlphaInfo.First.rawValue)

var format = vImage_CGImageFormat(
    bitsPerComponent: 8,
    bitsPerPixel: 32,
    colorSpace: nil,
    bitmapInfo: bitmapInfo,
    version: 0,
    decode: nil,
    renderingIntent: .RenderingIntentDefault)

func vImageBufferFromCIImage(ciImage: CIImage, ciContext: CIContext) -> vImage_Buffer
{
    let imageRef = ciContext.createCGImage(
        ciImage,
        fromRect: ciImage.extent)
    
    var buffer = vImage_Buffer()
    
    vImageBuffer_InitWithCGImage(
        &buffer,
        &format,
        nil,
        imageRef,
        UInt32(kvImageNoFlags))
    
    return buffer
}

extension CIImage
{
    convenience init?(fromvImageBuffer: vImage_Buffer)
    {
        var mutableBuffer = fromvImageBuffer
        var error = vImage_Error()
        
        let cgImage = vImageCreateCGImageFromBuffer(
            &mutableBuffer,
            &format,
            nil,
            nil,
            UInt32(kvImageNoFlags),
            &error)
        
        self.init(CGImage: cgImage.takeRetainedValue())
    }
}
