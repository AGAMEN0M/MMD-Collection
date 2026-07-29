// ============================================================================
// MMD Custom Node (URP SG)
// ----------------------------------------------------------------------------
// Description:
// Collection of custom Universal Render Pipeline lighting utility functions
// used for MMD-style toon shading, lightmap sampling, shadow processing,
// and additional light accumulation inside Shader Graph.
//
// Provides access to realtime lighting data, baked lightmaps, shadow masks,
// spherical harmonics ambient lighting, and additional light evaluation.
//
// Usage:
// Intended for Shader Graph Custom Function nodes to reproduce advanced
// MMD-inspired lighting behavior with URP.
//
// Notes:
// - Compatible with Universal Render Pipeline (URP).
// - Supports Shader Graph preview mode.
// - Supports realtime and baked lighting workflows.
// - Includes directional light, shadow, lightmap, and additional light helpers.
// - Supports shadow masks and dynamic lightmaps.
// - Additional lights use Lambert diffuse lighting accumulation.
// - Compatible with Forward+ / Cluster Light Loop rendering.
// - Designed for stylized toon and anime shading workflows.
//
// Author: Lucas Gomes Cecchini
// Pseudonym: AGAMENOM
// ============================================================================

// Function to compute spherical harmonics lighting based on the normal direction.
void vLight_float(float3 normal, out float3 Output)
{
	#if defined(SHADERGRAPH_PREVIEW)
		Output = 1; // In preview mode, output a constant value for debugging.
	#else
		Output = SampleSH(normal); // Sample the spherical harmonics with the given normal to get the lighting.
	#endif
}

// Function to calculate shadow attenuation at a given world position.
void shadowAtten_float(float3 worldPos, out float Output)
{
	#if defined(SHADERGRAPH_PREVIEW)
		Output = 1; // In preview mode, output a constant value for debugging.
	#else
		float4 shadowCoord = TransformWorldToShadowCoord(worldPos); // Transform world position to shadow coordinates.
		Light mainLight = GetMainLight(shadowCoord); // Get the main light information based on shadow coordinates.
		Output = mainLight.shadowAttenuation; // Output the shadow attenuation from the main light.
	#endif
}

// Function to calculate the light color at a given world position.
void lightColor_float(float3 worldPos, out float3 Output)
{
	#if defined(SHADERGRAPH_PREVIEW)
		Output = 1; // In preview mode, output a constant value for debugging.
	#else
		float4 shadowCoord = TransformWorldToShadowCoord(worldPos); // Transform world position to shadow coordinates.
		Light mainLight = GetMainLight(shadowCoord); // Get the main light information based on shadow coordinates.
		Output = mainLight.color; // Output the color of the main light.
	#endif
}

// Function to sample the lightmap color at the given UV coordinates.
void lightmapCol_float(float2 lightmapUV, out float3 Output)
{
	#if defined(SHADERGRAPH_PREVIEW)
		Output = 1; // In preview mode, output a constant value for debugging.
	#else
		float4 lightmapCol = 1; // Initialize lightmap color to default white (no lightmap influence).
		
		// Sample the lightmap texture using the provided UV coordinates if lightmaps are enabled.
		#ifdef LIGHTMAP_ON
			lightmapCol = SAMPLE_TEXTURE2D(unity_Lightmap, samplerunity_Lightmap, lightmapUV);
		#endif
		
		Output = lightmapCol.rgb; // Output the RGB component of the sampled or default lightmap color.
	#endif
}

// Function to get the world space direction of the main light.
void WorldSpaceLightDir_float(out float3 Output)
{
	#if defined(SHADERGRAPH_PREVIEW)
		Output = 1; // In preview mode, output a constant value for debugging.
	#else
		Output = _MainLightPosition.xyz; // Output the world space direction of the main light.
	#endif
}

// Function to calculate lightmap UV coordinates using transformation.
void LightmapUV_float(float2 UV, out float2 Output)
{
	#if defined(SHADERGRAPH_PREVIEW)
		Output = 1; // In preview mode, output a constant value for debugging.
	#else
		Output = UV * (unity_LightmapST).xy + (unity_LightmapST).zw; // Apply lightmap UV transformation.
	#endif
}

// Function to calculate dynamic lightmap UV coordinates using transformation.
void LightmapUV_Dynamic_float(float2 UV, out float2 Output)
{
	#if defined(SHADERGRAPH_PREVIEW)
		Output = 1; // In preview mode, output a constant value for debugging.
	#else
		Output = UV * (unity_DynamicLightmapST).xy + (unity_DynamicLightmapST).zw; // Apply dynamic lightmap UV transformation.
	#endif
}

