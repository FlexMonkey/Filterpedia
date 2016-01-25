//
//  Shaders.metal
//  Filterpedia
//
//  Created by Simon Gladman on 24/01/2016.
//
//  Copyright © 2016 Simon Gladman. All rights reserved.
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//    THE SOFTWARE.


#include <metal_stdlib>
using namespace metal;

// MARK: Pixellate

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

// MARK: Perlin Noise

// GLSL textureless classic 2D noise "cnoise",
// Author:  Stefan Gustavson (stefan.gustavson@liu.se)
// Version: 2011-08-22
//
// Copyright (c) 2011 Stefan Gustavson. All rights reserved.
// Distributed under the MIT license.
// https://github.com/ashima/webgl-noise
//
// Perlin Noise octaves approach taken from http://flafla2.github.io/2014/08/09/perlinnoise.html

float4 mod289(float4 x);

float4 mod289(float4 x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float4 permute(float4 x);

float4 permute(float4 x)
{
    return mod289(((x*34.0)+1.0)*x);
}

float4 taylorInvSqrt(float4 r);

float4 taylorInvSqrt(float4 r)
{
    return 1.79284291400159 - 0.85373472095314 * r;
}

float2 fade(float2 t);

float2 fade(float2 t)
{
    return t*t*t*(t*(t*6.0-15.0)+10.0);
}

float cnoise(float2 P);

float cnoise(float2 P)
{
    float4 Pi = floor(P.xyxy) + float4(0.0, 0.0, 1.0, 1.0);
    float4 Pf = fract(P.xyxy) - float4(0.0, 0.0, 1.0, 1.0);
    Pi = mod289(Pi); 
    float4 ix = Pi.xzxz;
    float4 iy = Pi.yyww;
    float4 fx = Pf.xzxz;
    float4 fy = Pf.yyww;
    
    float4 i = permute(permute(ix) + iy);
    
    float4 gx = fract(i * (1.0 / 41.0)) * 2.0 - 1.0 ;
    float4 gy = abs(gx) - 0.5 ;
    float4 tx = floor(gx + 0.5);
    gx = gx - tx;
    
    float2 g00 = float2(gx.x,gy.x);
    float2 g10 = float2(gx.y,gy.y);
    float2 g01 = float2(gx.z,gy.z);
    float2 g11 = float2(gx.w,gy.w);
    
    float4 norm = taylorInvSqrt(float4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
    g00 *= norm.x;
    g01 *= norm.y;
    g10 *= norm.z;
    g11 *= norm.w;
    
    float n00 = dot(g00, float2(fx.x, fy.x));
    float n10 = dot(g10, float2(fx.y, fy.y));
    float n01 = dot(g01, float2(fx.z, fy.z));
    float n11 = dot(g11, float2(fx.w, fy.w));
    
    float2 fade_xy = fade(Pf.xy);
    float2 n_x = mix(float2(n00, n01), float2(n10, n11), fade_xy.x);
    float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
    return 2.3 * n_xy;
}

kernel void perlin(
                    texture2d<float, access::read> inTexture [[texture(0)]],
                    texture2d<float, access::write> outTexture [[texture(1)]],
             
                    constant float &reciprocalScale [[ buffer(0) ]],
                    constant float &oct [[ buffer(1) ]],
                    constant float &persistence [[ buffer(2) ]],
                   
                    constant float4 &colorStart [[ buffer(3) ]],
                    constant float4 &colorFinish [[ buffer(4) ]],
                   
                    uint2 gid [[thread_position_in_grid]])
{
    float scale = float(1.0 / reciprocalScale);
    int octaves = int(oct);
    
    float total = 0;
    float frequency = 1;
    float amplitude = 1;
    float maxValue = 0;
    
    for(int i=0; i < octaves; i++)
    {
        total += cnoise(frequency * scale * float2(float(gid.x), float(gid.y))) * amplitude;
        
        maxValue += amplitude;
        
        amplitude *= persistence;
        frequency *= 2.0;
    }
 
    float4 colorDiff = colorFinish - colorStart;
    float4 color = colorStart + colorDiff * (total/maxValue);
    
    outTexture.write(color, gid);
}

// MARK: Kuwahara Filter

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
