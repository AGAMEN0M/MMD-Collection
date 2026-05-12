// ============================================================================
// MMD Custom Node (URP_ASE)
// ----------------------------------------------------------------------------
// Description:
// Collection of custom Universal Render Pipeline lighting utility functions
// used for MMD-style toon shading, lightmap sampling, shadow processing,
// and additional light evaluation inside Amplify Shader Editor.
//
// Provides access to realtime lighting data, baked lightmaps, shadow masks,
// spherical harmonics ambient lighting, and additional light evaluation.
//
// Usage:
// Intended for Amplify Shader Editor custom nodes to reproduce advanced
// MMD-inspired lighting behavior with URP.
//
// Notes:
// - Compatible with Universal Render Pipeline (URP).
// - Supports realtime and baked lighting workflows.
// - Includes directional light, shadow, and lightmap helpers.
// - Supports shadow masks and dynamic lightmaps.
// - Designed for stylized toon and anime shading workflows.
// - ASE version excludes Shader Graph preview handling.
//
// Author: Lucas Gomes Cecchini
// Pseudonym: AGAMENOM
// ============================================================================

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