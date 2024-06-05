#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

#if defined(SHADERGRAPH_PREVIEW)
#else
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
#pragma multi_compile_fragment _ _SHADOWS_SOFT
#pragma multi_compile _ SHADOWS_SHADOWMASK
#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
#pragma multi_compile _ LIGHTMAP_ON
#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
#endif

void lightColor_float(float3 worldPos, out float3 OutputColor, out float OutputShadowAtten, out float3 Direction)
{
    #if defined(SHADERGRAPH_PREVIEW)
        OutputColor = 1;
        OutputShadowAtten = 1;
        Direction = 1;
    #else
        float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
        Light mainLight = GetMainLight(shadowCoord);
        Direction = mainLight.direction;
        OutputColor = mainLight.color;
        OutputShadowAtten = mainLight.shadowAttenuation;
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