#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

// Calculates the direction of light in world space.
void WorldSpaceLightDir_float(float3 worldPos, out float3 Direction)
{
    #if defined(SHADERGRAPH_PREVIEW)
        Direction = 1; // Default direction for viewing in the Shader Graph.
    #else
        float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
        Light mainLight = GetMainLight(shadowCoord);
        Direction = mainLight.direction; // Actual direction of the main light.
    #endif
}

// Calculates shadow attenuation at world position.
void shadowAtten_float(float3 worldPos, out float OutputShadowAtten)
{
    #if defined(SHADERGRAPH_PREVIEW)
        OutputShadowAtten = 1; // Default shadow easing for preview.
    #else
        float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
        Light mainLight = GetMainLight(shadowCoord);    
        OutputShadowAtten = mainLight.shadowAttenuation; // True shadow attenuation.
    #endif
}

// Calculates the color of light at the world position.
void lightColor_float(float3 worldPos, out float3 OutputColor)
{
    #if defined(SHADERGRAPH_PREVIEW)
        OutputColor = 1;  // Default color for preview.
    #else
        float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
        Light mainLight = GetMainLight(shadowCoord);
        OutputColor = mainLight.color; // Actual color of the main light.
    #endif
}

// Calculates the contribution of additional lights to the world position.
void additionalLights_float(float3 WorldPosition, float3 WorldNormal, out float3 Output)
{
    #if defined(SHADERGRAPH_PREVIEW)
        Output = 1; // Standard contribution for viewing.
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
    
        Output = diffuseColor; // Real diffuse contribution from additional lights.
    #endif
}
#endif // CUSTOM_LIGHTING_INCLUDED.