#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

// Function to calculate the direction of the main light in world space.
void WorldSpaceLightDir_float(float3 worldPos, out float3 Direction)
{
    #if defined(SHADERGRAPH_PREVIEW)
        Direction = 1; // Use a default light direction for shader graph preview.
    #else
        float4 shadowCoord = TransformWorldToShadowCoord(worldPos); // Transform world position to shadow coordinates.
        Light mainLight = GetMainLight(shadowCoord); // Get the main light information based on shadow coordinates.
        Direction = mainLight.direction; // Output the direction of the main light.
    #endif
}

// Function to calculate shadow attenuation at a given world position.
void shadowAtten_float(float3 worldPos, out float OutputShadowAtten)
{
    #if defined(SHADERGRAPH_PREVIEW)
        OutputShadowAtten = 1; // Use default shadow attenuation for shader graph preview.
    #else
        float4 shadowCoord = TransformWorldToShadowCoord(worldPos); // Transform world position to shadow coordinates.
        Light mainLight = GetMainLight(shadowCoord); // Get the main light information based on shadow coordinates.
        OutputShadowAtten = mainLight.shadowAttenuation; // Output the shadow attenuation from the main light.
    #endif
}

// Function to calculate the color of the main light at a given world position.
void lightColor_float(float3 worldPos, out float3 OutputColor)
{
    #if defined(SHADERGRAPH_PREVIEW)
        OutputColor = 1; // Use default light color for shader graph preview.
    #else
        float4 shadowCoord = TransformWorldToShadowCoord(worldPos); // Transform world position to shadow coordinates.
        Light mainLight = GetMainLight(shadowCoord); // Get the main light information based on shadow coordinates.
        OutputColor = mainLight.color; // Output the color of the main light.
    #endif
}

// Function to calculate the contribution of additional lights at a given world position and normal.
void additionalLights_float(float3 WorldPosition, float3 WorldNormal, out float3 Output)
{
    #if defined(SHADERGRAPH_PREVIEW)
        Output = 1; // Use default light contribution for shader graph preview.
    #else
        float3 diffuseColor = 0; // Initialize the diffuse color to zero.
        WorldNormal = normalize(WorldNormal); // Normalize the world normal.
        int pixelLightCount = GetAdditionalLightsCount(); // Get the count of additional pixel lights.

        // Loop through each additional light to compute its contribution.
        for (int i = 0; i < pixelLightCount; i++)
        {
            // Get the additional light based on its index and world position.
            Light light = GetAdditionalLight(i, WorldPosition);
        
            // Calculate the attenuated light color considering distance and shadow attenuation.
            half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
        
            // Add the Lambertian lighting contribution of the current light to the diffuse color.
            diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
        }
    
        Output = diffuseColor; // Output the total diffuse color from all additional lights.
    #endif
}
#endif // CUSTOM_LIGHTING_INCLUDED.