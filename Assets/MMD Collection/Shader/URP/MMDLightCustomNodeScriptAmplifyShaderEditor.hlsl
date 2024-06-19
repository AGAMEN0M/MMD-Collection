void vLight_float(float3 normal, out float3 Output)
{
    Output = SampleSH(normal);
}

void shadowAtten_float(float3 worldPos, out float OutputShadowAtten)
{
    float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
    Light mainLight = GetMainLight(shadowCoord);
    OutputShadowAtten = mainLight.shadowAttenuation;
}

void lightColor_float(float3 worldPos, out float3 OutputColor)
{
    float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
    Light mainLight = GetMainLight(shadowCoord);
    OutputColor = mainLight.color;
}

void additionalLights_float(float3 WorldPosition, float3 WorldNormal, out float3 Output)
{
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
}

void CalculateFogDensity_float(float3 objectPosition, out float fogDensity)
{
    float3 diff = objectPosition - _WorldSpaceCameraPos;
    float distSquared = dot(diff, diff);
    float maxDistSquared = 2500.0;
    fogDensity = saturate(distSquared / maxDistSquared);
}