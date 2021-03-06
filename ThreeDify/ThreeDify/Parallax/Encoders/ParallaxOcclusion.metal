//
// 3Dify App
//
// Project website: https://github.com/3dify-app
//
// Authors:
// - Philipp Matthes 2020, Contact: mail@philippmatth.es
//
// Copyright notice: All rights reserved by the authors given above. Do not
// remove or change this copyright notice without confirmation of the authors.
//

#include <metal_stdlib>
using namespace metal;
#include "TextureMappingVertex.h"


float2 parallaxOcclusionMapping(
    float2 offset,
    float2 texCoords,
    texture2d<half, access::sample> depthTexture,
    float minLayers,
    float maxLayers,
    float pivot,
    float heightScale
)
{
    constexpr sampler sampler2d(coord::normalized, filter::linear, address::repeat);

    const float numLayers = mix(maxLayers, minLayers, abs(dot(float3(0.0, 0.0, 1.0), float3(offset, -1.0))));
    // calculate the size of each layer
    const float layerDepth = 1.0 / numLayers;
    
    // depth of current layer
    float currentLayerDepth = 0.0;
    // the amount to shift the texture coordinates per layer (from vector P)
    const float2 P = offset * heightScale;
    const float2 deltaTexCoords = P / numLayers;
    
    // get initial values
    float2 currentTexCoords = texCoords + pivot * offset;
    float currentDepthMapValue = 1.0 - depthTexture.sample(sampler2d, currentTexCoords).r;
      
    while(currentLayerDepth < currentDepthMapValue)
    {
        // shift texture coordinates along direction of P
        currentTexCoords -= deltaTexCoords;
        // get depthmap value at current texture coordinates
        currentDepthMapValue = 1.0 - depthTexture.sample(sampler2d, currentTexCoords).r;
        // get depth of next layer
        currentLayerDepth += layerDepth;
    }

    // get texture coordinates before collision (reverse operations)
    const float2 prevTexCoords = currentTexCoords + deltaTexCoords;

    // get depth after and before collision for linear interpolation
    const float afterDepth = currentDepthMapValue - currentLayerDepth;
    const float beforeDepth = 1.0 - depthTexture.sample(sampler2d, prevTexCoords).r - currentLayerDepth + layerDepth;
     
    // interpolation of texture coordinates
    const float weight = afterDepth / (afterDepth - beforeDepth);
    const float2 finalTexCoords = prevTexCoords * weight + currentTexCoords * (1.0 - weight);

    return finalTexCoords;
}

float2 parallaxOcclusionMapping(
    float2 offset,
    float2 texCoords,
    float pivot,
    texture2d<half, access::sample> depthTexture
)
{
    // number of depth layers
    const float minLayers = 32.0;
    const float maxLayers = 128.0;
    
    // the scale of depth
    const float heightScale = 1.0;
    
    return parallaxOcclusionMapping(offset, texCoords, depthTexture, minLayers, maxLayers, pivot, heightScale);
}

struct ParallaxPassOutput {
    half4 diffuse [[color(0)]];
    half4 depth [[color(1)]];
};

typedef struct {
    float offsetX;
    float offsetY;
    float focalPoint;
} ParallaxOcclusionUniforms;

fragment ParallaxPassOutput parallax_occlusion(
    TextureMappingVertex vert [[stage_in]],
    texture2d<half> diffuseTexture [[texture(0)]],
    texture2d<half> depthTexture [[texture(1)]],
    constant ParallaxOcclusionUniforms *uniforms [[buffer(0)]]
) {
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    
    float2 parallaxUv = parallaxOcclusionMapping(
        float2(uniforms->offsetX, uniforms->offsetY),
        vert.uv,
        uniforms->focalPoint,
        depthTexture
    );
    ParallaxPassOutput output;
    
    output.diffuse = diffuseTexture.sample(s, parallaxUv);
    output.depth = half4(half3(depthTexture.sample(s, parallaxUv).r), 1.0);
        
    return output;
}
