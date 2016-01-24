//
//  Shaders.metal
//  Filterpedia
//
//  Created by Simon Gladman on 24/01/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void pixellate(
                      texture2d<float, access::read> inTexture [[texture(0)]],
                      texture2d<float, access::write> outTexture [[texture(1)]],
                      
                      constant float &pixelWidth [[ buffer(0) ]],
                      constant float &pixelHeight [[ buffer(1) ]],
                      
                      uint2 gid [[thread_position_in_grid]])
{
    uint width = uint(pixelWidth);
    uint height = uint(pixelHeight);
    
    const uint2 pixellatedGid = uint2((gid.x / width) * width, (gid.y / height) * height);
    const float4 colorAtPixel = inTexture.read(pixellatedGid);
    outTexture.write(colorAtPixel, gid);
}

// -------------

kernel void kuwahara(
                     texture2d<float, access::read> inTexture [[texture(0)]],
                     texture2d<float, access::write> outTexture [[texture(1)]],
                     
                     constant float &r [[ buffer(0) ]],
                     
                     uint2 gid [[thread_position_in_grid]])
{
    
    int radius = int(r);
    float n = float((radius + 1) * (radius + 1));
    
    float3 means[4];
    float3 stdDevs[4];
    
    for (int i = 0; i < 4; i++)
    {
        means[i] = float3(0.0);
        stdDevs[i] = float3(0.0);
    }
    
    for (int x = -radius; x <= radius; x++)
    {
        for (int y = -radius; y <= radius; y++)
        {
            float3 color = inTexture.read(uint2(gid.x + x, gid.y + y)).rgb;
            
            float3 colorA = float3(float(x <= 0 && y <= 0)) * color;
            means[0] += colorA;
            stdDevs[0] += colorA * colorA;
            
            float3 colorB = float3(float(x >= 0 && y <= 0)) * color;
            means[1] +=  colorB;
            stdDevs[1] += colorB * colorB;
            
            float3 colorC = float3(float(x <= 0 && y >= 0)) * color;
            means[2] += colorC;
            stdDevs[2] += colorC * colorC;
            
            float3 colorD = float3(float(x >= 0 && y >= 0)) * color;
            means[3] += colorD;
            stdDevs[3] += colorD * colorD;
        }
    }
    
    float minSigma2 = 1e+2;
    float3 returnColor = float3(0.0);
    
    for (int j = 0; j < 4; j++)
    {
        means[j] /= n;
        stdDevs[j] = abs(stdDevs[j] / n - means[j] * means[j]);
        
        float sigma2 = stdDevs[j].r + stdDevs[j].g + stdDevs[j].b;
        
        returnColor = (sigma2 < minSigma2) ? means[j] : returnColor;
        minSigma2 = (sigma2 < minSigma2) ? sigma2 : minSigma2;
    }
    
    outTexture.write(float4(returnColor, 1), gid);
}
