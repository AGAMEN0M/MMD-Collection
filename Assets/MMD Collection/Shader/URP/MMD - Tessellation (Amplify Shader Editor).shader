// Made with Amplify Shader Editor v1.9.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Header(Material Color)]_Color("Diffuse", Color) = (0.8,0.8,0.8,0)
		_Specular("Specular", Color) = (0,0,0,0)
		_Ambient("Ambient", Color) = (1,1,1,0)
		_Opaque("Opaque", Range( 0 , 1)) = 1
		_Shininess("Reflection", Float) = 50
		[Header(Rendering)][ToggleUI]_SShad("S-Shad", Float) = 1
		[Header(Edge (Outline))][ToggleUI]_On("On", Float) = 0
		_OutlineColor("Color", Color) = (0,0,0,1)
		_EdgeSize("Size", Float) = 0
		[Header(Texture (Memo))][Enum(Disabled,0,Add Sphere,1,Multi Sphere,2,Sub Tex,3)]_EFFECTS("Effects", Float) = 0
		_MainTex("Texture", 2D) = "white" {}
		[NoScaleOffset]_ToonTex("Toon", 2D) = "white" {}
		[NoScaleOffset]_SphereCube("SPH", CUBE) = "white" {}
		[Enum(Layer 1,0,Layer 2,1,Layer 3,2,Layer 4,3)]_UVLayer("UV Layer", Int) = 0
		_SubTex("SPH SubTex", 2D) = "white" {}
		[Header(Custom Effects Settings)]_SpecularIntensity("Specular Intensity", Range( 0 , 1)) = 1
		_SPHOpacity("SPH Opacity", Range( 0 , 1)) = 1
		_ShadowLum("Shadow Luminescence", Range( 0 , 10)) = 1.5
		_HDR("HDR", Range( 1 , 1000)) = 1
		_ToonTone("Toon Tone", Vector) = (1,0.5,0.5,0)
		[ToggleUI]_MultipleLights("Multiple Lights", Float) = 1
		[Toggle][_FOG_ON]_Fog("Fog", Float) = 1
		_EdgeLength("Edge Length", Range( 2 , 50)) = 5
		_PhongTessStrength("Phong Tess Strength", Range( 0 , 1)) = 0.5
		_ExtrusionAmount("Extrusion Amount", Float) = 0
		[HideInInspector]_Surface("Surface Type", Float) = 0
		[HideInInspector]_Blend("Blending Mode", Float) = 0
		[HideInInspector]_Cull("Render Face", Float) = 2
		[HideInInspector]_SrcBlend("__src", Float) = 1
		[HideInInspector]_DstBlend("__dst", Float) = 0
		[HideInInspector]_ZWrite("__zw", Float) = 1
		[HideInInspector]_ZWriteControl("_ZWriteControl", Float) = 1
		[HideInInspector]_ZTest("_ZTest", Float) = 4
		[HideInInspector]_AlphaClip("Alpha Clip", Float) = 0
		[HideInInspector]_Cutoff("Alpha Cutoff", Range( 0 , 1)) = 0.5
		[HideInInspector]_CastShadows("Cast Shadows", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}


		//_TessPhongStrength( "Phong Tess Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}

		[HideInInspector][ToggleUI] _AddPrecomputedVelocity("Add Precomputed Velocity", Float) = 1
		[HideInInspector][ToggleOff] _ReceiveShadows("Receive Shadows", Float) = 1.0
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="_Surface" "Queue"="Overlay-2000" "UniversalMaterialType"="Unlit" }

		Cull [_Cull]
		AlphaToMask [_Invalid]

		

		HLSLINCLUDE
		#pragma target 4.5
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}

		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS
		ENDHLSL

		
		Pass
		{
			Name "OutlinePass"
			

			Blend [_SrcBlend] [_DstBlend], One Zero
			Cull Front
			ZWrite [_ZWrite]
			ZTest [_ZTest]
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#define ASE_TESSELLATION 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_PHONG_TESSELLATION
			#define ASE_LENGTH_TESSELLATION
			#define ASE_VERSION 19800
			#define ASE_SRP_VERSION 170003


			#pragma vertex vert
			#pragma fragment frag

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_VERT_NORMAL


			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float3 positionWS : TEXCOORD1;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD2;
				#endif
				#if defined(ASE_FOG) || defined(_ADDITIONAL_LIGHTS_VERTEX)
					half4 fogFactorAndVertexLight : TEXCOORD3;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _OutlineColor;
			float4 _Specular;
			float4 _SubTex_ST;
			float4 _Ambient;
			float4 _Color;
			float3 _ToonTone;
			float _SShad;
			float _EFFECTS;
			float _CastShadows;
			float _SPHOpacity;
			int _UVLayer;
			float _Shininess;
			float _SpecularIntensity;
			float _MultipleLights;
			float _ShadowLum;
			float _Cutoff;
			float _AlphaClip;
			float _Surface;
			float _ExtrusionAmount;
			float _EdgeSize;
			float _On;
			float _PhongTessStrength;
			float _EdgeLength;
			float _Fog;
			float _Blend;
			float _Cull;
			float _SrcBlend;
			float _DstBlend;
			float _ZWrite;
			float _ZWriteControl;
			float _ZTest;
			float _HDR;
			float _Opaque;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			

			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float OutlineStatus314 = _On;
				float3 temp_cast_1 = 0;
				float TessExtrusionAmount513 = _ExtrusionAmount;
				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( OutlineStatus314 == (float)0 ? temp_cast_1 : ( ( _EdgeSize + TessExtrusionAmount513 ) * input.normalOS ) );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					output.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				#if defined(ASE_FOG) || defined(_ADDITIONAL_LIGHTS_VERTEX)
					output.fogFactorAndVertexLight = 0;
					#if defined(ASE_FOG) && !defined(_FOG_FRAGMENT)
						output.fogFactorAndVertexLight.x = ComputeFogFactor(vertexInput.positionCS.z);
					#endif
					#ifdef _ADDITIONAL_LIGHTS_VERTEX
						half3 vertexLight = VertexLighting( vertexInput.positionWS, normalInput.normalWS );
						output.fogFactorAndVertexLight.yzw = vertexLight;
					#endif
				#endif

				output.positionCS = vertexInput.positionCS;
				output.clipPosV = vertexInput.positionCS;
				output.positionWS = vertexInput.positionWS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _EdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _PhongTessStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag ( PackedVaryings input  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( input );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				float3 WorldPosition = input.positionWS;
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float4 ClipPos = input.clipPosV;
				float4 ScreenPos = ComputeScreenPos( input.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = input.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
	
				InputData inputData = (InputData)0;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;

				#ifdef ASE_FOG
					inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogFactorAndVertexLight.x);
				#endif
				#ifdef _ADDITIONAL_LIGHTS_VERTEX
					inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
				#endif
	
				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float OutlineStatus314 = _On;
				float tSgurfaceType248 = _Surface;
				
				float myAlphaCutoff323 = ( _AlphaClip == (float)1 ? _Cutoff : 0.0001 );
				

				float3 Color = _OutlineColor.rgb;
				float Alpha = ( OutlineStatus314 == (float)1 ? ( tSgurfaceType248 == (float)0 ? (float)1 : saturate( _OutlineColor.a ) ) : (float)0 );
				float AlphaClipThreshold = myAlphaCutoff323;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						Color.rgb = MixFogColor(Color.rgb, half3(0,0,0), inputData.fogCoord);
					#else
						Color.rgb = MixFog(Color.rgb, inputData.fogCoord);
					#endif
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				return half4( Color, Alpha );
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" }

			Blend [_SrcBlend] [_DstBlend], One Zero
			ZWrite [_ZWrite]
			ZTest [_ZTest]
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#pragma multi_compile_fragment _ALPHATEST_ON
			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define ASE_TESSELLATION 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_PHONG_TESSELLATION
			#define ASE_LENGTH_TESSELLATION
			#define ASE_VERSION 19800
			#define ASE_SRP_VERSION 170003


			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fragment _ DEBUG_DISPLAY

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_UNLIT

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#include "MMD_Custom_Node_(URP_ASE).hlsl"
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_NORMAL
			#define ASE_NEEDS_FRAG_POSITION
			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile_fog
			#pragma multi_compile _ _FOG_ON
			#ifdef _FOG_ON
			#define ASE_FOG 1
			#endif
			#pragma multi_compile _ _FORWARD_PLUS
			#pragma multi_compile _ _LIGHT_LAYERS


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float3 positionWS : TEXCOORD1;
				#if defined(ASE_FOG) || defined(_ADDITIONAL_LIGHTS_VERTEX)
					half4 fogFactorAndVertexLight : TEXCOORD2;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD3;
				#endif
				float3 ase_normal : NORMAL;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _OutlineColor;
			float4 _Specular;
			float4 _SubTex_ST;
			float4 _Ambient;
			float4 _Color;
			float3 _ToonTone;
			float _SShad;
			float _EFFECTS;
			float _CastShadows;
			float _SPHOpacity;
			int _UVLayer;
			float _Shininess;
			float _SpecularIntensity;
			float _MultipleLights;
			float _ShadowLum;
			float _Cutoff;
			float _AlphaClip;
			float _Surface;
			float _ExtrusionAmount;
			float _EdgeSize;
			float _On;
			float _PhongTessStrength;
			float _EdgeLength;
			float _Fog;
			float _Blend;
			float _Cull;
			float _SrcBlend;
			float _DstBlend;
			float _ZWrite;
			float _ZWriteControl;
			float _ZTest;
			float _HDR;
			float _Opaque;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _ToonTex;
			sampler2D _MainTex;
			samplerCUBE _SphereCube;
			sampler2D _SubTex;


			half4 CalculateShadowMask1_g92( half2 LightmapUV )
			{
				#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
				return SAMPLE_SHADOWMASK( LightmapUV.xy );
				#elif !defined (LIGHTMAP_ON)
				return unity_ProbesOcclusion;
				#else
				return half4( 1, 1, 1, 1 );
				#endif
			}
			
			float3 AdditionalLightsLambertMask17x( float3 WorldPosition, float2 ScreenUV, float3 WorldNormal, float4 ShadowMask )
			{
				float3 Color = 0;
				#if defined(_ADDITIONAL_LIGHTS)
					#define SUM_LIGHTLAMBERT(Light)\
						half3 AttLightColor = Light.color * ( Light.distanceAttenuation * Light.shadowAttenuation );\
						Color += LightingLambert( AttLightColor, Light.direction, WorldNormal );
					InputData inputData = (InputData)0;
					inputData.normalizedScreenSpaceUV = ScreenUV;
					inputData.positionWS = WorldPosition;
					uint meshRenderingLayers = GetMeshRenderingLayer();
					uint pixelLightCount = GetAdditionalLightsCount();	
					#if USE_FORWARD_PLUS
					[loop] for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
					{
						FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#ifdef _LIGHT_LAYERS
						if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
						#endif
						{
							SUM_LIGHTLAMBERT( light );
						}
					}
					#endif
					
					LIGHT_LOOP_BEGIN( pixelLightCount )
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#ifdef _LIGHT_LAYERS
						if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
						#endif
						{
							SUM_LIGHTLAMBERT( light );
						}
					LIGHT_LOOP_END
				#endif
				return Color;
			}
			

			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float TessExtrusionAmount513 = _ExtrusionAmount;
				
				output.ase_normal = input.normalOS;
				output.ase_texcoord4 = input.positionOS;
				output.ase_texcoord5.xy = input.ase_texcoord1.xy;
				output.ase_texcoord6.xyz = input.ase_texcoord.xyz;
				output.ase_texcoord5.zw = input.ase_texcoord2.xy;
				output.ase_texcoord7.xy = input.ase_texcoord3.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord6.w = 0;
				output.ase_texcoord7.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( TessExtrusionAmount513 * input.normalOS );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );
				
				#if defined(ASE_FOG) || defined(_ADDITIONAL_LIGHTS_VERTEX)
					output.fogFactorAndVertexLight = 0;
					#if defined(ASE_FOG) && !defined(_FOG_FRAGMENT)
						output.fogFactorAndVertexLight.x = ComputeFogFactor(vertexInput.positionCS.z);
					#endif
					#ifdef _ADDITIONAL_LIGHTS_VERTEX
						half3 vertexLight = VertexLighting( vertexInput.positionWS, normalInput.normalWS );
						output.fogFactorAndVertexLight.yzw = vertexLight;
					#endif
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					output.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				output.positionCS = vertexInput.positionCS;
				output.clipPosV = vertexInput.positionCS;
				output.positionWS = vertexInput.positionWS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_texcoord2 = input.ase_texcoord2;
				output.ase_texcoord3 = input.ase_texcoord3;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _EdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				output.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _PhongTessStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag ( PackedVaryings input
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						#ifdef _WRITE_RENDERING_LAYERS
						, out float4 outRenderingLayers : SV_Target1
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				float3 WorldPosition = input.positionWS;
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float4 ClipPos = input.clipPosV;
				float4 ScreenPos = ComputeScreenPos( input.clipPosV );

				float2 NormalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = input.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float4 temp_cast_0 = (1.0).xxxx;
				float4 temp_cast_1 = (1.0).xxxx;
				float3 ToonTone32 = _ToonTone;
				float3 break52 = ToonTone32;
				float3 objToWorldDir84 = mul( GetObjectToWorldMatrix(), float4( input.ase_normal, 0 ) ).xyz;
				float3 normalizeResult59 = normalize( objToWorldDir84 );
				float3 normalizeResult60 = normalize( _MainLightPosition.xyz );
				float dotResult62 = dot( normalizeResult59 , normalizeResult60 );
				float NdotL89 = dotResult62;
				float localshadowAtten190 = ( 0.0 );
				float3 objToWorld114 = mul( GetObjectToWorldMatrix(), float4( input.ase_texcoord4.xyz, 1 ) ).xyz;
				float3 worldPos190 = objToWorld114;
				float OutputShadowAtten190 = 0.0;
				shadowAtten_float( worldPos190 , OutputShadowAtten190 );
				float toonRefl416 = min( ( ( break52.y * NdotL89 ) + break52.z ) , ( break52.z + ( break52.x * ( OutputShadowAtten190 - 0.5 ) ) ) );
				float temp_output_38_0 = saturate( toonRefl416 );
				float2 appendResult93 = (float2(temp_output_38_0 , temp_output_38_0));
				float4 tex2DNode92 = tex2D( _ToonTex, ( _SShad == (float)0 ? appendResult93 : float2( 0,0 ) ) );
				float temp_output_418_0 = ( toonRefl416 * 2.0 );
				float toonShadow424 = saturate( ( ( temp_output_418_0 * temp_output_418_0 ) - 1.0 ) );
				float4 lerpResult431 = lerp( tex2DNode92 , float4( float3(1,1,1) , 0.0 ) , toonShadow424);
				float locallightColor188 = ( 0.0 );
				float3 worldPos188 = objToWorld114;
				float3 OutputColor188 = float3( 0,0,0 );
				lightColor_float( worldPos188 , OutputColor188 );
				float3 originalLightColor174 = OutputColor188;
				float3 temp_cast_5 = 0;
				float locallightmapCol454 = ( 0.0 );
				float2 lightmapUV454 = (input.ase_texcoord5.xy*(unity_LightmapST).xy + (unity_LightmapST).zw);
				float3 Output454 = float3( 0,0,0 );
				lightmapCol_float( lightmapUV454 , Output454 );
				#ifdef LIGHTMAP_ON
				float3 staticSwitch457 = ( ( originalLightColor174 == temp_cast_5 ? ( Output454 * 2.0 ) : originalLightColor174 ) + Output454 );
				#else
				float3 staticSwitch457 = originalLightColor174;
				#endif
				float3 originalBakedLightColor474 = staticSwitch457;
				half3 MMDLIT_GLOBALLIGHTING139 = half3(0.6,0.6,0.6);
				float3 lightColor178 = ( originalBakedLightColor474 * MMDLIT_GLOBALLIGHTING139 );
				int localeffectsControl399 = ( 0 );
				float tSphereMapBlend289 = _EFFECTS;
				float Layer399 = tSphereMapBlend289;
				float4 Ambient44 = _Ambient;
				float4 break151 = Ambient44;
				float3 appendResult150 = (float3(break151.r , break151.g , break151.b));
				float4 Color13 = _Color;
				float4 break159 = Color13;
				float3 appendResult152 = (float3(break159.r , break159.g , break159.b));
				float3 appendResult154 = (float3(1.0 , 1.0 , 1.0));
				float localvLight187 = ( 0.0 );
				float3 objToWorldDir141 = mul( GetObjectToWorldMatrix(), float4( input.ase_normal, 0 ) ).xyz;
				float3 normal187 = objToWorldDir141;
				float3 Output187 = float3( 0,0,0 );
				vLight_float( normal187 , Output187 );
				float3 globalAmbient143 = Output187;
				float3 appendResult136 = (float3(1.0 , 1.0 , 1.0));
				half3 MMDLIT_CENTERAMBIENT138 = half3(0.5,0.5,0.5);
				float4 break163 = Ambient44;
				float3 appendResult162 = (float3(break163.r , break163.g , break163.b));
				half3 MMDLIT_CENTERAMBIENT_INV171 = ( half3(1,1,1) / 0.5 );
				float3 MMDLit_GetTempAmbientL135 = ( max( ( MMDLIT_CENTERAMBIENT138 - appendResult162 ) , float3(0,0,0) ) * MMDLIT_CENTERAMBIENT_INV171 );
				float3 MMDLit_GetAmbientRate48 = ( appendResult136 - MMDLit_GetTempAmbientL135 );
				float3 MMDLit_GetTempAmbient144 = ( globalAmbient143 * MMDLit_GetAmbientRate48 );
				float3 appendResult155 = (float3(0.0 , 0.0 , 0.0));
				float3 MMDLit_GetTempDiffuse160 = max( ( min( ( appendResult150 + ( appendResult152 * MMDLIT_GLOBALLIGHTING139 ) ) , appendResult154 ) - MMDLit_GetTempAmbient144 ) , appendResult155 );
				float2 uv_MainTex = input.ase_texcoord6.xyz.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 Albedo12 = tex2D( _MainTex, uv_MainTex );
				float4 temp_output_78_0 = ( float4( MMDLit_GetTempDiffuse160 , 0.0 ) * Albedo12 );
				float4 Base399 = temp_output_78_0;
				float3 objToView109 = mul( UNITY_MATRIX_MV, float4( input.ase_texcoord4.xyz, 1 ) ).xyz;
				float3 normalizeResult64 = normalize( objToView109 );
				float3 objToViewDir67 = normalize( mul( UNITY_MATRIX_IT_MV, float4( input.ase_normal, 0 ) ).xyz );
				float3 normalizeResult65 = normalize( objToViewDir67 );
				float4 SphereCube37 = texCUBE( _SphereCube, reflect( normalizeResult64 , normalizeResult65 ) );
				float4 temp_output_57_0 = ( SphereCube37 * _SPHOpacity );
				float4 Add399 = ( temp_output_78_0 + temp_output_57_0 );
				float4 temp_output_39_0 = ( temp_output_57_0 * Albedo12 );
				float4 Multi399 = ( temp_output_39_0 * float4( MMDLit_GetTempDiffuse160 , 0.0 ) );
				int localuvLayer391 = ( 0 );
				float Layer391 = (float)_UVLayer;
				float2 uv_SubTex = input.ase_texcoord6.xyz.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv0391 = uv_SubTex;
				float2 uv2_SubTex = input.ase_texcoord5.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv1391 = uv2_SubTex;
				float2 uv3_SubTex = input.ase_texcoord5.zw * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv2391 = uv3_SubTex;
				float2 uv4_SubTex = input.ase_texcoord7.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv3391 = uv4_SubTex;
				float2 UV391 = float2( 0,0 );
				uvLayer_float( Layer391 , uv0391 , uv1391 , uv2391 , uv3391 , UV391 );
				float4 tex2DNode379 = tex2D( _SubTex, UV391 );
				float4 Sub399 = ( float4( MMDLit_GetTempDiffuse160 , 0.0 ) * Albedo12 * tex2DNode379 );
				float4 RGBA399 = float4( 0,0,0,0 );
				effectsControl_float( Layer399 , Base399 , Add399 , Multi399 , Sub399 , RGBA399 );
				float3 objToWorldDir180 = mul( GetObjectToWorldMatrix(), float4( input.ase_normal, 0 ) ).xyz;
				float3 normalizeResult181 = normalize( objToWorldDir180 );
				float3 ase_viewDirWS = normalize( WorldViewDirection );
				float3 normalizeResult127 = normalize( ( _MainLightPosition.xyz + ase_viewDirWS ) );
				float dotResult128 = dot( normalizeResult181 , normalizeResult127 );
				float Specular131 = pow( saturate( dotResult128 ) , max( _Shininess , 0.001 ) );
				float localeffectsControl400 = ( 0.0 );
				float Layer400 = tSphereMapBlend289;
				float4 Base400 = Albedo12;
				float4 Add400 = ( temp_output_57_0 + Albedo12 );
				float4 Multi400 = temp_output_39_0;
				float4 Sub400 = Albedo12;
				float4 RGBA400 = float4( 0,0,0,0 );
				effectsControl_float( Layer400 , Base400 , Add400 , Multi400 , Sub400 , RGBA400 );
				float4 baseC73 = RGBA400;
				float3 worldPosValue184_g94 = WorldPosition;
				float3 WorldPosition173_g94 = worldPosValue184_g94;
				float4 ase_positionSSNorm = ScreenPos / ScreenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				float2 ScreenUV183_g94 = (ase_positionSSNorm).xy;
				float2 ScreenUV173_g94 = ScreenUV183_g94;
				float3 objToWorldDir261 = mul( GetObjectToWorldMatrix(), float4( input.ase_normal, 0 ) ).xyz;
				float3 worldNormalValue185_g94 = objToWorldDir261;
				float3 WorldNormal173_g94 = worldNormalValue185_g94;
				half2 LightmapUV1_g92 = (input.ase_texcoord5.zw*(unity_DynamicLightmapST).xy + (unity_DynamicLightmapST).zw);
				half4 localCalculateShadowMask1_g92 = CalculateShadowMask1_g92( LightmapUV1_g92 );
				float4 shadowMaskValue182_g94 = localCalculateShadowMask1_g92;
				float4 ShadowMask173_g94 = shadowMaskValue182_g94;
				float3 localAdditionalLightsLambertMask17x173_g94 = AdditionalLightsLambertMask17x( WorldPosition173_g94 , ScreenUV173_g94 , WorldNormal173_g94 , ShadowMask173_g94 );
				float3 mmdAdditionalLights268 = ( _MultipleLights == (float)1 ? ( localAdditionalLightsLambertMask17x173_g94 + globalAmbient143 ) : globalAmbient143 );
				float4 FinalColor336 = ( ( ( saturate( ( temp_cast_0 - ( _ShadowLum * ( temp_cast_1 - ( _SShad == (float)0 ? tex2DNode92 : lerpResult431 ) ) ) ) ) * float4( lightColor178 , 0.0 ) * RGBA399 ) + ( ( Specular131 * _Specular * float4( lightColor178 , 0.0 ) ) * _SpecularIntensity ) ) + ( baseC73 * float4( ( mmdAdditionalLights268 * MMDLit_GetAmbientRate48 ) , 0.0 ) ) );
				
				float tSgurfaceType248 = _Surface;
				
				float myAlphaCutoff323 = ( _AlphaClip == (float)1 ? _Cutoff : 0.0001 );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( FinalColor336 * _HDR ).rgb;
				float Alpha = ( tSgurfaceType248 == (float)0 ? (float)1 : saturate( ( _Opaque * ( tSphereMapBlend289 == (float)3 ? ( tex2DNode379.a * Albedo12.a ) : Albedo12.a ) ) ) );
				float AlphaClipThreshold = myAlphaCutoff323;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;

				#ifdef ASE_FOG
					inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogFactorAndVertexLight.x);
				#endif
				#ifdef _ADDITIONAL_LIGHTS_VERTEX
					inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
				#endif

				inputData.normalizedScreenSpaceUV = NormalizedScreenSpaceUV;

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(input.positionCS, Color);
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						Color.rgb = MixFogColor(Color.rgb, half3(0,0,0), inputData.fogCoord);
					#else
						Color.rgb = MixFog(Color.rgb, inputData.fogCoord);
					#endif
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
				#endif

				return half4( Color, Alpha );
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM

			#pragma multi_compile _ALPHATEST_ON
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define ASE_TESSELLATION 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_PHONG_TESSELLATION
			#define ASE_LENGTH_TESSELLATION
			#define ASE_VERSION 19800
			#define ASE_SRP_VERSION 170003


			#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#include "MMD_Custom_Node_(URP_ASE).hlsl"
			#define ASE_NEEDS_VERT_NORMAL
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile_fog
			#pragma multi_compile _ _FOG_ON
			#ifdef _FOG_ON
			#define ASE_FOG 1
			#endif


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 positionWS : TEXCOORD1;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _OutlineColor;
			float4 _Specular;
			float4 _SubTex_ST;
			float4 _Ambient;
			float4 _Color;
			float3 _ToonTone;
			float _SShad;
			float _EFFECTS;
			float _CastShadows;
			float _SPHOpacity;
			int _UVLayer;
			float _Shininess;
			float _SpecularIntensity;
			float _MultipleLights;
			float _ShadowLum;
			float _Cutoff;
			float _AlphaClip;
			float _Surface;
			float _ExtrusionAmount;
			float _EdgeSize;
			float _On;
			float _PhongTessStrength;
			float _EdgeLength;
			float _Fog;
			float _Blend;
			float _Cull;
			float _SrcBlend;
			float _DstBlend;
			float _ZWrite;
			float _ZWriteControl;
			float _ZTest;
			float _HDR;
			float _Opaque;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _SubTex;
			sampler2D _MainTex;


			
			float3 _LightDirection;
			float3 _LightPosition;

			PackedVaryings VertexFunction( Attributes input )
			{
				PackedVaryings output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( output );

				float TessExtrusionAmount513 = _ExtrusionAmount;
				
				output.ase_texcoord3.xy = input.ase_texcoord.xy;
				output.ase_texcoord3.zw = input.ase_texcoord1.xy;
				output.ase_texcoord4.xy = input.ase_texcoord2.xy;
				output.ase_texcoord4.zw = input.ase_texcoord3.xy;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( TessExtrusionAmount513 * input.normalOS );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;

				float3 positionWS = TransformObjectToWorld( input.positionOS.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					output.positionWS = positionWS;
				#endif

				float3 normalWS = TransformObjectToWorldDir(input.normalOS);

				#if _CASTING_PUNCTUAL_LIGHT_SHADOW
					float3 lightDirectionWS = normalize(_LightPosition - positionWS);
				#else
					float3 lightDirectionWS = _LightDirection;
				#endif

				float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

				//code for UNITY_REVERSED_Z is moved into Shadows.hlsl from 6000.0.22 and or higher
				positionCS = ApplyShadowClamping(positionCS);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					output.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				output.positionCS = positionCS;
				output.clipPosV = positionCS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_texcoord2 = input.ase_texcoord2;
				output.ase_texcoord3 = input.ase_texcoord3;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _EdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				output.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _PhongTessStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(PackedVaryings input
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( input );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = input.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float4 ClipPos = input.clipPosV;
				float4 ScreenPos = ComputeScreenPos( input.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = input.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float tSgurfaceType248 = _Surface;
				float tSphereMapBlend289 = _EFFECTS;
				int localuvLayer391 = ( 0 );
				float Layer391 = (float)_UVLayer;
				float2 uv_SubTex = input.ase_texcoord3.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv0391 = uv_SubTex;
				float2 uv2_SubTex = input.ase_texcoord3.zw * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv1391 = uv2_SubTex;
				float2 uv3_SubTex = input.ase_texcoord4.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv2391 = uv3_SubTex;
				float2 uv4_SubTex = input.ase_texcoord4.zw * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv3391 = uv4_SubTex;
				float2 UV391 = float2( 0,0 );
				uvLayer_float( Layer391 , uv0391 , uv1391 , uv2391 , uv3391 , UV391 );
				float4 tex2DNode379 = tex2D( _SubTex, UV391 );
				float2 uv_MainTex = input.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 Albedo12 = tex2D( _MainTex, uv_MainTex );
				
				float myAlphaCutoff323 = ( _AlphaClip == (float)1 ? _Cutoff : 0.0001 );
				

				float Alpha = ( tSgurfaceType248 == (float)0 ? (float)1 : saturate( ( _Opaque * ( tSphereMapBlend289 == (float)3 ? ( tex2DNode379.a * Albedo12.a ) : Albedo12.a ) ) ) );
				float AlphaClipThreshold = myAlphaCutoff323;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM

			#pragma multi_compile _ALPHATEST_ON
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define ASE_TESSELLATION 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_PHONG_TESSELLATION
			#define ASE_LENGTH_TESSELLATION
			#define ASE_VERSION 19800
			#define ASE_SRP_VERSION 170003


			#pragma vertex vert
			#pragma fragment frag

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#include "MMD_Custom_Node_(URP_ASE).hlsl"
			#define ASE_NEEDS_VERT_NORMAL
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile_fog
			#pragma multi_compile _ _FOG_ON
			#ifdef _FOG_ON
			#define ASE_FOG 1
			#endif


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 positionWS : TEXCOORD1;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _OutlineColor;
			float4 _Specular;
			float4 _SubTex_ST;
			float4 _Ambient;
			float4 _Color;
			float3 _ToonTone;
			float _SShad;
			float _EFFECTS;
			float _CastShadows;
			float _SPHOpacity;
			int _UVLayer;
			float _Shininess;
			float _SpecularIntensity;
			float _MultipleLights;
			float _ShadowLum;
			float _Cutoff;
			float _AlphaClip;
			float _Surface;
			float _ExtrusionAmount;
			float _EdgeSize;
			float _On;
			float _PhongTessStrength;
			float _EdgeLength;
			float _Fog;
			float _Blend;
			float _Cull;
			float _SrcBlend;
			float _DstBlend;
			float _ZWrite;
			float _ZWriteControl;
			float _ZTest;
			float _HDR;
			float _Opaque;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _SubTex;
			sampler2D _MainTex;


			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float TessExtrusionAmount513 = _ExtrusionAmount;
				
				output.ase_texcoord3.xy = input.ase_texcoord.xy;
				output.ase_texcoord3.zw = input.ase_texcoord1.xy;
				output.ase_texcoord4.xy = input.ase_texcoord2.xy;
				output.ase_texcoord4.zw = input.ase_texcoord3.xy;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( TessExtrusionAmount513 * input.normalOS );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					output.positionWS = vertexInput.positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					output.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				output.positionCS = vertexInput.positionCS;
				output.clipPosV = vertexInput.positionCS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_texcoord2 = input.ase_texcoord2;
				output.ase_texcoord3 = input.ase_texcoord3;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _EdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				output.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _PhongTessStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(PackedVaryings input
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = input.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float4 ClipPos = input.clipPosV;
				float4 ScreenPos = ComputeScreenPos( input.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = input.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float tSgurfaceType248 = _Surface;
				float tSphereMapBlend289 = _EFFECTS;
				int localuvLayer391 = ( 0 );
				float Layer391 = (float)_UVLayer;
				float2 uv_SubTex = input.ase_texcoord3.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv0391 = uv_SubTex;
				float2 uv2_SubTex = input.ase_texcoord3.zw * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv1391 = uv2_SubTex;
				float2 uv3_SubTex = input.ase_texcoord4.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv2391 = uv3_SubTex;
				float2 uv4_SubTex = input.ase_texcoord4.zw * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv3391 = uv4_SubTex;
				float2 UV391 = float2( 0,0 );
				uvLayer_float( Layer391 , uv0391 , uv1391 , uv2391 , uv3391 , UV391 );
				float4 tex2DNode379 = tex2D( _SubTex, UV391 );
				float2 uv_MainTex = input.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 Albedo12 = tex2D( _MainTex, uv_MainTex );
				
				float myAlphaCutoff323 = ( _AlphaClip == (float)1 ? _Cutoff : 0.0001 );
				

				float Alpha = ( tSgurfaceType248 == (float)0 ? (float)1 : saturate( ( _Opaque * ( tSphereMapBlend289 == (float)3 ? ( tex2DNode379.a * Albedo12.a ) : Albedo12.a ) ) ) );
				float AlphaClipThreshold = myAlphaCutoff323;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "SceneSelectionPass"
			Tags { "LightMode"="SceneSelectionPass" }

			Cull Off
			AlphaToMask Off

			HLSLPROGRAM

			#define ASE_TESSELLATION 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_PHONG_TESSELLATION
			#define ASE_LENGTH_TESSELLATION
			#define ASE_VERSION 19800
			#define ASE_SRP_VERSION 170003


			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "MMD_Custom_Node_(URP_ASE).hlsl"
			#define ASE_NEEDS_VERT_NORMAL
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile_fog
			#pragma multi_compile _ _FOG_ON
			#ifdef _FOG_ON
			#define ASE_FOG 1
			#endif


			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _OutlineColor;
			float4 _Specular;
			float4 _SubTex_ST;
			float4 _Ambient;
			float4 _Color;
			float3 _ToonTone;
			float _SShad;
			float _EFFECTS;
			float _CastShadows;
			float _SPHOpacity;
			int _UVLayer;
			float _Shininess;
			float _SpecularIntensity;
			float _MultipleLights;
			float _ShadowLum;
			float _Cutoff;
			float _AlphaClip;
			float _Surface;
			float _ExtrusionAmount;
			float _EdgeSize;
			float _On;
			float _PhongTessStrength;
			float _EdgeLength;
			float _Fog;
			float _Blend;
			float _Cull;
			float _SrcBlend;
			float _DstBlend;
			float _ZWrite;
			float _ZWriteControl;
			float _ZTest;
			float _HDR;
			float _Opaque;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _SubTex;
			sampler2D _MainTex;


			
			int _ObjectId;
			int _PassValue;

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			PackedVaryings VertexFunction(Attributes input  )
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);

				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float TessExtrusionAmount513 = _ExtrusionAmount;
				
				output.ase_texcoord.xy = input.ase_texcoord.xy;
				output.ase_texcoord.zw = input.ase_texcoord1.xy;
				output.ase_texcoord1.xy = input.ase_texcoord2.xy;
				output.ase_texcoord1.zw = input.ase_texcoord3.xy;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( TessExtrusionAmount513 * input.normalOS );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;

				float3 positionWS = TransformObjectToWorld( input.positionOS.xyz );

				output.positionCS = TransformWorldToHClip(positionWS);

				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_texcoord2 = input.ase_texcoord2;
				output.ase_texcoord3 = input.ase_texcoord3;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _EdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				output.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _PhongTessStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(PackedVaryings input ) : SV_Target
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float tSgurfaceType248 = _Surface;
				float tSphereMapBlend289 = _EFFECTS;
				int localuvLayer391 = ( 0 );
				float Layer391 = (float)_UVLayer;
				float2 uv_SubTex = input.ase_texcoord.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv0391 = uv_SubTex;
				float2 uv2_SubTex = input.ase_texcoord.zw * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv1391 = uv2_SubTex;
				float2 uv3_SubTex = input.ase_texcoord1.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv2391 = uv3_SubTex;
				float2 uv4_SubTex = input.ase_texcoord1.zw * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv3391 = uv4_SubTex;
				float2 UV391 = float2( 0,0 );
				uvLayer_float( Layer391 , uv0391 , uv1391 , uv2391 , uv3391 , UV391 );
				float4 tex2DNode379 = tex2D( _SubTex, UV391 );
				float2 uv_MainTex = input.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 Albedo12 = tex2D( _MainTex, uv_MainTex );
				
				float myAlphaCutoff323 = ( _AlphaClip == (float)1 ? _Cutoff : 0.0001 );
				

				surfaceDescription.Alpha = ( tSgurfaceType248 == (float)0 ? (float)1 : saturate( ( _Opaque * ( tSphereMapBlend289 == (float)3 ? ( tex2DNode379.a * Albedo12.a ) : Albedo12.a ) ) ) );
				surfaceDescription.AlphaClipThreshold = myAlphaCutoff323;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				return outColor;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "ScenePickingPass"
			Tags { "LightMode"="Picking" }

			AlphaToMask Off

			HLSLPROGRAM

			#define ASE_TESSELLATION 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_PHONG_TESSELLATION
			#define ASE_LENGTH_TESSELLATION
			#define ASE_VERSION 19800
			#define ASE_SRP_VERSION 170003


			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT

			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#include "MMD_Custom_Node_(URP_ASE).hlsl"
			#define ASE_NEEDS_VERT_NORMAL
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile_fog
			#pragma multi_compile _ _FOG_ON
			#ifdef _FOG_ON
			#define ASE_FOG 1
			#endif


			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _OutlineColor;
			float4 _Specular;
			float4 _SubTex_ST;
			float4 _Ambient;
			float4 _Color;
			float3 _ToonTone;
			float _SShad;
			float _EFFECTS;
			float _CastShadows;
			float _SPHOpacity;
			int _UVLayer;
			float _Shininess;
			float _SpecularIntensity;
			float _MultipleLights;
			float _ShadowLum;
			float _Cutoff;
			float _AlphaClip;
			float _Surface;
			float _ExtrusionAmount;
			float _EdgeSize;
			float _On;
			float _PhongTessStrength;
			float _EdgeLength;
			float _Fog;
			float _Blend;
			float _Cull;
			float _SrcBlend;
			float _DstBlend;
			float _ZWrite;
			float _ZWriteControl;
			float _ZTest;
			float _HDR;
			float _Opaque;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _SubTex;
			sampler2D _MainTex;


			
			float4 _SelectionID;

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			PackedVaryings VertexFunction(Attributes input  )
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);

				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float TessExtrusionAmount513 = _ExtrusionAmount;
				
				output.ase_texcoord.xy = input.ase_texcoord.xy;
				output.ase_texcoord.zw = input.ase_texcoord1.xy;
				output.ase_texcoord1.xy = input.ase_texcoord2.xy;
				output.ase_texcoord1.zw = input.ase_texcoord3.xy;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( TessExtrusionAmount513 * input.normalOS );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;

				float3 positionWS = TransformObjectToWorld( input.positionOS.xyz );
				output.positionCS = TransformWorldToHClip(positionWS);
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_texcoord2 = input.ase_texcoord2;
				output.ase_texcoord3 = input.ase_texcoord3;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _EdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				output.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _PhongTessStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(PackedVaryings input ) : SV_Target
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float tSgurfaceType248 = _Surface;
				float tSphereMapBlend289 = _EFFECTS;
				int localuvLayer391 = ( 0 );
				float Layer391 = (float)_UVLayer;
				float2 uv_SubTex = input.ase_texcoord.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv0391 = uv_SubTex;
				float2 uv2_SubTex = input.ase_texcoord.zw * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv1391 = uv2_SubTex;
				float2 uv3_SubTex = input.ase_texcoord1.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv2391 = uv3_SubTex;
				float2 uv4_SubTex = input.ase_texcoord1.zw * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv3391 = uv4_SubTex;
				float2 UV391 = float2( 0,0 );
				uvLayer_float( Layer391 , uv0391 , uv1391 , uv2391 , uv3391 , UV391 );
				float4 tex2DNode379 = tex2D( _SubTex, UV391 );
				float2 uv_MainTex = input.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 Albedo12 = tex2D( _MainTex, uv_MainTex );
				
				float myAlphaCutoff323 = ( _AlphaClip == (float)1 ? _Cutoff : 0.0001 );
				

				surfaceDescription.Alpha = ( tSgurfaceType248 == (float)0 ? (float)1 : saturate( ( _Opaque * ( tSphereMapBlend289 == (float)3 ? ( tex2DNode379.a * Albedo12.a ) : Albedo12.a ) ) ) );
				surfaceDescription.AlphaClipThreshold = myAlphaCutoff323;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;
				outColor = _SelectionID;

				return outColor;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthNormals"
			Tags { "LightMode"="DepthNormalsOnly" }

			ZTest LEqual
			ZWrite On

			HLSLPROGRAM

        	#pragma multi_compile _ALPHATEST_ON
        	#pragma multi_compile_instancing
        	#pragma multi_compile _ LOD_FADE_CROSSFADE
        	#define ASE_TESSELLATION 1
        	#pragma require tessellation tessHW
        	#pragma hull HullFunction
        	#pragma domain DomainFunction
        	#define ASE_PHONG_TESSELLATION
        	#define ASE_LENGTH_TESSELLATION
        	#define ASE_VERSION 19800
        	#define ASE_SRP_VERSION 170003


        	#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define VARYINGS_NEED_NORMAL_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

            #if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#include "MMD_Custom_Node_(URP_ASE).hlsl"
			#define ASE_NEEDS_VERT_NORMAL
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile_fog
			#pragma multi_compile _ _FOG_ON
			#ifdef _FOG_ON
			#define ASE_FOG 1
			#endif


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float3 positionWS : TEXCOORD1;
				float3 normalWS : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _OutlineColor;
			float4 _Specular;
			float4 _SubTex_ST;
			float4 _Ambient;
			float4 _Color;
			float3 _ToonTone;
			float _SShad;
			float _EFFECTS;
			float _CastShadows;
			float _SPHOpacity;
			int _UVLayer;
			float _Shininess;
			float _SpecularIntensity;
			float _MultipleLights;
			float _ShadowLum;
			float _Cutoff;
			float _AlphaClip;
			float _Surface;
			float _ExtrusionAmount;
			float _EdgeSize;
			float _On;
			float _PhongTessStrength;
			float _EdgeLength;
			float _Fog;
			float _Blend;
			float _Cull;
			float _SrcBlend;
			float _DstBlend;
			float _ZWrite;
			float _ZWriteControl;
			float _ZTest;
			float _HDR;
			float _Opaque;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _SubTex;
			sampler2D _MainTex;


			
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);

				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float TessExtrusionAmount513 = _ExtrusionAmount;
				
				output.ase_texcoord3.xy = input.ase_texcoord.xy;
				output.ase_texcoord3.zw = input.ase_texcoord1.xy;
				output.ase_texcoord4.xy = input.ase_texcoord2.xy;
				output.ase_texcoord4.zw = input.ase_texcoord3.xy;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( TessExtrusionAmount513 * input.normalOS );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				output.positionCS = vertexInput.positionCS;
				output.clipPosV = vertexInput.positionCS;
				output.positionWS = vertexInput.positionWS;
				output.normalWS = TransformObjectToWorldNormal( input.normalOS );
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_texcoord2 = input.ase_texcoord2;
				output.ase_texcoord3 = input.ase_texcoord3;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _EdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				output.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _PhongTessStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			void frag(PackedVaryings input
						, out half4 outNormalWS : SV_Target0
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						#ifdef _WRITE_RENDERING_LAYERS
						, out float4 outRenderingLayers : SV_Target1
						#endif
						 )
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );
				float3 WorldPosition = input.positionWS;
				float3 WorldNormal = input.normalWS;
				float4 ClipPos = input.clipPosV;
				float4 ScreenPos = ComputeScreenPos( input.clipPosV );

				float tSgurfaceType248 = _Surface;
				float tSphereMapBlend289 = _EFFECTS;
				int localuvLayer391 = ( 0 );
				float Layer391 = (float)_UVLayer;
				float2 uv_SubTex = input.ase_texcoord3.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv0391 = uv_SubTex;
				float2 uv2_SubTex = input.ase_texcoord3.zw * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv1391 = uv2_SubTex;
				float2 uv3_SubTex = input.ase_texcoord4.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv2391 = uv3_SubTex;
				float2 uv4_SubTex = input.ase_texcoord4.zw * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv3391 = uv4_SubTex;
				float2 UV391 = float2( 0,0 );
				uvLayer_float( Layer391 , uv0391 , uv1391 , uv2391 , uv3391 , UV391 );
				float4 tex2DNode379 = tex2D( _SubTex, UV391 );
				float2 uv_MainTex = input.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 Albedo12 = tex2D( _MainTex, uv_MainTex );
				
				float myAlphaCutoff323 = ( _AlphaClip == (float)1 ? _Cutoff : 0.0001 );
				

				float Alpha = ( tSgurfaceType248 == (float)0 ? (float)1 : saturate( ( _Opaque * ( tSphereMapBlend289 == (float)3 ? ( tex2DNode379.a * Albedo12.a ) : Albedo12.a ) ) ) );
				float AlphaClipThreshold = myAlphaCutoff323;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				#if defined(_GBUFFER_NORMALS_OCT)
					float3 normalWS = normalize(input.normalWS);
					float2 octNormalWS = PackNormalOctQuadEncode(normalWS);
					float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);
					half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);
					outNormalWS = half4(packedNormalWS, 0.0);
				#else
					float3 normalWS = input.normalWS;
					outNormalWS = half4(NormalizeNormalPerPixel(normalWS), 0.0);
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4(EncodeMeshRenderingLayer(renderingLayers), 0, 0, 0);
				#endif
			}
			ENDHLSL
		}
		
	
	}
	
	CustomEditor "MMDTessellationMaterialCustomInspector_AmplifyShaderEditor"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19800
