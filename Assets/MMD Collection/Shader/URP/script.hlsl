#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

#if defined(SHADERGRAPH_PREVIEW)
#else
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

#if ASE_SRP_VERSION >=140010
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#endif

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
#endif

void lightColor_float(float3 worldPos, out float OutputShadowAtten, out float OutputColor)
{
    #if defined(SHADERGRAPH_PREVIEW)
        OutputColor = 1;
        OutputShadowAtten = 1;
    #else
        float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
        Light mainLight = GetMainLight(shadowCoord);
        OutputShadowAtten = mainLight.shadowAttenuation;
        OutputColor = mainLight.color;
    #endif
}

void additionalLights_float(float3 WorldPosition, float3 WorldNormal, out float3 Output)
{
    #if defined(SHADERGRAPH_PREVIEW)
        Output = 1;
        
    #else
    float3 diffuseColor = 0;
    WorldNormal = normalize(WorldNormal);
    int pixelLightCount = GetAdditionalLightsCount();

    for (int i = 0; i < pixelLightCount; i++)
    {
        Light light = GetAdditionalLight(i, WorldPosition);
        half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
        diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
    }

    Output = diffuseColor;
    #endif
}
#endif