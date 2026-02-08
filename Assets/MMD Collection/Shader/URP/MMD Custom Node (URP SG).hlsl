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
		float3 Color = 0; // Initialize color to black.
	
		#if defined(_ADDITIONAL_LIGHTS)
			// Define a macro to calculate Lambert lighting for additional lights.
			#define SUM_LIGHTLAMBERT(Light)\
				half3 AttLightColor = Light.color * (Light.distanceAttenuation * Light.shadowAttenuation);\
				Color += LightingLambert(AttLightColor, Light.direction, WorldNormal); // Calculate Lambert diffuse contribution.
	
			InputData inputData = (InputData)0; // Initialize input data structure.
			inputData.normalizedScreenSpaceUV = ScreenUV; // Assign screen UV coordinates.
			inputData.positionWS = WorldPosition; // Assign world position in world space.
	
			uint meshRenderingLayers = GetMeshRenderingLayer(); // Retrieve mesh rendering layers.
			uint pixelLightCount = GetAdditionalLightsCount(); // Get the number of additional lights affecting the pixel.

			// Iterate through visible additional lights using Cluster Light Loop rendering.
			#if USE_CLUSTER_LIGHT_LOOP
				[loop] for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
				{
					CLUSTER_LIGHT_LOOP_SUBTRACTIVE_LIGHT_CHECK
					Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask); // Fetch light data.

					#ifdef _LIGHT_LAYERS
					if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers)) // Check if light layer matches the mesh.
					#endif
					{
						SUM_LIGHTLAMBERT(light); // Accumulate light using Lambert model.
					}
				}
			#endif

			// Fallback loop for all remaining additional lights.
			LIGHT_LOOP_BEGIN(pixelLightCount)
				Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask); // Fetch light data.

				#ifdef _LIGHT_LAYERS
				if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers)) // Check if light layer matches the mesh.
				#endif
				{
					SUM_LIGHTLAMBERT(light); // Accumulate light using Lambert model.
				}
	
			LIGHT_LOOP_END
		#endif

		Output = Color; // Set the output color with the accumulated lighting.
	#endif
}