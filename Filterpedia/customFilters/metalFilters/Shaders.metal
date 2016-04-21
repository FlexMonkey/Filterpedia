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

float3 mod289(float3 x);

float3 mod289(float3 x)
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

float3 fade(float3 t);

float3 fade(float3 t)
{
    return t*t*t*(t*(t*6.0-15.0)+10.0);
}

float cnoise(float3 P);

float cnoise(float3 P)
{
    float3 Pi0 = floor(P); // Integer part for indexing
    float3 Pi1 = Pi0 + float3(1.0); // Integer part + 1
    Pi0 = mod289(Pi0);
    Pi1 = mod289(Pi1);
    float3 Pf0 = fract(P); // Fractional part for interpolation
    float3 Pf1 = Pf0 - float3(1.0); // Fractional part - 1.0
    float4 ix = float4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
    float4 iy = float4(Pi0.yy, Pi1.yy);
    float4 iz0 = Pi0.zzzz;
    float4 iz1 = Pi1.zzzz;
    
    float4 ixy = permute(permute(ix) + iy);
    float4 ixy0 = permute(ixy + iz0);
    float4 ixy1 = permute(ixy + iz1);
    
    float4 gx0 = ixy0 * (1.0 / 7.0);
    float4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
    gx0 = fract(gx0);
    float4 gz0 = float4(0.5) - abs(gx0) - abs(gy0);
    float4 sz0 = step(gz0, float4(0.0));
    gx0 -= sz0 * (step(0.0, gx0) - 0.5);
    gy0 -= sz0 * (step(0.0, gy0) - 0.5);
    
    float4 gx1 = ixy1 * (1.0 / 7.0);
    float4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
    gx1 = fract(gx1);
    float4 gz1 = float4(0.5) - abs(gx1) - abs(gy1);
    float4 sz1 = step(gz1, float4(0.0));
    gx1 -= sz1 * (step(0.0, gx1) - 0.5);
    gy1 -= sz1 * (step(0.0, gy1) - 0.5);
    
    float3 g000 = float3(gx0.x,gy0.x,gz0.x);
    float3 g100 = float3(gx0.y,gy0.y,gz0.y);
    float3 g010 = float3(gx0.z,gy0.z,gz0.z);
    float3 g110 = float3(gx0.w,gy0.w,gz0.w);
    float3 g001 = float3(gx1.x,gy1.x,gz1.x);
    float3 g101 = float3(gx1.y,gy1.y,gz1.y);
    float3 g011 = float3(gx1.z,gy1.z,gz1.z);
    float3 g111 = float3(gx1.w,gy1.w,gz1.w);
    
    float4 norm0 = taylorInvSqrt(float4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
    g000 *= norm0.x;
    g010 *= norm0.y;
    g100 *= norm0.z;
    g110 *= norm0.w;
    float4 norm1 = taylorInvSqrt(float4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
    g001 *= norm1.x;
    g011 *= norm1.y;
    g101 *= norm1.z;
    g111 *= norm1.w;
    
    float n000 = dot(g000, Pf0);
    float n100 = dot(g100, float3(Pf1.x, Pf0.yz));
    float n010 = dot(g010, float3(Pf0.x, Pf1.y, Pf0.z));
    float n110 = dot(g110, float3(Pf1.xy, Pf0.z));
    float n001 = dot(g001, float3(Pf0.xy, Pf1.z));
    float n101 = dot(g101, float3(Pf1.x, Pf0.y, Pf1.z));
    float n011 = dot(g011, float3(Pf0.x, Pf1.yz));
    float n111 = dot(g111, Pf1);
    
    float3 fade_xyz = fade(Pf0);
    float4 n_z = mix(float4(n000, n100, n010, n110), float4(n001, n101, n011, n111), fade_xyz.z);
    float2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
    float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
    return 2.2 * n_xyz;
}

kernel void perlin(
                    texture2d<float, access::write> outTexture [[texture(0)]],
             
                    constant float &reciprocalScale [[ buffer(0) ]],
                    constant float &oct [[ buffer(1) ]],
                    constant float &persistence [[ buffer(2) ]],
                   
                    constant float4 &colorStart [[ buffer(3) ]],
                    constant float4 &colorFinish [[ buffer(4) ]],
                   
                    constant float &z [[ buffer(5) ]],
                   
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
        total += cnoise(frequency * scale * float3(float(gid.x), float(gid.y), z)) * amplitude;
        
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
