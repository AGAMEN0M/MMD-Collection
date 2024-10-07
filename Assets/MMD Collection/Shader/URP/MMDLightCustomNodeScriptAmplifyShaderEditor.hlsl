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

void lightmapCol_float(float2 lightmapUV, out float3 Output)
{
	#ifdef LIGHTMAP_ON
		// Ajusta as UVs do lightmap com Tiling e Offset (unity_LightmapST)
        float2 adjustedUV = lightmapUV * unity_LightmapST.xy + unity_LightmapST.zw;

        // Amostra o lightmap usando as UVs ajustadas
        //float4 lightmapCol = UNITY_SAMPLE_TEX2D(unity_Lightmap, adjustedUV);

        // Define a saída como a cor do lightmap
        //Output = lightmapCol.rgb;
		Output = float3(1, 0, 0);
	#else
		Output = float3(1, 1, 1);
	#endif
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
        RGBA = Sub; // Subtract effect.
    }
    else
    {
        RGBA = Base; // Default value if Layer is out of range.
    }
}