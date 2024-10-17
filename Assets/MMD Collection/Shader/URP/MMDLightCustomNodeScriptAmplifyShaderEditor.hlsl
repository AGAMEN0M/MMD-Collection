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

// Function to sample the lightmap color at the given UV coordinates.
void lightmapCol_float(float2 lightmapUV, out float3 Output)
{
    float4 lightmapCol = 1; // Initialize lightmap color to default white (no lightmap influence).
    
    // Sample the lightmap texture using the provided UV coordinates if lightmaps are enabled.
    #ifdef LIGHTMAP_ON
        lightmapCol = SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, lightmapUV );
	#endif
    
    Output = lightmapCol.rgb; // Output the RGB component of the sampled or default lightmap color.
}

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
void effectsControl_float(float Layer, float4 Base, float4 Add, float4 Multi, float4 Sub, out float4 RGBA)
{
    if (Layer == 0)
    {
        RGBA = Base; // Base effect.
    }
    else if (Layer == 1)
    {
        RGBA = Add; // Add effect.
    }
    else if (Layer == 2)
    {
        RGBA = Multi; // Multiply effect.
    }
    else if (Layer == 3)
    {
        RGBA = Sub; // Sub-Texture effect.
    }
    else
    {
        RGBA = Base; // Default value if Layer is out of range.
    }
}