// Function to switch between two light color inputs based on lightmap status.
void Switch_float(float3 False, float3 True, out float3 Output)
{
	#ifdef LIGHTMAP_ON
		Output = True; // Output True if lightmaps are enabled.
	#else
		Output = False; // Output False if lightmaps are disabled.
	#endif
}

// Function to sample the shadow mask at the given lightmap UV coordinates.
void ShadowMask_float(float2 LightmapUV, out float4 Output)
{
	#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
		Output = SAMPLE_SHADOWMASK(LightmapUV.xy); // Sample the shadow mask texture.
	#elif !defined(LIGHTMAP_ON)
		Output = unity_ProbesOcclusion; // Output occlusion from probes if lightmaps are off.
	#else
		Output = half4(1, 1, 1, 1); // Output default white value if no shadows or lightmaps are used.
	#endif
}

// Function to calculate additional light contributions using Lambert lighting in the Universal Render Pipeline (URP).
void SRPAdditionalLight_float(float3 WorldPosition, float2 ScreenUV, float3 WorldNormal, float4 ShadowMask, out float3 Output)
{
	#if defined(SHADERGRAPH_PREVIEW)
		Output = 1; // In preview mode, output a constant value for debugging.
	#else
		// Unity versions prior to 6.1 use the old Forward+ rendering path.
		// Map the legacy macro to the newer Cluster Light Loop macro so the
		// same code works across multiple URP versions.
		#if (UNITY_VERSION < 60010000) && !defined(USE_CLUSTER_LIGHT_LOOP)
			#define USE_CLUSTER_LIGHT_LOOP USE_FORWARD_PLUS
		#endif

		// Unity versions prior to 6.1 use a different macro name for skipping
		// subtractive lights in the Forward+ light loop.
		// Alias the old macro to the new name for compatibility.
		#if (UNITY_VERSION < 60010000) && !defined(CLUSTER_LIGHT_LOOP_SUBTRACTIVE_LIGHT_CHECK)
			#define CLUSTER_LIGHT_LOOP_SUBTRACTIVE_LIGHT_CHECK FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
		#endif

		float3 Color = 0; // Initialize accumulated light color to black.
	
		#if defined(_ADDITIONAL_LIGHTS)
			// LightingLambert() was introduced in newer URP versions.
			// Older versions use an equivalent manual Lambert calculation.
			#if (UNITY_VERSION >= 60010000)
				#define CALC_LAMBERT(Light) LightingLambert(AttLightColor, Light.direction, WorldNormal)
			#else
				#define CALC_LAMBERT(Light) (dot(Light.direction, WorldNormal) * 0.5 + 0.5)* AttLightColor
			#endif

			// Calculate the attenuated light color and accumulate its Lambert contribution.
			#define SUM_LIGHTLAMBERT(Light)\
				half3 AttLightColor = Light.color * (Light.distanceAttenuation * Light.shadowAttenuation);\
				Color += CALC_LAMBERT(Light);

			InputData inputData = (InputData)0; // Initialize input data structure.
			inputData.normalizedScreenSpaceUV = ScreenUV; // Assign screen-space UV coordinates.
			inputData.positionWS = WorldPosition; // Assign world-space position.
	
			uint meshRenderingLayers = GetMeshRenderingLayer(); // Retrieve the mesh rendering layers.
			uint pixelLightCount = GetAdditionalLightsCount(); // Retrieve the number of additional lights affecting this pixel.

			// Process clustered/Forward+ directional lights.
			// Depending on the Unity version, this loop may use either the
			// new Cluster Light Loop or the legacy Forward+ implementation.
			#if USE_CLUSTER_LIGHT_LOOP
				[loop]for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
				{
					// Skip subtractive lights when required by the current rendering path.
					CLUSTER_LIGHT_LOOP_SUBTRACTIVE_LIGHT_CHECK
					Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask); // Retrieve light data.

					#ifdef _LIGHT_LAYERS
					if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers)) // Verify that the light affects this mesh.
					#endif
					{
						SUM_LIGHTLAMBERT(light); // Accumulate Lambert lighting.
					}
				}
			#endif

			// Process all remaining additional lights.
			LIGHT_LOOP_BEGIN(pixelLightCount)
				Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask); // Retrieve light data.

				#ifdef _LIGHT_LAYERS
				if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers)) // Verify that the light affects this mesh.
				#endif
				{
					SUM_LIGHTLAMBERT(light); // Accumulate Lambert lighting.
				}
	
			LIGHT_LOOP_END
		#endif

		Output = Color; // Return the accumulated additional lighting.
	#endif
}