// ============================================================================
// MMD Effects Custom Node (URP SG)
// ----------------------------------------------------------------------------
// Description:
// Retrieves the main directional light vector used for toon shading and
// lighting calculations in Universal Render Pipeline Shader Graph.
//
// Supports both realtime directional lighting and directional lightmap data,
// automatically selecting the correct source depending on the current shader
// stage and lightmapping configuration.
//
// Usage:
// Use this node to obtain the primary light direction for custom toon,
// rim light, shadow ramp, or stylized lighting calculations inside
// Shader Graph custom function nodes.
//
// Notes:
// - Supports Shader Graph preview mode.
// - Supports directional lightmaps.
// - Compatible with DOTS instancing lightmap sampling.
// - Outputs light direction in world space.
// - Lightmap direction vectors are decoded from [0,1] to [-1,1] range.
// - In preview mode, a fixed upward direction is used for stable previews.
//
// Author: Lucas Gomes Cecchini
// Pseudonym: AGAMENOM
// ============================================================================

// Gets the key light direction considering different build stages and lightmap settings.
void GetMainLightDirection_float(float2 lightmapUV, out float3 Direction)
{
#if defined(SHADERGRAPH_PREVIEW)
    Direction = float3(0.0, 1.0, 0.0); // In Shader Graph preview mode, use a fixed light direction for preview.
#else
    // If the directional lightmap is combined and is in fragment or ray tracing stage:
    #if defined(DIRLIGHTMAP_COMBINED) && (defined(SHADER_STAGE_FRAGMENT) || defined(SHADER_STAGE_RAY_TRACING))
        float4 staticDir = 0;
    
        #if defined(UNITY_DOTS_INSTANCING_ENABLED)
            // Sample directional lightmap using DOTS instancing.
            staticDir = SAMPLE_TEXTURE2D_LIGHTMAP(unity_LightmapsInd,samplerunity_Lightmaps, lightmapUV, unity_LightmapIndex.x);
        #else
            // Samples the default directional lightmap.
            staticDir = SAMPLE_TEXTURE2D_LIGHTMAP(unity_LightmapInd,samplerunity_Lightmap, lightmapUV);
        #endif
    
        // Decodes the light direction of the lightmap (from [0,1] to [-1,1]).
        Direction = staticDir.xyz * 2.0 - 1.0;
    #else
        Direction = _MainLightPosition.xyz; // Uses the direction of the key light provided directly.
    #endif
#endif
}