// Gets the key light direction considering different build stages and lightmap settings.
void GetMainLightDirection_float(float2 lightmapUV, out float3 Direction)
{
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
}