Node;AmplifyShaderEditor.CommentaryNode;282;-2656,-4160;Inherit;False;2145.128;2174.384;Sphere Map Composition - Option to Add, Multiply, Sub Tex, Turn off the effect;35;401;399;408;284;400;379;57;63;56;289;207;407;406;405;283;377;378;380;80;75;78;79;77;73;39;71;477;478;384;484;391;485;486;487;488;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;478;-2560,-2816;Inherit;True;Property;_SubTex;SPH SubTex;14;0;Create;False;0;0;0;False;0;False;None;a4bd0e91e1c27e244a687b69ae743b93;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CommentaryNode;273;-4096,-7648;Inherit;False;1665.6;1246.8;Base Properties;17;32;292;12;37;44;13;11;28;10;40;43;65;64;67;109;66;110;;1,1,1,1;0;0
Node;AmplifyShaderEditor.IntNode;384;-2080,-2624;Inherit;False;Property;_UVLayer;UV Layer;13;1;[Enum];Create;True;0;4;Layer 1;0;Layer 2;1;Layer 3;2;Layer 4;3;0;False;0;False;0;1;False;0;1;INT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;484;-2144,-2528;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;485;-2144,-2400;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;486;-2144,-2272;Inherit;False;2;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;487;-2144,-2144;Inherit;False;3;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;10;-2944,-7264;Inherit;True;Property;_MainTex;Texture;10;0;Create;False;1;Texture (Memo);0;0;False;0;False;-1;None;73029f145f0f8b2469831e89ee17037b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.CustomExpressionNode;391;-1824,-2464;Float;False;#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS$#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS$#pragma multi_compile_fragment _ _SHADOWS_SOFT$#pragma multi_compile _ SHADOWS_SHADOWMASK$$$#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING$$float3 diffuseColor = 0@$WorldNormal = normalize( WorldNormal)@$$int pixelLightCount = GetAdditionalLightsCount()@$for(int i = 0@  i < pixelLightCount@ i++)${$	Light light = GetAdditionalLight(i, WorldPosition)@$        	half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation)@$        	diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal)@$}$$return diffuseColor@$;7;File;6;True;Layer;FLOAT;0;In;;Inherit;False;True;uv0;FLOAT2;0,0;In;;Inherit;False;True;uv1;FLOAT2;0,0;In;;Inherit;False;True;uv2;FLOAT2;0,0;In;;Inherit;False;True;uv3;FLOAT2;0,0;In;;Inherit;False;True;UV;FLOAT2;0,0;Out;;Inherit;False;uvLayer;False;False;0;eaabac11517cd514998e1309a04e4362;True;7;0;INT;0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;2;INT;0;FLOAT2;7
Node;AmplifyShaderEditor.WireNode;488;-1744,-2736;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.CommentaryNode;276;-1408,-1280;Inherit;False;1792.641;864.4399;Color Transparency;15;246;205;249;247;250;27;412;16;414;411;410;413;17;14;415;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;-2656,-7264;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;379;-1536,-2464;Inherit;True;Property;_SubTex1;SPH SubTex1;14;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;a4bd0e91e1c27e244a687b69ae743b93;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.GetLocalVarNode;14;-1344,-672;Inherit;False;12;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;207;-1600,-4064;Inherit;True;Property;_EFFECTS;Effects;9;2;[Header];[Enum];Create;False;1;Texture (Memo);4;Disabled;0;Add Sphere;1;Multi Sphere;2;Sub Tex;3;0;False;0;False;0;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;477;-1168,-2192;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;289;-1408,-4064;Inherit;False;tSphereMapBlend;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;17;-1152,-672;Inherit;True;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.WireNode;415;-1040,-976;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;252;-2368,-7648;Inherit;False;926.4001;1502.8;SURFACE OPTIONS;20;320;227;228;321;323;322;221;229;230;231;226;232;225;224;223;248;510;511;512;513;;1,1,1,1;0;0
Node;AmplifyShaderEditor.IntNode;413;-864,-1040;Inherit;False;Constant;_Int0;Int 0;32;0;Create;True;0;0;0;False;0;False;3;0;False;0;1;INT;0
Node;AmplifyShaderEditor.GetLocalVarNode;410;-928,-1136;Inherit;False;289;tSphereMapBlend;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;411;-912,-896;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;414;-688,-688;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;320;-2144,-6272;Inherit;False;Constant;_Float2;Float 2;29;0;Create;True;0;0;0;False;0;False;0.0001;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;412;-576,-928;Inherit;True;0;4;0;FLOAT;0;False;1;INT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;227;-2272,-6528;Inherit;True;Property;_Cutoff;Alpha Cutoff;34;1;[HideInInspector];Create;False;0;0;0;True;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;228;-2112,-6816;Inherit;True;Property;_AlphaClip;Alpha Clip;33;1;[HideInInspector];Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;223;-2336,-7584;Inherit;True;Property;_Surface;Surface Type;25;1;[HideInInspector];Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-608,-1216;Inherit;True;Property;_Opaque;Opaque;3;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;321;-2304,-6624;Inherit;False;Constant;_Int12;Int 12;29;0;Create;True;0;0;0;False;0;False;1;0;False;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;512;-1920,-6272;Inherit;False;Property;_ExtrusionAmount;Extrusion Amount;24;0;Create;True;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;275;-1376,-7648;Inherit;False;1694.017;1537.14;Outline;4;324;277;278;498;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;248;-2144,-7584;Inherit;False;tSgurfaceType;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;322;-1920,-6624;Inherit;True;0;4;0;FLOAT;0;False;1;INT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-288,-928;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;513;-1696,-6272;Inherit;False;TessExtrusionAmount;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;476;-4864,-3744;Inherit;False;2142;764.76;Baked Lightmaps;12;457;474;458;460;473;467;468;466;471;454;455;472;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;281;-448,-4160;Inherit;False;766.3999;318;Main light color;4;176;175;177;178;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;280;-448,-3104;Inherit;False;829.5997;573.9999;Specular Final Calculation;6;86;88;82;87;83;85;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;279;-448,-2464;Inherit;False;764.8726;417.5675;Final Calculation Additional Lights;5;196;197;194;195;193;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;274;-4960,-7648;Inherit;False;796.562;1277.431;MMD constants;8;171;170;169;168;138;167;139;166;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;272;-4672,-4640;Inherit;False;1950.375;831.9285;Light Calculation;16;113;190;174;112;90;52;58;54;53;51;50;111;114;294;34;188;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;271;-4448,-2912;Inherit;False;1724.8;794.8001;Specular;14;123;125;124;180;129;131;127;179;126;181;122;121;130;128;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;270;-4512,-2048;Inherit;False;1791.2;765.4001;Additional lights;12;268;303;312;304;307;261;260;263;265;440;441;442;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;19;-2720,-6080;Inherit;False;925.5996;319.0001;globalAmbient;4;143;187;142;141;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;20;-1216,-5056;Inherit;False;2335.284;833.136;RAMP;20;435;437;430;429;427;93;92;436;431;433;432;434;295;94;47;97;96;95;46;426;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;21;-6048,-4640;Inherit;False;1310.401;542.2002;NdotL;7;89;62;59;60;61;84;68;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;22;-4512,-6080;Inherit;False;1726.917;637.1161;MMDLit_GetTempAmbientL;10;135;164;33;134;31;165;29;41;163;162;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;23;-2656,-5696;Inherit;False;857.6006;408.6001;MMDLit_GetAmbientRate;4;35;161;136;48;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;24;-1728,-6048;Inherit;False;572;316.6001;MMDLit_GetTempAmbient;2;144;70;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;25;-2656,-4576;Inherit;False;673.5999;319.8001;ToonRefl;3;416;38;36;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;26;-5024,-5376;Inherit;False;2302.557;671.2762;MMDLit_GetTempDiffuse;16;160;157;145;153;147;159;158;152;151;149;154;150;155;148;146;156;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;278;-1344,-7584;Inherit;False;1246.42;666.926;Color and Transparency Line;11;317;318;316;315;313;209;216;293;214;251;208;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;277;-1341.6,-6880;Inherit;False;956;733.3997;Line width;9;438;201;215;202;200;212;314;514;515;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;335;96,-1984;Inherit;False;222.2587;416.6802;Fog;2;326;373;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;417;-2656,-5056;Inherit;False;1375.195;414.165;MMDLIT_GetToonShadow;8;424;423;421;422;420;418;419;425;;1,1,1,1;0;0
Node;AmplifyShaderEditor.IntNode;250;-64,-1024;Inherit;False;Constant;_Int5;Int 0;10;0;Create;True;0;0;0;False;0;False;1;0;False;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;247;-64,-1120;Inherit;False;Constant;_Int4;Int 0;10;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.GetLocalVarNode;249;-128,-1216;Inherit;False;248;tSgurfaceType;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;323;-1664,-6624;Inherit;False;myAlphaCutoff;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;205;-64,-928;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;516;-80,-352;Inherit;False;513;TessExtrusionAmount;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;517;-80,-224;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;68;-6016,-4576;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;128;-3648,-2848;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;130;-3424,-2848;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;121;-3456,-2592;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;-128,-4096;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;-352,-2752;Inherit;False;178;lightColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-128,-3040;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;160,-3040;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;195;-96,-2400;Inherit;False;73;baseC;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;193;96,-2400;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;194;-112,-2304;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;196;-384,-2304;Inherit;False;268;mmdAdditionalLights;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;197;-416,-2208;Inherit;False;48;MMDLit_GetAmbientRate;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;178;96,-4096;Inherit;False;lightColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;84;-5792,-4576;Inherit;True;Object;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;60;-5536,-4320;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;59;-5536,-4576;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;62;-5248,-4448;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;181;-3936,-2848;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;126;-4160,-2592;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;179;-4416,-2848;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;127;-3936,-2592;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;260;-4480,-1728;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;110;-4032,-7040;Inherit;True;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;66;-4032,-6784;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;109;-3776,-7040;Inherit;True;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformDirectionNode;67;-3776,-6784;Inherit;True;Object;View;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;64;-3520,-7040;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;65;-3520,-6784;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ReflectOpNode;43;-3232,-7040;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-2656,-6592;Inherit;False;Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;-2656,-6816;Inherit;False;Ambient;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-2656,-7040;Inherit;False;SphereCube;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-2656,-7584;Inherit;False;ToonTone;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;251;-1088,-7520;Inherit;False;248;tSgurfaceType;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;214;-832,-7392;Inherit;True;0;4;0;FLOAT;0;False;1;INT;0;False;2;INT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;293;-1024,-7360;Inherit;False;Constant;_Int6;Int 6;40;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;216;-1024,-7264;Inherit;False;Constant;_Int3;Int 0;10;0;Create;True;0;0;0;False;0;False;1;0;False;0;1;INT;0
Node;AmplifyShaderEditor.SaturateNode;209;-1024,-7168;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;315;-352,-7360;Inherit;True;0;4;0;FLOAT;0;False;1;INT;0;False;2;FLOAT;0;False;3;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;316;-544,-7360;Inherit;False;Constant;_Int10;Int 6;40;0;Create;True;0;0;0;False;0;False;1;0;False;0;1;INT;0
Node;AmplifyShaderEditor.WireNode;318;-592,-7312;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;317;-544,-7232;Inherit;False;Constant;_Int11;Int 0;10;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.Compare;212;-640,-6816;Inherit;True;0;4;0;FLOAT;0;False;1;INT;0;False;2;INT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;324;-288,-6880;Inherit;False;323;myAlphaCutoff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;167;-4928,-7264;Half;True;Constant;_Vector3;Vector 2;14;0;Create;True;0;0;0;False;0;False;0.5,0.5,0.5;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;138;-4704,-7264;Half;False;MMDLIT_CENTERAMBIENT;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;168;-4928,-6944;Half;True;Constant;_Vector4;Vector 2;14;0;Create;True;0;0;0;False;0;False;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;169;-4928,-6624;Inherit;True;Constant;_Float7;Float 7;10;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;170;-4736,-6816;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;171;-4512,-6816;Half;False;MMDLIT_CENTERAMBIENT_INV;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;162;-4064,-5920;Inherit;True;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;163;-4288,-5920;Inherit;True;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.Vector3Node;41;-3840,-5760;Inherit;True;Constant;_Vector0;Vector 0;3;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;29;-3840,-6016;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;165;-4128,-6016;Inherit;False;138;MMDLIT_CENTERAMBIENT;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;31;-3584,-6016;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;134;-3616,-5760;Inherit;False;171;MMDLIT_CENTERAMBIENT_INV;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-3296,-6016;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;136;-2624,-5632;Inherit;True;FLOAT3;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;35;-2304,-5632;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;142;-2688,-6016;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;187;-2240,-6016;Float;False;return SampleSH(normal)@$;7;File;2;True;normal;FLOAT3;0,0,0;In;;Inherit;False;True;Output;FLOAT3;0,0,0;Out;;Inherit;False;vLight;False;False;0;eaabac11517cd514998e1309a04e4362;True;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;2;FLOAT;0;FLOAT3;3
Node;AmplifyShaderEditor.GetLocalVarNode;164;-4480,-5920;Inherit;False;44;Ambient;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;143;-2016,-6016;Inherit;False;globalAmbient;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-2080,-5632;Inherit;False;MMDLit_GetAmbientRate;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-1696,-5984;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StickyNoteNode;342;1056,-1152;Inherit;False;572.4;1000.8;Notes;;1,1,0,1;==Material Color==$Diffuse = Material color.$$Specular = Color of light reflection/glow.$$Ambient = (It affects the model's color and lighting too so I think it's like a raycast)$$Opaque = Alpha value.$$Reflection = Reflection value.$$==Rendering==$2-SIDE = Renders both sides of the mesh. [Equivalent to Render Face/_Cull]$$G-SHAD = Shadow on the ground. [Equivalent to Cast Shadows/ShaderPass"SHADOWCASTER"]$$S-MAP = Shadow on the mesh. (Including herself) [Equivalent to Receive Shadows/_ReceiveShadows/Keyword"_RECEIVE_SHADOWS_OFF"]$$S-SHAD = Receives shade only from himself.$$==Edge (Outline)==$On = Activate the outline.$$Color = Contour color including transparesis.$$Size = Outline size/distance.$$==Texture/Memo==$Texture = Material texture.$$Toon = Complements the remains of the object.$$SPH = Artificial reflection to compromise Specular.$$***Effects***$It uses the SPH texture.$$Disabled = does not do anything.$$Multi-Sphere = It multiplies a glowing sphere map. (It gives me a feeling of being a metallic reflection)$$Add-Sphere = It creates a glowing sphere map. (It gives me a feeling of being a reflection of practical)$$Sub-Tex = It changes the SPH from 'Cube Texture' to 'Texture' to allow the use of Subtexture to place more than one texture on the same material.$The new texture is applied to another UV Layer allowing the creation of more complex effects. (This function replaces Add-Sphere and Multi-Sphere);0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;156;-3504,-5280;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMinOpNode;146;-3840,-5280;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;148;-4096,-5280;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;155;-3456,-5024;Inherit;True;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;150;-4576,-5280;Inherit;True;FLOAT3;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;154;-4064,-5024;Inherit;True;FLOAT3;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;-4992,-5280;Inherit;False;44;Ambient;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;151;-4800,-5280;Inherit;True;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;152;-4576,-5056;Inherit;True;FLOAT3;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;158;-4992,-5056;Inherit;False;13;Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;159;-4800,-5056;Inherit;True;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;-4320,-5056;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;153;-4640,-4800;Inherit;False;139;MMDLIT_GLOBALLIGHTING;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;-3808,-5024;Inherit;False;144;MMDLit_GetTempAmbient;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;157;-3232,-5280;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;200;-1120,-6368;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;202;-864,-6592;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;129;-3200,-2848;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;180;-4160,-2848;Inherit;True;Object;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;123;-3648,-2368;Inherit;True;Constant;_smoothness;smoothness;11;0;Create;True;0;0;0;False;0;False;0.001;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;312;-3584,-1376;Inherit;False;143;globalAmbient;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Compare;303;-3232,-1760;Inherit;True;0;4;0;FLOAT;0;False;1;INT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;160;-3008,-5280;Inherit;False;MMDLit_GetTempDiffuse;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMinOpNode;36;-2624,-4512;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;313;-640,-7520;Inherit;False;314;OutlineStatus;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;215;-864,-6720;Inherit;False;Constant;_Int2;Int 0;10;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.Compare;246;128,-1120;Inherit;True;0;4;0;FLOAT;0;False;1;INT;0;False;2;INT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;221;-2112,-7072;Inherit;True;Property;_CastShadows;Cast Shadows;35;1;[HideInInspector];Create;False;0;0;0;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;-352,-3040;Inherit;False;131;Specular;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;71;-1792,-3840;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1792,-3584;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;-928,-3776;Inherit;False;baseC;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-1408,-3392;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;-1792,-3328;Inherit;False;160;MMDLit_GetTempDiffuse;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-1408,-3136;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;-1632,-3072;Inherit;False;12;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;80;-1152,-2912;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;380;-1152,-2656;Inherit;True;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;378;-1504,-2656;Inherit;False;160;MMDLit_GetTempDiffuse;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;377;-1504,-2560;Inherit;False;12;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;283;-2016,-3712;Inherit;False;12;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;405;-2064,-3760;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;406;-2016,-3456;Inherit;False;12;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;407;-2064,-3088;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;-2560,-3584;Inherit;False;37;SphereCube;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-2304,-3584;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomExpressionNode;400;-1120,-3776;Float;False;#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS$#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS$#pragma multi_compile_fragment _ _SHADOWS_SOFT$#pragma multi_compile _ SHADOWS_SHADOWMASK$$$#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING$$float3 diffuseColor = 0@$WorldNormal = normalize( WorldNormal)@$$int pixelLightCount = GetAdditionalLightsCount()@$for(int i = 0@  i < pixelLightCount@ i++)${$	Light light = GetAdditionalLight(i, WorldPosition)@$        	half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation)@$        	diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal)@$}$$return diffuseColor@$;7;File;6;True;Layer;FLOAT;0;In;;Inherit;False;True;Base;FLOAT4;0,0,0,0;In;;Inherit;False;True;Add;FLOAT4;0,0,0,0;In;;Inherit;False;True;Multi;FLOAT4;0,0,0,0;In;;Inherit;False;True;Sub;FLOAT4;0,0,0,0;In;;Inherit;False;True;RGBA;FLOAT4;0,0,0,0;Out;;Inherit;False;effectsControl;False;False;0;eaabac11517cd514998e1309a04e4362;True;7;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;2;FLOAT;0;FLOAT4;7
Node;AmplifyShaderEditor.GetLocalVarNode;284;-1408,-3840;Inherit;False;12;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;408;-1408,-3520;Inherit;False;12;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;401;-992,-3328;Inherit;False;289;tSphereMapBlend;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;419;-2624,-4896;Inherit;False;Constant;_Float3;Float 3;33;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;418;-2400,-4992;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;420;-2176,-4992;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;422;-2112,-4736;Inherit;False;Constant;_Float4;Float 4;33;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;421;-1920,-4992;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;423;-1696,-4992;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;426;-928,-4768;Inherit;True;0;4;0;FLOAT;0;False;1;INT;0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;46;192,-4672;Inherit;True;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;480,-4672;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;96;704,-4672;Inherit;True;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;97;928,-4672;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;94;512,-4768;Inherit;False;Constant;_Float5;Float 5;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;295;32,-4704;Inherit;False;Constant;_Float0;Float 0;40;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;434;-96,-4608;Inherit;True;0;4;0;FLOAT;0;False;1;INT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;432;-672,-4512;Inherit;False;Constant;_Vector5;Vector 5;33;0;Create;True;0;0;0;False;0;False;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;433;-672,-4320;Inherit;False;424;toonShadow;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;431;-384,-4480;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;436;-208,-4848;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;93;-1184,-4640;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;427;-1120,-4384;Inherit;False;Constant;_Vector1;Vector 1;32;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.IntNode;430;-1152,-4736;Inherit;False;Constant;_Int1;Int 1;33;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.WireNode;437;-336,-4592;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.IntNode;435;-320,-4672;Inherit;False;Constant;_Int7;Int 1;33;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;1312,-4160;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;69;1664,-3072;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;172;1920,-2432;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;336;2144,-2432;Inherit;False;FinalColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;161;-2624,-5376;Inherit;False;135;MMDLit_GetTempAmbientL;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;144;-1472,-5984;Inherit;False;MMDLit_GetTempAmbient;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;229;-2336,-7072;Inherit;True;Property;_ZTest;_ZTest;32;1;[HideInInspector];Create;False;0;0;0;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;230;-1664,-7328;Inherit;True;Property;_ZWriteControl;_ZWriteControl;31;1;[HideInInspector];Create;False;0;0;0;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;231;-1888,-7328;Inherit;True;Property;_ZWrite;__zw;30;1;[HideInInspector];Create;False;0;0;0;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;226;-2112,-7328;Inherit;True;Property;_DstBlend;__dst;29;1;[HideInInspector];Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;232;-2336,-7328;Inherit;True;Property;_SrcBlend;__src;28;1;[HideInInspector];Create;False;0;0;0;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;225;-1664,-7584;Inherit;True;Property;_Cull;Render Face;27;1;[HideInInspector];Create;False;0;0;0;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;224;-1888,-7584;Inherit;True;Property;_Blend;Blending Mode;26;1;[HideInInspector];Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;292;-2848,-7584;Inherit;True;Property;_ToonTone;Toon Tone;19;0;Create;False;0;0;0;False;0;False;1,0.5,0.5;1,0.5,0.5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;47;192,-4928;Inherit;True;Property;_ShadowLum;Shadow Luminescence;17;0;Create;False;0;0;0;False;0;False;1.5;1.5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-2624,-3488;Inherit;True;Property;_SPHOpacity;SPH Opacity;16;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-128,-2784;Inherit;True;Property;_SpecularIntensity;Specular Intensity;15;1;[Header];Create;True;1;Custom Effects Settings;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;208;-1312,-7424;Inherit;False;Property;_OutlineColor;Color;7;0;Create;False;0;0;0;False;0;False;0,0,0,1;0,0,0,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;122;-3648,-2592;Inherit;True;Property;_Shininess;Reflection;4;0;Create;False;0;0;0;False;0;False;50;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;28;-2880,-6816;Inherit;False;Property;_Ambient;Ambient;2;0;Create;True;1;;0;0;False;0;False;1,1,1,0;0,1,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ColorNode;82;-416,-2944;Inherit;False;Property;_Specular;Specular;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.6,0.1999999,0.6,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ColorNode;11;-2880,-6592;Inherit;False;Property;_Color;Diffuse;0;1;[Header];Create;False;1;Material Color;0;0;False;0;False;0.8,0.8,0.8,0;1,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode;40;-2944,-7040;Inherit;True;Property;_SphereCube;SPH;12;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;a8a7bd80f070ab24abe78fbeb282fe0f;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.TransformDirectionNode;141;-2464,-6016;Inherit;True;Object;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;92;-672,-4768;Inherit;True;Property;_ToonTex;Toon;11;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;f35b8759e2061eb469494abb58b512c1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;429;-1152,-4992;Inherit;True;Property;_SShad;S-Shad;5;2;[Header];[ToggleUI];Create;True;1;Rendering;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;307;-3488,-1984;Inherit;True;Property;_MultipleLights;Multiple Lights;20;1;[ToggleUI];Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;304;-3488,-1728;Inherit;False;Constant;_Int9;Int 9;37;0;Create;True;0;0;0;False;0;False;1;0;False;0;1;INT;0
Node;AmplifyShaderEditor.GetLocalVarNode;263;-3904,-1600;Inherit;False;143;globalAmbient;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;261;-4224,-1728;Inherit;True;Object;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;265;-3584,-1632;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;373;128,-1920;Inherit;False;336;FinalColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;326;144,-1824;Inherit;True;Property;_Fog;Fog;21;1;[Toggle];Create;True;0;0;1;UnityEngine.Rendering.CullMode;True;1;_FOG_ON;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;441;-4224,-1472;Inherit;False;Shadow Mask;-1;;92;b50f5becdd6b8504a861ba5b9b861159;0;1;3;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;442;-3904,-1728;Inherit;False;SRP Additional Light;-1;;94;6c86746ad131a0a408ca599df5f40861;3,6,1,9,1,23,0;6;2;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;15;FLOAT3;0,0,0;False;14;FLOAT3;0,0,0;False;18;FLOAT;0.5;False;32;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;440;-4480,-1472;Inherit;False;Lightmap UV;-1;;96;1940f027d0458684eb0ad486f669d7d5;1,1,1;0;1;FLOAT2;0
Node;AmplifyShaderEditor.CustomExpressionNode;399;-736,-3200;Float;False;#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS$#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS$#pragma multi_compile_fragment _ _SHADOWS_SOFT$#pragma multi_compile _ SHADOWS_SHADOWMASK$$$#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING$$float3 diffuseColor = 0@$WorldNormal = normalize( WorldNormal)@$$int pixelLightCount = GetAdditionalLightsCount()@$for(int i = 0@  i < pixelLightCount@ i++)${$	Light light = GetAdditionalLight(i, WorldPosition)@$        	half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation)@$        	diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal)@$}$$return diffuseColor@$;7;File;6;True;Layer;FLOAT;0;In;;Inherit;False;True;Base;FLOAT4;0,0,0,0;In;;Inherit;False;True;Add;FLOAT4;0,0,0,0;In;;Inherit;False;True;Multi;FLOAT4;0,0,0,0;In;;Inherit;False;True;Sub;FLOAT4;0,0,0,0;In;;Inherit;False;True;RGBA;FLOAT4;0,0,0,0;Out;;Inherit;False;effectsControl;False;False;0;eaabac11517cd514998e1309a04e4362;True;7;0;INT;0;False;1;FLOAT;0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;2;INT;0;FLOAT4;7
Node;AmplifyShaderEditor.SaturateNode;38;-2176,-4512;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;371;416,-1920;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;370;64,-1536;Inherit;True;Property;_HDR;HDR;18;0;Create;True;0;0;0;False;0;False;1;1;1;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;139;-4704,-7584;Half;False;MMDLIT_GLOBALLIGHTING;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;166;-4928,-7584;Half;True;Constant;_Vector2;Vector 2;14;0;Create;True;0;0;0;False;0;False;0.6,0.6,0.6;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;175;-416,-4096;Inherit;False;474;originalBakedLightColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;455;-4832,-3648;Inherit;False;Lightmap UV;-1;;97;1940f027d0458684eb0ad486f669d7d5;1,1,0;0;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;468;-4096,-3488;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IntNode;467;-4000,-3584;Inherit;False;Constant;_Int8;Int 8;33;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.GetLocalVarNode;473;-4000,-3232;Inherit;False;174;originalLightColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Compare;460;-3744,-3488;Inherit;True;0;4;0;FLOAT3;0,0,0;False;1;INT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;458;-3456,-3232;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;131;-2944,-2848;Inherit;False;Specular;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;268;-2976,-1760;Inherit;False;mmdAdditionalLights;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;416;-2400,-4512;Inherit;False;toonRefl;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-2976,-4576;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;51;-2976,-4288;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-3328,-4224;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-3328,-4576;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-3552,-4480;Inherit;False;89;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;112;-3584,-4160;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;190;-3968,-4192;Float;False;#pragma multi_compile _ _MAIN_LIGHT_SHADOWS$#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE$float4 shadowCoord = TransformWorldToShadowCoord(worldPos)@$Light mainLight = GetMainLight(shadowCoord)@$return mainLight.shadowAttenuation@;7;File;2;True;worldPos;FLOAT3;0,0,0;In;;Inherit;False;True;OutputShadowAtten;FLOAT;0;Out;;Inherit;False;shadowAtten;False;False;0;eaabac11517cd514998e1309a04e4362;True;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;2;FLOAT;0;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;111;-3808,-4064;Inherit;False;Constant;_Float1;Float 1;5;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;114;-4384,-4192;Inherit;True;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;113;-4640,-4192;Inherit;True;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;52;-3936,-4448;Inherit;True;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;90;-4192,-4448;Inherit;False;32;ToonTone;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;188;-4096,-3936;Float;False;$float4 shadowCoord = TransformWorldToShadowCoord(worldPos)@$Light mainLight = GetMainLight(shadowCoord)@$return mainLight.color@;7;File;2;True;worldPos;FLOAT3;0,0,0;In;;Inherit;False;True;OutputColor;FLOAT3;0,0,0;Out;;Inherit;False;lightColor;False;False;0;eaabac11517cd514998e1309a04e4362;True;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;2;FLOAT;0;FLOAT3;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;174;-3840,-3936;Inherit;False;originalLightColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;294;-3120,-4368;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;34;-3600,-4528;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;89;-4992,-4448;Inherit;False;NdotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;125;-4416,-2400;Inherit;True;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;124;-4416,-2624;Inherit;True;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;471;-4000,-3680;Inherit;False;174;originalLightColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;176;-416,-4000;Inherit;False;139;MMDLIT_GLOBALLIGHTING;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;474;-3008,-3488;Inherit;False;originalBakedLightColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;454;-4608,-3648;Float;False;#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS$#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS$#pragma multi_compile_fragment _ _SHADOWS_SOFT$#pragma multi_compile _ SHADOWS_SHADOWMASK$$$#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING$$float3 diffuseColor = 0@$WorldNormal = normalize( WorldNormal)@$$int pixelLightCount = GetAdditionalLightsCount()@$for(int i = 0@  i < pixelLightCount@ i++)${$	Light light = GetAdditionalLight(i, WorldPosition)@$        	half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation)@$        	diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal)@$}$$return diffuseColor@$;7;File;2;True;lightmapUV;FLOAT2;0,0;In;;Inherit;False;True;Output;FLOAT3;0,0,0;Out;;Inherit;False;lightmapCol;False;False;0;eaabac11517cd514998e1309a04e4362;True;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT3;0,0,0;False;2;FLOAT;0;FLOAT3;3
Node;AmplifyShaderEditor.StaticSwitch;457;-3232,-3488;Float;False;Property;_Keyword3;Keyword 2;2;0;Create;True;0;0;0;False;0;False;0;0;0;False;LIGHTMAP_ON;Toggle;2;Key0;Key1;Fetch;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;424;-1504,-4992;Inherit;False;toonShadow;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;425;-2624,-4992;Inherit;False;416;toonRefl;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;61;-5792,-4320;Inherit;True;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;466;-4288,-3392;Inherit;False;Constant;_Float6;Float 6;33;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;472;-4240,-3152;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;135;-3072,-6016;Inherit;False;MMDLit_GetTempAmbientL;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;509;-624,-7440;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;510;-1888,-7072;Inherit;False;Property;_EdgeLength;Edge Length;22;0;Create;True;0;0;0;True;0;False;5;5;2;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;511;-1888,-6976;Inherit;False;Property;_PhongTessStrength;Phong Tess Strength;23;0;Create;True;0;0;0;True;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;201;-1312,-6592;Inherit;True;Property;_EdgeSize;Size;8;0;Create;False;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;438;-1312,-6816;Inherit;True;Property;_On;On;6;2;[Header];[ToggleUI];Create;True;1;Edge (Outline);0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;314;-1120,-6816;Inherit;False;OutlineStatus;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;514;-1120,-6592;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;515;-1168,-6288;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;518;208,-352;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;325;448,-1024;Inherit;False;323;myAlphaCutoff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;500;768,-1152;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;501;768,-1152;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;502;768,-1152;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;503;768,-1152;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;504;768,-1152;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;505;768,-1152;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;506;768,-1152;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;507;768,-1152;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;508;768,-1152;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;MotionVectors;0;10;MotionVectors;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;False;False;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=MotionVectors;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;499;768,-1152;Float;False;True;-1;2;MMDTessellationMaterialCustomInspector_AmplifyShaderEditor;0;13;MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor);2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;9;False;False;False;False;False;False;False;False;False;False;False;False;True;0;True;_Invalid;True;True;0;True;_Cull;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=_Surface=RenderType;Queue=Overlay=Queue=-2000;UniversalMaterialType=Unlit;True;5;True;12;all;0;True;True;1;1;True;_SrcBlend;0;True;_DstBlend;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;1;True;_ZWrite;True;3;True;_ZTest;True;True;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;12;Include;;False;;Native;False;0;0;;Pragma;multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE;False;;Custom;False;0;0;;Pragma;multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS;False;;Custom;False;0;0;;Pragma;multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS;False;;Custom;False;0;0;;Pragma;multi_compile_fragment _ _SHADOWS_SOFT;False;;Custom;False;0;0;;Pragma;multi_compile _ SHADOWS_SHADOWMASK;False;;Custom;False;0;0;;Pragma;multi_compile _ LIGHTMAP_SHADOW_MIXING;False;;Custom;False;0;0;;Pragma;multi_compile_fog;False;;Custom;False;0;0;;Pragma;multi_compile _ _FOG_ON;False;;Custom;False;0;0;;Custom;#ifdef _FOG_ON;False;;Custom;False;0;0;;Define;ASE_FOG 1;False;;Custom;False;0;0;;Custom;#endif;False;;Custom;False;0;0;;;0;0;Standard;27;Surface;0;0;  Blend;0;0;Two Sided;1;0;Alpha Clipping;1;0;  Use Shadow Threshold;0;0;Forward Only;0;0;Cast Shadows;1;0;Receive Shadows;1;0;Motion Vectors;0;0;  Add Precomputed Velocity;0;0;GPU Instancing;1;0;LOD CrossFade;1;0;Built-in Fog;0;638670621200094653;Meta Pass;0;0;Extra Pre Pass;1;638670624603007853;Tessellation;1;638670638954938407;  Phong;1;638670638974924703;  Strength;0.5,True,_PhongTessStrength;638670639086480540;  Type;2;638670641429772971;  Tess;16,True,_EdgeLength;638670639265146067;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;20,True,_EdgeLength;0;  Max Displacement;25,False,;0;Write Depth;0;0;  Early Z;0;0;Vertex Position,InvertActionOnDeselection;1;0;0;11;True;True;True;True;False;False;True;True;True;False;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;498;32,-1348;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;OutlinePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;True;True;1;0;True;_SrcBlend;0;True;_DstBlend;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;True;True;1;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;1;True;_ZWrite;True;3;True;_ZTest;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
WireConnection;484;2;478;0
WireConnection;485;2;478;0
WireConnection;486;2;478;0
WireConnection;487;2;478;0
WireConnection;391;1;384;0
WireConnection;391;2;484;0
WireConnection;391;3;485;0
WireConnection;391;4;486;0
WireConnection;391;5;487;0
WireConnection;488;0;478;0
WireConnection;12;0;10;0
WireConnection;379;0;488;0
WireConnection;379;1;391;7
WireConnection;477;0;379;4
WireConnection;289;0;207;0
WireConnection;17;0;14;0
WireConnection;415;0;477;0
WireConnection;411;0;415;0
WireConnection;411;1;17;3
WireConnection;414;0;17;3
WireConnection;412;0;410;0
WireConnection;412;1;413;0
WireConnection;412;2;411;0
WireConnection;412;3;414;0
WireConnection;248;0;223;0
WireConnection;322;0;228;0
WireConnection;322;1;321;0
WireConnection;322;2;227;0
WireConnection;322;3;320;0
WireConnection;27;0;16;0
WireConnection;27;1;412;0
WireConnection;513;0;512;0
WireConnection;323;0;322;0
WireConnection;205;0;27;0
WireConnection;128;0;181;0
WireConnection;128;1;127;0
WireConnection;130;0;128;0
WireConnection;121;0;122;0
WireConnection;121;1;123;0
WireConnection;177;0;175;0
WireConnection;177;1;176;0
WireConnection;83;0;86;0
WireConnection;83;1;82;0
WireConnection;83;2;85;0
WireConnection;87;0;83;0
WireConnection;87;1;88;0
WireConnection;193;0;195;0
WireConnection;193;1;194;0
WireConnection;194;0;196;0
WireConnection;194;1;197;0
WireConnection;178;0;177;0
WireConnection;84;0;68;0
WireConnection;60;0;61;0
WireConnection;59;0;84;0
WireConnection;62;0;59;0
WireConnection;62;1;60;0
WireConnection;181;0;180;0
WireConnection;126;0;124;0
WireConnection;126;1;125;0
WireConnection;127;0;126;0
WireConnection;109;0;110;0
WireConnection;67;0;66;0
WireConnection;64;0;109;0
WireConnection;65;0;67;0
WireConnection;43;0;64;0
WireConnection;43;1;65;0
WireConnection;13;0;11;0
WireConnection;44;0;28;0
WireConnection;37;0;40;0
WireConnection;32;0;292;0
WireConnection;214;0;251;0
WireConnection;214;1;293;0
WireConnection;214;2;216;0
WireConnection;214;3;209;0
WireConnection;209;0;208;4
WireConnection;315;0;313;0
WireConnection;315;1;316;0
WireConnection;315;2;318;0
WireConnection;315;3;317;0
WireConnection;318;0;214;0
WireConnection;212;0;314;0
WireConnection;212;1;215;0
WireConnection;212;2;215;0
WireConnection;212;3;202;0
WireConnection;138;0;167;0
WireConnection;170;0;168;0
WireConnection;170;1;169;0
WireConnection;171;0;170;0
WireConnection;162;0;163;0
WireConnection;162;1;163;1
WireConnection;162;2;163;2
WireConnection;163;0;164;0
WireConnection;29;0;165;0
WireConnection;29;1;162;0
WireConnection;31;0;29;0
WireConnection;31;1;41;0
WireConnection;33;0;31;0
WireConnection;33;1;134;0
WireConnection;35;0;136;0
WireConnection;35;1;161;0
WireConnection;187;1;141;0
WireConnection;143;0;187;3
WireConnection;48;0;35;0
WireConnection;70;0;143;0
WireConnection;70;1;48;0
WireConnection;156;0;146;0
WireConnection;156;1;145;0
WireConnection;146;0;148;0
WireConnection;146;1;154;0
WireConnection;148;0;150;0
WireConnection;148;1;147;0
WireConnection;150;0;151;0
WireConnection;150;1;151;1
WireConnection;150;2;151;2
WireConnection;151;0;149;0
WireConnection;152;0;159;0
WireConnection;152;1;159;1
WireConnection;152;2;159;2
WireConnection;159;0;158;0
WireConnection;147;0;152;0
WireConnection;147;1;153;0
WireConnection;157;0;156;0
WireConnection;157;1;155;0
WireConnection;202;0;514;0
WireConnection;202;1;200;0
WireConnection;129;0;130;0
WireConnection;129;1;121;0
WireConnection;180;0;179;0
WireConnection;303;0;307;0
WireConnection;303;1;304;0
WireConnection;303;2;265;0
WireConnection;303;3;312;0
WireConnection;160;0;157;0
WireConnection;36;0;53;0
WireConnection;36;1;51;0
WireConnection;246;0;249;0
WireConnection;246;1;247;0
WireConnection;246;2;250;0
WireConnection;246;3;205;0
WireConnection;71;0;405;0
WireConnection;71;1;283;0
WireConnection;39;0;57;0
WireConnection;39;1;406;0
WireConnection;73;0;400;7
WireConnection;77;0;39;0
WireConnection;77;1;79;0
WireConnection;78;0;79;0
WireConnection;78;1;75;0
WireConnection;80;0;78;0
WireConnection;80;1;407;0
WireConnection;380;0;378;0
WireConnection;380;1;377;0
WireConnection;380;2;379;0
WireConnection;405;0;57;0
WireConnection;407;0;57;0
WireConnection;57;0;63;0
WireConnection;57;1;56;0
WireConnection;400;1;289;0
WireConnection;400;2;284;0
WireConnection;400;3;71;0
WireConnection;400;4;39;0
WireConnection;400;5;408;0
WireConnection;418;0;425;0
WireConnection;418;1;419;0
WireConnection;420;0;418;0
WireConnection;420;1;418;0
WireConnection;421;0;420;0
WireConnection;421;1;422;0
WireConnection;423;0;421;0
WireConnection;426;0;429;0
WireConnection;426;1;430;0
WireConnection;426;2;93;0
WireConnection;426;3;427;0
WireConnection;46;0;295;0
WireConnection;46;1;434;0
WireConnection;95;0;47;0
WireConnection;95;1;46;0
WireConnection;96;0;94;0
WireConnection;96;1;95;0
WireConnection;97;0;96;0
WireConnection;434;0;436;0
WireConnection;434;1;435;0
WireConnection;434;2;437;0
WireConnection;434;3;431;0
WireConnection;431;0;92;0
WireConnection;431;1;432;0
WireConnection;431;2;433;0
WireConnection;436;0;429;0
WireConnection;93;0;38;0
WireConnection;93;1;38;0
WireConnection;437;0;92;0
WireConnection;49;0;97;0
WireConnection;49;1;178;0
WireConnection;49;2;399;7
WireConnection;69;0;49;0
WireConnection;69;1;87;0
WireConnection;172;0;69;0
WireConnection;172;1;193;0
WireConnection;336;0;172;0
WireConnection;144;0;70;0
WireConnection;40;1;43;0
WireConnection;141;0;142;0
WireConnection;92;1;426;0
WireConnection;261;0;260;0
WireConnection;265;0;442;0
WireConnection;265;1;263;0
WireConnection;441;3;440;0
WireConnection;442;11;261;0
WireConnection;442;32;441;0
WireConnection;399;1;401;0
WireConnection;399;2;78;0
WireConnection;399;3;80;0
WireConnection;399;4;77;0
WireConnection;399;5;380;0
WireConnection;38;0;416;0
WireConnection;371;0;373;0
WireConnection;371;1;370;0
WireConnection;139;0;166;0
WireConnection;468;0;454;3
WireConnection;468;1;466;0
WireConnection;460;0;471;0
WireConnection;460;1;467;0
WireConnection;460;2;468;0
WireConnection;460;3;473;0
WireConnection;458;0;460;0
WireConnection;458;1;472;0
WireConnection;131;0;129;0
WireConnection;268;0;303;0
WireConnection;416;0;36;0
WireConnection;53;0;54;0
WireConnection;53;1;294;0
WireConnection;51;0;52;2
WireConnection;51;1;50;0
WireConnection;50;0;52;0
WireConnection;50;1;112;0
WireConnection;54;0;34;0
WireConnection;54;1;58;0
WireConnection;112;0;190;3
WireConnection;112;1;111;0
WireConnection;190;1;114;0
WireConnection;114;0;113;0
WireConnection;52;0;90;0
WireConnection;188;1;114;0
WireConnection;174;0;188;3
WireConnection;294;0;52;2
WireConnection;34;0;52;1
WireConnection;89;0;62;0
WireConnection;474;0;457;0
WireConnection;454;1;455;0
WireConnection;457;1;471;0
WireConnection;457;0;458;0
WireConnection;424;0;423;0
WireConnection;472;0;454;3
WireConnection;135;0;33;0
WireConnection;509;0;208;0
WireConnection;314;0;438;0
WireConnection;514;0;201;0
WireConnection;514;1;515;0
WireConnection;515;0;513;0
WireConnection;518;0;516;0
WireConnection;518;1;517;0
WireConnection;499;2;371;0
WireConnection;499;3;246;0
WireConnection;499;4;325;0
WireConnection;499;5;518;0
WireConnection;498;0;509;0
WireConnection;498;1;315;0
WireConnection;498;2;324;0
WireConnection;498;3;212;0
ASEEND*/
//CHKSM=17A43F25A57B6D68ED6CF48029835BA36800B8A7