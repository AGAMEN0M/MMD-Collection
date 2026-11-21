// Made with Amplify Shader Editor v1.9.9.15
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMD Collection/URP/Effects/MMD Normal and Height Map - Tessellation (Amplify Shader Editor)"
{
	Properties
	{
		[HideInInspector] _Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5
		[Header(Material Color)] _Color( "Diffuse", Color ) = ( 0.8, 0.8, 0.8, 0 )
		_Specular( "Specular", Color ) = ( 0, 0, 0, 0 )
		_Ambient( "Ambient", Color ) = ( 1, 1, 1, 0 )
		_Opaque( "Opaque", Range( 0, 1 ) ) = 1
		_Shininess( "Reflection", Float ) = 50
		[Header(Rendering)][ToggleUI] _SShad( "S-Shad", Float ) = 1
		[Header(Edge (Outline))][ToggleUI] _On( "On", Float ) = 0
		_OutlineColor( "Color", Color ) = ( 0, 0, 0, 1 )
		_EdgeSize( "Size", Float ) = 0
		[Header(Texture (Memo))][Enum(Disabled,0,Add Sphere,1,Multi Sphere,2,Sub Tex,3)] _EFFECTS( "Effects", Float ) = 0
		_MainTex( "Texture", 2D ) = "white" {}
		[NoScaleOffset] _ToonTex( "Toon", 2D ) = "white" {}
		[NoScaleOffset] _SphereCube( "SPH", CUBE ) = "white" {}
		[Enum(Layer 1,0,Layer 2,1,Layer 3,2,Layer 4,3)] _UVLayer( "UV Layer", Integer ) = 0
		_SubTex( "SPH SubTex", 2D ) = "white" {}
		[Header(Custom Effects Settings)] _SpecularIntensity( "Specular Intensity", Range( 0, 1 ) ) = 1
		_SPHOpacity( "SPH Opacity", Range( 0, 1 ) ) = 1
		_ShadowLum( "Shadow Luminescence", Range( 0, 10 ) ) = 1.5
		_HDR( "HDR", Range( 1, 1000 ) ) = 1
		_ToonTone( "Toon Tone", Vector ) = ( 1, 0.5, 0.5, 0 )
		[ToggleUI] _MultipleLights( "Multiple Lights", Float ) = 1
		[Toggle( _FOG_ON )] _Fog( "Fog", Float ) = 1
		[Header(Simulator Normal Map Settings)][Toggle] _SimulatorNormalMap( "Simulator Normal Map", Float ) = 0
		[NoScaleOffset][Normal] _NormalMap( "Normal Map", 2D ) = "bump" {}
		_BumpScale( "Normal Scale", Float ) = 1
		[Header(Simulator Height Map Settings)][Toggle] _SimulatorHeightMap( "Simulator Height Map", Float ) = 0
		[NoScaleOffset] _ParallaxMap( "Height Map", 2D ) = "white" {}
		_Parallax( "Parallax", Range( 0.005, 0.08 ) ) = 0.005
		_EdgeLength( "Edge Length", Range( 2, 50 ) ) = 5
		_PhongTessStrength( "Phong Tess Strength", Range( 0, 1 ) ) = 0.5
		_ExtrusionAmount( "Extrusion Amount", Float ) = 0
		[HideInInspector] _Surface( "Surface Type", Float ) = 0
		[HideInInspector] _Blend( "Blending Mode", Float ) = 0
		[HideInInspector] _Cull( "Render Face", Float ) = 2
		[HideInInspector] _SrcBlend( "Src Blend (Auto)", Float ) = 1
		[HideInInspector] _DstBlend( "Dst Blend (Auto)", Float ) = 0
		[HideInInspector] _ZWriteControl( "Depth Write Mode", Float ) = 1
		[HideInInspector] _ZWrite( "ZWrite (Internal)", Float ) = 1
		[HideInInspector] _ZTest( "Depth Test", Float ) = 4
		[HideInInspector] _CastShadows( "Cast Shadows", Float ) = 1


		[HideInInspector] _TessPhongStrength( "Phong Tess Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		[HideInInspector] _TessEdgeLength ( "Edge length", Range( 2, 50 ) ) = 20
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}

		[HideInInspector][ToggleUI] _ReceiveShadows("Receive Shadows", Float) = 1.0
		//[Toggle(ASE_WRITE_DEPTH)] _WriteDepth("Write Depth", Float) = 1.0
		[HideInInspector][ToggleUI] _ScreenSpaceReflectionsContributeTransparent("Screen Space Reflections Contribute Transparent", Float) = 1.0

		[HideInInspector][ToggleUI] _AddPrecomputedVelocity("Add Precomputed Velocity", Float) = 1
		[HideInInspector] _XRMotionVectorsPass("_XRMotionVectorsPass", Float) = 1

		[HideInInspector] _AlphaClip("__clip", Float) = 0
	}

	SubShader
	{
		PackageRequirements
		{
			"com.unity.render-pipelines.universal": "[17.0,18.0]"
		}

		

		

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="_Surface" "Queue"="Overlay-2000" "UniversalMaterialType"="Unlit" "AlwaysRenderMotionVectors"="false" }

	LOD 0

		ZWrite On
		ZClip True
		Cull [_Cull]
		AlphaToMask Off
		Conservative False
		ColorMask RGBA
		Blend [_SrcBlend] [_DstBlend], One Zero
		BlendOp Add, Add

		

		HLSLINCLUDE
		#pragma target 5.0
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

		#ifndef GLOBAL_HEADER_INCLUDED
		#define GLOBAL_HEADER_INCLUDED

			#define ASE_ADJUST_CLIP_POSITION( x ) x

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

		#endif //GLOBAL_HEADER_INCLUDED
		ENDHLSL

		
		Pass
		{
			Name "OutlinePass"
			

			Cull Front
			ZWrite [_On]
			ZTest [_ZTest]
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#pragma shader_feature_local _ALPHATEST_ON
			#define _NORMAL_DROPOFF_TS 1
			#define ASE_OPAQUE_KEEP_ALPHA
			#define ASE_TESSELLATION 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_PHONG_TESSELLATION
			#define ASE_LENGTH_TESSELLATION
			#define ASE_FOG 1
			#define ASE_VERSION 19915
			#define ASE_SRP_VERSION 170600


			#pragma vertex vert
			#pragma fragment frag

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_VERT_NORMAL
			#pragma multi_compile _ _FOG_ON
			#ifndef _FOG_ON
			#undef ASE_FOG
			#endif
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING


			#if defined(DEBUG_DISPLAY) || defined(ASE_NEEDS_FRAG_WORLD_NORMAL) || defined(ASE_NEEDS_FRAG_WORLD_TANGENT) || defined(ASE_NEEDS_FRAG_WORLD_BITANGENT)
				#define ASE_NEEDS_TANGENT_TO_WORLD 1
			#endif

			#if defined(ASE_WRITE_DEPTH_CONSERVATIVE) && (SHADER_TARGET >= 45)
				#if UNITY_REVERSED_Z
					#define ASE_SV_DEPTH SV_DepthLessEqual
				#else
					#define ASE_SV_DEPTH SV_DepthGreaterEqual
				#endif
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 positionWSAndFogFactor : TEXCOORD0;
				#if defined(ASE_NEEDS_TANGENT_TO_WORLD)
					half3 normalWS : TEXCOORD1;
					half4 tangentWS : TEXCOORD2;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _OutlineColor;
			float4 _Specular;
			float4 _Ambient;
			float4 _Color;
			float4 _SubTex_ST;
			float4 _MainTex_ST;
			float3 _ToonTone;
			float _CastShadows;
			float _ShadowLum;
			float _SShad;
			float _EFFECTS;
			int _UVLayer;
			float _Shininess;
			float _SpecularIntensity;
			float _MultipleLights;
			float _HDR;
			float _Opaque;
			float _SPHOpacity;
			float _BumpScale;
			float _Parallax;
			float _SimulatorHeightMap;
			float _ZTest;
			float _SrcBlend;
			float _DstBlend;
			float _ZWriteControl;
			float _ZWrite;
			float _Cull;
			#define ASE_PROPERTY_CUTOFF
			float _Blend;
			float _PhongTessStrength;
			float _On;
			float _EdgeSize;
			float _ExtrusionAmount;
			float _Surface;
			float _SimulatorNormalMap;
			float _EdgeLength;
			#define ASE_PROPERTY_ALPHACLIP
			#ifdef ASE_PROPERTY_ALPHACLIP
				float _AlphaClip;
			#endif
			#ifdef ASE_PROPERTY_CUTOFF
				float _Cutoff;
			#endif
			#ifdef ASE_TESSELLATION
				#ifdef ASE_PHONG_TESSELLATION
					float _TessPhongStrength;
				#endif
				#if defined( ASE_FIXED_TESSELLATION ) || defined( ASE_DISTANCE_TESSELLATION )
					float _TessValue;
				#endif
				#ifdef ASE_DISTANCE_TESSELLATION
					float _TessMin;
					float _TessMax;
				#endif
				#if defined( ASE_LENGTH_TESSELLATION ) || defined( ASE_LENGTH_CULL_TESSELLATION )
					float _TessEdgeLength;
				#endif
				#ifdef ASE_LENGTH_CULL_TESSELLATION
					float _TessMaxDisp;
				#endif
			#endif
			UNITY_TEXTURE_STREAMING_DEBUG_VARS;
			CBUFFER_END

			

			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float Status23_g61490 = _On;
				float3 temp_cast_1 = 0;
				float temp_output_9_0_g61489 = _ExtrusionAmount;
				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( Status23_g61490 == (float)0 ? temp_cast_1 : ( ( _EdgeSize + temp_output_9_0_g61489 ) * input.normalOS ) );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );
				VertexNormalInputs normalInput = GetVertexNormalInputs( input.normalOS, input.tangentOS );

				float fogFactor = 0;
				#if defined(ASE_FOG) && !defined(_FOG_FRAGMENT)
					fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
				#endif

				output.positionCS = ASE_ADJUST_CLIP_POSITION( vertexInput.positionCS );
				output.positionWSAndFogFactor = float4( vertexInput.positionWS, fogFactor );
				#if defined(ASE_NEEDS_TANGENT_TO_WORLD)
					output.normalWS = normalInput.normalWS;
					output.tangentWS = half4( normalInput.tangentWS, ( input.tangentOS.w > 0.0 ? 1.0 : -1.0 ) * GetOddNegativeScale() );
				#endif
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				
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
				output.tangentOS = input.tangentOS;
				
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				#if defined( ASE_FIXED_TESSELLATION ) || defined( ASE_DISTANCE_TESSELLATION )
				float tessValue = _TessValue;
				#endif
				#if defined( ASE_DISTANCE_TESSELLATION )
				float tessMin = _TessMin; float tessMax = _TessMax;
				#endif
				#if defined( ASE_LENGTH_TESSELLATION ) || defined( ASE_LENGTH_CULL_TESSELLATION )
				float edgeLength = _EdgeLength;
				#endif
				#if defined( ASE_LENGTH_CULL_TESSELLATION )
				float tessMaxDisp = _TessMaxDisp;
				#endif
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
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				
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
						#if defined( ASE_WRITE_DEPTH )
						,out float outputDepth : ASE_SV_DEPTH
						#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( input );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				#if defined( _SURFACE_TYPE_TRANSPARENT )
					const bool isTransparent = true;
				#else
					const bool isTransparent = false;
				#endif

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord = TransformWorldToShadowCoord(input.positionWSAndFogFactor.xyz);
				#else
					float4 shadowCoord = float4(0, 0, 0, 0);
				#endif

				#if defined(ASE_NEEDS_TANGENT_TO_WORLD)
					// @diogo: mikktspace compliant
					float renormFactor = 1.0 / max( FLT_MIN, length( input.normalWS ) );
				#endif

				float3 PositionWS = input.positionWSAndFogFactor.xyz;
				float3 PositionRWS = GetCameraRelativePositionWS( PositionWS );
				half3 ViewDirWS = GetWorldSpaceNormalizeViewDir( PositionWS );
				float4 ShadowCoord = shadowCoord;
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;
				float4 ScreenPos = ComputeScreenPos( ClipPos );
				#if defined(ASE_NEEDS_TANGENT_TO_WORLD)
					float3 TangentWS = input.tangentWS.xyz * renormFactor;
					float3 BitangentWS = cross( input.normalWS, input.tangentWS.xyz ) * input.tangentWS.w * renormFactor;
					float3 NormalWS = input.normalWS * renormFactor;
				#endif

				float4 temp_output_25_0_g61490 = _OutlineColor;
				
				float Status23_g61490 = _On;
				float Sgurface248 = _Surface;
				
				float compareResult2_g61488 = ( float )0;
				if( _AlphaClip == (float)1 )
				{
					compareResult2_g61488 = _Cutoff;
				}
				else
				{
					compareResult2_g61488 = 0.0001;
				}
				float Alpha_Clip_Threshold323 = compareResult2_g61488;
				

				float3 Color = (temp_output_25_0_g61490).rgb;
				float Alpha = ( Status23_g61490 == (float)1 ? ( Sgurface248 == (float)0 ? (float)1 : saturate( temp_output_25_0_g61490.a ) ) : (float)0 );
				#if defined( _ALPHATEST_ON )
					#ifdef ASE_PROPERTY_CUTOFF
					float alphaCutoff = _Cutoff;
					#else
					float alphaCutoff = 0.5;
					#endif
					float AlphaClipThreshold = Alpha_Clip_Threshold323;
				#endif

				#if defined( ASE_WRITE_DEPTH )
					input.positionCS.z = input.positionCS.z;
				#endif

				#if defined( _ALPHATEST_ON )
					AlphaDiscard( Alpha, AlphaClipThreshold );
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = PositionWS;
				inputData.positionCS = input.positionCS;
				inputData.normalizedScreenSpaceUV = ScreenPosNorm.xy;
				#if defined(ASE_NEEDS_TANGENT_TO_WORLD)
					inputData.normalWS = NormalWS;
				#else
					inputData.normalWS = half3( 0, 0, 1 );
				#endif
				inputData.viewDirectionWS = ViewDirWS;

				#ifdef ASE_FOG
					inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.positionWSAndFogFactor.w);

					#ifdef TERRAIN_SPLAT_ADDPASS
						Color.rgb = MixFogColor(Color.rgb, half3(0,0,0), inputData.fogCoord);
					#elif ( UNITY_VERSION >= 60070000 )
						// @diogo: as in URP's Unlit, only the fog color is pre-exposed
						Color.rgb = ClampExposed( MixFogColor( Color.rgb, unity_FogColor.rgb * GetPreExposureMultiplier(), inputData.fogCoord ) );
					#else
						Color.rgb = MixFog(Color.rgb, inputData.fogCoord);
					#endif
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined( ASE_WRITE_DEPTH )
					outputDepth = input.positionCS.z;
				#endif

				#if defined( ASE_OPAQUE_KEEP_ALPHA )
					return half4( Color, Alpha );
				#else
					return half4( Color, OutputAlpha( Alpha, isTransparent ) );
				#endif
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Unlit"
			Tags { "LightMode"="UniversalForwardOnly" }

			ZWrite [_ZWrite]
			ZTest [_ZTest]
			Offset 0 , 0
			ColorMask RGBA
			Blend [_SrcBlend] [_DstBlend], One Zero
			BlendOp Add, Add

			

			HLSLPROGRAM

			#pragma shader_feature_local _ALPHATEST_ON
			#define _NORMAL_DROPOFF_TS 1
			#define UNLIT_DEFAULT_DECAL_BLENDING
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#define UNLIT_DEFAULT_SSAO
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma shader_feature_local_fragment _RECEIVE_SHADOWS_OFF
			#define ASE_OPAQUE_KEEP_ALPHA
			#define ASE_TESSELLATION 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_PHONG_TESSELLATION
			#define ASE_LENGTH_TESSELLATION
			#define ASE_FOG 1
			#define ASE_VERSION 19915
			#define ASE_SRP_VERSION 170600


			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3

			#pragma multi_compile_fragment _ DEBUG_DISPLAY

			#if ( UNITY_VERSION >= 60070000 ) && ( defined( ASE_FOG ) || ( defined( _SURFACE_TYPE_TRANSPARENT ) && defined( _TRANSPARENT_RECEIVE_FOG ) ) )
			#pragma multi_compile_fragment _ _EXPOSURE
			#endif

			#if ( UNITY_VERSION >= 60070000 ) && defined( _SURFACE_TYPE_TRANSPARENT ) && defined( _TRANSPARENT_RECEIVE_FOG )
			#pragma multi_compile_fragment _FOG_ANALYTIC _FOG_VOLUMETRIC
			#endif

			#pragma vertex vert
			#pragma fragment frag

			// Option "Keep Lighting Variants" @david please keep this note for future changes in Unlit  lighting
			//#define UNLIT_REALTIME_LIGHTING 1
			//#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			//#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			//#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			//#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			//#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			//#pragma multi_compile_fragment _ _REFLECTION_PROBE_ATLAS
			//#pragma multi_compile _ REFLECTION_PROBE_ROTATION
			//#pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
			//#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			//#pragma multi_compile _ SHADOWS_SHADOWMASK
			//#pragma multi_compile_fragment _ _LIGHT_LAYERS
			//#pragma multi_compile_fragment _ _LIGHT_COOKIES
			//#pragma multi_compile _ _CLUSTER_LIGHT_LOOP

			#define SHADERPASS SHADERPASS_UNLIT

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#if ( UNITY_VERSION >= 60010000 )
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
			#else
			#pragma multi_compile_fog
			#endif
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Unlit.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#include "../../MMD_Custom_Node_(URP_ASE).hlsl"
			#include "../MMD_Effects_Custom_Node_(URP_ASE).hlsl"
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_NORMAL
			#define ASE_NEEDS_FRAG_POSITION
			#define ASE_NEEDS_TEXTURE_COORDINATES2
			#define ASE_NEEDS_TEXTURE_COORDINATES3
			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES2
			#pragma multi_compile _ _FOG_ON
			#if (UNITY_VERSION >= 202220) && (UNITY_VERSION < 60070000)
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#endif
			#if (UNITY_VERSION >= 60070000)
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX
			#endif
			#if (UNITY_VERSION >= 60070000)
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHTS
			#endif
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#if (UNITY_VERSION >= 202220)
			#pragma multi_compile _ _LIGHT_LAYERS
			#endif
			#if (UNITY_VERSION >= 202220) && (UNITY_VERSION < 60010000)
			#pragma multi_compile _ _FORWARD_PLUS
			#endif
			#if (UNITY_VERSION >= 60010000) && (UNITY_VERSION < 60070000)
			#pragma multi_compile _ _CLUSTER_LIGHT_LOOP
			#endif
			#if (UNITY_VERSION >= 60070000)
			#pragma multi_compile_fragment _ _CLUSTER_LIGHT_LOOP
			#endif
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#ifndef _FOG_ON
			#undef ASE_FOG
			#endif
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING


			#if defined(DEBUG_DISPLAY) || defined(ASE_NEEDS_FRAG_WORLD_NORMAL) || defined(ASE_NEEDS_FRAG_WORLD_TANGENT) || defined(ASE_NEEDS_FRAG_WORLD_BITANGENT)
				#define ASE_NEEDS_TANGENT_TO_WORLD 1
			#endif

			#if defined(ASE_WRITE_DEPTH_CONSERVATIVE) && (SHADER_TARGET >= 45)
				#if UNITY_REVERSED_Z
					#define ASE_SV_DEPTH SV_DepthLessEqual
				#else
					#define ASE_SV_DEPTH SV_DepthGreaterEqual
				#endif
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 positionWSAndFogFactor : TEXCOORD0;
				#if defined(ASE_NEEDS_TANGENT_TO_WORLD)
					half3 normalWS : TEXCOORD1;
					half4 tangentWS : TEXCOORD2;
				#endif
				float3 ase_normal : NORMAL;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _OutlineColor;
			float4 _Specular;
			float4 _Ambient;
			float4 _Color;
			float4 _SubTex_ST;
			float4 _MainTex_ST;
			float3 _ToonTone;
			float _CastShadows;
			float _ShadowLum;
			float _SShad;
			float _EFFECTS;
			int _UVLayer;
			float _Shininess;
			float _SpecularIntensity;
			float _MultipleLights;
			float _HDR;
			float _Opaque;
			float _SPHOpacity;
			float _BumpScale;
			float _Parallax;
			float _SimulatorHeightMap;
			float _ZTest;
			float _SrcBlend;
			float _DstBlend;
			float _ZWriteControl;
			float _ZWrite;
			float _Cull;
			#define ASE_PROPERTY_CUTOFF
			float _Blend;
			float _PhongTessStrength;
			float _On;
			float _EdgeSize;
			float _ExtrusionAmount;
			float _Surface;
			float _SimulatorNormalMap;
			float _EdgeLength;
			#define ASE_PROPERTY_ALPHACLIP
			#ifdef ASE_PROPERTY_ALPHACLIP
				float _AlphaClip;
			#endif
			#ifdef ASE_PROPERTY_CUTOFF
				float _Cutoff;
			#endif
			#ifdef ASE_TESSELLATION
				#ifdef ASE_PHONG_TESSELLATION
					float _TessPhongStrength;
				#endif
				#if defined( ASE_FIXED_TESSELLATION ) || defined( ASE_DISTANCE_TESSELLATION )
					float _TessValue;
				#endif
				#ifdef ASE_DISTANCE_TESSELLATION
					float _TessMin;
					float _TessMax;
				#endif
				#if defined( ASE_LENGTH_TESSELLATION ) || defined( ASE_LENGTH_CULL_TESSELLATION )
					float _TessEdgeLength;
				#endif
				#ifdef ASE_LENGTH_CULL_TESSELLATION
					float _TessMaxDisp;
				#endif
			#endif
			UNITY_TEXTURE_STREAMING_DEBUG_VARS;
			CBUFFER_END

			sampler2D _NormalMap;
			sampler2D _MainTex;
			sampler2D _ParallaxMap;
			sampler2D _ToonTex;
			samplerCUBE _SphereCube;
			sampler2D _SubTex;


			half4 CalculateShadowMask1_g61479( half2 LightmapUV )
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
				#if ( UNITY_VERSION < 60010000 ) && !defined( USE_CLUSTER_LIGHT_LOOP )
				#define USE_CLUSTER_LIGHT_LOOP USE_FORWARD_PLUS
				#endif
				#if ( UNITY_VERSION < 60010000 ) && !defined( CLUSTER_LIGHT_LOOP_SUBTRACTIVE_LIGHT_CHECK )
				#define CLUSTER_LIGHT_LOOP_SUBTRACTIVE_LIGHT_CHECK FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
				#endif
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
				#if USE_CLUSTER_LIGHT_LOOP
				[loop] for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
				{
					CLUSTER_LIGHT_LOOP_SUBTRACTIVE_LIGHT_CHECK
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

				float temp_output_9_0_g61489 = _ExtrusionAmount;
				float3 Extrusion_Vertex_Offset684 = ( temp_output_9_0_g61489 * input.normalOS );
				
				output.ase_normal = input.normalOS;
				output.ase_texcoord3.xyz = input.ase_texcoord.xyz;
				output.ase_texcoord4.xy = input.ase_texcoord1.xy;
				output.ase_texcoord5 = input.positionOS;
				output.ase_texcoord4.zw = input.ase_texcoord2.xy;
				output.ase_texcoord6.xy = input.ase_texcoord3.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord3.w = 0;
				output.ase_texcoord6.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = Extrusion_Vertex_Offset684;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				#ifdef ASE_CUSTOM_MOTION_VECTOR
					// Declared so the Motion Vector output port surfaces on the master node; only consumed by the motion vector passes.
					float3 aseCustomMotionVector = float3(0, 0, 0);
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );
				VertexNormalInputs normalInput = GetVertexNormalInputs( input.normalOS, input.tangentOS );

				float fogFactor = 0;
				#if defined(ASE_FOG) && !defined(_FOG_FRAGMENT)
					fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
				#endif

				output.positionCS = ASE_ADJUST_CLIP_POSITION( vertexInput.positionCS );
				output.positionWSAndFogFactor = float4( vertexInput.positionWS, fogFactor );
				#if defined(ASE_NEEDS_TANGENT_TO_WORLD)
					output.normalWS = normalInput.normalWS;
					output.tangentWS = half4( normalInput.tangentWS, ( input.tangentOS.w > 0.0 ? 1.0 : -1.0 ) * GetOddNegativeScale() );;
				#endif
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
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
				output.tangentOS = input.tangentOS;
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
				#if defined( ASE_FIXED_TESSELLATION ) || defined( ASE_DISTANCE_TESSELLATION )
				float tessValue = _TessValue;
				#endif
				#if defined( ASE_DISTANCE_TESSELLATION )
				float tessMin = _TessMin; float tessMax = _TessMax;
				#endif
				#if defined( ASE_LENGTH_TESSELLATION ) || defined( ASE_LENGTH_CULL_TESSELLATION )
				float edgeLength = _EdgeLength;
				#endif
				#if defined( ASE_LENGTH_CULL_TESSELLATION )
				float tessMaxDisp = _TessMaxDisp;
				#endif
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
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
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

			half4 frag ( PackedVaryings input
						#if defined( ASE_WRITE_DEPTH )
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						#ifdef _WRITE_RENDERING_LAYERS
						#if ( UNITY_VERSION >= 60020000 )
						, out uint outRenderingLayers : SV_Target1
						#else
						, out float4 outRenderingLayers : SV_Target1
						#endif
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				#if defined( _SURFACE_TYPE_TRANSPARENT )
					const bool isTransparent = true;
				#else
					const bool isTransparent = false;
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					float4 shadowCoord = TransformWorldToShadowCoord( input.positionWSAndFogFactor.xyz );
				#else
					float4 shadowCoord = float4(0, 0, 0, 0);
				#endif

				#if defined(ASE_NEEDS_TANGENT_TO_WORLD)
					// @diogo: mikktspace compliant
					float renormFactor = 1.0 / max( FLT_MIN, length( input.normalWS ) );
				#endif

				float3 PositionWS = input.positionWSAndFogFactor.xyz;
				float3 PositionRWS = GetCameraRelativePositionWS( PositionWS );
				half3 ViewDirWS = GetWorldSpaceNormalizeViewDir( PositionWS );
				float4 ShadowCoord = shadowCoord;
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;
				float4 ScreenPos = ComputeScreenPos( ClipPos );
				#if defined(ASE_NEEDS_TANGENT_TO_WORLD)
					float3 TangentWS = input.tangentWS.xyz * renormFactor;
					float3 BitangentWS = cross( input.normalWS, input.tangentWS.xyz ) * input.tangentWS.w * renormFactor;
					float3 NormalWS = input.normalWS * renormFactor;
				#endif

				float localvLight3_g61463 = ( 0.0 );
				float3 objToWorldDir2_g61463 = mul( GetObjectToWorldMatrix(), float4( input.ase_normal, 0.0 ) ).xyz;
				float3 normal3_g61463 = objToWorldDir2_g61463;
				float3 Output3_g61463 = float3( 0,0,0 );
				vLight_float( normal3_g61463 , Output3_g61463 );
				float3 Global_Ambient682 = Output3_g61463;
				float2 HeightMapUV36_g61469 = (input.ase_texcoord3.xyz.xy*_MainTex_ST.xy + _MainTex_ST.zw);
				float4 tex2DNode9_g61469 = tex2D( _ParallaxMap, HeightMapUV36_g61469 );
				float4 break56_g61469 = tex2DNode9_g61469;
				float3 tanToWorld0 = float3( TangentWS.x, BitangentWS.x, NormalWS.x );
				float3 tanToWorld1 = float3( TangentWS.y, BitangentWS.y, NormalWS.y );
				float3 tanToWorld2 = float3( TangentWS.z, BitangentWS.z, NormalWS.z );
				float3 ase_viewVectorTS =  tanToWorld0 * ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - PositionWS : UNITY_MATRIX_V[ 2 ].xyz ).x + tanToWorld1 * ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - PositionWS : UNITY_MATRIX_V[ 2 ].xyz ).y  + tanToWorld2 * ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - PositionWS : UNITY_MATRIX_V[ 2 ].xyz ).z;
				float3 ase_viewDirTS = normalize( ase_viewVectorTS );
				float2 compareResult23_g61469 = ( float2 )0;
				if( (int)_SimulatorHeightMap == 1 )
				{
					compareResult23_g61469 = ( HeightMapUV36_g61469 + ( ( ( break56_g61469.b - 0.5 ) * (  (0.5 + ( _Parallax - 0.005 ) * ( 8.0 - 0.5 ) / ( 0.08 - 0.005 ) ) * 0.01 ) ) * (ase_viewDirTS).xy ) );
				}
				else
				{
					compareResult23_g61469 = HeightMapUV36_g61469;
				}
				float2 temp_output_714_0 = compareResult23_g61469;
				float4 tex2DNode21_g61486 = tex2D( _NormalMap, temp_output_714_0 );
				float3 unpack24_g61486 = UnpackNormalScale( tex2DNode21_g61486, _BumpScale );
				unpack24_g61486.z = lerp( 1, unpack24_g61486.z, saturate(_BumpScale) );
				float3 tanNormal33_g61486 = unpack24_g61486;
				float3 worldNormal33_g61486 = float3( dot( tanToWorld0, tanNormal33_g61486 ), dot( tanToWorld1, tanNormal33_g61486 ), dot( tanToWorld2, tanNormal33_g61486 ) );
				float localGetMainLightDirection2_g61484 = ( 0.0 );
				float2 lightmapUV2_g61484 = (input.ase_texcoord4.xy*(unity_LightmapST).xy + (unity_LightmapST).zw);
				float3 Direction2_g61484 = float3( 0,0,0 );
				GetMainLightDirection_float( lightmapUV2_g61484 , Direction2_g61484 );
				float dotResult45_g61486 = dot( worldNormal33_g61486 , Direction2_g61484 );
				float locallightColor15_g61467 = ( 0.0 );
				float3 objToWorld8_g61467 = mul( GetObjectToWorldMatrix(), float4( input.ase_texcoord5.xyz, 1 ) ).xyz;
				float3 worldPos15_g61467 = objToWorld8_g61467;
				float3 OutputColor15_g61467 = float3( 0,0,0 );
				lightColor_float( worldPos15_g61467 , OutputColor15_g61467 );
				float3 temp_output_12_0_g61470 = OutputColor15_g61467;
				float3 staticSwitch8_g61470 = ( float3 )0;
				#ifdef LIGHTMAP_ON
				{
					float dotResult14_g61470 = dot( temp_output_12_0_g61470 , temp_output_12_0_g61470 );
					float locallightmapCol11_g61470 = ( 0.0 );
					float2 lightmapUV11_g61470 = (input.ase_texcoord4.xy*(unity_LightmapST).xy + (unity_LightmapST).zw);
					float3 Output11_g61470 = float3( 0,0,0 );
					lightmapCol_float( lightmapUV11_g61470 , Output11_g61470 );
					float3 compareResult10_g61470 = ( float3 )0;
					if( dotResult14_g61470 == (float)0 )
					{
						compareResult10_g61470 = ( Output11_g61470 * 2.0 );
					}
					else
					{
						compareResult10_g61470 = temp_output_12_0_g61470;
					}
					staticSwitch8_g61470 = ( compareResult10_g61470 + Output11_g61470 );
				}
				#else
				{
					staticSwitch8_g61470 = temp_output_12_0_g61470;
				}
				#endif
				float3 Baked_Light_Maps680 = staticSwitch8_g61470;
				float temp_output_23_0_g61477 = _SShad;
				float3 break10_g61467 = _ToonTone;
				float3 objToWorldDir5_g61466 = mul( GetObjectToWorldMatrix(), float4( input.ase_normal, 0.0 ) ).xyz;
				float3 normalizeResult3_g61466 = normalize( objToWorldDir5_g61466 );
				float3 normalizeResult2_g61466 = normalize( _MainLightPosition.xyz );
				float dotResult4_g61466 = dot( normalizeResult3_g61466 , normalizeResult2_g61466 );
				float temp_output_1_0_g61467 = ( ( break10_g61467.y * dotResult4_g61466 ) + break10_g61467.z );
				float localshadowAtten16_g61467 = ( 0.0 );
				float3 worldPos16_g61467 = objToWorld8_g61467;
				float OutputShadowAtten16_g61467 = 0.0;
				shadowAtten_float( worldPos16_g61467 , OutputShadowAtten16_g61467 );
				float temp_output_2_0_g61467 = ( break10_g61467.z + ( break10_g61467.x * ( OutputShadowAtten16_g61467 - 0.5 ) ) );
				float temp_output_701_22 = min( temp_output_1_0_g61467, temp_output_2_0_g61467 );
				float2 compareResult1_g61477 = ( float2 )0;
				if( temp_output_23_0_g61477 == (float)0 )
				{
					float temp_output_21_0_g61477 = saturate( temp_output_701_22 );
					float2 appendResult11_g61477 = (float2(temp_output_21_0_g61477 , temp_output_21_0_g61477));
					compareResult1_g61477 = appendResult11_g61477;
				}
				else
				{
					compareResult1_g61477 = float2( 0,0 );
				}
				float4 tex2DNode33_g61477 = tex2D( _ToonTex, compareResult1_g61477 );
				float4 compareResult8_g61477 = ( float4 )0;
				if( temp_output_23_0_g61477 == (float)0 )
				{
					compareResult8_g61477 = tex2DNode33_g61477;
				}
				else
				{
					float temp_output_3_0_g61472 = ( temp_output_701_22 * 2.0 );
					float4 lerpResult9_g61477 = lerp( tex2DNode33_g61477 , float4( float3( 1, 1, 1 ) , 0.0 ) , saturate( ( ( temp_output_3_0_g61472 * temp_output_3_0_g61472 ) - 1.0 ) ));
					compareResult8_g61477 = lerpResult9_g61477;
				}
				float4 Toon_Ramp_Shadow681 = saturate( ( 1.0 - ( _ShadowLum * ( 1.0 - compareResult8_g61477 ) ) ) );
				half3 Global_Light_Scale139 = half3( 0.6, 0.6, 0.6 );
				float3 Light_Color647 = ( Baked_Light_Maps680 * Global_Light_Scale139 );
				float3 Ambient_Blend_Factor48 = ( float3( 1, 1, 1 ) - ( max( ( half3( 0.5, 0.5, 0.5 ) - (_Ambient).rgb ), float3( 0, 0, 0 ) ) * ( half3( 1, 1, 1 ) / 0.5 ) ) );
				float3 Weighted_Ambient144 = ( Global_Ambient682 * Ambient_Blend_Factor48 );
				float3 Temp_Diffuse46_g61473 = max( ( min( ( (_Ambient).rgb + ( (_Color).rgb * Global_Light_Scale139 ) ), float3( 1, 1, 1 ) ) - Weighted_Ambient144 ), float3( 0, 0, 0 ) );
				float4 tex2DNode10 = tex2D( _MainTex, temp_output_714_0 );
				float4 Albedo_Texture41_g61473 = tex2DNode10;
				float4 temp_output_18_0_g61473 = ( float4( Temp_Diffuse46_g61473 , 0.0 ) * Albedo_Texture41_g61473 );
				float3 objToView2_g61468 = TransformWorldToView( TransformObjectToWorld(input.ase_texcoord5.xyz) );
				float3 normalizeResult4_g61468 = normalize( objToView2_g61468 );
				float3 objToViewDir3_g61468 = normalize( mul( UNITY_MATRIX_IT_MV, float4( input.ase_normal, 0.0 ) ).xyz );
				float3 normalizeResult5_g61468 = normalize( objToViewDir3_g61468 );
				float4 texCUBENode40 = texCUBE( _SphereCube, reflect( normalizeResult4_g61468 , normalizeResult5_g61468 ) );
				float4 temp_output_27_0_g61473 = ( texCUBENode40 * _SPHOpacity );
				float Layer289 = _EFFECTS;
				float Effect_Layer13_g61473 = Layer289;
				float Layer_Value17_g61476 = Effect_Layer13_g61473;
				float4 lerpResult6_g61476 = lerp( temp_output_18_0_g61473 , ( temp_output_18_0_g61473 + temp_output_27_0_g61473 ) , step( 0.5 , Layer_Value17_g61476 ));
				float4 temp_output_15_0_g61473 = ( temp_output_27_0_g61473 * Albedo_Texture41_g61473 );
				float4 lerpResult14_g61476 = lerp( lerpResult6_g61476 , ( temp_output_15_0_g61473 * float4( Temp_Diffuse46_g61473 , 0.0 ) ) , step( 1.5 , Layer_Value17_g61476 ));
				float2 uv_SubTex = input.ase_texcoord3.xyz.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv2_SubTex = input.ase_texcoord4.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float Layer_Value17_g61475 = (float)_UVLayer;
				float2 lerpResult6_g61475 = lerp( uv_SubTex , uv2_SubTex , step( 0.5 , Layer_Value17_g61475 ));
				float2 uv3_SubTex = input.ase_texcoord4.zw * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 lerpResult14_g61475 = lerp( lerpResult6_g61475 , uv3_SubTex , step( 1.5 , Layer_Value17_g61475 ));
				float2 uv4_SubTex = input.ase_texcoord6.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 lerpResult16_g61475 = lerp( lerpResult14_g61475 , uv4_SubTex , step( 2.5 , Layer_Value17_g61475 ));
				float4 tex2DNode10_g61473 = tex2D( _SubTex, lerpResult16_g61475 );
				float4 lerpResult16_g61476 = lerp( lerpResult14_g61476 , ( float4( Temp_Diffuse46_g61473 , 0.0 ) * Albedo_Texture41_g61473 * tex2DNode10_g61473 ) , step( 2.5 , Layer_Value17_g61476 ));
				float4 Sphere_Map_Diffuse_Blend678 = lerpResult16_g61476;
				float3 objToWorldDir9_g61483 = mul( GetObjectToWorldMatrix(), float4( input.ase_normal, 0.0 ) ).xyz;
				float3 normalizeResult4_g61483 = normalize( objToWorldDir9_g61483 );
				float3 normalizeResult7_g61483 = normalize( ( _MainLightPosition.xyz + ViewDirWS ) );
				float dotResult1_g61483 = dot( normalizeResult4_g61483 , normalizeResult7_g61483 );
				float Layer_Value17_g61474 = Effect_Layer13_g61473;
				float4 lerpResult6_g61474 = lerp( Albedo_Texture41_g61473 , ( temp_output_27_0_g61473 + Albedo_Texture41_g61473 ) , step( 0.5 , Layer_Value17_g61474 ));
				float4 lerpResult14_g61474 = lerp( lerpResult6_g61474 , temp_output_15_0_g61473 , step( 1.5 , Layer_Value17_g61474 ));
				float4 lerpResult16_g61474 = lerp( lerpResult14_g61474 , Albedo_Texture41_g61473 , step( 2.5 , Layer_Value17_g61474 ));
				float4 Sphere_Map_Color679 = lerpResult16_g61474;
				float3 temp_output_13_0_g61478 = Global_Ambient682;
				float3 compareResult2_g61478 = ( float3 )0;
				if( _MultipleLights == (float)1 )
				{
					float3 WorldPosition288_g61482 = PositionWS;
					float3 WorldPosition305_g61482 = WorldPosition288_g61482;
					float2 ScreenUV286_g61482 = (ScreenPosNorm).xy;
					float2 ScreenUV305_g61482 = ScreenUV286_g61482;
					float3 objToWorldDir5_g61478 = mul( GetObjectToWorldMatrix(), float4( input.ase_normal, 0.0 ) ).xyz;
					float3 WorldNormal281_g61482 = objToWorldDir5_g61478;
					float3 WorldNormal305_g61482 = WorldNormal281_g61482;
					half2 LightmapUV1_g61479 = (input.ase_texcoord4.zw*(unity_DynamicLightmapST).xy + (unity_DynamicLightmapST).zw);
					half4 localCalculateShadowMask1_g61479 = CalculateShadowMask1_g61479( LightmapUV1_g61479 );
					float4 ShadowMask360_g61482 = localCalculateShadowMask1_g61479;
					float4 ShadowMask305_g61482 = ShadowMask360_g61482;
					float3 localAdditionalLightsLambertMask17x305_g61482 = AdditionalLightsLambertMask17x( WorldPosition305_g61482 , ScreenUV305_g61482 , WorldNormal305_g61482 , ShadowMask305_g61482 );
					compareResult2_g61478 = ( localAdditionalLightsLambertMask17x305_g61482 + temp_output_13_0_g61478 );
				}
				else
				{
					compareResult2_g61478 = temp_output_13_0_g61478;
				}
				float3 Additional_Lights268 = compareResult2_g61478;
				float4 temp_output_2_0_g61486 = ( ( ( Toon_Ramp_Shadow681 * float4( Light_Color647 , 0.0 ) * Sphere_Map_Diffuse_Blend678 ) + ( ( pow( saturate( dotResult1_g61483 ) , max( _Shininess, 0.001 ) ) * _Specular * float4( Light_Color647 , 0.0 ) ) * _SpecularIntensity ) ) + ( Sphere_Map_Color679 * float4( ( Additional_Lights268 * Ambient_Blend_Factor48 ) , 0.0 ) ) );
				float4 compareResult19_g61486 = ( float4 )0;
				if( (int)_SimulatorNormalMap == 1 )
				{
					compareResult19_g61486 = ( float4( ( Global_Ambient682 + ( saturate( dotResult45_g61486 ) * Baked_Light_Maps680 ) ) , 0.0 ) * temp_output_2_0_g61486 );
				}
				else
				{
					compareResult19_g61486 = temp_output_2_0_g61486;
				}
				float3 Final_Lighting_Composition_Output675 = ( (compareResult19_g61486).xyz * _HDR );
				
				float Sgurface248 = _Surface;
				float compareResult14_g61487 = ( float )0;
				if( Sgurface248 == (float)0 )
				{
					compareResult14_g61487 = (float)1;
				}
				else
				{
					float compareResult7_g61487 = ( float )0;
					if( Layer289 == (float)3 )
					{
						compareResult7_g61487 = ( tex2DNode10_g61473.a * tex2DNode10.a );
					}
					else
					{
						compareResult7_g61487 = tex2DNode10.a;
					}
					compareResult14_g61487 = saturate( ( _Opaque * compareResult7_g61487 ) );
				}
				
				float compareResult2_g61488 = ( float )0;
				if( _AlphaClip == (float)1 )
				{
					compareResult2_g61488 = _Cutoff;
				}
				else
				{
					compareResult2_g61488 = 0.0001;
				}
				float Alpha_Clip_Threshold323 = compareResult2_g61488;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = Final_Lighting_Composition_Output675;
				float3 Normal = float3(0, 0, 1);

				float Alpha = compareResult14_g61487;
				#if defined( _ALPHATEST_ON )
					#ifdef ASE_PROPERTY_CUTOFF
					float alphaCutoff = _Cutoff;
					#else
					float alphaCutoff = 0.5;
					#endif
					float AlphaClipThreshold = Alpha_Clip_Threshold323;
					float AlphaClipThresholdShadow = 0.5;
				#endif

				#if defined( ASE_WRITE_DEPTH )
					input.positionCS.z = input.positionCS.z;
				#endif

				#if defined( _ALPHATEST_ON )
					AlphaDiscard( Alpha, AlphaClipThreshold );
				#endif

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS) && defined(ASE_CHANGES_WORLD_POS)
					ShadowCoord = TransformWorldToShadowCoord( PositionWS );
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = PositionWS;
				inputData.positionCS = input.positionCS;
				inputData.normalizedScreenSpaceUV = ScreenPosNorm.xy;
				#if defined(ASE_NEEDS_TANGENT_TO_WORLD)
					inputData.normalWS = NormalWS;
				#else
					inputData.normalWS = half3( 0, 0, 1 );
				#endif
				inputData.viewDirectionWS = ViewDirWS;

				#if defined(_SCREEN_SPACE_OCCLUSION) && !defined(_SURFACE_TYPE_TRANSPARENT) && defined(UNLIT_DEFAULT_SSAO)
					float2 normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
					AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion(normalizedScreenSpaceUV);
					Color.rgb *= aoFactor.directAmbientOcclusion;
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.positionWSAndFogFactor.w);
				#endif

				#if defined(_DBUFFER) && defined(UNLIT_DEFAULT_DECAL_BLENDING)
					ApplyDecalToBaseColor(input.positionCS, Color);
				#endif

				#if defined(DEBUG_DISPLAY)
					SETUP_DEBUG_TEXTURE_DATA_NO_UV( inputData );
					half4 debugColor = UniversalFragmentUnlit( inputData, Color, Alpha );
					Color = debugColor.rgb;
					Alpha = debugColor.a;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						Color.rgb = MixFogColor(Color.rgb, half3(0,0,0), inputData.fogCoord);
					#elif ( UNITY_VERSION >= 60070000 )
						// @diogo: as in URP's Unlit, only the fog color is pre-exposed
						Color.rgb = ClampExposed( MixFogColor( Color.rgb, unity_FogColor.rgb * GetPreExposureMultiplier(), inputData.fogCoord ) );
					#else
						Color.rgb = MixFog(Color.rgb, inputData.fogCoord);
					#endif
				#endif

				#if ( UNITY_VERSION >= 60070000 ) && defined( _SURFACE_TYPE_TRANSPARENT ) && defined( _TRANSPARENT_RECEIVE_FOG )
					Color.rgb = MixVolumetricFog( Color.rgb, Alpha, ASE_BLEND_MODE, false, input.positionCS );
				#endif

				#if defined( ASE_WRITE_DEPTH )
					outputDepth = input.positionCS.z;
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					#if ( UNITY_VERSION >= 60020000 )
					outRenderingLayers = EncodeMeshRenderingLayer();
					#else
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
					#endif
				#endif

				#if defined( ASE_OPAQUE_KEEP_ALPHA )
					return half4( Color, Alpha );
				#else
					return half4( Color, OutputAlpha( Alpha, isTransparent ) );
				#endif
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

			#pragma shader_feature_local _ALPHATEST_ON
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define ASE_OPAQUE_KEEP_ALPHA
			#define ASE_TESSELLATION 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_PHONG_TESSELLATION
			#define ASE_LENGTH_TESSELLATION
			#define ASE_FOG 1
			#define ASE_VERSION 19915
			#define ASE_SRP_VERSION 170600


			#pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW // @diogo: removed _vertex for POM node

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_VERT_TANGENT
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_TEXTURE_COORDINATES2
			#define ASE_NEEDS_TEXTURE_COORDINATES3
			#pragma multi_compile _ _FOG_ON
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#ifndef _FOG_ON
			#undef ASE_FOG
			#endif
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING


			#if defined(ASE_WRITE_DEPTH_CONSERVATIVE) && (SHADER_TARGET >= 45)
				#if UNITY_REVERSED_Z
					#define ASE_SV_DEPTH SV_DepthLessEqual
				#else
					#define ASE_SV_DEPTH SV_DepthGreaterEqual
				#endif
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _OutlineColor;
			float4 _Specular;
			float4 _Ambient;
			float4 _Color;
			float4 _SubTex_ST;
			float4 _MainTex_ST;
			float3 _ToonTone;
			float _CastShadows;
			float _ShadowLum;
			float _SShad;
			float _EFFECTS;
			int _UVLayer;
			float _Shininess;
			float _SpecularIntensity;
			float _MultipleLights;
			float _HDR;
			float _Opaque;
			float _SPHOpacity;
			float _BumpScale;
			float _Parallax;
			float _SimulatorHeightMap;
			float _ZTest;
			float _SrcBlend;
			float _DstBlend;
			float _ZWriteControl;
			float _ZWrite;
			float _Cull;
			#define ASE_PROPERTY_CUTOFF
			float _Blend;
			float _PhongTessStrength;
			float _On;
			float _EdgeSize;
			float _ExtrusionAmount;
			float _Surface;
			float _SimulatorNormalMap;
			float _EdgeLength;
			#define ASE_PROPERTY_ALPHACLIP
			#ifdef ASE_PROPERTY_ALPHACLIP
				float _AlphaClip;
			#endif
			#ifdef ASE_PROPERTY_CUTOFF
				float _Cutoff;
			#endif
			#ifdef ASE_TESSELLATION
				#ifdef ASE_PHONG_TESSELLATION
					float _TessPhongStrength;
				#endif
				#if defined( ASE_FIXED_TESSELLATION ) || defined( ASE_DISTANCE_TESSELLATION )
					float _TessValue;
				#endif
				#ifdef ASE_DISTANCE_TESSELLATION
					float _TessMin;
					float _TessMax;
				#endif
				#if defined( ASE_LENGTH_TESSELLATION ) || defined( ASE_LENGTH_CULL_TESSELLATION )
					float _TessEdgeLength;
				#endif
				#ifdef ASE_LENGTH_CULL_TESSELLATION
					float _TessMaxDisp;
				#endif
			#endif
			UNITY_TEXTURE_STREAMING_DEBUG_VARS;
			CBUFFER_END

			sampler2D _MainTex;
			sampler2D _ParallaxMap;
			sampler2D _SubTex;


			float3 _LightDirection;
			float3 _LightPosition;

			
			PackedVaryings VertexFunction( Attributes input )
			{
				PackedVaryings output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( output );

				float temp_output_9_0_g61489 = _ExtrusionAmount;
				float3 Extrusion_Vertex_Offset684 = ( temp_output_9_0_g61489 * input.normalOS );
				
				float3 ase_positionWS = TransformObjectToWorld( ( input.positionOS ).xyz );
				output.ase_texcoord1.xyz = ase_positionWS;
				float3 ase_tangentWS = TransformObjectToWorldDir( input.tangentOS.xyz );
				output.ase_texcoord2.xyz = ase_tangentWS;
				float3 ase_normalWS = TransformObjectToWorldNormal( input.normalOS );
				output.ase_texcoord3.xyz = ase_normalWS;
				float ase_tangentSign = input.tangentOS.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_bitangentWS = cross( ase_normalWS, ase_tangentWS ) * ase_tangentSign;
				output.ase_texcoord4.xyz = ase_bitangentWS;
				
				output.ase_texcoord.xyz = input.ase_texcoord.xyz;
				output.ase_texcoord5.xy = input.ase_texcoord1.xy;
				output.ase_texcoord5.zw = input.ase_texcoord2.xy;
				output.ase_texcoord6.xy = input.ase_texcoord3.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord.w = 0;
				output.ase_texcoord1.w = 0;
				output.ase_texcoord2.w = 0;
				output.ase_texcoord3.w = 0;
				output.ase_texcoord4.w = 0;
				output.ase_texcoord6.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = Extrusion_Vertex_Offset684;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				float3 positionWS = TransformObjectToWorld( input.positionOS.xyz );
				half3 normalWS = TransformObjectToWorldDir(input.normalOS);

				#if _CASTING_PUNCTUAL_LIGHT_SHADOW
					float3 lightDirectionWS = normalize(_LightPosition - positionWS);
				#else
					float3 lightDirectionWS = _LightDirection;
				#endif

				float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

				#if UNITY_REVERSED_Z
					positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
				#else
					positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
				#endif

				output.positionCS = ASE_ADJUST_CLIP_POSITION( positionCS );
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
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
				#if defined( ASE_FIXED_TESSELLATION ) || defined( ASE_DISTANCE_TESSELLATION )
				float tessValue = _TessValue;
				#endif
				#if defined( ASE_DISTANCE_TESSELLATION )
				float tessMin = _TessMin; float tessMax = _TessMax;
				#endif
				#if defined( ASE_LENGTH_TESSELLATION ) || defined( ASE_LENGTH_CULL_TESSELLATION )
				float edgeLength = _EdgeLength;
				#endif
				#if defined( ASE_LENGTH_CULL_TESSELLATION )
				float tessMaxDisp = _TessMaxDisp;
				#endif
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
						#if defined( ASE_WRITE_DEPTH )
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( input );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;
				float4 ScreenPos = ComputeScreenPos( ClipPos );

				float Sgurface248 = _Surface;
				float Layer289 = _EFFECTS;
				float compareResult14_g61487 = ( float )0;
				if( Sgurface248 == (float)0 )
				{
					compareResult14_g61487 = (float)1;
				}
				else
				{
					float2 HeightMapUV36_g61469 = (input.ase_texcoord.xyz.xy*_MainTex_ST.xy + _MainTex_ST.zw);
					float4 tex2DNode9_g61469 = tex2D( _ParallaxMap, HeightMapUV36_g61469 );
					float4 break56_g61469 = tex2DNode9_g61469;
					float3 ase_positionWS = input.ase_texcoord1.xyz;
					float3 ase_tangentWS = input.ase_texcoord2.xyz;
					float3 ase_normalWS = input.ase_texcoord3.xyz;
					float3 ase_bitangentWS = input.ase_texcoord4.xyz;
					float3 tanToWorld0 = float3( ase_tangentWS.x, ase_bitangentWS.x, ase_normalWS.x );
					float3 tanToWorld1 = float3( ase_tangentWS.y, ase_bitangentWS.y, ase_normalWS.y );
					float3 tanToWorld2 = float3( ase_tangentWS.z, ase_bitangentWS.z, ase_normalWS.z );
					float3 ase_viewVectorTS =  tanToWorld0 * ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - ase_positionWS : UNITY_MATRIX_V[ 2 ].xyz ).x + tanToWorld1 * ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - ase_positionWS : UNITY_MATRIX_V[ 2 ].xyz ).y  + tanToWorld2 * ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - ase_positionWS : UNITY_MATRIX_V[ 2 ].xyz ).z;
					float3 ase_viewDirTS = normalize( ase_viewVectorTS );
					float2 compareResult23_g61469 = ( float2 )0;
					if( (int)_SimulatorHeightMap == 1 )
					{
						compareResult23_g61469 = ( HeightMapUV36_g61469 + ( ( ( break56_g61469.b - 0.5 ) * (  (0.5 + ( _Parallax - 0.005 ) * ( 8.0 - 0.5 ) / ( 0.08 - 0.005 ) ) * 0.01 ) ) * (ase_viewDirTS).xy ) );
					}
					else
					{
						compareResult23_g61469 = HeightMapUV36_g61469;
					}
					float2 temp_output_714_0 = compareResult23_g61469;
					float4 tex2DNode10 = tex2D( _MainTex, temp_output_714_0 );
					float compareResult7_g61487 = ( float )0;
					if( Layer289 == (float)3 )
					{
						float2 uv_SubTex = input.ase_texcoord.xyz.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 uv2_SubTex = input.ase_texcoord5.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float Layer_Value17_g61475 = (float)_UVLayer;
						float2 lerpResult6_g61475 = lerp( uv_SubTex , uv2_SubTex , step( 0.5 , Layer_Value17_g61475 ));
						float2 uv3_SubTex = input.ase_texcoord5.zw * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 lerpResult14_g61475 = lerp( lerpResult6_g61475 , uv3_SubTex , step( 1.5 , Layer_Value17_g61475 ));
						float2 uv4_SubTex = input.ase_texcoord6.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 lerpResult16_g61475 = lerp( lerpResult14_g61475 , uv4_SubTex , step( 2.5 , Layer_Value17_g61475 ));
						float4 tex2DNode10_g61473 = tex2D( _SubTex, lerpResult16_g61475 );
						compareResult7_g61487 = ( tex2DNode10_g61473.a * tex2DNode10.a );
					}
					else
					{
						compareResult7_g61487 = tex2DNode10.a;
					}
					compareResult14_g61487 = saturate( ( _Opaque * compareResult7_g61487 ) );
				}
				
				float compareResult2_g61488 = ( float )0;
				if( _AlphaClip == (float)1 )
				{
					compareResult2_g61488 = _Cutoff;
				}
				else
				{
					compareResult2_g61488 = 0.0001;
				}
				float Alpha_Clip_Threshold323 = compareResult2_g61488;
				

				float Alpha = compareResult14_g61487;
				#if defined( _ALPHATEST_ON )
					#ifdef ASE_PROPERTY_CUTOFF
					float alphaCutoff = _Cutoff;
					#else
					float alphaCutoff = 0.5;
					#endif
					float AlphaClipThreshold = Alpha_Clip_Threshold323;
					float AlphaClipThresholdShadow = 0.5;
				#endif

				#if defined( ASE_WRITE_DEPTH )
					input.positionCS.z = input.positionCS.z;
				#endif

				#if defined( _ALPHATEST_ON )
					#if defined( _ALPHATEST_SHADOW_ON )
						AlphaDiscard( Alpha, AlphaClipThresholdShadow );
					#else
						AlphaDiscard( Alpha, AlphaClipThreshold );
					#endif
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined( ASE_WRITE_DEPTH )
					outputDepth = input.positionCS.z;
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

			#pragma shader_feature_local _ALPHATEST_ON
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define ASE_OPAQUE_KEEP_ALPHA
			#define ASE_TESSELLATION 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_PHONG_TESSELLATION
			#define ASE_LENGTH_TESSELLATION
			#define ASE_FOG 1
			#define ASE_VERSION 19915
			#define ASE_SRP_VERSION 170600


			#pragma vertex vert
			#pragma fragment frag

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_VERT_TANGENT
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_TEXTURE_COORDINATES2
			#define ASE_NEEDS_TEXTURE_COORDINATES3
			#pragma multi_compile _ _FOG_ON
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#ifndef _FOG_ON
			#undef ASE_FOG
			#endif
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING


			#if defined(ASE_WRITE_DEPTH_CONSERVATIVE) && (SHADER_TARGET >= 45)
				#if UNITY_REVERSED_Z
					#define ASE_SV_DEPTH SV_DepthLessEqual
				#else
					#define ASE_SV_DEPTH SV_DepthGreaterEqual
				#endif
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _OutlineColor;
			float4 _Specular;
			float4 _Ambient;
			float4 _Color;
			float4 _SubTex_ST;
			float4 _MainTex_ST;
			float3 _ToonTone;
			float _CastShadows;
			float _ShadowLum;
			float _SShad;
			float _EFFECTS;
			int _UVLayer;
			float _Shininess;
			float _SpecularIntensity;
			float _MultipleLights;
			float _HDR;
			float _Opaque;
			float _SPHOpacity;
			float _BumpScale;
			float _Parallax;
			float _SimulatorHeightMap;
			float _ZTest;
			float _SrcBlend;
			float _DstBlend;
			float _ZWriteControl;
			float _ZWrite;
			float _Cull;
			#define ASE_PROPERTY_CUTOFF
			float _Blend;
			float _PhongTessStrength;
			float _On;
			float _EdgeSize;
			float _ExtrusionAmount;
			float _Surface;
			float _SimulatorNormalMap;
			float _EdgeLength;
			#define ASE_PROPERTY_ALPHACLIP
			#ifdef ASE_PROPERTY_ALPHACLIP
				float _AlphaClip;
			#endif
			#ifdef ASE_PROPERTY_CUTOFF
				float _Cutoff;
			#endif
			#ifdef ASE_TESSELLATION
				#ifdef ASE_PHONG_TESSELLATION
					float _TessPhongStrength;
				#endif
				#if defined( ASE_FIXED_TESSELLATION ) || defined( ASE_DISTANCE_TESSELLATION )
					float _TessValue;
				#endif
				#ifdef ASE_DISTANCE_TESSELLATION
					float _TessMin;
					float _TessMax;
				#endif
				#if defined( ASE_LENGTH_TESSELLATION ) || defined( ASE_LENGTH_CULL_TESSELLATION )
					float _TessEdgeLength;
				#endif
				#ifdef ASE_LENGTH_CULL_TESSELLATION
					float _TessMaxDisp;
				#endif
			#endif
			UNITY_TEXTURE_STREAMING_DEBUG_VARS;
			CBUFFER_END

			sampler2D _MainTex;
			sampler2D _ParallaxMap;
			sampler2D _SubTex;


			float3 _LightDirection;
			float3 _LightPosition;

			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float temp_output_9_0_g61489 = _ExtrusionAmount;
				float3 Extrusion_Vertex_Offset684 = ( temp_output_9_0_g61489 * input.normalOS );
				
				float3 ase_positionWS = TransformObjectToWorld( ( input.positionOS ).xyz );
				output.ase_texcoord1.xyz = ase_positionWS;
				float3 ase_tangentWS = TransformObjectToWorldDir( input.tangentOS.xyz );
				output.ase_texcoord2.xyz = ase_tangentWS;
				float3 ase_normalWS = TransformObjectToWorldNormal( input.normalOS );
				output.ase_texcoord3.xyz = ase_normalWS;
				float ase_tangentSign = input.tangentOS.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_bitangentWS = cross( ase_normalWS, ase_tangentWS ) * ase_tangentSign;
				output.ase_texcoord4.xyz = ase_bitangentWS;
				
				output.ase_texcoord.xyz = input.ase_texcoord.xyz;
				output.ase_texcoord5.xy = input.ase_texcoord1.xy;
				output.ase_texcoord5.zw = input.ase_texcoord2.xy;
				output.ase_texcoord6.xy = input.ase_texcoord3.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord.w = 0;
				output.ase_texcoord1.w = 0;
				output.ase_texcoord2.w = 0;
				output.ase_texcoord3.w = 0;
				output.ase_texcoord4.w = 0;
				output.ase_texcoord6.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = Extrusion_Vertex_Offset684;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				output.positionCS = ASE_ADJUST_CLIP_POSITION( vertexInput.positionCS );
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
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
				#if defined( ASE_FIXED_TESSELLATION ) || defined( ASE_DISTANCE_TESSELLATION )
				float tessValue = _TessValue;
				#endif
				#if defined( ASE_DISTANCE_TESSELLATION )
				float tessMin = _TessMin; float tessMax = _TessMax;
				#endif
				#if defined( ASE_LENGTH_TESSELLATION ) || defined( ASE_LENGTH_CULL_TESSELLATION )
				float edgeLength = _EdgeLength;
				#endif
				#if defined( ASE_LENGTH_CULL_TESSELLATION )
				float tessMaxDisp = _TessMaxDisp;
				#endif
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
						#if defined( ASE_WRITE_DEPTH )
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;
				float4 ScreenPos = ComputeScreenPos( ClipPos );

				float Sgurface248 = _Surface;
				float Layer289 = _EFFECTS;
				float compareResult14_g61487 = ( float )0;
				if( Sgurface248 == (float)0 )
				{
					compareResult14_g61487 = (float)1;
				}
				else
				{
					float2 HeightMapUV36_g61469 = (input.ase_texcoord.xyz.xy*_MainTex_ST.xy + _MainTex_ST.zw);
					float4 tex2DNode9_g61469 = tex2D( _ParallaxMap, HeightMapUV36_g61469 );
					float4 break56_g61469 = tex2DNode9_g61469;
					float3 ase_positionWS = input.ase_texcoord1.xyz;
					float3 ase_tangentWS = input.ase_texcoord2.xyz;
					float3 ase_normalWS = input.ase_texcoord3.xyz;
					float3 ase_bitangentWS = input.ase_texcoord4.xyz;
					float3 tanToWorld0 = float3( ase_tangentWS.x, ase_bitangentWS.x, ase_normalWS.x );
					float3 tanToWorld1 = float3( ase_tangentWS.y, ase_bitangentWS.y, ase_normalWS.y );
					float3 tanToWorld2 = float3( ase_tangentWS.z, ase_bitangentWS.z, ase_normalWS.z );
					float3 ase_viewVectorTS =  tanToWorld0 * ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - ase_positionWS : UNITY_MATRIX_V[ 2 ].xyz ).x + tanToWorld1 * ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - ase_positionWS : UNITY_MATRIX_V[ 2 ].xyz ).y  + tanToWorld2 * ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - ase_positionWS : UNITY_MATRIX_V[ 2 ].xyz ).z;
					float3 ase_viewDirTS = normalize( ase_viewVectorTS );
					float2 compareResult23_g61469 = ( float2 )0;
					if( (int)_SimulatorHeightMap == 1 )
					{
						compareResult23_g61469 = ( HeightMapUV36_g61469 + ( ( ( break56_g61469.b - 0.5 ) * (  (0.5 + ( _Parallax - 0.005 ) * ( 8.0 - 0.5 ) / ( 0.08 - 0.005 ) ) * 0.01 ) ) * (ase_viewDirTS).xy ) );
					}
					else
					{
						compareResult23_g61469 = HeightMapUV36_g61469;
					}
					float2 temp_output_714_0 = compareResult23_g61469;
					float4 tex2DNode10 = tex2D( _MainTex, temp_output_714_0 );
					float compareResult7_g61487 = ( float )0;
					if( Layer289 == (float)3 )
					{
						float2 uv_SubTex = input.ase_texcoord.xyz.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 uv2_SubTex = input.ase_texcoord5.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float Layer_Value17_g61475 = (float)_UVLayer;
						float2 lerpResult6_g61475 = lerp( uv_SubTex , uv2_SubTex , step( 0.5 , Layer_Value17_g61475 ));
						float2 uv3_SubTex = input.ase_texcoord5.zw * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 lerpResult14_g61475 = lerp( lerpResult6_g61475 , uv3_SubTex , step( 1.5 , Layer_Value17_g61475 ));
						float2 uv4_SubTex = input.ase_texcoord6.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 lerpResult16_g61475 = lerp( lerpResult14_g61475 , uv4_SubTex , step( 2.5 , Layer_Value17_g61475 ));
						float4 tex2DNode10_g61473 = tex2D( _SubTex, lerpResult16_g61475 );
						compareResult7_g61487 = ( tex2DNode10_g61473.a * tex2DNode10.a );
					}
					else
					{
						compareResult7_g61487 = tex2DNode10.a;
					}
					compareResult14_g61487 = saturate( ( _Opaque * compareResult7_g61487 ) );
				}
				
				float compareResult2_g61488 = ( float )0;
				if( _AlphaClip == (float)1 )
				{
					compareResult2_g61488 = _Cutoff;
				}
				else
				{
					compareResult2_g61488 = 0.0001;
				}
				float Alpha_Clip_Threshold323 = compareResult2_g61488;
				

				float Alpha = compareResult14_g61487;
				#if defined( _ALPHATEST_ON )
					#ifdef ASE_PROPERTY_CUTOFF
					float alphaCutoff = _Cutoff;
					#else
					float alphaCutoff = 0.5;
					#endif
					float AlphaClipThreshold = Alpha_Clip_Threshold323;
				#endif

				#if defined( ASE_WRITE_DEPTH )
					input.positionCS.z = input.positionCS.z;
				#endif

				#if defined( _ALPHATEST_ON )
					AlphaDiscard( Alpha, AlphaClipThreshold );
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined( ASE_WRITE_DEPTH )
					outputDepth = input.positionCS.z;
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

			#pragma shader_feature_local _ALPHATEST_ON
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#define ASE_OPAQUE_KEEP_ALPHA
			#define ASE_TESSELLATION 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_PHONG_TESSELLATION
			#define ASE_LENGTH_TESSELLATION
			#define ASE_FOG 1
			#define ASE_VERSION 19915
			#define ASE_SRP_VERSION 170600


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
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_VERT_TANGENT
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_TEXTURE_COORDINATES2
			#define ASE_NEEDS_TEXTURE_COORDINATES3
			#pragma multi_compile _ _FOG_ON
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#ifndef _FOG_ON
			#undef ASE_FOG
			#endif
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING


			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _OutlineColor;
			float4 _Specular;
			float4 _Ambient;
			float4 _Color;
			float4 _SubTex_ST;
			float4 _MainTex_ST;
			float3 _ToonTone;
			float _CastShadows;
			float _ShadowLum;
			float _SShad;
			float _EFFECTS;
			int _UVLayer;
			float _Shininess;
			float _SpecularIntensity;
			float _MultipleLights;
			float _HDR;
			float _Opaque;
			float _SPHOpacity;
			float _BumpScale;
			float _Parallax;
			float _SimulatorHeightMap;
			float _ZTest;
			float _SrcBlend;
			float _DstBlend;
			float _ZWriteControl;
			float _ZWrite;
			float _Cull;
			#define ASE_PROPERTY_CUTOFF
			float _Blend;
			float _PhongTessStrength;
			float _On;
			float _EdgeSize;
			float _ExtrusionAmount;
			float _Surface;
			float _SimulatorNormalMap;
			float _EdgeLength;
			#define ASE_PROPERTY_ALPHACLIP
			#ifdef ASE_PROPERTY_ALPHACLIP
				float _AlphaClip;
			#endif
			#ifdef ASE_PROPERTY_CUTOFF
				float _Cutoff;
			#endif
			#ifdef ASE_TESSELLATION
				#ifdef ASE_PHONG_TESSELLATION
					float _TessPhongStrength;
				#endif
				#if defined( ASE_FIXED_TESSELLATION ) || defined( ASE_DISTANCE_TESSELLATION )
					float _TessValue;
				#endif
				#ifdef ASE_DISTANCE_TESSELLATION
					float _TessMin;
					float _TessMax;
				#endif
				#if defined( ASE_LENGTH_TESSELLATION ) || defined( ASE_LENGTH_CULL_TESSELLATION )
					float _TessEdgeLength;
				#endif
				#ifdef ASE_LENGTH_CULL_TESSELLATION
					float _TessMaxDisp;
				#endif
			#endif
			UNITY_TEXTURE_STREAMING_DEBUG_VARS;
			CBUFFER_END

			sampler2D _MainTex;
			sampler2D _ParallaxMap;
			sampler2D _SubTex;


			
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

				float temp_output_9_0_g61489 = _ExtrusionAmount;
				float3 Extrusion_Vertex_Offset684 = ( temp_output_9_0_g61489 * input.normalOS );
				
				float3 ase_positionWS = TransformObjectToWorld( ( input.positionOS ).xyz );
				output.ase_texcoord1.xyz = ase_positionWS;
				float3 ase_tangentWS = TransformObjectToWorldDir( input.tangentOS.xyz );
				output.ase_texcoord2.xyz = ase_tangentWS;
				float3 ase_normalWS = TransformObjectToWorldNormal( input.normalOS );
				output.ase_texcoord3.xyz = ase_normalWS;
				float ase_tangentSign = input.tangentOS.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_bitangentWS = cross( ase_normalWS, ase_tangentWS ) * ase_tangentSign;
				output.ase_texcoord4.xyz = ase_bitangentWS;
				
				output.ase_texcoord.xyz = input.ase_texcoord.xyz;
				output.ase_texcoord5.xy = input.ase_texcoord1.xy;
				output.ase_texcoord5.zw = input.ase_texcoord2.xy;
				output.ase_texcoord6.xy = input.ase_texcoord3.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord.w = 0;
				output.ase_texcoord1.w = 0;
				output.ase_texcoord2.w = 0;
				output.ase_texcoord3.w = 0;
				output.ase_texcoord4.w = 0;
				output.ase_texcoord6.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = Extrusion_Vertex_Offset684;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				output.positionCS = ASE_ADJUST_CLIP_POSITION( vertexInput.positionCS );
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
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
				#if defined( ASE_FIXED_TESSELLATION ) || defined( ASE_DISTANCE_TESSELLATION )
				float tessValue = _TessValue;
				#endif
				#if defined( ASE_DISTANCE_TESSELLATION )
				float tessMin = _TessMin; float tessMax = _TessMax;
				#endif
				#if defined( ASE_LENGTH_TESSELLATION ) || defined( ASE_LENGTH_CULL_TESSELLATION )
				float edgeLength = _EdgeLength;
				#endif
				#if defined( ASE_LENGTH_CULL_TESSELLATION )
				float tessMaxDisp = _TessMaxDisp;
				#endif
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
				UNITY_SETUP_INSTANCE_ID(input);
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float Sgurface248 = _Surface;
				float Layer289 = _EFFECTS;
				float compareResult14_g61487 = ( float )0;
				if( Sgurface248 == (float)0 )
				{
					compareResult14_g61487 = (float)1;
				}
				else
				{
					float2 HeightMapUV36_g61469 = (input.ase_texcoord.xyz.xy*_MainTex_ST.xy + _MainTex_ST.zw);
					float4 tex2DNode9_g61469 = tex2D( _ParallaxMap, HeightMapUV36_g61469 );
					float4 break56_g61469 = tex2DNode9_g61469;
					float3 ase_positionWS = input.ase_texcoord1.xyz;
					float3 ase_tangentWS = input.ase_texcoord2.xyz;
					float3 ase_normalWS = input.ase_texcoord3.xyz;
					float3 ase_bitangentWS = input.ase_texcoord4.xyz;
					float3 tanToWorld0 = float3( ase_tangentWS.x, ase_bitangentWS.x, ase_normalWS.x );
					float3 tanToWorld1 = float3( ase_tangentWS.y, ase_bitangentWS.y, ase_normalWS.y );
					float3 tanToWorld2 = float3( ase_tangentWS.z, ase_bitangentWS.z, ase_normalWS.z );
					float3 ase_viewVectorTS =  tanToWorld0 * ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - ase_positionWS : UNITY_MATRIX_V[ 2 ].xyz ).x + tanToWorld1 * ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - ase_positionWS : UNITY_MATRIX_V[ 2 ].xyz ).y  + tanToWorld2 * ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - ase_positionWS : UNITY_MATRIX_V[ 2 ].xyz ).z;
					float3 ase_viewDirTS = normalize( ase_viewVectorTS );
					float2 compareResult23_g61469 = ( float2 )0;
					if( (int)_SimulatorHeightMap == 1 )
					{
						compareResult23_g61469 = ( HeightMapUV36_g61469 + ( ( ( break56_g61469.b - 0.5 ) * (  (0.5 + ( _Parallax - 0.005 ) * ( 8.0 - 0.5 ) / ( 0.08 - 0.005 ) ) * 0.01 ) ) * (ase_viewDirTS).xy ) );
					}
					else
					{
						compareResult23_g61469 = HeightMapUV36_g61469;
					}
					float2 temp_output_714_0 = compareResult23_g61469;
					float4 tex2DNode10 = tex2D( _MainTex, temp_output_714_0 );
					float compareResult7_g61487 = ( float )0;
					if( Layer289 == (float)3 )
					{
						float2 uv_SubTex = input.ase_texcoord.xyz.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 uv2_SubTex = input.ase_texcoord5.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float Layer_Value17_g61475 = (float)_UVLayer;
						float2 lerpResult6_g61475 = lerp( uv_SubTex , uv2_SubTex , step( 0.5 , Layer_Value17_g61475 ));
						float2 uv3_SubTex = input.ase_texcoord5.zw * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 lerpResult14_g61475 = lerp( lerpResult6_g61475 , uv3_SubTex , step( 1.5 , Layer_Value17_g61475 ));
						float2 uv4_SubTex = input.ase_texcoord6.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 lerpResult16_g61475 = lerp( lerpResult14_g61475 , uv4_SubTex , step( 2.5 , Layer_Value17_g61475 ));
						float4 tex2DNode10_g61473 = tex2D( _SubTex, lerpResult16_g61475 );
						compareResult7_g61487 = ( tex2DNode10_g61473.a * tex2DNode10.a );
					}
					else
					{
						compareResult7_g61487 = tex2DNode10.a;
					}
					compareResult14_g61487 = saturate( ( _Opaque * compareResult7_g61487 ) );
				}
				
				float compareResult2_g61488 = ( float )0;
				if( _AlphaClip == (float)1 )
				{
					compareResult2_g61488 = _Cutoff;
				}
				else
				{
					compareResult2_g61488 = 0.0001;
				}
				float Alpha_Clip_Threshold323 = compareResult2_g61488;
				

				surfaceDescription.Alpha = compareResult14_g61487;
				#if defined( _ALPHATEST_ON )
					#ifdef ASE_PROPERTY_CUTOFF
					float alphaCutoff = _Cutoff;
					#else
					float alphaCutoff = 0.5;
					#endif
					surfaceDescription.AlphaClipThreshold = Alpha_Clip_Threshold323;
				#endif

				#ifdef _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
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

			#pragma shader_feature_local _ALPHATEST_ON
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#define ASE_OPAQUE_KEEP_ALPHA
			#define ASE_TESSELLATION 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_PHONG_TESSELLATION
			#define ASE_LENGTH_TESSELLATION
			#define ASE_FOG 1
			#define ASE_VERSION 19915
			#define ASE_SRP_VERSION 170600


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
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_VERT_TANGENT
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_TEXTURE_COORDINATES2
			#define ASE_NEEDS_TEXTURE_COORDINATES3
			#pragma multi_compile _ _FOG_ON
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#ifndef _FOG_ON
			#undef ASE_FOG
			#endif
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING


			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _OutlineColor;
			float4 _Specular;
			float4 _Ambient;
			float4 _Color;
			float4 _SubTex_ST;
			float4 _MainTex_ST;
			float3 _ToonTone;
			float _CastShadows;
			float _ShadowLum;
			float _SShad;
			float _EFFECTS;
			int _UVLayer;
			float _Shininess;
			float _SpecularIntensity;
			float _MultipleLights;
			float _HDR;
			float _Opaque;
			float _SPHOpacity;
			float _BumpScale;
			float _Parallax;
			float _SimulatorHeightMap;
			float _ZTest;
			float _SrcBlend;
			float _DstBlend;
			float _ZWriteControl;
			float _ZWrite;
			float _Cull;
			#define ASE_PROPERTY_CUTOFF
			float _Blend;
			float _PhongTessStrength;
			float _On;
			float _EdgeSize;
			float _ExtrusionAmount;
			float _Surface;
			float _SimulatorNormalMap;
			float _EdgeLength;
			#define ASE_PROPERTY_ALPHACLIP
			#ifdef ASE_PROPERTY_ALPHACLIP
				float _AlphaClip;
			#endif
			#ifdef ASE_PROPERTY_CUTOFF
				float _Cutoff;
			#endif
			#ifdef ASE_TESSELLATION
				#ifdef ASE_PHONG_TESSELLATION
					float _TessPhongStrength;
				#endif
				#if defined( ASE_FIXED_TESSELLATION ) || defined( ASE_DISTANCE_TESSELLATION )
					float _TessValue;
				#endif
				#ifdef ASE_DISTANCE_TESSELLATION
					float _TessMin;
					float _TessMax;
				#endif
				#if defined( ASE_LENGTH_TESSELLATION ) || defined( ASE_LENGTH_CULL_TESSELLATION )
					float _TessEdgeLength;
				#endif
				#ifdef ASE_LENGTH_CULL_TESSELLATION
					float _TessMaxDisp;
				#endif
			#endif
			UNITY_TEXTURE_STREAMING_DEBUG_VARS;
			CBUFFER_END

			sampler2D _MainTex;
			sampler2D _ParallaxMap;
			sampler2D _SubTex;


			
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

				float temp_output_9_0_g61489 = _ExtrusionAmount;
				float3 Extrusion_Vertex_Offset684 = ( temp_output_9_0_g61489 * input.normalOS );
				
				float3 ase_positionWS = TransformObjectToWorld( ( input.positionOS ).xyz );
				output.ase_texcoord1.xyz = ase_positionWS;
				float3 ase_tangentWS = TransformObjectToWorldDir( input.tangentOS.xyz );
				output.ase_texcoord2.xyz = ase_tangentWS;
				float3 ase_normalWS = TransformObjectToWorldNormal( input.normalOS );
				output.ase_texcoord3.xyz = ase_normalWS;
				float ase_tangentSign = input.tangentOS.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_bitangentWS = cross( ase_normalWS, ase_tangentWS ) * ase_tangentSign;
				output.ase_texcoord4.xyz = ase_bitangentWS;
				
				output.ase_texcoord.xyz = input.ase_texcoord.xyz;
				output.ase_texcoord5.xy = input.ase_texcoord1.xy;
				output.ase_texcoord5.zw = input.ase_texcoord2.xy;
				output.ase_texcoord6.xy = input.ase_texcoord3.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord.w = 0;
				output.ase_texcoord1.w = 0;
				output.ase_texcoord2.w = 0;
				output.ase_texcoord3.w = 0;
				output.ase_texcoord4.w = 0;
				output.ase_texcoord6.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = Extrusion_Vertex_Offset684;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				output.positionCS = ASE_ADJUST_CLIP_POSITION( vertexInput.positionCS );
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
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
				#if defined( ASE_FIXED_TESSELLATION ) || defined( ASE_DISTANCE_TESSELLATION )
				float tessValue = _TessValue;
				#endif
				#if defined( ASE_DISTANCE_TESSELLATION )
				float tessMin = _TessMin; float tessMax = _TessMax;
				#endif
				#if defined( ASE_LENGTH_TESSELLATION ) || defined( ASE_LENGTH_CULL_TESSELLATION )
				float edgeLength = _EdgeLength;
				#endif
				#if defined( ASE_LENGTH_CULL_TESSELLATION )
				float tessMaxDisp = _TessMaxDisp;
				#endif
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
				UNITY_SETUP_INSTANCE_ID(input);
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float Sgurface248 = _Surface;
				float Layer289 = _EFFECTS;
				float compareResult14_g61487 = ( float )0;
				if( Sgurface248 == (float)0 )
				{
					compareResult14_g61487 = (float)1;
				}
				else
				{
					float2 HeightMapUV36_g61469 = (input.ase_texcoord.xyz.xy*_MainTex_ST.xy + _MainTex_ST.zw);
					float4 tex2DNode9_g61469 = tex2D( _ParallaxMap, HeightMapUV36_g61469 );
					float4 break56_g61469 = tex2DNode9_g61469;
					float3 ase_positionWS = input.ase_texcoord1.xyz;
					float3 ase_tangentWS = input.ase_texcoord2.xyz;
					float3 ase_normalWS = input.ase_texcoord3.xyz;
					float3 ase_bitangentWS = input.ase_texcoord4.xyz;
					float3 tanToWorld0 = float3( ase_tangentWS.x, ase_bitangentWS.x, ase_normalWS.x );
					float3 tanToWorld1 = float3( ase_tangentWS.y, ase_bitangentWS.y, ase_normalWS.y );
					float3 tanToWorld2 = float3( ase_tangentWS.z, ase_bitangentWS.z, ase_normalWS.z );
					float3 ase_viewVectorTS =  tanToWorld0 * ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - ase_positionWS : UNITY_MATRIX_V[ 2 ].xyz ).x + tanToWorld1 * ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - ase_positionWS : UNITY_MATRIX_V[ 2 ].xyz ).y  + tanToWorld2 * ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - ase_positionWS : UNITY_MATRIX_V[ 2 ].xyz ).z;
					float3 ase_viewDirTS = normalize( ase_viewVectorTS );
					float2 compareResult23_g61469 = ( float2 )0;
					if( (int)_SimulatorHeightMap == 1 )
					{
						compareResult23_g61469 = ( HeightMapUV36_g61469 + ( ( ( break56_g61469.b - 0.5 ) * (  (0.5 + ( _Parallax - 0.005 ) * ( 8.0 - 0.5 ) / ( 0.08 - 0.005 ) ) * 0.01 ) ) * (ase_viewDirTS).xy ) );
					}
					else
					{
						compareResult23_g61469 = HeightMapUV36_g61469;
					}
					float2 temp_output_714_0 = compareResult23_g61469;
					float4 tex2DNode10 = tex2D( _MainTex, temp_output_714_0 );
					float compareResult7_g61487 = ( float )0;
					if( Layer289 == (float)3 )
					{
						float2 uv_SubTex = input.ase_texcoord.xyz.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 uv2_SubTex = input.ase_texcoord5.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float Layer_Value17_g61475 = (float)_UVLayer;
						float2 lerpResult6_g61475 = lerp( uv_SubTex , uv2_SubTex , step( 0.5 , Layer_Value17_g61475 ));
						float2 uv3_SubTex = input.ase_texcoord5.zw * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 lerpResult14_g61475 = lerp( lerpResult6_g61475 , uv3_SubTex , step( 1.5 , Layer_Value17_g61475 ));
						float2 uv4_SubTex = input.ase_texcoord6.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 lerpResult16_g61475 = lerp( lerpResult14_g61475 , uv4_SubTex , step( 2.5 , Layer_Value17_g61475 ));
						float4 tex2DNode10_g61473 = tex2D( _SubTex, lerpResult16_g61475 );
						compareResult7_g61487 = ( tex2DNode10_g61473.a * tex2DNode10.a );
					}
					else
					{
						compareResult7_g61487 = tex2DNode10.a;
					}
					compareResult14_g61487 = saturate( ( _Opaque * compareResult7_g61487 ) );
				}
				
				float compareResult2_g61488 = ( float )0;
				if( _AlphaClip == (float)1 )
				{
					compareResult2_g61488 = _Cutoff;
				}
				else
				{
					compareResult2_g61488 = 0.0001;
				}
				float Alpha_Clip_Threshold323 = compareResult2_g61488;
				

				surfaceDescription.Alpha = compareResult14_g61487;
				#if defined( _ALPHATEST_ON )
					#ifdef ASE_PROPERTY_CUTOFF
					float alphaCutoff = _Cutoff;
					#else
					float alphaCutoff = 0.5;
					#endif
					surfaceDescription.AlphaClipThreshold = Alpha_Clip_Threshold323;
				#endif

				#ifdef _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				half4 outColor = 0;
				outColor = unity_SelectionID;

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

        	#pragma shader_feature_local _ALPHATEST_ON
        	#define _NORMAL_DROPOFF_TS 1
        	#pragma multi_compile_instancing
        	#pragma multi_compile _ LOD_FADE_CROSSFADE
        	#define ASE_OPAQUE_KEEP_ALPHA
        	#define ASE_TESSELLATION 1
        	#pragma require tessellation tessHW
        	#pragma hull HullFunction
        	#pragma domain DomainFunction
        	#define ASE_PHONG_TESSELLATION
        	#define ASE_LENGTH_TESSELLATION
        	#define ASE_FOG 1
        	#define ASE_VERSION 19915
        	#define ASE_SRP_VERSION 170600


        	#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define VARYINGS_NEED_NORMAL_WS
			#define VARYINGS_NEED_TANGENT_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if ( UNITY_VERSION >= 60070000 )
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/PackNormalsTexture.hlsl"
			#endif

            #if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_TEXTURE_COORDINATES2
			#define ASE_NEEDS_TEXTURE_COORDINATES3
			#pragma multi_compile _ _FOG_ON
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#ifndef _FOG_ON
			#undef ASE_FOG
			#endif
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING


			#if defined(ASE_WRITE_DEPTH_CONSERVATIVE) && (SHADER_TARGET >= 45)
				#if UNITY_REVERSED_Z
					#define ASE_SV_DEPTH SV_DepthLessEqual
				#else
					#define ASE_SV_DEPTH SV_DepthGreaterEqual
				#endif
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				half3 normalWS : TEXCOORD0;
				float4 tangentWS : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				#if defined( SHADER_STAGE_FRAGMENT ) && defined( ASE_NEED_CULLFACE )
					uint cullFace : SV_IsFrontFace;
				#endif
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _OutlineColor;
			float4 _Specular;
			float4 _Ambient;
			float4 _Color;
			float4 _SubTex_ST;
			float4 _MainTex_ST;
			float3 _ToonTone;
			float _CastShadows;
			float _ShadowLum;
			float _SShad;
			float _EFFECTS;
			int _UVLayer;
			float _Shininess;
			float _SpecularIntensity;
			float _MultipleLights;
			float _HDR;
			float _Opaque;
			float _SPHOpacity;
			float _BumpScale;
			float _Parallax;
			float _SimulatorHeightMap;
			float _ZTest;
			float _SrcBlend;
			float _DstBlend;
			float _ZWriteControl;
			float _ZWrite;
			float _Cull;
			#define ASE_PROPERTY_CUTOFF
			float _Blend;
			float _PhongTessStrength;
			float _On;
			float _EdgeSize;
			float _ExtrusionAmount;
			float _Surface;
			float _SimulatorNormalMap;
			float _EdgeLength;
			#define ASE_PROPERTY_ALPHACLIP
			#ifdef ASE_PROPERTY_ALPHACLIP
				float _AlphaClip;
			#endif
			#ifdef ASE_PROPERTY_CUTOFF
				float _Cutoff;
			#endif
			#ifdef ASE_TESSELLATION
				#ifdef ASE_PHONG_TESSELLATION
					float _TessPhongStrength;
				#endif
				#if defined( ASE_FIXED_TESSELLATION ) || defined( ASE_DISTANCE_TESSELLATION )
					float _TessValue;
				#endif
				#ifdef ASE_DISTANCE_TESSELLATION
					float _TessMin;
					float _TessMax;
				#endif
				#if defined( ASE_LENGTH_TESSELLATION ) || defined( ASE_LENGTH_CULL_TESSELLATION )
					float _TessEdgeLength;
				#endif
				#ifdef ASE_LENGTH_CULL_TESSELLATION
					float _TessMaxDisp;
				#endif
			#endif
			UNITY_TEXTURE_STREAMING_DEBUG_VARS;
			CBUFFER_END

			sampler2D _MainTex;
			sampler2D _ParallaxMap;
			sampler2D _SubTex;


			
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

				float temp_output_9_0_g61489 = _ExtrusionAmount;
				float3 Extrusion_Vertex_Offset684 = ( temp_output_9_0_g61489 * input.normalOS );
				
				float3 ase_positionWS = TransformObjectToWorld( ( input.positionOS ).xyz );
				output.ase_texcoord3.xyz = ase_positionWS;
				
				output.ase_texcoord2.xyz = input.ase_texcoord.xyz;
				output.ase_texcoord4.xy = input.ase_texcoord1.xy;
				output.ase_texcoord4.zw = input.ase_texcoord2.xy;
				output.ase_texcoord5.xy = input.ase_texcoord3.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord2.w = 0;
				output.ase_texcoord3.w = 0;
				output.ase_texcoord5.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = Extrusion_Vertex_Offset684;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );
				VertexNormalInputs normalInput = GetVertexNormalInputs( input.normalOS, input.tangentOS );

				output.positionCS = ASE_ADJUST_CLIP_POSITION( vertexInput.positionCS );
				output.normalWS = normalInput.normalWS;
				output.tangentWS = float4( normalInput.tangentWS, ( input.tangentOS.w > 0.0 ? 1.0 : -1.0 ) * GetOddNegativeScale() );
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
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
				output.tangentOS = input.tangentOS;
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
				#if defined( ASE_FIXED_TESSELLATION ) || defined( ASE_DISTANCE_TESSELLATION )
				float tessValue = _TessValue;
				#endif
				#if defined( ASE_DISTANCE_TESSELLATION )
				float tessMin = _TessMin; float tessMax = _TessMax;
				#endif
				#if defined( ASE_LENGTH_TESSELLATION ) || defined( ASE_LENGTH_CULL_TESSELLATION )
				float edgeLength = _EdgeLength;
				#endif
				#if defined( ASE_LENGTH_CULL_TESSELLATION )
				float tessMaxDisp = _TessMaxDisp;
				#endif
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
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
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
						#if defined( ASE_WRITE_DEPTH )
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						#ifdef _WRITE_RENDERING_LAYERS
						#if ( UNITY_VERSION >= 60020000 )
						, out uint outRenderingLayers : SV_Target1
						#else
						, out float4 outRenderingLayers : SV_Target1
						#endif
						#endif
						 )
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				// @diogo: mikktspace compliant
				float renormFactor = 1.0 / max( FLT_MIN, length( input.normalWS ) );

				float3 NormalWS = input.normalWS * renormFactor;
				float3 TangentWS = input.tangentWS.xyz * renormFactor;
				float3 BitangentWS = cross( input.normalWS, input.tangentWS.xyz ) * input.tangentWS.w * renormFactor;
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;
				float4 ScreenPos = ComputeScreenPos( ClipPos );

				#if defined( SHADER_STAGE_FRAGMENT ) && defined( ASE_NEED_CULLFACE )
					float IsFrontFace = input.cullFace;
				#else
					float IsFrontFace = 1;
				#endif

				float Sgurface248 = _Surface;
				float Layer289 = _EFFECTS;
				float compareResult14_g61487 = ( float )0;
				if( Sgurface248 == (float)0 )
				{
					compareResult14_g61487 = (float)1;
				}
				else
				{
					float2 HeightMapUV36_g61469 = (input.ase_texcoord2.xyz.xy*_MainTex_ST.xy + _MainTex_ST.zw);
					float4 tex2DNode9_g61469 = tex2D( _ParallaxMap, HeightMapUV36_g61469 );
					float4 break56_g61469 = tex2DNode9_g61469;
					float3 ase_positionWS = input.ase_texcoord3.xyz;
					float3 tanToWorld0 = float3( TangentWS.x, BitangentWS.x, NormalWS.x );
					float3 tanToWorld1 = float3( TangentWS.y, BitangentWS.y, NormalWS.y );
					float3 tanToWorld2 = float3( TangentWS.z, BitangentWS.z, NormalWS.z );
					float3 ase_viewVectorTS =  tanToWorld0 * ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - ase_positionWS : UNITY_MATRIX_V[ 2 ].xyz ).x + tanToWorld1 * ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - ase_positionWS : UNITY_MATRIX_V[ 2 ].xyz ).y  + tanToWorld2 * ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - ase_positionWS : UNITY_MATRIX_V[ 2 ].xyz ).z;
					float3 ase_viewDirTS = normalize( ase_viewVectorTS );
					float2 compareResult23_g61469 = ( float2 )0;
					if( (int)_SimulatorHeightMap == 1 )
					{
						compareResult23_g61469 = ( HeightMapUV36_g61469 + ( ( ( break56_g61469.b - 0.5 ) * (  (0.5 + ( _Parallax - 0.005 ) * ( 8.0 - 0.5 ) / ( 0.08 - 0.005 ) ) * 0.01 ) ) * (ase_viewDirTS).xy ) );
					}
					else
					{
						compareResult23_g61469 = HeightMapUV36_g61469;
					}
					float2 temp_output_714_0 = compareResult23_g61469;
					float4 tex2DNode10 = tex2D( _MainTex, temp_output_714_0 );
					float compareResult7_g61487 = ( float )0;
					if( Layer289 == (float)3 )
					{
						float2 uv_SubTex = input.ase_texcoord2.xyz.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 uv2_SubTex = input.ase_texcoord4.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float Layer_Value17_g61475 = (float)_UVLayer;
						float2 lerpResult6_g61475 = lerp( uv_SubTex , uv2_SubTex , step( 0.5 , Layer_Value17_g61475 ));
						float2 uv3_SubTex = input.ase_texcoord4.zw * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 lerpResult14_g61475 = lerp( lerpResult6_g61475 , uv3_SubTex , step( 1.5 , Layer_Value17_g61475 ));
						float2 uv4_SubTex = input.ase_texcoord5.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 lerpResult16_g61475 = lerp( lerpResult14_g61475 , uv4_SubTex , step( 2.5 , Layer_Value17_g61475 ));
						float4 tex2DNode10_g61473 = tex2D( _SubTex, lerpResult16_g61475 );
						compareResult7_g61487 = ( tex2DNode10_g61473.a * tex2DNode10.a );
					}
					else
					{
						compareResult7_g61487 = tex2DNode10.a;
					}
					compareResult14_g61487 = saturate( ( _Opaque * compareResult7_g61487 ) );
				}
				
				float compareResult2_g61488 = ( float )0;
				if( _AlphaClip == (float)1 )
				{
					compareResult2_g61488 = _Cutoff;
				}
				else
				{
					compareResult2_g61488 = 0.0001;
				}
				float Alpha_Clip_Threshold323 = compareResult2_g61488;
				

				float3 Normal = float3(0, 0, 1);

				float Alpha = compareResult14_g61487;
				#if defined( _ALPHATEST_ON )
					#ifdef ASE_PROPERTY_CUTOFF
					float alphaCutoff = _Cutoff;
					#else
					float alphaCutoff = 0.5;
					#endif
					float AlphaClipThreshold = Alpha_Clip_Threshold323;
				#endif

				#if defined( ASE_WRITE_DEPTH )
					input.positionCS.z = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined( ASE_WRITE_DEPTH )
					outputDepth = input.positionCS.z;
				#endif

				#if defined( ASE_DOUBLE_SIDED_FLIP ) || defined( ASE_DOUBLE_SIDED_MIRROR )
					NormalWS = IsFrontFace ? NormalWS : -NormalWS;
					#if defined( ASE_DOUBLE_SIDED_FLIP ) && _NORMAL_DROPOFF_TS
						Normal.xy = IsFrontFace ? Normal.xy : -Normal.xy;
					#endif
				#endif

				#if defined(_NORMALMAP)
					#if _NORMAL_DROPOFF_TS
						float3 normalWS = TransformTangentToWorld(Normal, half3x3(TangentWS, BitangentWS, NormalWS));
					#elif _NORMAL_DROPOFF_OS
						float3 normalWS = TransformObjectToWorldNormal(Normal);
					#elif _NORMAL_DROPOFF_WS
						float3 normalWS = Normal;
					#endif
					#if !_NORMAL_DROPOFF_TS && ( defined( ASE_DOUBLE_SIDED_FLIP ) || defined( ASE_DOUBLE_SIDED_MIRROR ) )
						// @diogo: same back-face correction as HDRP's GetNormalWS_SrcWS
						if ( !IsFrontFace )
						{
							normalWS += 2 * NormalWS * max( 0, -dot( NormalWS, normalWS ) );
							#if defined( ASE_DOUBLE_SIDED_FLIP )
								normalWS = reflect( -normalWS, NormalWS );
							#endif
						}
					#endif
				#else
					float3 normalWS = NormalWS;
				#endif

				#if ( UNITY_VERSION >= 60070000 )
					outNormalWS = half4( PackNormalWSToTexture( NormalizeNormalPerPixel( normalWS ) ), 0.0 );
				#elif defined(_GBUFFER_NORMALS_OCT)
					float2 octNormalWS = PackNormalOctQuadEncode(NormalizeNormalPerPixel(normalWS));
					float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);
					half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);
					outNormalWS = half4(packedNormalWS, 0.0);
				#else
					outNormalWS = half4(NormalizeNormalPerPixel(normalWS), 0.0);
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					#if ( UNITY_VERSION >= 60020000 )
					outRenderingLayers = EncodeMeshRenderingLayer();
					#else
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
					#endif
				#endif
			}
			ENDHLSL
		}

		
		Pass
		{			
			
			Name "GBuffer"
			Tags { "LightMode"="UniversalGBuffer" }

			ZWrite [_ZWrite]
			ZTest [_ZTest]
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#pragma shader_feature_local _ALPHATEST_ON
			#define _NORMAL_DROPOFF_TS 1
			#define UNLIT_DEFAULT_DECAL_BLENDING
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_instancing
			#pragma shader_feature_local_fragment _RECEIVE_SHADOWS_OFF
			#define ASE_OPAQUE_KEEP_ALPHA
			#define ASE_TESSELLATION 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_PHONG_TESSELLATION
			#define ASE_LENGTH_TESSELLATION
			#define ASE_FOG 1
			#define ASE_VERSION 19915
			#define ASE_SRP_VERSION 170600


			// Deferred Rendering Path does not support the OpenGL-based graphics API:
			// Desktop OpenGL, OpenGL ES 3.0, WebGL 2.0.
			#pragma exclude_renderers glcore gles3 

			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
			#pragma multi_compile_fragment _ _RENDER_PASS_ENABLED

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_GBUFFER

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if ( UNITY_VERSION >= 60030017 && UNITY_VERSION < 60040000 ) || ( UNITY_VERSION >= 60040010 )
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GBufferOutputFormat.hlsl"
			#endif

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#include "../../MMD_Custom_Node_(URP_ASE).hlsl"
			#include "../MMD_Effects_Custom_Node_(URP_ASE).hlsl"
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_NORMAL
			#define ASE_NEEDS_FRAG_POSITION
			#define ASE_NEEDS_TEXTURE_COORDINATES2
			#define ASE_NEEDS_TEXTURE_COORDINATES3
			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES2
			#pragma multi_compile _ _FOG_ON
			#if (UNITY_VERSION >= 60010000) && (UNITY_VERSION < 60070000)
			#pragma multi_compile _ _CLUSTER_LIGHT_LOOP
			#endif
			#if (UNITY_VERSION >= 60070000)
			#pragma multi_compile_fragment _ _CLUSTER_LIGHT_LOOP
			#endif
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#ifndef _FOG_ON
			#undef ASE_FOG
			#endif
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING


			#if defined(ASE_WRITE_DEPTH_CONSERVATIVE) && (SHADER_TARGET >= 45)
				#if UNITY_REVERSED_Z
					#define ASE_SV_DEPTH SV_DepthLessEqual
				#else
					#define ASE_SV_DEPTH SV_DepthGreaterEqual
				#endif
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				half3 normalWS : TEXCOORD1;
				half4 tangentWS : TEXCOORD2;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				#if defined( SHADER_STAGE_FRAGMENT ) && defined( ASE_NEED_CULLFACE )
					uint cullFace : SV_IsFrontFace;
				#endif
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _OutlineColor;
			float4 _Specular;
			float4 _Ambient;
			float4 _Color;
			float4 _SubTex_ST;
			float4 _MainTex_ST;
			float3 _ToonTone;
			float _CastShadows;
			float _ShadowLum;
			float _SShad;
			float _EFFECTS;
			int _UVLayer;
			float _Shininess;
			float _SpecularIntensity;
			float _MultipleLights;
			float _HDR;
			float _Opaque;
			float _SPHOpacity;
			float _BumpScale;
			float _Parallax;
			float _SimulatorHeightMap;
			float _ZTest;
			float _SrcBlend;
			float _DstBlend;
			float _ZWriteControl;
			float _ZWrite;
			float _Cull;
			#define ASE_PROPERTY_CUTOFF
			float _Blend;
			float _PhongTessStrength;
			float _On;
			float _EdgeSize;
			float _ExtrusionAmount;
			float _Surface;
			float _SimulatorNormalMap;
			float _EdgeLength;
			#define ASE_PROPERTY_ALPHACLIP
			#ifdef ASE_PROPERTY_ALPHACLIP
				float _AlphaClip;
			#endif
			#ifdef ASE_PROPERTY_CUTOFF
				float _Cutoff;
			#endif
			#ifdef ASE_TESSELLATION
				#ifdef ASE_PHONG_TESSELLATION
					float _TessPhongStrength;
				#endif
				#if defined( ASE_FIXED_TESSELLATION ) || defined( ASE_DISTANCE_TESSELLATION )
					float _TessValue;
				#endif
				#ifdef ASE_DISTANCE_TESSELLATION
					float _TessMin;
					float _TessMax;
				#endif
				#if defined( ASE_LENGTH_TESSELLATION ) || defined( ASE_LENGTH_CULL_TESSELLATION )
					float _TessEdgeLength;
				#endif
				#ifdef ASE_LENGTH_CULL_TESSELLATION
					float _TessMaxDisp;
				#endif
			#endif
			UNITY_TEXTURE_STREAMING_DEBUG_VARS;
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _NormalMap;
			sampler2D _MainTex;
			sampler2D _ParallaxMap;
			sampler2D _ToonTex;
			samplerCUBE _SphereCube;
			sampler2D _SubTex;


			#if ( UNITY_VERSION >= 60010000 )
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GBufferOutput.hlsl"
			#else
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
			#endif

			half4 CalculateShadowMask1_g61479( half2 LightmapUV )
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
				#if ( UNITY_VERSION < 60010000 ) && !defined( USE_CLUSTER_LIGHT_LOOP )
				#define USE_CLUSTER_LIGHT_LOOP USE_FORWARD_PLUS
				#endif
				#if ( UNITY_VERSION < 60010000 ) && !defined( CLUSTER_LIGHT_LOOP_SUBTRACTIVE_LIGHT_CHECK )
				#define CLUSTER_LIGHT_LOOP_SUBTRACTIVE_LIGHT_CHECK FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
				#endif
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
				#if USE_CLUSTER_LIGHT_LOOP
				[loop] for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
				{
					CLUSTER_LIGHT_LOOP_SUBTRACTIVE_LIGHT_CHECK
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

				float temp_output_9_0_g61489 = _ExtrusionAmount;
				float3 Extrusion_Vertex_Offset684 = ( temp_output_9_0_g61489 * input.normalOS );
				
				output.ase_normal = input.normalOS;
				output.ase_texcoord3.xyz = input.ase_texcoord.xyz;
				output.ase_texcoord4.xy = input.ase_texcoord1.xy;
				output.ase_texcoord5 = input.positionOS;
				output.ase_texcoord4.zw = input.ase_texcoord2.xy;
				output.ase_texcoord6.xy = input.ase_texcoord3.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord3.w = 0;
				output.ase_texcoord6.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = Extrusion_Vertex_Offset684;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );
				VertexNormalInputs normalInput = GetVertexNormalInputs( input.normalOS, input.tangentOS );

				output.positionCS = ASE_ADJUST_CLIP_POSITION(vertexInput.positionCS );
				output.positionWS = vertexInput.positionWS;
				output.normalWS = normalInput.normalWS;
				output.tangentWS = half4( normalInput.tangentWS, ( input.tangentOS.w > 0.0 ? 1.0 : -1.0 ) * GetOddNegativeScale() );;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
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
				output.tangentOS = input.tangentOS;
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
				#if defined( ASE_FIXED_TESSELLATION ) || defined( ASE_DISTANCE_TESSELLATION )
				float tessValue = _TessValue;
				#endif
				#if defined( ASE_DISTANCE_TESSELLATION )
				float tessMin = _TessMin; float tessMax = _TessMax;
				#endif
				#if defined( ASE_LENGTH_TESSELLATION ) || defined( ASE_LENGTH_CULL_TESSELLATION )
				float edgeLength = _EdgeLength;
				#endif
				#if defined( ASE_LENGTH_CULL_TESSELLATION )
				float tessMaxDisp = _TessMaxDisp;
				#endif
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
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
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

		#if ( UNITY_VERSION >= 60010000 )
			GBufferFragOutput frag ( PackedVaryings input
		#else
			FragmentOutput frag ( PackedVaryings input
		#endif
								#if defined( ASE_WRITE_DEPTH )
								,out float outputDepth : ASE_SV_DEPTH
								#endif
								 )
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				// @diogo: mikktspace compliant
				float renormFactor = 1.0 / max( FLT_MIN, length( input.normalWS ) );

				float3 PositionWS = input.positionWS;
				float3 ViewDirWS = GetWorldSpaceNormalizeViewDir( PositionWS );
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;
				float4 ScreenPos = ComputeScreenPos( ClipPos );
				float3 TangentWS = input.tangentWS.xyz * renormFactor;
				float3 BitangentWS = cross( input.normalWS, input.tangentWS.xyz ) * input.tangentWS.w * renormFactor;
				float3 NormalWS = input.normalWS * renormFactor;

				#if defined( SHADER_STAGE_FRAGMENT ) && defined( ASE_NEED_CULLFACE )
					float IsFrontFace = input.cullFace;
				#else
					float IsFrontFace = 1;
				#endif

				float localvLight3_g61463 = ( 0.0 );
				float3 objToWorldDir2_g61463 = mul( GetObjectToWorldMatrix(), float4( input.ase_normal, 0.0 ) ).xyz;
				float3 normal3_g61463 = objToWorldDir2_g61463;
				float3 Output3_g61463 = float3( 0,0,0 );
				vLight_float( normal3_g61463 , Output3_g61463 );
				float3 Global_Ambient682 = Output3_g61463;
				float2 HeightMapUV36_g61469 = (input.ase_texcoord3.xyz.xy*_MainTex_ST.xy + _MainTex_ST.zw);
				float4 tex2DNode9_g61469 = tex2D( _ParallaxMap, HeightMapUV36_g61469 );
				float4 break56_g61469 = tex2DNode9_g61469;
				float3 tanToWorld0 = float3( TangentWS.x, BitangentWS.x, NormalWS.x );
				float3 tanToWorld1 = float3( TangentWS.y, BitangentWS.y, NormalWS.y );
				float3 tanToWorld2 = float3( TangentWS.z, BitangentWS.z, NormalWS.z );
				float3 ase_viewVectorTS =  tanToWorld0 * ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - PositionWS : UNITY_MATRIX_V[ 2 ].xyz ).x + tanToWorld1 * ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - PositionWS : UNITY_MATRIX_V[ 2 ].xyz ).y  + tanToWorld2 * ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - PositionWS : UNITY_MATRIX_V[ 2 ].xyz ).z;
				float3 ase_viewDirTS = normalize( ase_viewVectorTS );
				float2 compareResult23_g61469 = ( float2 )0;
				if( (int)_SimulatorHeightMap == 1 )
				{
					compareResult23_g61469 = ( HeightMapUV36_g61469 + ( ( ( break56_g61469.b - 0.5 ) * (  (0.5 + ( _Parallax - 0.005 ) * ( 8.0 - 0.5 ) / ( 0.08 - 0.005 ) ) * 0.01 ) ) * (ase_viewDirTS).xy ) );
				}
				else
				{
					compareResult23_g61469 = HeightMapUV36_g61469;
				}
				float2 temp_output_714_0 = compareResult23_g61469;
				float4 tex2DNode21_g61486 = tex2D( _NormalMap, temp_output_714_0 );
				float3 unpack24_g61486 = UnpackNormalScale( tex2DNode21_g61486, _BumpScale );
				unpack24_g61486.z = lerp( 1, unpack24_g61486.z, saturate(_BumpScale) );
				float3 tanNormal33_g61486 = unpack24_g61486;
				float3 worldNormal33_g61486 = float3( dot( tanToWorld0, tanNormal33_g61486 ), dot( tanToWorld1, tanNormal33_g61486 ), dot( tanToWorld2, tanNormal33_g61486 ) );
				float localGetMainLightDirection2_g61484 = ( 0.0 );
				float2 lightmapUV2_g61484 = (input.ase_texcoord4.xy*(unity_LightmapST).xy + (unity_LightmapST).zw);
				float3 Direction2_g61484 = float3( 0,0,0 );
				GetMainLightDirection_float( lightmapUV2_g61484 , Direction2_g61484 );
				float dotResult45_g61486 = dot( worldNormal33_g61486 , Direction2_g61484 );
				float locallightColor15_g61467 = ( 0.0 );
				float3 objToWorld8_g61467 = mul( GetObjectToWorldMatrix(), float4( input.ase_texcoord5.xyz, 1 ) ).xyz;
				float3 worldPos15_g61467 = objToWorld8_g61467;
				float3 OutputColor15_g61467 = float3( 0,0,0 );
				lightColor_float( worldPos15_g61467 , OutputColor15_g61467 );
				float3 temp_output_12_0_g61470 = OutputColor15_g61467;
				float3 staticSwitch8_g61470 = ( float3 )0;
				#ifdef LIGHTMAP_ON
				{
					float dotResult14_g61470 = dot( temp_output_12_0_g61470 , temp_output_12_0_g61470 );
					float locallightmapCol11_g61470 = ( 0.0 );
					float2 lightmapUV11_g61470 = (input.ase_texcoord4.xy*(unity_LightmapST).xy + (unity_LightmapST).zw);
					float3 Output11_g61470 = float3( 0,0,0 );
					lightmapCol_float( lightmapUV11_g61470 , Output11_g61470 );
					float3 compareResult10_g61470 = ( float3 )0;
					if( dotResult14_g61470 == (float)0 )
					{
						compareResult10_g61470 = ( Output11_g61470 * 2.0 );
					}
					else
					{
						compareResult10_g61470 = temp_output_12_0_g61470;
					}
					staticSwitch8_g61470 = ( compareResult10_g61470 + Output11_g61470 );
				}
				#else
				{
					staticSwitch8_g61470 = temp_output_12_0_g61470;
				}
				#endif
				float3 Baked_Light_Maps680 = staticSwitch8_g61470;
				float temp_output_23_0_g61477 = _SShad;
				float3 break10_g61467 = _ToonTone;
				float3 objToWorldDir5_g61466 = mul( GetObjectToWorldMatrix(), float4( input.ase_normal, 0.0 ) ).xyz;
				float3 normalizeResult3_g61466 = normalize( objToWorldDir5_g61466 );
				float3 normalizeResult2_g61466 = normalize( _MainLightPosition.xyz );
				float dotResult4_g61466 = dot( normalizeResult3_g61466 , normalizeResult2_g61466 );
				float temp_output_1_0_g61467 = ( ( break10_g61467.y * dotResult4_g61466 ) + break10_g61467.z );
				float localshadowAtten16_g61467 = ( 0.0 );
				float3 worldPos16_g61467 = objToWorld8_g61467;
				float OutputShadowAtten16_g61467 = 0.0;
				shadowAtten_float( worldPos16_g61467 , OutputShadowAtten16_g61467 );
				float temp_output_2_0_g61467 = ( break10_g61467.z + ( break10_g61467.x * ( OutputShadowAtten16_g61467 - 0.5 ) ) );
				float temp_output_701_22 = min( temp_output_1_0_g61467, temp_output_2_0_g61467 );
				float2 compareResult1_g61477 = ( float2 )0;
				if( temp_output_23_0_g61477 == (float)0 )
				{
					float temp_output_21_0_g61477 = saturate( temp_output_701_22 );
					float2 appendResult11_g61477 = (float2(temp_output_21_0_g61477 , temp_output_21_0_g61477));
					compareResult1_g61477 = appendResult11_g61477;
				}
				else
				{
					compareResult1_g61477 = float2( 0,0 );
				}
				float4 tex2DNode33_g61477 = tex2D( _ToonTex, compareResult1_g61477 );
				float4 compareResult8_g61477 = ( float4 )0;
				if( temp_output_23_0_g61477 == (float)0 )
				{
					compareResult8_g61477 = tex2DNode33_g61477;
				}
				else
				{
					float temp_output_3_0_g61472 = ( temp_output_701_22 * 2.0 );
					float4 lerpResult9_g61477 = lerp( tex2DNode33_g61477 , float4( float3( 1, 1, 1 ) , 0.0 ) , saturate( ( ( temp_output_3_0_g61472 * temp_output_3_0_g61472 ) - 1.0 ) ));
					compareResult8_g61477 = lerpResult9_g61477;
				}
				float4 Toon_Ramp_Shadow681 = saturate( ( 1.0 - ( _ShadowLum * ( 1.0 - compareResult8_g61477 ) ) ) );
				half3 Global_Light_Scale139 = half3( 0.6, 0.6, 0.6 );
				float3 Light_Color647 = ( Baked_Light_Maps680 * Global_Light_Scale139 );
				float3 Ambient_Blend_Factor48 = ( float3( 1, 1, 1 ) - ( max( ( half3( 0.5, 0.5, 0.5 ) - (_Ambient).rgb ), float3( 0, 0, 0 ) ) * ( half3( 1, 1, 1 ) / 0.5 ) ) );
				float3 Weighted_Ambient144 = ( Global_Ambient682 * Ambient_Blend_Factor48 );
				float3 Temp_Diffuse46_g61473 = max( ( min( ( (_Ambient).rgb + ( (_Color).rgb * Global_Light_Scale139 ) ), float3( 1, 1, 1 ) ) - Weighted_Ambient144 ), float3( 0, 0, 0 ) );
				float4 tex2DNode10 = tex2D( _MainTex, temp_output_714_0 );
				float4 Albedo_Texture41_g61473 = tex2DNode10;
				float4 temp_output_18_0_g61473 = ( float4( Temp_Diffuse46_g61473 , 0.0 ) * Albedo_Texture41_g61473 );
				float3 objToView2_g61468 = TransformWorldToView( TransformObjectToWorld(input.ase_texcoord5.xyz) );
				float3 normalizeResult4_g61468 = normalize( objToView2_g61468 );
				float3 objToViewDir3_g61468 = normalize( mul( UNITY_MATRIX_IT_MV, float4( input.ase_normal, 0.0 ) ).xyz );
				float3 normalizeResult5_g61468 = normalize( objToViewDir3_g61468 );
				float4 texCUBENode40 = texCUBE( _SphereCube, reflect( normalizeResult4_g61468 , normalizeResult5_g61468 ) );
				float4 temp_output_27_0_g61473 = ( texCUBENode40 * _SPHOpacity );
				float Layer289 = _EFFECTS;
				float Effect_Layer13_g61473 = Layer289;
				float Layer_Value17_g61476 = Effect_Layer13_g61473;
				float4 lerpResult6_g61476 = lerp( temp_output_18_0_g61473 , ( temp_output_18_0_g61473 + temp_output_27_0_g61473 ) , step( 0.5 , Layer_Value17_g61476 ));
				float4 temp_output_15_0_g61473 = ( temp_output_27_0_g61473 * Albedo_Texture41_g61473 );
				float4 lerpResult14_g61476 = lerp( lerpResult6_g61476 , ( temp_output_15_0_g61473 * float4( Temp_Diffuse46_g61473 , 0.0 ) ) , step( 1.5 , Layer_Value17_g61476 ));
				float2 uv_SubTex = input.ase_texcoord3.xyz.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv2_SubTex = input.ase_texcoord4.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float Layer_Value17_g61475 = (float)_UVLayer;
				float2 lerpResult6_g61475 = lerp( uv_SubTex , uv2_SubTex , step( 0.5 , Layer_Value17_g61475 ));
				float2 uv3_SubTex = input.ase_texcoord4.zw * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 lerpResult14_g61475 = lerp( lerpResult6_g61475 , uv3_SubTex , step( 1.5 , Layer_Value17_g61475 ));
				float2 uv4_SubTex = input.ase_texcoord6.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 lerpResult16_g61475 = lerp( lerpResult14_g61475 , uv4_SubTex , step( 2.5 , Layer_Value17_g61475 ));
				float4 tex2DNode10_g61473 = tex2D( _SubTex, lerpResult16_g61475 );
				float4 lerpResult16_g61476 = lerp( lerpResult14_g61476 , ( float4( Temp_Diffuse46_g61473 , 0.0 ) * Albedo_Texture41_g61473 * tex2DNode10_g61473 ) , step( 2.5 , Layer_Value17_g61476 ));
				float4 Sphere_Map_Diffuse_Blend678 = lerpResult16_g61476;
				float3 objToWorldDir9_g61483 = mul( GetObjectToWorldMatrix(), float4( input.ase_normal, 0.0 ) ).xyz;
				float3 normalizeResult4_g61483 = normalize( objToWorldDir9_g61483 );
				float3 normalizeResult7_g61483 = normalize( ( _MainLightPosition.xyz + ViewDirWS ) );
				float dotResult1_g61483 = dot( normalizeResult4_g61483 , normalizeResult7_g61483 );
				float Layer_Value17_g61474 = Effect_Layer13_g61473;
				float4 lerpResult6_g61474 = lerp( Albedo_Texture41_g61473 , ( temp_output_27_0_g61473 + Albedo_Texture41_g61473 ) , step( 0.5 , Layer_Value17_g61474 ));
				float4 lerpResult14_g61474 = lerp( lerpResult6_g61474 , temp_output_15_0_g61473 , step( 1.5 , Layer_Value17_g61474 ));
				float4 lerpResult16_g61474 = lerp( lerpResult14_g61474 , Albedo_Texture41_g61473 , step( 2.5 , Layer_Value17_g61474 ));
				float4 Sphere_Map_Color679 = lerpResult16_g61474;
				float3 temp_output_13_0_g61478 = Global_Ambient682;
				float3 compareResult2_g61478 = ( float3 )0;
				if( _MultipleLights == (float)1 )
				{
					float3 WorldPosition288_g61482 = PositionWS;
					float3 WorldPosition305_g61482 = WorldPosition288_g61482;
					float2 ScreenUV286_g61482 = (ScreenPosNorm).xy;
					float2 ScreenUV305_g61482 = ScreenUV286_g61482;
					float3 objToWorldDir5_g61478 = mul( GetObjectToWorldMatrix(), float4( input.ase_normal, 0.0 ) ).xyz;
					float3 WorldNormal281_g61482 = objToWorldDir5_g61478;
					float3 WorldNormal305_g61482 = WorldNormal281_g61482;
					half2 LightmapUV1_g61479 = (input.ase_texcoord4.zw*(unity_DynamicLightmapST).xy + (unity_DynamicLightmapST).zw);
					half4 localCalculateShadowMask1_g61479 = CalculateShadowMask1_g61479( LightmapUV1_g61479 );
					float4 ShadowMask360_g61482 = localCalculateShadowMask1_g61479;
					float4 ShadowMask305_g61482 = ShadowMask360_g61482;
					float3 localAdditionalLightsLambertMask17x305_g61482 = AdditionalLightsLambertMask17x( WorldPosition305_g61482 , ScreenUV305_g61482 , WorldNormal305_g61482 , ShadowMask305_g61482 );
					compareResult2_g61478 = ( localAdditionalLightsLambertMask17x305_g61482 + temp_output_13_0_g61478 );
				}
				else
				{
					compareResult2_g61478 = temp_output_13_0_g61478;
				}
				float3 Additional_Lights268 = compareResult2_g61478;
				float4 temp_output_2_0_g61486 = ( ( ( Toon_Ramp_Shadow681 * float4( Light_Color647 , 0.0 ) * Sphere_Map_Diffuse_Blend678 ) + ( ( pow( saturate( dotResult1_g61483 ) , max( _Shininess, 0.001 ) ) * _Specular * float4( Light_Color647 , 0.0 ) ) * _SpecularIntensity ) ) + ( Sphere_Map_Color679 * float4( ( Additional_Lights268 * Ambient_Blend_Factor48 ) , 0.0 ) ) );
				float4 compareResult19_g61486 = ( float4 )0;
				if( (int)_SimulatorNormalMap == 1 )
				{
					compareResult19_g61486 = ( float4( ( Global_Ambient682 + ( saturate( dotResult45_g61486 ) * Baked_Light_Maps680 ) ) , 0.0 ) * temp_output_2_0_g61486 );
				}
				else
				{
					compareResult19_g61486 = temp_output_2_0_g61486;
				}
				float3 Final_Lighting_Composition_Output675 = ( (compareResult19_g61486).xyz * _HDR );
				
				float Sgurface248 = _Surface;
				float compareResult14_g61487 = ( float )0;
				if( Sgurface248 == (float)0 )
				{
					compareResult14_g61487 = (float)1;
				}
				else
				{
					float compareResult7_g61487 = ( float )0;
					if( Layer289 == (float)3 )
					{
						compareResult7_g61487 = ( tex2DNode10_g61473.a * tex2DNode10.a );
					}
					else
					{
						compareResult7_g61487 = tex2DNode10.a;
					}
					compareResult14_g61487 = saturate( ( _Opaque * compareResult7_g61487 ) );
				}
				
				float compareResult2_g61488 = ( float )0;
				if( _AlphaClip == (float)1 )
				{
					compareResult2_g61488 = _Cutoff;
				}
				else
				{
					compareResult2_g61488 = 0.0001;
				}
				float Alpha_Clip_Threshold323 = compareResult2_g61488;
				

				float3 Color = Final_Lighting_Composition_Output675;
				float3 Normal = float3(0, 0, 1);

				float Alpha = compareResult14_g61487;
				#if defined( _ALPHATEST_ON )
					#ifdef ASE_PROPERTY_CUTOFF
					float alphaCutoff = _Cutoff;
					#else
					float alphaCutoff = 0.5;
					#endif
					float AlphaClipThreshold = Alpha_Clip_Threshold323;
					float AlphaClipThresholdShadow = 0.5;
				#endif

				#if defined( ASE_WRITE_DEPTH )
					input.positionCS.z = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = PositionWS;
				inputData.positionCS = input.positionCS;
				inputData.normalizedScreenSpaceUV = ScreenPosNorm.xy;

				#if defined( ASE_DOUBLE_SIDED_FLIP ) || defined( ASE_DOUBLE_SIDED_MIRROR )
					NormalWS = IsFrontFace ? NormalWS : -NormalWS;
					#if defined( ASE_DOUBLE_SIDED_FLIP ) && _NORMAL_DROPOFF_TS
						Normal.xy = IsFrontFace ? Normal.xy : -Normal.xy;
					#endif
				#endif

				#ifdef _NORMALMAP
					#if _NORMAL_DROPOFF_TS
						inputData.normalWS = TransformTangentToWorld(Normal, half3x3( TangentWS, BitangentWS, NormalWS ));
					#elif _NORMAL_DROPOFF_OS
						inputData.normalWS = TransformObjectToWorldNormal(Normal);
					#elif _NORMAL_DROPOFF_WS
						inputData.normalWS = Normal;
					#endif
					#if !_NORMAL_DROPOFF_TS && ( defined( ASE_DOUBLE_SIDED_FLIP ) || defined( ASE_DOUBLE_SIDED_MIRROR ) )
						// @diogo: same back-face correction as HDRP's GetNormalWS_SrcWS
						if ( !IsFrontFace )
						{
							inputData.normalWS += 2 * NormalWS * max( 0, -dot( NormalWS, inputData.normalWS ) );
							#if defined( ASE_DOUBLE_SIDED_FLIP )
								inputData.normalWS = reflect( -inputData.normalWS, NormalWS );
							#endif
						}
					#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = NormalWS;
				#endif

				inputData.viewDirectionWS = ViewDirWS;

				#if defined(_DBUFFER) && defined(UNLIT_DEFAULT_DECAL_BLENDING)
					ApplyDecalToBaseColor(input.positionCS, Color);
				#endif

				#if defined( ASE_WRITE_DEPTH )
					outputDepth = input.positionCS.z;
				#endif

				SurfaceData surfaceData = (SurfaceData)0;
				surfaceData.albedo = Color;
				surfaceData.alpha = Alpha;

				#if defined(_SCREEN_SPACE_OCCLUSION) && !defined(_SURFACE_TYPE_TRANSPARENT)
					float2 normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV( input.positionCS );
					AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion( normalizedScreenSpaceUV );
					surfaceData.albedo.rgb *= aoFactor.directAmbientOcclusion;
				#else
					surfaceData.occlusion = 1;
				#endif

			#if ( UNITY_VERSION >= 60010000 )
				return PackGBuffersSurfaceData( surfaceData, inputData, Color );
			#else
				return SurfaceDataToGbuffer( surfaceData, inputData, Color, kLightingInvalid );
			#endif
			}

			ENDHLSL
		}
		
	}
	

	

	CustomEditor "MMDCollection.ShaderMMD.MMDMaterial_ASE_T_NHM"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback "MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)"
}
/*ASEBEGIN
Version=19915
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":610,"pos":[-7680,-5056],"params":["Inherit","False","6561.605","4258.632","MMD Material Calculation","36","499","292","591","558","429","325","268","607","47","307","606","249","410","16","289","602","10","478","56","40","207","601","145","139","11","144","48","28","676","678","679","680","681","682","685","715","","0,1,0,1","0","0"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":28,"pos":[-7648,-2560],"params":["Inherit","False","Property","_Ambient","Ambient","11","0","Create","True","1","","0","0","False","0","False","Object","-1","","1,1,1,0","0,1,0,0","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":691,"pos":[-7648,-2912],"params":["Inherit","True","MMD Constants (Amplify Shader Editor)","-1","","61460","418dddb8757e55344877d4066e563a11","0","0","3","FLOAT3","1","FLOAT3","2","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":687,"pos":[-6720,-2912],"params":["Inherit","True","Ambient Pivot Adjustment (Amplify Shader Editor)","-1","","61461","582f37f9bea582d40a5b5476b5710fed","0","3","12","FLOAT3","0.5,0.5,0.5","False","11","FLOAT3","1,1,1","False","13","COLOR","1,1,1,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":688,"pos":[-6272,-2912],"params":["Inherit","True","Ambient Blend Factor (Amplify Shader Editor)","-1","","61462","c421f4bc8a9adda44bd4cd4e12093875","0","1","7","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":689,"pos":[-6176,-3136],"params":["Inherit","True","Global Ambient (Amplify Shader Editor)","-1","","61463","2ba15a2d50724194cb38a2ebb214fec5","0","0","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":682,"pos":[-5792,-3136],"params":["Inherit","False","Global Ambient","-1","True","1","0","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":48,"pos":[-5856,-2912],"params":["Inherit","False","Ambient Blend Factor","-1","True","1","0","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":690,"pos":[-5472,-3136],"params":["Inherit","True","Weighted Ambient (Amplify Shader Editor)","-1","","61464","c74b4378eb191434689832628f4ac715","0","2","2","FLOAT3","0,0,0","False","3","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":624,"pos":[-7808,-736],"params":["Inherit","False","1600.062","799.5147","Height Map","7","637","636","635","634","633","632","631","","0,1,1,1","0","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":144,"pos":[-5056,-3136],"params":["Inherit","False","Weighted Ambient","-1","True","1","0","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":11,"pos":[-7040,-2432],"params":["Inherit","False","Property","_Color","Diffuse","9","1","[Header]","Create","False","1","Material Color","0","0","False","0","False","Object","-1","","0.8,0.8,0.8,0","1,0,0,0","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":145,"pos":[-7104,-2624],"params":["Inherit","False","144","Weighted Ambient","1","0","OBJECT","","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.TexCoordVertexDataNode, AmplifyShaderEditor","id":632,"pos":[-7520,-448],"params":["Inherit","True","0","2","0","5","FLOAT2","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4"]}
{"type":"AmplifyShaderEditor.TextureTransformNode, AmplifyShaderEditor","id":631,"pos":[-7520,-192],"params":["Inherit","True","-1","False","","1","0","SAMPLER2D","","False","2","FLOAT2","0","FLOAT2","1"]}
{"type":"AmplifyShaderEditor.ScaleAndOffsetNode, AmplifyShaderEditor","id":633,"pos":[-7232,-192],"params":["Inherit","True","3","0","FLOAT2","0,0","False","1","FLOAT2","1,0","False","2","FLOAT2","0,0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor","id":634,"pos":[-7232,-672],"params":["Inherit","True","Property","_ParallaxMap","Height Map","35","1","[NoScaleOffset]","Create","False","0","0","0","False","0","False","","None","None","False","white","Auto","Texture2D","False","-1","0","2","SAMPLER2D","0","SAMPLERSTATE","1"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":636,"pos":[-7232,-448],"params":["Inherit","True","Property","_Parallax","Parallax","36","0","Create","False","0","0","0","False","0","False","Object","-1","","0.005","0","0.005","0.08","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":635,"pos":[-6816,-672],"params":["Inherit","True","Property","_SimulatorHeightMap","Simulator Height Map","34","2","[Header]","[Toggle]","Create","True","1","Simulator Height Map Settings","0","0","False","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":692,"pos":[-6720,-2592],"params":["Inherit","True","Balanced Diffuse (Amplify Shader Editor)","-1","","61465","b9d74c6ebcf90ea4dba95e1f0d9a6f0b","0","4","22","FLOAT3","0.6,0.6,0.6","False","23","FLOAT3","0,0,0","False","20","COLOR","1,1,1,0","False","21","COLOR","0.8,0.8,0.8,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.Vector3Node, AmplifyShaderEditor","id":292,"pos":[-5408,-4032],"params":["Inherit","True","Property","_ToonTone","Toon Tone","28","0","Create","False","0","0","0","False","0","False","Object","-1","","1,0.5,0.5","1,0.5,0.5","0","4","FLOAT3","0","FLOAT","1","FLOAT","2","FLOAT","3"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":699,"pos":[-5472,-3680],"params":["Inherit","True","N dot L (Amplify Shader Editor)","-1","","61466","96e0e28ec623e134ba66ab21882969ae","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":701,"pos":[-5152,-4032],"params":["Inherit","True","Light Calculation (Amplify Shader Editor)","-1","","61467","af01f53e0d9e3474ca896a09a7abf366","0","2","19","FLOAT3","1,0.5,0.5","False","20","FLOAT","0","False","4","FLOAT","0","FLOAT","17","FLOAT","22","FLOAT3","18"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":625,"pos":[-6016,-736],"params":["Inherit","False","2368.544","1441.232","Final Lighting Composition","8","657","659","658","666","660","630","629","628","","1,0,1,1","0","0"]}
{"type":"AmplifyShaderEditor.WireNode, AmplifyShaderEditor","id":601,"pos":[-6256,-2256],"params":["Inherit","False","Tensions","1","1","1","0","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":207,"pos":[-6208,-2528],"params":["Inherit","True","Property","_EFFECTS","Effects","18","2","[Header]","[Enum]","Create","False","1","Texture (Memo)","4","Disabled","0","Add Sphere","1","Multi Sphere","2","Sub Tex","3","0","False","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor","id":637,"pos":[-7776,-608],"params":["Inherit","True","Property","_MainTex","Texture","19","0","Create","False","0","0","0","False","0","False","","None","None","False","white","Auto","Texture2D","False","-1","0","2","SAMPLER2D","0","SAMPLERSTATE","1"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":693,"pos":[-6496,-2080],"params":["Inherit","True","Sphere Map UV (Amplify Shader Editor)","-1","","61468","5f56ef3cc5ba0704c81e1b4a6eaa4beb","0","0","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":714,"pos":[-6592,-352],"params":["Inherit","True","Simulator Height Map (Amplify Shader Editor)","5","","61469","612de69265c51c744b405e94bbb18df0","1,51,2","4","1","INT","0","False","2","SAMPLER2D","","False","3","FLOAT","0","False","4","FLOAT2","0,0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":703,"pos":[-4736,-3904],"params":["Inherit","True","Baked LightMap Contribution (Amplify Shader Editor)","-1","","61470","b0308fde66b3df54883fd907b3a91063","0","1","12","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":629,"pos":[-5984,-288],"params":["Inherit","False","1214.356","831.2264","Specular Final Calculation","6","656","654","653","122","82","88","","1,0,1,1","0","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":630,"pos":[-5536,-640],"params":["Inherit","False","768.4946","317.6277","Main Light Color","4","649","648","647","646","","1,0,1,1","0","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":139,"pos":[-7264,-2816],"params":["Half","False","Global Light Scale","-1","True","1","0","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":40,"pos":[-6112,-2080],"params":["Inherit","True","Property","_SphereCube","SPH","21","1","[NoScaleOffset]","Create","False","0","0","0","False","0","False","","-1","None","None","True","0","False","white","LockedToCube","False","Object","-1","Auto","Cube","False","8","0","SAMPLERCUBE","","False","1","FLOAT3","0,0,0","False","2","FLOAT","0","False","3","FLOAT3","0,0,0","False","4","FLOAT3","0,0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":56,"pos":[-6112,-1824],"params":["Inherit","True","Property","_SPHOpacity","SPH Opacity","25","0","Create","True","0","0","0","False","0","False","Object","-1","","1","1","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor","id":478,"pos":[-6048,-1568],"params":["Inherit","True","Property","_SubTex","SPH SubTex","23","0","Create","False","0","0","0","False","0","False","","None","None","False","white","Auto","Texture2D","False","-1","0","2","SAMPLER2D","0","SAMPLERSTATE","1"]}
{"type":"AmplifyShaderEditor.WireNode, AmplifyShaderEditor","id":602,"pos":[-5808,-2128],"params":["Inherit","False","Tensions","1","1","1","0","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":289,"pos":[-5984,-2528],"params":["Inherit","False","Layer","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":10,"pos":[-6112,-1344],"params":["Inherit","True","Property","_TextureSample1","Texture Sample 1","10","0","Create","True","1","Texture (Memo)","0","0","False","0","False","","-1","None","73029f145f0f8b2469831e89ee17037b","True","0","False","white","Auto","False","Object","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":307,"pos":[-5728,-3424],"params":["Inherit","True","Property","_MultipleLights","Multiple Lights","29","1","[ToggleUI]","Create","True","0","0","0","False","0","False","Object","-1","","1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":47,"pos":[-4736,-4800],"params":["Inherit","True","Property","_ShadowLum","Shadow Luminescence","26","0","Create","False","0","0","0","False","0","False","Object","-1","","1.5","1.5","0","10","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":429,"pos":[-4416,-4992],"params":["Inherit","True","Property","_SShad","S-Shad","14","2","[Header]","[ToggleUI]","Create","True","1","Rendering","0","0","False","0","False","Object","-1","","1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor","id":558,"pos":[-4576,-4544],"params":["Inherit","True","Property","_ToonTex","Toon","20","1","[NoScaleOffset]","Create","False","0","0","0","False","0","False","","None","f35b8759e2061eb469494abb58b512c1","False","white","Auto","Texture2D","False","-1","0","2","SAMPLER2D","0","SAMPLERSTATE","1"]}
{"type":"AmplifyShaderEditor.WireNode, AmplifyShaderEditor","id":591,"pos":[-4272,-4144],"params":["Inherit","False","Tensions","1","1","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":680,"pos":[-4256,-3904],"params":["Inherit","False","Baked Light Maps","-1","True","1","0","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":700,"pos":[-4736,-4288],"params":["Inherit","True","Toon Shadow Mask (Amplify Shader Editor)","-1","","61472","d4c61b1560e7f524485e042d9cbfa12f","0","1","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.IntegerNode, AmplifyShaderEditor","id":715,"pos":[-5984,-2400],"params":["Inherit","True","Property","_UVLayer","UV Layer","22","1","[Enum]","Create","True","0","4","Layer 1","0","Layer 2","1","Layer 3","2","Layer 4","3","0","False","0","False","Object","-1","","0","0","False","0","0","0","1","INT","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":695,"pos":[-5568,-2080],"params":["Inherit","True","Sphere Map Blend (Amplify Shader Editor)","-1","","61473","40c32954e5f9d9046ae98d6e4ad2a766","0","7","38","FLOAT","0","False","40","FLOAT","0","False","45","FLOAT3","1,1,1","False","43","COLOR","1,1,1,1","False","44","FLOAT","1","False","47","SAMPLER2D","1,1,1,1","False","42","COLOR","1,1,1,1","False","3","COLOR","0","COLOR","1","FLOAT","37"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":649,"pos":[-5504,-480],"params":["Inherit","False","139","Global Light Scale","1","0","OBJECT","","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":122,"pos":[-5952,-224],"params":["Inherit","True","Property","_Shininess","Reflection","13","0","Create","False","0","0","0","False","0","False","Object","-1","","50","50","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":646,"pos":[-5504,-576],"params":["Inherit","False","680","Baked Light Maps","1","0","OBJECT","","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":702,"pos":[-4192,-4672],"params":["Inherit","True","Toon Ramp Shadow (Amplify Shader Editor)","-1","","61477","12d15763f50b8154696c9a4946cb6844","0","5","23","FLOAT","1","False","25","FLOAT","1.5","False","26","SAMPLER2D","0","False","29","FLOAT","0","False","22","FLOAT","0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":704,"pos":[-5472,-3424],"params":["Inherit","True","Additional Lights (Amplify Shader Editor)","-1","","61478","0903e89e038650f4c8f73f079567a741","0","2","15","FLOAT","1","False","13","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":628,"pos":[-4704,256],"params":["Inherit","False","798.7908","413.8333","Final Calculation Additional Lights","5","665","664","663","662","661","","1,0,1,1","0","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":648,"pos":[-5248,-576],"params":["Inherit","True","2","2","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":678,"pos":[-5088,-1984],"params":["Inherit","False","Sphere Map Diffuse Blend","-1","True","1","0","COLOR","0,0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":653,"pos":[-5536,256],"params":["Inherit","False","647","Light Color","1","0","OBJECT","","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":681,"pos":[-3776,-4672],"params":["Inherit","False","Toon Ramp Shadow","-1","True","1","0","COLOR","0,0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":268,"pos":[-5088,-3424],"params":["Inherit","False","Additional Lights","-1","True","1","0","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":82,"pos":[-5568,32],"params":["Inherit","False","Property","_Specular","Specular","10","0","Create","True","0","0","0","False","0","False","Object","-1","","0,0,0,0","0.6,0.2,0.6,0","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":706,"pos":[-5728,-224],"params":["Inherit","True","Blinn Phong Specular (Amplify Shader Editor)","-1","","61483","0d9f1343fd295844e9ab4da8a467178a","0","1","14","FLOAT","50","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":647,"pos":[-4992,-576],"params":["Inherit","False","Light Color","-1","True","1","0","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":654,"pos":[-5312,32],"params":["Inherit","True","3","3","0","FLOAT","0","False","1","COLOR","0,0,0,0","False","2","FLOAT3","0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":679,"pos":[-5088,-2080],"params":["Inherit","False","Sphere Map Color","-1","True","1","0","COLOR","0,0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":662,"pos":[-4672,416],"params":["Inherit","False","268","Additional Lights","1","0","OBJECT","","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":663,"pos":[-4672,512],"params":["Inherit","False","48","Ambient Blend Factor","1","0","OBJECT","","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":659,"pos":[-4704,-672],"params":["Inherit","False","681","Toon Ramp Shadow","1","0","OBJECT","","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":657,"pos":[-4704,-448],"params":["Inherit","False","678","Sphere Map Diffuse Blend","1","0","OBJECT","","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":88,"pos":[-5312,288],"params":["Inherit","True","Property","_SpecularIntensity","Specular Intensity","24","1","[Header]","Create","True","1","Custom Effects Settings","0","0","False","0","False","Object","-1","","1","1","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":656,"pos":[-4992,32],"params":["Inherit","True","2","2","0","COLOR","0,0,0,0","False","1","FLOAT","0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":664,"pos":[-4384,416],"params":["Inherit","True","2","2","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":658,"pos":[-4384,-608],"params":["Inherit","True","3","3","0","COLOR","0,0,0,0","False","1","FLOAT3","0,0,0","False","2","COLOR","0,0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":661,"pos":[-4672,320],"params":["Inherit","False","679","Sphere Map Color","1","0","OBJECT","","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":665,"pos":[-4128,320],"params":["Inherit","True","2","2","0","COLOR","0,0,0,0","False","1","FLOAT3","0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor","id":660,"pos":[-4160,0],"params":["Inherit","True","2","2","0","COLOR","0,0,0,0","False","1","COLOR","0,0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":626,"pos":[-3552,-64],"params":["Inherit","False","1184.567","1152.014","Normal Map","9","674","672","670","669","668","667","645","641","640","","0,1,1,1","0","0"]}
{"type":"AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor","id":666,"pos":[-3872,0],"params":["Inherit","True","2","2","0","COLOR","0,0,0,0","False","1","COLOR","0,0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":252,"pos":[-7680,-6528],"params":["Inherit","False","1024.206","1407.06","Surface Options","15","323","227","228","510","224","225","232","226","231","230","229","221","248","223","621","","0,1,0,1","0","0"]}
{"type":"AmplifyShaderEditor.WireNode, AmplifyShaderEditor","id":672,"pos":[-3536,208],"params":["Inherit","False","Tensions","1","1","1","0","COLOR","0,0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":223,"pos":[-7648,-6464],"params":["Inherit","True","Property","_Surface","Surface Type","40","1","[HideInInspector]","Create","False","0","0","0","True","0","False","Object","-1","","0","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.WireNode, AmplifyShaderEditor","id":668,"pos":[-3280,208],"params":["Inherit","False","Tensions","1","1","1","0","COLOR","0,0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.WireNode, AmplifyShaderEditor","id":673,"pos":[-5776,1136],"params":["Inherit","False","Tensions","1","1","1","0","FLOAT2","0,0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":275,"pos":[-6592,-6176],"params":["Inherit","False","1407.715","1056.216","Outline","7","498","684","622","201","208","438","612","","0,1,0,1","0","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":627,"pos":[-2304,-64],"params":["Inherit","False","929.3441","414.8319","Final Lighting Composition (HDR)","3","675","643","370","","1,0,1,1","0","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":248,"pos":[-7456,-6464],"params":["Inherit","False","Sgurface","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.WireNode, AmplifyShaderEditor","id":670,"pos":[-3216,112],"params":["Inherit","False","Tensions","1","1","1","0","COLOR","0,0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.WireNode, AmplifyShaderEditor","id":674,"pos":[-3088,1008],"params":["Inherit","False","Tensions","1","1","1","0","FLOAT2","0,0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":669,"pos":[-3168,128],"params":["Inherit","False","682","Global Ambient","1","0","OBJECT","","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":667,"pos":[-3520,0],"params":["Inherit","True","Property","_SimulatorNormalMap","Simulator Normal Map","31","2","[Header]","[Toggle]","Create","True","1","Simulator Normal Map Settings","0","0","False","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor","id":640,"pos":[-3296,608],"params":["Inherit","True","Property","_NormalMap","Normal Map","32","2","[NoScaleOffset]","[Normal]","Create","False","0","0","0","False","0","False","","None","None","True","bump","Auto","Texture2D","False","-1","0","2","SAMPLER2D","0","SAMPLERSTATE","1"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":641,"pos":[-3296,832],"params":["Inherit","True","Property","_BumpScale","Normal Scale","33","0","Create","False","0","0","0","False","0","False","Object","-1","","1","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":645,"pos":[-3264,480],"params":["Inherit","False","680","Baked Light Maps","1","0","OBJECT","","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":709,"pos":[-3520,256],"params":["Inherit","True","Get Main Light Direction (Amplify Shader Editor)","-1","","61484","3e34af2748d79ec4fabf2093c96d24b3","0","0","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":16,"pos":[-5504,-1152],"params":["Inherit","True","Property","_Opaque","Opaque","12","0","Create","True","0","0","0","False","0","False","Object","-1","","1","1","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":410,"pos":[-5408,-1280],"params":["Inherit","False","289","Layer","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":249,"pos":[-5344,-896],"params":["Inherit","False","248","Sgurface","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":227,"pos":[-7648,-5376],"params":["Float","True","Property","_Cutoff","Alpha Cutoff","49","1","[HideInInspector]","Fetch","False","0","0","0","True","0","False","Object","-1","","0.5","0.669","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":228,"pos":[-7552,-5664],"params":["Inherit","True","Property","_AlphaClip","Alpha Clip","48","1","[HideInInspector]","Fetch","False","0","0","0","True","0","False","Object","-1","","0","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":201,"pos":[-6560,-5632],"params":["Inherit","True","Property","_EdgeSize","Size","17","0","Create","False","0","0","0","False","0","False","Object","-1","","0","0.1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":622,"pos":[-6560,-5376],"params":["Inherit","True","Property","_ExtrusionAmount","Extrusion Amount","39","0","Create","True","0","0","0","False","0","False","Object","-1","","0","0.1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":370,"pos":[-2272,96],"params":["Inherit","True","Property","_HDR","HDR","27","0","Create","True","0","0","0","False","0","False","Object","-1","","1","1","1","1000","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":705,"pos":[-2784,0],"params":["Inherit","True","Simulator Normal Map (Amplify Shader Editor)","0","","61486","f87281042f1d80e4d8b7b2eef537554a","0","8","1","INT","0","False","2","FLOAT4","0,0,0,0","False","3","FLOAT3","0,0,0","False","4","FLOAT3","0,0,0","False","5","FLOAT3","0,0,0","False","6","SAMPLER2D","","False","7","FLOAT","0","False","8","FLOAT2","0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":696,"pos":[-5056,-1440],"params":["Inherit","True","Transparency Control (Amplify Shader Editor)","-1","","61487","6d43ae7b10f2e8e4ca2eeb598d02c48d","0","5","16","FLOAT","1","False","15","COLOR","1,1,1,1","False","17","FLOAT","0","False","18","FLOAT","1","False","19","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":697,"pos":[-7328,-5664],"params":["Inherit","True","Alpha Clip Threshold (Amplify Shader Editor)","-1","","61488","171eab994f1a2214cbab7964a5267fe1","0","2","7","FLOAT","0","False","6","FLOAT","0.5","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":698,"pos":[-6304,-5632],"params":["Inherit","True","Extrusion Amount Calculation (Amplify Shader Editor)","-1","","61489","e5ebc5dc6bc5c3d41b2c1a8fb58a735f","0","2","8","FLOAT","0","False","9","FLOAT","0","False","2","FLOAT","0","FLOAT3","7"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":643,"pos":[-1952,0],"params":["Inherit","True","2","2","0","FLOAT3","0,0,0","False","1","FLOAT","0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.WireNode, AmplifyShaderEditor","id":606,"pos":[-2416,-1744],"params":["Inherit","False","Tensions","1","1","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":323,"pos":[-6912,-5664],"params":["Inherit","False","Alpha Clip Threshold","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":684,"pos":[-5824,-5600],"params":["Inherit","False","Extrusion Vertex Offset","-1","True","1","0","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":675,"pos":[-1696,0],"params":["Inherit","False","Final Lighting Composition Output","-1","True","1","0","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.StickyNoteNode, AmplifyShaderEditor","id":342,"pos":[-5120,-6112],"params":["Inherit","False","575.6002","991.2004","Notes","","1,1,0,1","==Material Color==\nDiffuse = Material color.\n\nSpecular = Color of light reflection/glow.\n\nAmbient = (It affects the model's color and lighting too so I think it's like a raycast)\n\nOpaque = Alpha value.\n\nReflection = Reflection value.\n\n==Rendering==\n2-SIDE = Renders both sides of the mesh. [Equivalent to Render Face/_Cull]\n\nG-SHAD = Shadow on the ground. [Equivalent to Cast Shadows/ShaderPass\"SHADOWCASTER\"]\n\nS-MAP = Shadow on the mesh. (Including herself) [Equivalent to Receive Shadows/_ReceiveShadows/Keyword\"_RECEIVE_SHADOWS_OFF\"]\n\nS-SHAD = Receives shade only from himself.\n\n==Edge (Outline)==\nOn = Activate the outline.\n\nColor = Contour color including transparesis.\n\nSize = Outline size/distance.\n\n==Texture/Memo==\nTexture = Material texture.\n\nToon = Complements the remains of the object.\n\nSPH = Artificial reflection to compromise Specular.\n\n***Effects***\nIt uses the SPH texture.\n\nDisabled = does not do anything.\n\nMulti-Sphere = It multiplies a glowing sphere map. (It gives me a feeling of being a metallic reflection)\n\nAdd-Sphere = It creates a glowing sphere map. (It gives me a feeling of being a reflection of practical)\n\nSub-Tex = It changes the SPH from 'Cube Texture' to 'Texture' to allow the use of Subtexture to place more than one texture on the same material.\nThe new texture is applied to another UV Layer allowing the creation of more complex effects. (This function replaces Add-Sphere and Multi-Sphere)","0","0"]}
{"type":"AmplifyShaderEditor.WireNode, AmplifyShaderEditor","id":607,"pos":[-1776,-2640],"params":["Inherit","False","Tensions","1","1","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":612,"pos":[-6304,-6112],"params":["Inherit","False","248","Sgurface","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor","id":510,"pos":[-7200,-5952],"params":["Inherit","True","Property","_Fog","Fog","30","0","Create","True","0","0","0","True","0","False","","1","1","1","True","_FOG_ON","Toggle","2","Key0","Key1","Create","False","False","All","False","False","True","False","0","9","1","FLOAT","0","False","0","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","4","FLOAT","0","False","5","FLOAT","0","False","6","FLOAT","0","False","7","FLOAT","0","False","8","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":221,"pos":[-7424,-5952],"params":["Inherit","True","Property","_CastShadows","Cast Shadows","50","1","[HideInInspector]","Create","False","0","0","0","True","0","False","Object","-1","","1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":229,"pos":[-7648,-5952],"params":["Inherit","True","Property","_ZTest","Depth Test","47","1","[HideInInspector]","Create","False","0","0","0","True","0","False","Object","-1","","4","4","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":232,"pos":[-7648,-6208],"params":["Inherit","True","Property","_SrcBlend","Src Blend (Auto)","43","1","[HideInInspector]","Create","False","0","0","0","True","0","False","Object","-1","","1","5","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":226,"pos":[-7424,-6208],"params":["Inherit","True","Property","_DstBlend","Dst Blend (Auto)","44","1","[HideInInspector]","Create","False","0","0","0","True","0","False","Object","-1","","0","10","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":230,"pos":[-7168,-6208],"params":["Inherit","True","Property","_ZWriteControl","Depth Write Mode","45","1","[HideInInspector]","Create","False","0","0","0","True","0","False","Object","-1","","1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":231,"pos":[-6912,-6208],"params":["Inherit","True","Property","_ZWrite","ZWrite (Internal)","46","1","[HideInInspector]","Create","False","0","0","0","True","0","False","Object","-1","","1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":225,"pos":[-6976,-6464],"params":["Inherit","True","Property","_Cull","Render Face","42","1","[HideInInspector]","Create","False","0","0","0","True","0","False","Object","-1","","2","2","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":224,"pos":[-7200,-6464],"params":["Inherit","True","Property","_Blend","Blending Mode","41","1","[HideInInspector]","Create","False","0","0","0","True","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":620,"pos":[-7296,-5376],"params":["Inherit","True","Property","_EdgeLength","Edge Length","37","0","Create","True","0","0","0","True","0","False","Object","-1","","5","5","2","50","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":621,"pos":[-6976,-5376],"params":["Inherit","True","Property","_PhongTessStrength","Phong Tess Strength","38","0","Create","True","0","0","0","True","0","False","Object","-1","","0.5","0","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":438,"pos":[-6560,-6112],"params":["Inherit","True","Property","_On","On","15","2","[Header]","[ToggleUI]","Create","True","1","Edge (Outline)","0","0","False","0","False","Object","-1","","0","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":208,"pos":[-6560,-5856],"params":["Inherit","False","Property","_OutlineColor","Color","16","0","Create","False","0","0","0","False","0","False","Object","-1","","0,0,0,1","0,0,0,0.5019608","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":676,"pos":[-1760,-2880],"params":["Inherit","False","675","Final Lighting Composition Output","1","0","OBJECT","","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":325,"pos":[-1696,-2624],"params":["Inherit","False","323","Alpha Clip Threshold","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":685,"pos":[-1664,-2496],"params":["Inherit","False","684","Extrusion Vertex Offset","1","0","OBJECT","","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":707,"pos":[-5824,-5984],"params":["Inherit","True","Outline Control (Amplify Shader Editor)","-1","","61490","9b89aaf063c597e47936ca5e506b1b8f","0","4","28","FLOAT","0","False","32","FLOAT","0","False","25","COLOR","0,0,0,1","False","24","FLOAT","0","False","3","FLOAT3","29","FLOAT","0","FLOAT3","30"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":500,"pos":[768,-1152],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphUnlitGUI","0","1","New Amplify Shader","2992e84f91cbeb14eab234972e07ea9d","True","ShadowCaster","0","2","ShadowCaster","0","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","True","1","False","","True","5","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Unlit","AlwaysRenderMotionVectors=false","True","5","True","14","all","0","True","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","False","False","True","False","False","False","False","0","False","","False","False","False","False","False","False","False","False","False","True","1","False","","True","3","False","","False","False","True","1","LightMode=ShadowCaster","False","False","0","False","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":501,"pos":[768,-1152],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphUnlitGUI","0","1","New Amplify Shader","2992e84f91cbeb14eab234972e07ea9d","True","DepthOnly","0","3","DepthOnly","0","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","True","1","False","","True","5","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Unlit","AlwaysRenderMotionVectors=false","True","5","True","14","all","0","True","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","False","False","True","False","False","False","False","0","False","","False","False","False","False","False","False","False","False","False","True","1","False","","False","False","False","True","1","LightMode=DepthOnly","False","False","0","False","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":502,"pos":[768,-1152],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphUnlitGUI","0","1","New Amplify Shader","2992e84f91cbeb14eab234972e07ea9d","True","Meta","0","4","Meta","0","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","True","1","False","","True","5","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Unlit","AlwaysRenderMotionVectors=false","True","5","True","14","all","0","True","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","2","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","LightMode=Meta","False","False","0","False","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":503,"pos":[768,-1152],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphUnlitGUI","0","1","New Amplify Shader","2992e84f91cbeb14eab234972e07ea9d","True","Universal2D","0","5","Universal2D","0","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","True","1","False","","True","5","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Unlit","AlwaysRenderMotionVectors=false","True","5","True","14","all","0","True","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","1","LightMode=Universal2D","False","False","0","False","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":504,"pos":[768,-1152],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphUnlitGUI","0","1","New Amplify Shader","2992e84f91cbeb14eab234972e07ea9d","True","SceneSelectionPass","0","6","SceneSelectionPass","0","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","True","1","False","","True","5","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Unlit","AlwaysRenderMotionVectors=false","True","5","True","14","all","0","True","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","2","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","LightMode=SceneSelectionPass","False","False","0","False","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":505,"pos":[768,-1152],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphUnlitGUI","0","1","New Amplify Shader","2992e84f91cbeb14eab234972e07ea9d","True","ScenePickingPass","0","7","ScenePickingPass","0","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","True","1","False","","True","5","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Unlit","AlwaysRenderMotionVectors=false","True","5","True","14","all","0","True","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","LightMode=Picking","False","False","0","False","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":506,"pos":[768,-1152],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphUnlitGUI","0","1","New Amplify Shader","2992e84f91cbeb14eab234972e07ea9d","True","DepthNormals","0","8","DepthNormals","0","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","True","1","False","","True","5","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Unlit","AlwaysRenderMotionVectors=false","True","5","True","14","all","0","True","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","False","","True","3","False","","False","False","True","1","LightMode=DepthNormalsOnly","False","False","0","False","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":507,"pos":[768,-1152],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphUnlitGUI","0","1","New Amplify Shader","2992e84f91cbeb14eab234972e07ea9d","True","DepthNormalsOnly","0","9","DepthNormalsOnly","0","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","True","1","False","","True","5","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Unlit","AlwaysRenderMotionVectors=false","True","5","True","14","all","0","True","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","False","","True","3","False","","False","False","True","1","LightMode=DepthNormalsOnly","False","True","11","d3d11","metal","vulkan","xboxone","xboxseries","playstation","ps4","ps5","switch","switch2","webgpu","0","False","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":508,"pos":[768,-1152],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphUnlitGUI","0","1","New Amplify Shader","2992e84f91cbeb14eab234972e07ea9d","True","MotionVectors","0","10","MotionVectors","0","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","True","1","False","","True","5","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Unlit","AlwaysRenderMotionVectors=false","True","5","True","14","all","0","True","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","True","True","False","False","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","LightMode=MotionVectors","False","False","0","False","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":511,"pos":[768,-1170],"params":["Float","False","False","-1","3","UnityEditor.ShaderGraphUnlitGUI","0","1","New Amplify Shader","2992e84f91cbeb14eab234972e07ea9d","True","XRMotionVectors","0","11","XRMotionVectors","0","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","True","1","False","","True","5","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Unlit","AlwaysRenderMotionVectors=false","True","5","True","14","all","0","True","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","True","1","False","","255","False","","1","False","","7","False","","3","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","False","False","False","False","True","1","LightMode=XRMotionVectors","False","False","0","False","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":499,"pos":[-1376,-2816],"params":["Float","False","True","-1","2","MMDCollection.ShaderMMD.MMDMaterial_ASE_T_NHM","0","19","MMD Collection/URP/Effects/MMD Normal and Height Map - Tessellation (Amplify Shader Editor)","2992e84f91cbeb14eab234972e07ea9d","True","Unlit","0","1","Unlit","12","True","True","1","1","True","_SrcBlend","0","True","_DstBlend","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","True","True","0","True","_Cull","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","True","1","False","","True","5","RenderPipeline=UniversalPipeline","RenderType=_Surface=RenderType","Queue=Overlay=Queue=-2000","UniversalMaterialType=Unlit","AlwaysRenderMotionVectors=false","True","7","True","14","all","0","True","0","False","","True","True","1","1","True","_SrcBlend","0","True","_DstBlend","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","True","True","1","True","_ZWrite","True","3","True","_ZTest","True","True","0","False","","0","False","","False","True","1","LightMode=UniversalForwardOnly","False","False","7","Include","","False","","Native","False","0","0","","Pragma","multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE","False","","Custom","False","0","0","","Pragma","multi_compile_fragment _ _SHADOWS_SOFT","False","","Custom","False","0","0","","Pragma","multi_compile _ SHADOWS_SHADOWMASK","False","","Custom","False","0","0","","Custom","#ifndef _FOG_ON","False","","Custom","False","0","0","","Custom","#undef ASE_FOG","False","","Custom","False","0","0","","Custom","#endif","False","","Custom","False","0","0","","False","MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)","0","0","Standard","38","Surface","0","0","  Keep Alpha","1","639051702240721720","  Blend","0","0","Double-Sided","0","0","Alpha Clipping","2","639051685394695303","  Use Shadow Threshold","0","0","Fragment Normal Space","0","0","Forward Only","0","0","Cast Shadows","1","0","Receive Shadows","2","639051685057082009","Default Decal Blending","1","0","Motion Vectors","0","638670679113611176","  Additional Motion Vectors","1","0","  Alembic Motion Vectors","0","0","  XR Motion Vectors","0","0","Meta Pass","0","0","Extra Pre Pass","1","638670624603007853","Tessellation","1","639054494181942725","  Phong","1","639054494188145685","  Strength","0.5,True,_PhongTessStrength","639054494317855630","  Type","2","639054494384237405","  Tess","16,True,_EdgeLength","0","  Min","10,False,","0","  Max","25,False,","0","  Edge Length","20,True,_EdgeLength","639054494469843900","  Max Displacement","25,False,","0","Write Depth","0","0","  Conservative","0","0","Vertex Position","1","0","Rendering Layers","1","0","Decals","1","0","Receive SSAO","1","0","Debug Display","1","0","GPU Instancing","1","0","DOTS Instancing","1","0","LOD CrossFade","1","0","Built-in Fog","1","639308891157396896","  Receive Fog","0","0","0","13","ExtraPrePass","True","Unlit","True","ShadowCaster","True","DepthOnly","True","Meta","False","Universal2D","False","SceneSelectionPass","True","ScenePickingPass","True","DepthNormals","True","DepthNormalsOnly","False","MotionVectors","False","XRMotionVectors","False","GBuffer","True","False","","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":615,"pos":[-1376,-2696],"params":["Float","False","False","-1","3","UnityEditor.ShaderGraphUnlitGUI","0","1","New Amplify Shader","2992e84f91cbeb14eab234972e07ea9d","True","GBuffer","0","12","GBuffer","0","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","True","1","False","","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Unlit","True","5","True","14","all","0","True","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","True","","True","3","True","","True","True","0","False","","0","False","","False","True","1","LightMode=UniversalGBuffer","False","True","12","d3d11","gles","metal","vulkan","xboxone","xboxseries","playstation","ps4","ps5","switch","switch2","webgpu","0","False","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":498,"pos":[-5440,-5984],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphUnlitGUI","0","19","New Amplify Shader","2992e84f91cbeb14eab234972e07ea9d","True","ExtraPrePass","0","0","OutlinePass","6","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","True","1","False","","True","5","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Unlit","AlwaysRenderMotionVectors=false","True","5","True","14","all","0","True","0","False","","True","False","False","False","False","False","False","False","False","False","False","False","False","True","True","1","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","True","True","1","True","_On","True","3","True","_ZTest","True","True","0","False","","0","False","","False","True","0","False","False","4","Include","","False","","Native","False","0","0","","Custom","#ifndef _FOG_ON","False","","Custom","False","0","0","","Custom","#undef ASE_FOG","False","","Custom","False","0","0","","Custom","#endif","False","","Custom","False","0","0","","False","","0","0","Standard","0","False","0"]}
{"wire":[687,12,691,1]}
{"wire":[687,11,691,2]}
{"wire":[687,13,28,0]}
{"wire":[688,7,687,0]}
{"wire":[682,0,689,0]}
{"wire":[48,0,688,0]}
{"wire":[690,2,682,0]}
{"wire":[690,3,48,0]}
{"wire":[144,0,690,0]}
{"wire":[631,0,637,0]}
{"wire":[633,0,632,0]}
{"wire":[633,1,631,0]}
{"wire":[633,2,631,1]}
{"wire":[692,22,139,0]}
{"wire":[692,23,145,0]}
{"wire":[692,20,28,0]}
{"wire":[692,21,11,0]}
{"wire":[701,19,292,0]}
{"wire":[701,20,699,0]}
{"wire":[601,0,692,0]}
{"wire":[714,1,635,0]}
{"wire":[714,2,634,0]}
{"wire":[714,3,636,0]}
{"wire":[714,4,633,0]}
{"wire":[703,12,701,18]}
{"wire":[139,0,691,0]}
{"wire":[40,1,693,0]}
{"wire":[602,0,601,0]}
{"wire":[289,0,207,0]}
{"wire":[10,0,637,0]}
{"wire":[10,1,714,0]}
{"wire":[591,0,701,22]}
{"wire":[680,0,703,0]}
{"wire":[700,1,701,22]}
{"wire":[695,38,289,0]}
{"wire":[695,40,715,0]}
{"wire":[695,45,602,0]}
{"wire":[695,43,40,0]}
{"wire":[695,44,56,0]}
{"wire":[695,47,478,0]}
{"wire":[695,42,10,0]}
{"wire":[702,23,429,0]}
{"wire":[702,25,47,0]}
{"wire":[702,26,558,0]}
{"wire":[702,29,700,0]}
{"wire":[702,22,591,0]}
{"wire":[704,15,307,0]}
{"wire":[704,13,682,0]}
{"wire":[648,0,646,0]}
{"wire":[648,1,649,0]}
{"wire":[678,0,695,1]}
{"wire":[681,0,702,0]}
{"wire":[268,0,704,0]}
{"wire":[706,14,122,0]}
{"wire":[647,0,648,0]}
{"wire":[654,0,706,0]}
{"wire":[654,1,82,0]}
{"wire":[654,2,653,0]}
{"wire":[679,0,695,0]}
{"wire":[656,0,654,0]}
{"wire":[656,1,88,0]}
{"wire":[664,0,662,0]}
{"wire":[664,1,663,0]}
{"wire":[658,0,659,0]}
{"wire":[658,1,647,0]}
{"wire":[658,2,657,0]}
{"wire":[665,0,661,0]}
{"wire":[665,1,664,0]}
{"wire":[660,0,658,0]}
{"wire":[660,1,656,0]}
{"wire":[666,0,660,0]}
{"wire":[666,1,665,0]}
{"wire":[672,0,666,0]}
{"wire":[668,0,672,0]}
{"wire":[673,0,714,0]}
{"wire":[248,0,223,0]}
{"wire":[670,0,668,0]}
{"wire":[674,0,673,0]}
{"wire":[705,1,667,0]}
{"wire":[705,2,670,0]}
{"wire":[705,3,669,0]}
{"wire":[705,4,709,0]}
{"wire":[705,5,645,0]}
{"wire":[705,6,640,0]}
{"wire":[705,7,641,0]}
{"wire":[705,8,674,0]}
{"wire":[696,16,695,37]}
{"wire":[696,15,10,0]}
{"wire":[696,17,410,0]}
{"wire":[696,18,16,0]}
{"wire":[696,19,249,0]}
{"wire":[697,7,228,0]}
{"wire":[697,6,227,0]}
{"wire":[698,8,201,0]}
{"wire":[698,9,622,0]}
{"wire":[643,0,705,0]}
{"wire":[643,1,370,0]}
{"wire":[606,0,696,0]}
{"wire":[323,0,697,0]}
{"wire":[684,0,698,7]}
{"wire":[675,0,643,0]}
{"wire":[607,0,606,0]}
{"wire":[707,28,612,0]}
{"wire":[707,32,438,0]}
{"wire":[707,25,208,0]}
{"wire":[707,24,698,0]}
{"wire":[499,2,676,0]}
{"wire":[499,3,607,0]}
{"wire":[499,4,325,0]}
{"wire":[499,5,685,0]}
{"wire":[498,0,707,29]}
{"wire":[498,1,707,0]}
{"wire":[498,3,707,30]}
ASEEND*/
//CHKSM=B7835854D272AAB0C0632E304255572C5ED3B935