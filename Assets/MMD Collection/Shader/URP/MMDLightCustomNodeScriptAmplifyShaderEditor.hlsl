// Function to compute spherical harmonics lighting based on the normal direction.
void vLight_float(float3 normal, out float3 Output)
{
    Output = SampleSH(normal); // Sample the spherical harmonics with the given normal to get the lighting.
}

// Function to calculate shadow attenuation at a given world position.
void shadowAtten_float(float3 worldPos, out float OutputShadowAtten)
{
    float4 shadowCoord = TransformWorldToShadowCoord(worldPos); // Transform world position to shadow coordinates.
    Light mainLight = GetMainLight(shadowCoord); // Get the main light information based on shadow coordinates.
    OutputShadowAtten = mainLight.shadowAttenuation; // Output the shadow attenuation from the main light.
}

// Function to calculate the light color at a given world position.
void lightColor_float(float3 worldPos, out float3 OutputColor)
{
    float4 shadowCoord = TransformWorldToShadowCoord(worldPos); // Transform world position to shadow coordinates.
    Light mainLight = GetMainLight(shadowCoord); // Get the main light information based on shadow coordinates.
    OutputColor = mainLight.color; // Output the color of the main light.
}

// Function to calculate the contribution of additional lights at a given world position and normal.
void additionalLights_float(float3 WorldPosition, float3 WorldNormal, out float3 Output)
{
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
}