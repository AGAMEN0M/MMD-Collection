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
            // Sample the shadow mask to determine shadow coverage at this fragment's position.
            float4 shadowMask = SAMPLE_SHADOWMASK(dynamicLightmapUV);
        
            // Get the additional light based on its index, world position, and the shadow mask.
            Light light = GetAdditionalLight(i, WorldPosition, shadowMask);
        
            // Calculate the attenuated light color considering distance and shadow attenuation.
            half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
        
            // Add the Lambertian lighting contribution of the current light to the diffuse color.
            diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
        }
    
        Output = diffuseColor; // Output the total diffuse color from all additional lights.
    #endif
}

// Function to sample the lightmap color at the given UV coordinates.
void lightmapCol_float(float2 lightmapUV, out float3 Output)
{
    #if defined(SHADERGRAPH_PREVIEW)
        Output = 1; // Use default lightmap color for shader graph preview.
    #else
        float4 lightmapCol = 1; // Initialize lightmap color to default white (no lightmap influence).
    
        #ifdef LIGHTMAP_ON
            // Adjust the lightmap UVs with Tiling and Offset (using unity_LightmapST)
            float2 sizeLightmapUV = lightmapUV * unity_LightmapST.xy + unity_LightmapST.zw;
    
            // Sample the lightmap texture using the provided UV coordinates if lightmaps are enabled.
            lightmapCol = 30 * SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, sizeLightmapUV );
        #endif
    
        Output = lightmapCol.rgb; // Output the RGB component of the sampled or default lightmap color.
    #endif
}

#endif // CUSTOM_LIGHTING_INCLUDED.

// Function to select a UV layer based on the given layer index.
void uvLayer_float(float Layer, float2 uv0, float2 uv1, float2 uv2, float2 uv3, out float2 UV)
{
    if (Layer == 0)
    {
        UV = uv0; // UV0 - Standard UV channel.
    }
    else if (Layer == 1)
    {
        UV = uv1; // UV1 - Second UV channel.
    }
    else if (Layer == 2)
    {
        UV = uv2; // UV2 - Third UV channel.
    }
    else if (Layer == 3)
    {
        UV = uv3; // UV3 - Fourth UV channel.
    }
    else
    {
        UV = uv0; // Default value if Layer is out of range.
    }
}

// Function to control effects based on the given layer index.
void effectsControl_float(float Layer, float3 Base, float3 Add, float3 Multi, float3 Sub, out float3 RGB)
{
    if (Layer == 0)
    {
        RGB = Base; // Base effect.
    }
    else if (Layer == 1)
    {
        RGB = Add; // Add effect.
    }
    else if (Layer == 2)
    {
        RGB = Multi; // Multiply effect.
    }
    else if (Layer == 3)
    {
        RGB = Sub; // Subtract effect.
    }
    else
    {
        RGB = Base; // Default value if Layer is out of range.
    }
}