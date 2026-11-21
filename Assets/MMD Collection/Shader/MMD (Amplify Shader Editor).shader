// Made with Amplify Shader Editor v1.9.9.15
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMD Collection/URP/MMD (Amplify Shader Editor)"
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
		[HideInInspector] _Surface( "Surface Type", Float ) = 0
		[HideInInspector] _Blend( "Blending Mode", Float ) = 0
		[HideInInspector] _Cull( "Render Face", Float ) = 2
		[HideInInspector] _SrcBlend( "Src Blend (Auto)", Float ) = 1
		[HideInInspector] _DstBlend( "Dst Blend (Auto)", Float ) = 0
		[HideInInspector] _ZWriteControl( "Depth Write Mode", Float ) = 1
		[HideInInspector] _ZWrite( "ZWrite (Internal)", Float ) = 1
		[HideInInspector] _ZTest( "Depth Test", Float ) = 4
		[HideInInspector] _CastShadows( "Cast Shadows", Float ) = 1


		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
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
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ LIGHTMAP_ON


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
			float4 _Specular;
			float4 _SubTex_ST;
			float4 _OutlineColor;
			float4 _MainTex_ST;
			float4 _Color;
			float4 _Ambient;
			float3 _ToonTone;
			float _Opaque;
			float _HDR;
			float _MultipleLights;
			float _SpecularIntensity;
			float _Shininess;
			int _UVLayer;
			float _EFFECTS;
			float _SPHOpacity;
			float _Blend;
			float _SShad;
			float _ShadowLum;
			float _Surface;
			float _EdgeSize;
			float _On;
			float _CastShadows;
			float _ZTest;
			float _ZWrite;
			float _ZWriteControl;
			float _DstBlend;
			float _SrcBlend;
			float _Cull;
			#define ASE_PROPERTY_CUTOFF
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

				float Status23_g61413 = _On;
				float3 temp_cast_1 = 0;
				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( Status23_g61413 == (float)0 ? temp_cast_1 : ( _EdgeSize * input.normalOS ) );

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

				float4 temp_output_25_0_g61413 = _OutlineColor;
				
				float Status23_g61413 = _On;
				float Sgurface248 = _Surface;
				
				float compareResult2_g61411 = ( float )0;
				if( _AlphaClip == (float)1 )
				{
					compareResult2_g61411 = _Cutoff;
				}
				else
				{
					compareResult2_g61411 = 0.0001;
				}
				float Alpha_Clip_Threshold323 = compareResult2_g61411;
				

				float3 Color = (temp_output_25_0_g61413).rgb;
				float Alpha = ( Status23_g61413 == (float)1 ? ( Sgurface248 == (float)0 ? (float)1 : saturate( temp_output_25_0_g61413.a ) ) : (float)0 );
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

			#include "MMD_Custom_Node_(URP_ASE).hlsl"
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_NORMAL
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_POSITION
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES2
			#define ASE_NEEDS_TEXTURE_COORDINATES3
			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR
			#define ASE_NEEDS_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
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
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ LIGHTMAP_ON


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
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
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
			float4 _Specular;
			float4 _SubTex_ST;
			float4 _OutlineColor;
			float4 _MainTex_ST;
			float4 _Color;
			float4 _Ambient;
			float3 _ToonTone;
			float _Opaque;
			float _HDR;
			float _MultipleLights;
			float _SpecularIntensity;
			float _Shininess;
			int _UVLayer;
			float _EFFECTS;
			float _SPHOpacity;
			float _Blend;
			float _SShad;
			float _ShadowLum;
			float _Surface;
			float _EdgeSize;
			float _On;
			float _CastShadows;
			float _ZTest;
			float _ZWrite;
			float _ZWriteControl;
			float _DstBlend;
			float _SrcBlend;
			float _Cull;
			#define ASE_PROPERTY_CUTOFF
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

			sampler2D _ToonTex;
			sampler2D _MainTex;
			samplerCUBE _SphereCube;
			sampler2D _SubTex;


			half4 CalculateShadowMask1_g61399( half2 LightmapUV )
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

				output.ase_normal = input.normalOS;
				output.ase_texcoord3 = input.positionOS;
				output.ase_texcoord4.xy = input.ase_texcoord1.xy;
				output.ase_texcoord5.xyz = input.ase_texcoord.xyz;
				output.ase_texcoord4.zw = input.ase_texcoord2.xy;
				output.ase_texcoord6.xy = input.ase_texcoord3.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord5.w = 0;
				output.ase_texcoord6.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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
				output.tangentOS = input.tangentOS;
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

				float temp_output_23_0_g61408 = _SShad;
				float3 break10_g61396 = _ToonTone;
				float3 objToWorldDir5_g61394 = mul( GetObjectToWorldMatrix(), float4( input.ase_normal, 0.0 ) ).xyz;
				float3 normalizeResult3_g61394 = normalize( objToWorldDir5_g61394 );
				float3 normalizeResult2_g61394 = normalize( _MainLightPosition.xyz );
				float dotResult4_g61394 = dot( normalizeResult3_g61394 , normalizeResult2_g61394 );
				float temp_output_1_0_g61396 = ( ( break10_g61396.y * dotResult4_g61394 ) + break10_g61396.z );
				float localshadowAtten16_g61396 = ( 0.0 );
				float3 objToWorld8_g61396 = mul( GetObjectToWorldMatrix(), float4( input.ase_texcoord3.xyz, 1 ) ).xyz;
				float3 worldPos16_g61396 = objToWorld8_g61396;
				float OutputShadowAtten16_g61396 = 0.0;
				shadowAtten_float( worldPos16_g61396 , OutputShadowAtten16_g61396 );
				float temp_output_2_0_g61396 = ( break10_g61396.z + ( break10_g61396.x * ( OutputShadowAtten16_g61396 - 0.5 ) ) );
				float temp_output_633_22 = min( temp_output_1_0_g61396, temp_output_2_0_g61396 );
				float2 compareResult1_g61408 = ( float2 )0;
				if( temp_output_23_0_g61408 == (float)0 )
				{
					float temp_output_21_0_g61408 = saturate( temp_output_633_22 );
					float2 appendResult11_g61408 = (float2(temp_output_21_0_g61408 , temp_output_21_0_g61408));
					compareResult1_g61408 = appendResult11_g61408;
				}
				else
				{
					compareResult1_g61408 = float2( 0,0 );
				}
				float4 tex2DNode33_g61408 = tex2D( _ToonTex, compareResult1_g61408 );
				float4 compareResult8_g61408 = ( float4 )0;
				if( temp_output_23_0_g61408 == (float)0 )
				{
					compareResult8_g61408 = tex2DNode33_g61408;
				}
				else
				{
					float temp_output_3_0_g61397 = ( temp_output_633_22 * 2.0 );
					float4 lerpResult9_g61408 = lerp( tex2DNode33_g61408 , float4( float3( 1, 1, 1 ) , 0.0 ) , saturate( ( ( temp_output_3_0_g61397 * temp_output_3_0_g61397 ) - 1.0 ) ));
					compareResult8_g61408 = lerpResult9_g61408;
				}
				float locallightColor15_g61396 = ( 0.0 );
				float3 worldPos15_g61396 = objToWorld8_g61396;
				float3 OutputColor15_g61396 = float3( 0,0,0 );
				lightColor_float( worldPos15_g61396 , OutputColor15_g61396 );
				float3 temp_output_12_0_g61409 = OutputColor15_g61396;
				float3 staticSwitch8_g61409 = ( float3 )0;
				#ifdef LIGHTMAP_ON
				{
					float dotResult14_g61409 = dot( temp_output_12_0_g61409 , temp_output_12_0_g61409 );
					float locallightmapCol11_g61409 = ( 0.0 );
					float2 lightmapUV11_g61409 = (input.ase_texcoord4.xy*(unity_LightmapST).xy + (unity_LightmapST).zw);
					float3 Output11_g61409 = float3( 0,0,0 );
					lightmapCol_float( lightmapUV11_g61409 , Output11_g61409 );
					float3 compareResult10_g61409 = ( float3 )0;
					if( dotResult14_g61409 == (float)0 )
					{
						compareResult10_g61409 = ( Output11_g61409 * 2.0 );
					}
					else
					{
						compareResult10_g61409 = temp_output_12_0_g61409;
					}
					staticSwitch8_g61409 = ( compareResult10_g61409 + Output11_g61409 );
				}
				#else
				{
					staticSwitch8_g61409 = temp_output_12_0_g61409;
				}
				#endif
				half3 Global_Light_Scale139 = half3( 0.6, 0.6, 0.6 );
				float3 Light_Color25_g61414 = ( staticSwitch8_g61409 * Global_Light_Scale139 );
				float localvLight3_g61391 = ( 0.0 );
				float3 objToWorldDir2_g61391 = mul( GetObjectToWorldMatrix(), float4( input.ase_normal, 0.0 ) ).xyz;
				float3 normal3_g61391 = objToWorldDir2_g61391;
				float3 Output3_g61391 = float3( 0,0,0 );
				vLight_float( normal3_g61391 , Output3_g61391 );
				float3 temp_output_623_0 = Output3_g61391;
				float3 Ambient_Blend_Factor48 = ( float3( 1, 1, 1 ) - ( max( ( half3( 0.5, 0.5, 0.5 ) - (_Ambient).rgb ), float3( 0, 0, 0 ) ) * ( half3( 1, 1, 1 ) / 0.5 ) ) );
				float3 Weighted_Ambient144 = ( temp_output_623_0 * Ambient_Blend_Factor48 );
				float3 Temp_Diffuse46_g61403 = max( ( min( ( (_Ambient).rgb + ( (_Color).rgb * Global_Light_Scale139 ) ), float3( 1, 1, 1 ) ) - Weighted_Ambient144 ), float3( 0, 0, 0 ) );
				float2 uv_MainTex = input.ase_texcoord5.xyz.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode10 = tex2D( _MainTex, uv_MainTex );
				float4 Albedo_Texture41_g61403 = tex2DNode10;
				float4 temp_output_18_0_g61403 = ( float4( Temp_Diffuse46_g61403 , 0.0 ) * Albedo_Texture41_g61403 );
				float3 objToView2_g61395 = TransformWorldToView( TransformObjectToWorld(input.ase_texcoord3.xyz) );
				float3 normalizeResult4_g61395 = normalize( objToView2_g61395 );
				float3 objToViewDir3_g61395 = normalize( mul( UNITY_MATRIX_IT_MV, float4( input.ase_normal, 0.0 ) ).xyz );
				float3 normalizeResult5_g61395 = normalize( objToViewDir3_g61395 );
				float4 temp_output_27_0_g61403 = ( texCUBE( _SphereCube, reflect( normalizeResult4_g61395 , normalizeResult5_g61395 ) ) * _SPHOpacity );
				float Layer289 = _EFFECTS;
				float Effect_Layer13_g61403 = Layer289;
				float Layer_Value17_g61406 = Effect_Layer13_g61403;
				float4 lerpResult6_g61406 = lerp( temp_output_18_0_g61403 , ( temp_output_18_0_g61403 + temp_output_27_0_g61403 ) , step( 0.5 , Layer_Value17_g61406 ));
				float4 temp_output_15_0_g61403 = ( temp_output_27_0_g61403 * Albedo_Texture41_g61403 );
				float4 lerpResult14_g61406 = lerp( lerpResult6_g61406 , ( temp_output_15_0_g61403 * float4( Temp_Diffuse46_g61403 , 0.0 ) ) , step( 1.5 , Layer_Value17_g61406 ));
				float2 uv_SubTex = input.ase_texcoord5.xyz.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv2_SubTex = input.ase_texcoord4.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float Layer_Value17_g61405 = (float)_UVLayer;
				float2 lerpResult6_g61405 = lerp( uv_SubTex , uv2_SubTex , step( 0.5 , Layer_Value17_g61405 ));
				float2 uv3_SubTex = input.ase_texcoord4.zw * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 lerpResult14_g61405 = lerp( lerpResult6_g61405 , uv3_SubTex , step( 1.5 , Layer_Value17_g61405 ));
				float2 uv4_SubTex = input.ase_texcoord6.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 lerpResult16_g61405 = lerp( lerpResult14_g61405 , uv4_SubTex , step( 2.5 , Layer_Value17_g61405 ));
				float4 tex2DNode10_g61403 = tex2D( _SubTex, lerpResult16_g61405 );
				float4 lerpResult16_g61406 = lerp( lerpResult14_g61406 , ( float4( Temp_Diffuse46_g61403 , 0.0 ) * Albedo_Texture41_g61403 * tex2DNode10_g61403 ) , step( 2.5 , Layer_Value17_g61406 ));
				float3 objToWorldDir9_g61412 = mul( GetObjectToWorldMatrix(), float4( input.ase_normal, 0.0 ) ).xyz;
				float3 normalizeResult4_g61412 = normalize( objToWorldDir9_g61412 );
				float3 normalizeResult7_g61412 = normalize( ( _MainLightPosition.xyz + ViewDirWS ) );
				float dotResult1_g61412 = dot( normalizeResult4_g61412 , normalizeResult7_g61412 );
				float Layer_Value17_g61404 = Effect_Layer13_g61403;
				float4 lerpResult6_g61404 = lerp( Albedo_Texture41_g61403 , ( temp_output_27_0_g61403 + Albedo_Texture41_g61403 ) , step( 0.5 , Layer_Value17_g61404 ));
				float4 lerpResult14_g61404 = lerp( lerpResult6_g61404 , temp_output_15_0_g61403 , step( 1.5 , Layer_Value17_g61404 ));
				float4 lerpResult16_g61404 = lerp( lerpResult14_g61404 , Albedo_Texture41_g61403 , step( 2.5 , Layer_Value17_g61404 ));
				float3 temp_output_13_0_g61398 = temp_output_623_0;
				float3 compareResult2_g61398 = ( float3 )0;
				if( _MultipleLights == (float)1 )
				{
					float3 WorldPosition288_g61402 = PositionWS;
					float3 WorldPosition305_g61402 = WorldPosition288_g61402;
					float2 ScreenUV286_g61402 = (ScreenPosNorm).xy;
					float2 ScreenUV305_g61402 = ScreenUV286_g61402;
					float3 objToWorldDir5_g61398 = mul( GetObjectToWorldMatrix(), float4( input.ase_normal, 0.0 ) ).xyz;
					float3 WorldNormal281_g61402 = objToWorldDir5_g61398;
					float3 WorldNormal305_g61402 = WorldNormal281_g61402;
					half2 LightmapUV1_g61399 = (input.ase_texcoord4.zw*(unity_DynamicLightmapST).xy + (unity_DynamicLightmapST).zw);
					half4 localCalculateShadowMask1_g61399 = CalculateShadowMask1_g61399( LightmapUV1_g61399 );
					float4 ShadowMask360_g61402 = localCalculateShadowMask1_g61399;
					float4 ShadowMask305_g61402 = ShadowMask360_g61402;
					float3 localAdditionalLightsLambertMask17x305_g61402 = AdditionalLightsLambertMask17x( WorldPosition305_g61402 , ScreenUV305_g61402 , WorldNormal305_g61402 , ShadowMask305_g61402 );
					compareResult2_g61398 = ( localAdditionalLightsLambertMask17x305_g61402 + temp_output_13_0_g61398 );
				}
				else
				{
					compareResult2_g61398 = temp_output_13_0_g61398;
				}
				float3 Additional_Lights268 = compareResult2_g61398;
				
				float Sgurface248 = _Surface;
				float compareResult14_g61407 = ( float )0;
				if( Sgurface248 == (float)0 )
				{
					compareResult14_g61407 = (float)1;
				}
				else
				{
					float compareResult7_g61407 = ( float )0;
					if( Layer289 == (float)3 )
					{
						compareResult7_g61407 = ( tex2DNode10_g61403.a * tex2DNode10.a );
					}
					else
					{
						compareResult7_g61407 = tex2DNode10.a;
					}
					compareResult14_g61407 = saturate( ( _Opaque * compareResult7_g61407 ) );
				}
				
				float compareResult2_g61411 = ( float )0;
				if( _AlphaClip == (float)1 )
				{
					compareResult2_g61411 = _Cutoff;
				}
				else
				{
					compareResult2_g61411 = 0.0001;
				}
				float Alpha_Clip_Threshold323 = compareResult2_g61411;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( ( ( saturate( ( 1.0 - ( _ShadowLum * ( 1.0 - compareResult8_g61408 ) ) ) ) * float4( Light_Color25_g61414 , 0.0 ) * lerpResult16_g61406 ) + ( ( pow( saturate( dotResult1_g61412 ) , max( _Shininess, 0.001 ) ) * _Specular * float4( Light_Color25_g61414 , 0.0 ) ) * _SpecularIntensity ) ) + ( lerpResult16_g61404 * float4( ( Additional_Lights268 * Ambient_Blend_Factor48 ) , 0.0 ) ) ) * _HDR ).rgb;
				float3 Normal = float3(0, 0, 1);

				float Alpha = compareResult14_g61407;
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

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
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
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ LIGHTMAP_ON


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Specular;
			float4 _SubTex_ST;
			float4 _OutlineColor;
			float4 _MainTex_ST;
			float4 _Color;
			float4 _Ambient;
			float3 _ToonTone;
			float _Opaque;
			float _HDR;
			float _MultipleLights;
			float _SpecularIntensity;
			float _Shininess;
			int _UVLayer;
			float _EFFECTS;
			float _SPHOpacity;
			float _Blend;
			float _SShad;
			float _ShadowLum;
			float _Surface;
			float _EdgeSize;
			float _On;
			float _CastShadows;
			float _ZTest;
			float _ZWrite;
			float _ZWriteControl;
			float _DstBlend;
			float _SrcBlend;
			float _Cull;
			#define ASE_PROPERTY_CUTOFF
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
			sampler2D _SubTex;


			float3 _LightDirection;
			float3 _LightPosition;

			
			PackedVaryings VertexFunction( Attributes input )
			{
				PackedVaryings output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( output );

				output.ase_texcoord.xyz = input.ase_texcoord.xyz;
				output.ase_texcoord1.xy = input.ase_texcoord1.xy;
				output.ase_texcoord1.zw = input.ase_texcoord2.xy;
				output.ase_texcoord2.xy = input.ase_texcoord3.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord.w = 0;
				output.ase_texcoord2.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;
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
				float compareResult14_g61407 = ( float )0;
				if( Sgurface248 == (float)0 )
				{
					compareResult14_g61407 = (float)1;
				}
				else
				{
					float2 uv_MainTex = input.ase_texcoord.xyz.xy * _MainTex_ST.xy + _MainTex_ST.zw;
					float4 tex2DNode10 = tex2D( _MainTex, uv_MainTex );
					float compareResult7_g61407 = ( float )0;
					if( Layer289 == (float)3 )
					{
						float2 uv_SubTex = input.ase_texcoord.xyz.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 uv2_SubTex = input.ase_texcoord1.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float Layer_Value17_g61405 = (float)_UVLayer;
						float2 lerpResult6_g61405 = lerp( uv_SubTex , uv2_SubTex , step( 0.5 , Layer_Value17_g61405 ));
						float2 uv3_SubTex = input.ase_texcoord1.zw * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 lerpResult14_g61405 = lerp( lerpResult6_g61405 , uv3_SubTex , step( 1.5 , Layer_Value17_g61405 ));
						float2 uv4_SubTex = input.ase_texcoord2.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 lerpResult16_g61405 = lerp( lerpResult14_g61405 , uv4_SubTex , step( 2.5 , Layer_Value17_g61405 ));
						float4 tex2DNode10_g61403 = tex2D( _SubTex, lerpResult16_g61405 );
						compareResult7_g61407 = ( tex2DNode10_g61403.a * tex2DNode10.a );
					}
					else
					{
						compareResult7_g61407 = tex2DNode10.a;
					}
					compareResult14_g61407 = saturate( ( _Opaque * compareResult7_g61407 ) );
				}
				
				float compareResult2_g61411 = ( float )0;
				if( _AlphaClip == (float)1 )
				{
					compareResult2_g61411 = _Cutoff;
				}
				else
				{
					compareResult2_g61411 = 0.0001;
				}
				float Alpha_Clip_Threshold323 = compareResult2_g61411;
				

				float Alpha = compareResult14_g61407;
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

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
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
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ LIGHTMAP_ON


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Specular;
			float4 _SubTex_ST;
			float4 _OutlineColor;
			float4 _MainTex_ST;
			float4 _Color;
			float4 _Ambient;
			float3 _ToonTone;
			float _Opaque;
			float _HDR;
			float _MultipleLights;
			float _SpecularIntensity;
			float _Shininess;
			int _UVLayer;
			float _EFFECTS;
			float _SPHOpacity;
			float _Blend;
			float _SShad;
			float _ShadowLum;
			float _Surface;
			float _EdgeSize;
			float _On;
			float _CastShadows;
			float _ZTest;
			float _ZWrite;
			float _ZWriteControl;
			float _DstBlend;
			float _SrcBlend;
			float _Cull;
			#define ASE_PROPERTY_CUTOFF
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
			sampler2D _SubTex;


			float3 _LightDirection;
			float3 _LightPosition;

			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				output.ase_texcoord.xyz = input.ase_texcoord.xyz;
				output.ase_texcoord1.xy = input.ase_texcoord1.xy;
				output.ase_texcoord1.zw = input.ase_texcoord2.xy;
				output.ase_texcoord2.xy = input.ase_texcoord3.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord.w = 0;
				output.ase_texcoord2.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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
				float compareResult14_g61407 = ( float )0;
				if( Sgurface248 == (float)0 )
				{
					compareResult14_g61407 = (float)1;
				}
				else
				{
					float2 uv_MainTex = input.ase_texcoord.xyz.xy * _MainTex_ST.xy + _MainTex_ST.zw;
					float4 tex2DNode10 = tex2D( _MainTex, uv_MainTex );
					float compareResult7_g61407 = ( float )0;
					if( Layer289 == (float)3 )
					{
						float2 uv_SubTex = input.ase_texcoord.xyz.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 uv2_SubTex = input.ase_texcoord1.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float Layer_Value17_g61405 = (float)_UVLayer;
						float2 lerpResult6_g61405 = lerp( uv_SubTex , uv2_SubTex , step( 0.5 , Layer_Value17_g61405 ));
						float2 uv3_SubTex = input.ase_texcoord1.zw * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 lerpResult14_g61405 = lerp( lerpResult6_g61405 , uv3_SubTex , step( 1.5 , Layer_Value17_g61405 ));
						float2 uv4_SubTex = input.ase_texcoord2.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 lerpResult16_g61405 = lerp( lerpResult14_g61405 , uv4_SubTex , step( 2.5 , Layer_Value17_g61405 ));
						float4 tex2DNode10_g61403 = tex2D( _SubTex, lerpResult16_g61405 );
						compareResult7_g61407 = ( tex2DNode10_g61403.a * tex2DNode10.a );
					}
					else
					{
						compareResult7_g61407 = tex2DNode10.a;
					}
					compareResult14_g61407 = saturate( ( _Opaque * compareResult7_g61407 ) );
				}
				
				float compareResult2_g61411 = ( float )0;
				if( _AlphaClip == (float)1 )
				{
					compareResult2_g61411 = _Cutoff;
				}
				else
				{
					compareResult2_g61411 = 0.0001;
				}
				float Alpha_Clip_Threshold323 = compareResult2_g61411;
				

				float Alpha = compareResult14_g61407;
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

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
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
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ LIGHTMAP_ON


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Specular;
			float4 _SubTex_ST;
			float4 _OutlineColor;
			float4 _MainTex_ST;
			float4 _Color;
			float4 _Ambient;
			float3 _ToonTone;
			float _Opaque;
			float _HDR;
			float _MultipleLights;
			float _SpecularIntensity;
			float _Shininess;
			int _UVLayer;
			float _EFFECTS;
			float _SPHOpacity;
			float _Blend;
			float _SShad;
			float _ShadowLum;
			float _Surface;
			float _EdgeSize;
			float _On;
			float _CastShadows;
			float _ZTest;
			float _ZWrite;
			float _ZWriteControl;
			float _DstBlend;
			float _SrcBlend;
			float _Cull;
			#define ASE_PROPERTY_CUTOFF
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

				output.ase_texcoord.xyz = input.ase_texcoord.xyz;
				output.ase_texcoord1.xy = input.ase_texcoord1.xy;
				output.ase_texcoord1.zw = input.ase_texcoord2.xy;
				output.ase_texcoord2.xy = input.ase_texcoord3.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord.w = 0;
				output.ase_texcoord2.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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
				float compareResult14_g61407 = ( float )0;
				if( Sgurface248 == (float)0 )
				{
					compareResult14_g61407 = (float)1;
				}
				else
				{
					float2 uv_MainTex = input.ase_texcoord.xyz.xy * _MainTex_ST.xy + _MainTex_ST.zw;
					float4 tex2DNode10 = tex2D( _MainTex, uv_MainTex );
					float compareResult7_g61407 = ( float )0;
					if( Layer289 == (float)3 )
					{
						float2 uv_SubTex = input.ase_texcoord.xyz.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 uv2_SubTex = input.ase_texcoord1.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float Layer_Value17_g61405 = (float)_UVLayer;
						float2 lerpResult6_g61405 = lerp( uv_SubTex , uv2_SubTex , step( 0.5 , Layer_Value17_g61405 ));
						float2 uv3_SubTex = input.ase_texcoord1.zw * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 lerpResult14_g61405 = lerp( lerpResult6_g61405 , uv3_SubTex , step( 1.5 , Layer_Value17_g61405 ));
						float2 uv4_SubTex = input.ase_texcoord2.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 lerpResult16_g61405 = lerp( lerpResult14_g61405 , uv4_SubTex , step( 2.5 , Layer_Value17_g61405 ));
						float4 tex2DNode10_g61403 = tex2D( _SubTex, lerpResult16_g61405 );
						compareResult7_g61407 = ( tex2DNode10_g61403.a * tex2DNode10.a );
					}
					else
					{
						compareResult7_g61407 = tex2DNode10.a;
					}
					compareResult14_g61407 = saturate( ( _Opaque * compareResult7_g61407 ) );
				}
				
				float compareResult2_g61411 = ( float )0;
				if( _AlphaClip == (float)1 )
				{
					compareResult2_g61411 = _Cutoff;
				}
				else
				{
					compareResult2_g61411 = 0.0001;
				}
				float Alpha_Clip_Threshold323 = compareResult2_g61411;
				

				surfaceDescription.Alpha = compareResult14_g61407;
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

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
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
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ LIGHTMAP_ON


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Specular;
			float4 _SubTex_ST;
			float4 _OutlineColor;
			float4 _MainTex_ST;
			float4 _Color;
			float4 _Ambient;
			float3 _ToonTone;
			float _Opaque;
			float _HDR;
			float _MultipleLights;
			float _SpecularIntensity;
			float _Shininess;
			int _UVLayer;
			float _EFFECTS;
			float _SPHOpacity;
			float _Blend;
			float _SShad;
			float _ShadowLum;
			float _Surface;
			float _EdgeSize;
			float _On;
			float _CastShadows;
			float _ZTest;
			float _ZWrite;
			float _ZWriteControl;
			float _DstBlend;
			float _SrcBlend;
			float _Cull;
			#define ASE_PROPERTY_CUTOFF
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

				output.ase_texcoord.xyz = input.ase_texcoord.xyz;
				output.ase_texcoord1.xy = input.ase_texcoord1.xy;
				output.ase_texcoord1.zw = input.ase_texcoord2.xy;
				output.ase_texcoord2.xy = input.ase_texcoord3.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord.w = 0;
				output.ase_texcoord2.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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
				float compareResult14_g61407 = ( float )0;
				if( Sgurface248 == (float)0 )
				{
					compareResult14_g61407 = (float)1;
				}
				else
				{
					float2 uv_MainTex = input.ase_texcoord.xyz.xy * _MainTex_ST.xy + _MainTex_ST.zw;
					float4 tex2DNode10 = tex2D( _MainTex, uv_MainTex );
					float compareResult7_g61407 = ( float )0;
					if( Layer289 == (float)3 )
					{
						float2 uv_SubTex = input.ase_texcoord.xyz.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 uv2_SubTex = input.ase_texcoord1.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float Layer_Value17_g61405 = (float)_UVLayer;
						float2 lerpResult6_g61405 = lerp( uv_SubTex , uv2_SubTex , step( 0.5 , Layer_Value17_g61405 ));
						float2 uv3_SubTex = input.ase_texcoord1.zw * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 lerpResult14_g61405 = lerp( lerpResult6_g61405 , uv3_SubTex , step( 1.5 , Layer_Value17_g61405 ));
						float2 uv4_SubTex = input.ase_texcoord2.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 lerpResult16_g61405 = lerp( lerpResult14_g61405 , uv4_SubTex , step( 2.5 , Layer_Value17_g61405 ));
						float4 tex2DNode10_g61403 = tex2D( _SubTex, lerpResult16_g61405 );
						compareResult7_g61407 = ( tex2DNode10_g61403.a * tex2DNode10.a );
					}
					else
					{
						compareResult7_g61407 = tex2DNode10.a;
					}
					compareResult14_g61407 = saturate( ( _Opaque * compareResult7_g61407 ) );
				}
				
				float compareResult2_g61411 = ( float )0;
				if( _AlphaClip == (float)1 )
				{
					compareResult2_g61411 = _Cutoff;
				}
				else
				{
					compareResult2_g61411 = 0.0001;
				}
				float Alpha_Clip_Threshold323 = compareResult2_g61411;
				

				surfaceDescription.Alpha = compareResult14_g61407;
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

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
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
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ LIGHTMAP_ON


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				#if defined( SHADER_STAGE_FRAGMENT ) && defined( ASE_NEED_CULLFACE )
					uint cullFace : SV_IsFrontFace;
				#endif
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Specular;
			float4 _SubTex_ST;
			float4 _OutlineColor;
			float4 _MainTex_ST;
			float4 _Color;
			float4 _Ambient;
			float3 _ToonTone;
			float _Opaque;
			float _HDR;
			float _MultipleLights;
			float _SpecularIntensity;
			float _Shininess;
			int _UVLayer;
			float _EFFECTS;
			float _SPHOpacity;
			float _Blend;
			float _SShad;
			float _ShadowLum;
			float _Surface;
			float _EdgeSize;
			float _On;
			float _CastShadows;
			float _ZTest;
			float _ZWrite;
			float _ZWriteControl;
			float _DstBlend;
			float _SrcBlend;
			float _Cull;
			#define ASE_PROPERTY_CUTOFF
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

				output.ase_texcoord2.xyz = input.ase_texcoord.xyz;
				output.ase_texcoord3.xy = input.ase_texcoord1.xy;
				output.ase_texcoord3.zw = input.ase_texcoord2.xy;
				output.ase_texcoord4.xy = input.ase_texcoord3.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord2.w = 0;
				output.ase_texcoord4.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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
				float compareResult14_g61407 = ( float )0;
				if( Sgurface248 == (float)0 )
				{
					compareResult14_g61407 = (float)1;
				}
				else
				{
					float2 uv_MainTex = input.ase_texcoord2.xyz.xy * _MainTex_ST.xy + _MainTex_ST.zw;
					float4 tex2DNode10 = tex2D( _MainTex, uv_MainTex );
					float compareResult7_g61407 = ( float )0;
					if( Layer289 == (float)3 )
					{
						float2 uv_SubTex = input.ase_texcoord2.xyz.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 uv2_SubTex = input.ase_texcoord3.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float Layer_Value17_g61405 = (float)_UVLayer;
						float2 lerpResult6_g61405 = lerp( uv_SubTex , uv2_SubTex , step( 0.5 , Layer_Value17_g61405 ));
						float2 uv3_SubTex = input.ase_texcoord3.zw * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 lerpResult14_g61405 = lerp( lerpResult6_g61405 , uv3_SubTex , step( 1.5 , Layer_Value17_g61405 ));
						float2 uv4_SubTex = input.ase_texcoord4.xy * _SubTex_ST.xy + _SubTex_ST.zw;
						float2 lerpResult16_g61405 = lerp( lerpResult14_g61405 , uv4_SubTex , step( 2.5 , Layer_Value17_g61405 ));
						float4 tex2DNode10_g61403 = tex2D( _SubTex, lerpResult16_g61405 );
						compareResult7_g61407 = ( tex2DNode10_g61403.a * tex2DNode10.a );
					}
					else
					{
						compareResult7_g61407 = tex2DNode10.a;
					}
					compareResult14_g61407 = saturate( ( _Opaque * compareResult7_g61407 ) );
				}
				
				float compareResult2_g61411 = ( float )0;
				if( _AlphaClip == (float)1 )
				{
					compareResult2_g61411 = _Cutoff;
				}
				else
				{
					compareResult2_g61411 = 0.0001;
				}
				float Alpha_Clip_Threshold323 = compareResult2_g61411;
				

				float3 Normal = float3(0, 0, 1);

				float Alpha = compareResult14_g61407;
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

			#include "MMD_Custom_Node_(URP_ASE).hlsl"
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_NORMAL
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_POSITION
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES2
			#define ASE_NEEDS_TEXTURE_COORDINATES3
			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR
			#define ASE_NEEDS_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
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
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ LIGHTMAP_ON


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
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
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
			float4 _Specular;
			float4 _SubTex_ST;
			float4 _OutlineColor;
			float4 _MainTex_ST;
			float4 _Color;
			float4 _Ambient;
			float3 _ToonTone;
			float _Opaque;
			float _HDR;
			float _MultipleLights;
			float _SpecularIntensity;
			float _Shininess;
			int _UVLayer;
			float _EFFECTS;
			float _SPHOpacity;
			float _Blend;
			float _SShad;
			float _ShadowLum;
			float _Surface;
			float _EdgeSize;
			float _On;
			float _CastShadows;
			float _ZTest;
			float _ZWrite;
			float _ZWriteControl;
			float _DstBlend;
			float _SrcBlend;
			float _Cull;
			#define ASE_PROPERTY_CUTOFF
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

			sampler2D _ToonTex;
			sampler2D _MainTex;
			samplerCUBE _SphereCube;
			sampler2D _SubTex;


			#if ( UNITY_VERSION >= 60010000 )
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GBufferOutput.hlsl"
			#else
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
			#endif

			half4 CalculateShadowMask1_g61399( half2 LightmapUV )
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

				output.ase_normal = input.normalOS;
				output.ase_texcoord3 = input.positionOS;
				output.ase_texcoord4.xy = input.ase_texcoord1.xy;
				output.ase_texcoord5.xyz = input.ase_texcoord.xyz;
				output.ase_texcoord4.zw = input.ase_texcoord2.xy;
				output.ase_texcoord6.xy = input.ase_texcoord3.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord5.w = 0;
				output.ase_texcoord6.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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
				output.tangentOS = input.tangentOS;
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

				float temp_output_23_0_g61408 = _SShad;
				float3 break10_g61396 = _ToonTone;
				float3 objToWorldDir5_g61394 = mul( GetObjectToWorldMatrix(), float4( input.ase_normal, 0.0 ) ).xyz;
				float3 normalizeResult3_g61394 = normalize( objToWorldDir5_g61394 );
				float3 normalizeResult2_g61394 = normalize( _MainLightPosition.xyz );
				float dotResult4_g61394 = dot( normalizeResult3_g61394 , normalizeResult2_g61394 );
				float temp_output_1_0_g61396 = ( ( break10_g61396.y * dotResult4_g61394 ) + break10_g61396.z );
				float localshadowAtten16_g61396 = ( 0.0 );
				float3 objToWorld8_g61396 = mul( GetObjectToWorldMatrix(), float4( input.ase_texcoord3.xyz, 1 ) ).xyz;
				float3 worldPos16_g61396 = objToWorld8_g61396;
				float OutputShadowAtten16_g61396 = 0.0;
				shadowAtten_float( worldPos16_g61396 , OutputShadowAtten16_g61396 );
				float temp_output_2_0_g61396 = ( break10_g61396.z + ( break10_g61396.x * ( OutputShadowAtten16_g61396 - 0.5 ) ) );
				float temp_output_633_22 = min( temp_output_1_0_g61396, temp_output_2_0_g61396 );
				float2 compareResult1_g61408 = ( float2 )0;
				if( temp_output_23_0_g61408 == (float)0 )
				{
					float temp_output_21_0_g61408 = saturate( temp_output_633_22 );
					float2 appendResult11_g61408 = (float2(temp_output_21_0_g61408 , temp_output_21_0_g61408));
					compareResult1_g61408 = appendResult11_g61408;
				}
				else
				{
					compareResult1_g61408 = float2( 0,0 );
				}
				float4 tex2DNode33_g61408 = tex2D( _ToonTex, compareResult1_g61408 );
				float4 compareResult8_g61408 = ( float4 )0;
				if( temp_output_23_0_g61408 == (float)0 )
				{
					compareResult8_g61408 = tex2DNode33_g61408;
				}
				else
				{
					float temp_output_3_0_g61397 = ( temp_output_633_22 * 2.0 );
					float4 lerpResult9_g61408 = lerp( tex2DNode33_g61408 , float4( float3( 1, 1, 1 ) , 0.0 ) , saturate( ( ( temp_output_3_0_g61397 * temp_output_3_0_g61397 ) - 1.0 ) ));
					compareResult8_g61408 = lerpResult9_g61408;
				}
				float locallightColor15_g61396 = ( 0.0 );
				float3 worldPos15_g61396 = objToWorld8_g61396;
				float3 OutputColor15_g61396 = float3( 0,0,0 );
				lightColor_float( worldPos15_g61396 , OutputColor15_g61396 );
				float3 temp_output_12_0_g61409 = OutputColor15_g61396;
				float3 staticSwitch8_g61409 = ( float3 )0;
				#ifdef LIGHTMAP_ON
				{
					float dotResult14_g61409 = dot( temp_output_12_0_g61409 , temp_output_12_0_g61409 );
					float locallightmapCol11_g61409 = ( 0.0 );
					float2 lightmapUV11_g61409 = (input.ase_texcoord4.xy*(unity_LightmapST).xy + (unity_LightmapST).zw);
					float3 Output11_g61409 = float3( 0,0,0 );
					lightmapCol_float( lightmapUV11_g61409 , Output11_g61409 );
					float3 compareResult10_g61409 = ( float3 )0;
					if( dotResult14_g61409 == (float)0 )
					{
						compareResult10_g61409 = ( Output11_g61409 * 2.0 );
					}
					else
					{
						compareResult10_g61409 = temp_output_12_0_g61409;
					}
					staticSwitch8_g61409 = ( compareResult10_g61409 + Output11_g61409 );
				}
				#else
				{
					staticSwitch8_g61409 = temp_output_12_0_g61409;
				}
				#endif
				half3 Global_Light_Scale139 = half3( 0.6, 0.6, 0.6 );
				float3 Light_Color25_g61414 = ( staticSwitch8_g61409 * Global_Light_Scale139 );
				float localvLight3_g61391 = ( 0.0 );
				float3 objToWorldDir2_g61391 = mul( GetObjectToWorldMatrix(), float4( input.ase_normal, 0.0 ) ).xyz;
				float3 normal3_g61391 = objToWorldDir2_g61391;
				float3 Output3_g61391 = float3( 0,0,0 );
				vLight_float( normal3_g61391 , Output3_g61391 );
				float3 temp_output_623_0 = Output3_g61391;
				float3 Ambient_Blend_Factor48 = ( float3( 1, 1, 1 ) - ( max( ( half3( 0.5, 0.5, 0.5 ) - (_Ambient).rgb ), float3( 0, 0, 0 ) ) * ( half3( 1, 1, 1 ) / 0.5 ) ) );
				float3 Weighted_Ambient144 = ( temp_output_623_0 * Ambient_Blend_Factor48 );
				float3 Temp_Diffuse46_g61403 = max( ( min( ( (_Ambient).rgb + ( (_Color).rgb * Global_Light_Scale139 ) ), float3( 1, 1, 1 ) ) - Weighted_Ambient144 ), float3( 0, 0, 0 ) );
				float2 uv_MainTex = input.ase_texcoord5.xyz.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode10 = tex2D( _MainTex, uv_MainTex );
				float4 Albedo_Texture41_g61403 = tex2DNode10;
				float4 temp_output_18_0_g61403 = ( float4( Temp_Diffuse46_g61403 , 0.0 ) * Albedo_Texture41_g61403 );
				float3 objToView2_g61395 = TransformWorldToView( TransformObjectToWorld(input.ase_texcoord3.xyz) );
				float3 normalizeResult4_g61395 = normalize( objToView2_g61395 );
				float3 objToViewDir3_g61395 = normalize( mul( UNITY_MATRIX_IT_MV, float4( input.ase_normal, 0.0 ) ).xyz );
				float3 normalizeResult5_g61395 = normalize( objToViewDir3_g61395 );
				float4 temp_output_27_0_g61403 = ( texCUBE( _SphereCube, reflect( normalizeResult4_g61395 , normalizeResult5_g61395 ) ) * _SPHOpacity );
				float Layer289 = _EFFECTS;
				float Effect_Layer13_g61403 = Layer289;
				float Layer_Value17_g61406 = Effect_Layer13_g61403;
				float4 lerpResult6_g61406 = lerp( temp_output_18_0_g61403 , ( temp_output_18_0_g61403 + temp_output_27_0_g61403 ) , step( 0.5 , Layer_Value17_g61406 ));
				float4 temp_output_15_0_g61403 = ( temp_output_27_0_g61403 * Albedo_Texture41_g61403 );
				float4 lerpResult14_g61406 = lerp( lerpResult6_g61406 , ( temp_output_15_0_g61403 * float4( Temp_Diffuse46_g61403 , 0.0 ) ) , step( 1.5 , Layer_Value17_g61406 ));
				float2 uv_SubTex = input.ase_texcoord5.xyz.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 uv2_SubTex = input.ase_texcoord4.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float Layer_Value17_g61405 = (float)_UVLayer;
				float2 lerpResult6_g61405 = lerp( uv_SubTex , uv2_SubTex , step( 0.5 , Layer_Value17_g61405 ));
				float2 uv3_SubTex = input.ase_texcoord4.zw * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 lerpResult14_g61405 = lerp( lerpResult6_g61405 , uv3_SubTex , step( 1.5 , Layer_Value17_g61405 ));
				float2 uv4_SubTex = input.ase_texcoord6.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 lerpResult16_g61405 = lerp( lerpResult14_g61405 , uv4_SubTex , step( 2.5 , Layer_Value17_g61405 ));
				float4 tex2DNode10_g61403 = tex2D( _SubTex, lerpResult16_g61405 );
				float4 lerpResult16_g61406 = lerp( lerpResult14_g61406 , ( float4( Temp_Diffuse46_g61403 , 0.0 ) * Albedo_Texture41_g61403 * tex2DNode10_g61403 ) , step( 2.5 , Layer_Value17_g61406 ));
				float3 objToWorldDir9_g61412 = mul( GetObjectToWorldMatrix(), float4( input.ase_normal, 0.0 ) ).xyz;
				float3 normalizeResult4_g61412 = normalize( objToWorldDir9_g61412 );
				float3 normalizeResult7_g61412 = normalize( ( _MainLightPosition.xyz + ViewDirWS ) );
				float dotResult1_g61412 = dot( normalizeResult4_g61412 , normalizeResult7_g61412 );
				float Layer_Value17_g61404 = Effect_Layer13_g61403;
				float4 lerpResult6_g61404 = lerp( Albedo_Texture41_g61403 , ( temp_output_27_0_g61403 + Albedo_Texture41_g61403 ) , step( 0.5 , Layer_Value17_g61404 ));
				float4 lerpResult14_g61404 = lerp( lerpResult6_g61404 , temp_output_15_0_g61403 , step( 1.5 , Layer_Value17_g61404 ));
				float4 lerpResult16_g61404 = lerp( lerpResult14_g61404 , Albedo_Texture41_g61403 , step( 2.5 , Layer_Value17_g61404 ));
				float3 temp_output_13_0_g61398 = temp_output_623_0;
				float3 compareResult2_g61398 = ( float3 )0;
				if( _MultipleLights == (float)1 )
				{
					float3 WorldPosition288_g61402 = PositionWS;
					float3 WorldPosition305_g61402 = WorldPosition288_g61402;
					float2 ScreenUV286_g61402 = (ScreenPosNorm).xy;
					float2 ScreenUV305_g61402 = ScreenUV286_g61402;
					float3 objToWorldDir5_g61398 = mul( GetObjectToWorldMatrix(), float4( input.ase_normal, 0.0 ) ).xyz;
					float3 WorldNormal281_g61402 = objToWorldDir5_g61398;
					float3 WorldNormal305_g61402 = WorldNormal281_g61402;
					half2 LightmapUV1_g61399 = (input.ase_texcoord4.zw*(unity_DynamicLightmapST).xy + (unity_DynamicLightmapST).zw);
					half4 localCalculateShadowMask1_g61399 = CalculateShadowMask1_g61399( LightmapUV1_g61399 );
					float4 ShadowMask360_g61402 = localCalculateShadowMask1_g61399;
					float4 ShadowMask305_g61402 = ShadowMask360_g61402;
					float3 localAdditionalLightsLambertMask17x305_g61402 = AdditionalLightsLambertMask17x( WorldPosition305_g61402 , ScreenUV305_g61402 , WorldNormal305_g61402 , ShadowMask305_g61402 );
					compareResult2_g61398 = ( localAdditionalLightsLambertMask17x305_g61402 + temp_output_13_0_g61398 );
				}
				else
				{
					compareResult2_g61398 = temp_output_13_0_g61398;
				}
				float3 Additional_Lights268 = compareResult2_g61398;
				
				float Sgurface248 = _Surface;
				float compareResult14_g61407 = ( float )0;
				if( Sgurface248 == (float)0 )
				{
					compareResult14_g61407 = (float)1;
				}
				else
				{
					float compareResult7_g61407 = ( float )0;
					if( Layer289 == (float)3 )
					{
						compareResult7_g61407 = ( tex2DNode10_g61403.a * tex2DNode10.a );
					}
					else
					{
						compareResult7_g61407 = tex2DNode10.a;
					}
					compareResult14_g61407 = saturate( ( _Opaque * compareResult7_g61407 ) );
				}
				
				float compareResult2_g61411 = ( float )0;
				if( _AlphaClip == (float)1 )
				{
					compareResult2_g61411 = _Cutoff;
				}
				else
				{
					compareResult2_g61411 = 0.0001;
				}
				float Alpha_Clip_Threshold323 = compareResult2_g61411;
				

				float3 Color = ( ( ( ( saturate( ( 1.0 - ( _ShadowLum * ( 1.0 - compareResult8_g61408 ) ) ) ) * float4( Light_Color25_g61414 , 0.0 ) * lerpResult16_g61406 ) + ( ( pow( saturate( dotResult1_g61412 ) , max( _Shininess, 0.001 ) ) * _Specular * float4( Light_Color25_g61414 , 0.0 ) ) * _SpecularIntensity ) ) + ( lerpResult16_g61404 * float4( ( Additional_Lights268 * Ambient_Blend_Factor48 ) , 0.0 ) ) ) * _HDR ).rgb;
				float3 Normal = float3(0, 0, 1);

				float Alpha = compareResult14_g61407;
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
	

	

	CustomEditor "MMDCollection.ShaderMMD.MMDMaterial_ASE"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback "Universal Render Pipeline/Unlit"
}
/*ASEBEGIN
Version=19915
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":610,"pos":[-7680,-5056],"params":["Inherit","False","6561.605","4258.632","MMD Material Calculation","55","499","292","591","558","429","325","370","196","268","197","176","609","607","122","603","605","88","82","604","47","307","606","249","410","16","289","602","10","478","56","40","207","601","145","139","11","144","48","28","635","632","637","633","631","639","624","623","622","621","625","627","628","634","638","640","","0,1,0,1","0","0"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":28,"pos":[-7648,-2560],"params":["Inherit","False","Property","_Ambient","Ambient","2","0","Create","True","1","","0","0","False","0","False","Object","-1","","1,1,1,0","0,1,0,0","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":625,"pos":[-7648,-2912],"params":["Inherit","True","MMD Constants (Amplify Shader Editor)","-1","","61388","418dddb8757e55344877d4066e563a11","0","0","3","FLOAT3","1","FLOAT3","2","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":621,"pos":[-6720,-2912],"params":["Inherit","True","Ambient Pivot Adjustment (Amplify Shader Editor)","-1","","61389","582f37f9bea582d40a5b5476b5710fed","0","3","12","FLOAT3","0.5,0.5,0.5","False","11","FLOAT3","1,1,1","False","13","COLOR","1,1,1,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":622,"pos":[-6272,-2912],"params":["Inherit","True","Ambient Blend Factor (Amplify Shader Editor)","-1","","61390","c421f4bc8a9adda44bd4cd4e12093875","0","1","7","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":623,"pos":[-5920,-3136],"params":["Inherit","True","Global Ambient (Amplify Shader Editor)","-1","","61391","2ba15a2d50724194cb38a2ebb214fec5","0","0","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":48,"pos":[-5856,-2912],"params":["Inherit","False","Ambient Blend Factor","-1","True","1","0","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":624,"pos":[-5472,-3136],"params":["Inherit","True","Weighted Ambient (Amplify Shader Editor)","-1","","61392","c74b4378eb191434689832628f4ac715","0","2","2","FLOAT3","0,0,0","False","3","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":144,"pos":[-5056,-3136],"params":["Inherit","False","Weighted Ambient","-1","True","1","0","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":252,"pos":[-7680,-6528],"params":["Inherit","False","1024.206","1407.06","Surface Options","15","323","227","228","510","224","225","232","226","231","230","229","221","248","223","629","","0,1,0,1","0","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":145,"pos":[-7104,-2624],"params":["Inherit","False","144","Weighted Ambient","1","0","OBJECT","","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":11,"pos":[-7040,-2432],"params":["Inherit","False","Property","_Color","Diffuse","0","1","[Header]","Create","False","1","Material Color","0","0","False","0","False","Object","-1","","0.8,0.8,0.8,0","1,0,0,0","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":626,"pos":[-6720,-2592],"params":["Inherit","True","Balanced Diffuse (Amplify Shader Editor)","-1","","61393","b9d74c6ebcf90ea4dba95e1f0d9a6f0b","0","4","22","FLOAT3","0.6,0.6,0.6","False","23","FLOAT3","0,0,0","False","20","COLOR","1,1,1,0","False","21","COLOR","0.8,0.8,0.8,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":223,"pos":[-7648,-6464],"params":["Inherit","True","Property","_Surface","Surface Type","22","1","[HideInInspector]","Create","False","0","0","0","True","0","False","Object","-1","","0","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.Vector3Node, AmplifyShaderEditor","id":292,"pos":[-5408,-4032],"params":["Inherit","True","Property","_ToonTone","Toon Tone","19","0","Create","False","0","0","0","False","0","False","Object","-1","","1,0.5,0.5","1,0.5,0.5","0","4","FLOAT3","0","FLOAT","1","FLOAT","2","FLOAT","3"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":631,"pos":[-5472,-3680],"params":["Inherit","True","N dot L (Amplify Shader Editor)","-1","","61394","96e0e28ec623e134ba66ab21882969ae","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.WireNode, AmplifyShaderEditor","id":601,"pos":[-6256,-2256],"params":["Inherit","False","Tensions","1","1","1","0","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":207,"pos":[-6208,-2528],"params":["Inherit","True","Property","_EFFECTS","Effects","9","2","[Header]","[Enum]","Create","False","1","Texture (Memo)","4","Disabled","0","Add Sphere","1","Multi Sphere","2","Sub Tex","3","0","False","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":627,"pos":[-6496,-2080],"params":["Inherit","True","Sphere Map UV (Amplify Shader Editor)","-1","","61395","5f56ef3cc5ba0704c81e1b4a6eaa4beb","0","0","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":633,"pos":[-5152,-4032],"params":["Inherit","True","Light Calculation (Amplify Shader Editor)","-1","","61396","af01f53e0d9e3474ca896a09a7abf366","0","2","19","FLOAT3","1,0.5,0.5","False","20","FLOAT","0","False","4","FLOAT","0","FLOAT","17","FLOAT","22","FLOAT3","18"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":307,"pos":[-5728,-3424],"params":["Inherit","True","Property","_MultipleLights","Multiple Lights","20","1","[ToggleUI]","Create","True","0","0","0","False","0","False","Object","-1","","1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":248,"pos":[-7456,-6464],"params":["Inherit","False","Sgurface","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":56,"pos":[-6112,-1824],"params":["Inherit","True","Property","_SPHOpacity","SPH Opacity","16","0","Create","True","0","0","0","False","0","False","Object","-1","","1","1","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.WireNode, AmplifyShaderEditor","id":602,"pos":[-5808,-2128],"params":["Inherit","False","Tensions","1","1","1","0","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":289,"pos":[-5984,-2528],"params":["Inherit","False","Layer","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":40,"pos":[-6112,-2080],"params":["Inherit","True","Property","_SphereCube","SPH","12","1","[NoScaleOffset]","Create","False","0","0","0","False","0","False","","-1","None","None","True","0","False","white","LockedToCube","False","Object","-1","Auto","Cube","False","8","0","SAMPLERCUBE","","False","1","FLOAT3","0,0,0","False","2","FLOAT","0","False","3","FLOAT3","0,0,0","False","4","FLOAT3","0,0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor","id":478,"pos":[-6048,-1568],"params":["Inherit","True","Property","_SubTex","SPH SubTex","14","0","Create","False","0","0","0","False","0","False","","None","None","False","white","Auto","Texture2D","False","-1","0","2","SAMPLER2D","0","SAMPLERSTATE","1"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":16,"pos":[-5504,-1152],"params":["Inherit","True","Property","_Opaque","Opaque","3","0","Create","True","0","0","0","False","0","False","Object","-1","","1","1","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":410,"pos":[-5408,-1280],"params":["Inherit","False","289","Layer","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":249,"pos":[-5344,-896],"params":["Inherit","False","248","Sgurface","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":227,"pos":[-7648,-5376],"params":["Float","True","Property","_Cutoff","Alpha Cutoff","31","1","[HideInInspector]","Fetch","False","0","0","0","True","0","False","Object","-1","","0.5","0.669","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":228,"pos":[-7552,-5664],"params":["Inherit","True","Property","_AlphaClip","Alpha Clip","30","1","[HideInInspector]","Fetch","False","0","0","0","True","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.WireNode, AmplifyShaderEditor","id":591,"pos":[-4272,-4144],"params":["Inherit","False","Tensions","1","1","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":429,"pos":[-4416,-4992],"params":["Inherit","True","Property","_SShad","S-Shad","5","2","[Header]","[ToggleUI]","Create","True","1","Rendering","0","0","False","0","False","Object","-1","","1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":47,"pos":[-4736,-4800],"params":["Inherit","True","Property","_ShadowLum","Shadow Luminescence","17","0","Create","False","0","0","0","False","0","False","Object","-1","","1.5","1.5","0","10","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor","id":558,"pos":[-4576,-4544],"params":["Inherit","True","Property","_ToonTex","Toon","11","1","[NoScaleOffset]","Create","False","0","0","0","False","0","False","","None","f35b8759e2061eb469494abb58b512c1","False","white","Auto","Texture2D","False","-1","0","2","SAMPLER2D","0","SAMPLERSTATE","1"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":632,"pos":[-4736,-4288],"params":["Inherit","True","Toon Shadow Mask (Amplify Shader Editor)","-1","","61397","d4c61b1560e7f524485e042d9cbfa12f","0","1","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":639,"pos":[-5472,-3424],"params":["Inherit","True","Additional Lights (Amplify Shader Editor)","-1","","61398","0903e89e038650f4c8f73f079567a741","0","2","15","FLOAT","1","False","13","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":628,"pos":[-5568,-2080],"params":["Inherit","True","Sphere Map Blend (Amplify Shader Editor)","-1","","61403","40c32954e5f9d9046ae98d6e4ad2a766","0","7","38","FLOAT","0","False","40","FLOAT","0","False","45","FLOAT3","1,1,1","False","43","COLOR","1,1,1,1","False","44","FLOAT","1","False","47","SAMPLER2D","1,1,1,1","False","42","COLOR","1,1,1,1","False","3","COLOR","0","COLOR","1","FLOAT","37"]}
{"type":"AmplifyShaderEditor.IntegerNode, AmplifyShaderEditor","id":640,"pos":[-5952,-2400],"params":["Inherit","True","Property","_UVLayer","UV Layer","13","1","[Enum]","Create","True","0","4","Layer 1","0","Layer 2","1","Layer 3","2","Layer 4","3","0","False","0","False","Object","-1","","0","0","False","0","0","0","1","INT","0"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":10,"pos":[-6112,-1344],"params":["Inherit","True","Property","_MainTex","Texture","10","0","Create","False","1","Texture (Memo)","0","0","False","0","False","","-1","None","73029f145f0f8b2469831e89ee17037b","True","0","False","white","Auto","False","Object","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":139,"pos":[-7264,-2816],"params":["Half","False","Global Light Scale","-1","True","1","0","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":630,"pos":[-5056,-1440],"params":["Inherit","True","Transparency Control (Amplify Shader Editor)","-1","","61407","6d43ae7b10f2e8e4ca2eeb598d02c48d","0","5","16","FLOAT","1","False","15","COLOR","1,1,1,1","False","17","FLOAT","0","False","18","FLOAT","1","False","19","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":122,"pos":[-3808,-2816],"params":["Inherit","True","Property","_Shininess","Reflection","4","0","Create","False","0","0","0","False","0","False","Object","-1","","50","50","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":635,"pos":[-4192,-4672],"params":["Inherit","True","Toon Ramp Shadow (Amplify Shader Editor)","-1","","61408","12d15763f50b8154696c9a4946cb6844","0","5","23","FLOAT","1","False","25","FLOAT","1.5","False","26","SAMPLER2D","0","False","29","FLOAT","0","False","22","FLOAT","0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":637,"pos":[-4736,-3904],"params":["Inherit","True","Baked LightMap Contribution (Amplify Shader Editor)","-1","","61409","b0308fde66b3df54883fd907b3a91063","0","1","12","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":629,"pos":[-7328,-5664],"params":["Inherit","True","Alpha Clip Threshold (Amplify Shader Editor)","-1","","61411","171eab994f1a2214cbab7964a5267fe1","0","2","7","FLOAT","0","False","6","FLOAT","0.5","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":268,"pos":[-5088,-3424],"params":["Inherit","False","Additional Lights","-1","True","1","0","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":275,"pos":[-6592,-5824],"params":["Inherit","False","1184.906","701.7709","Outline","6","498","612","201","208","438","636","","0,1,0,1","0","0"]}
{"type":"AmplifyShaderEditor.WireNode, AmplifyShaderEditor","id":606,"pos":[-2416,-1744],"params":["Inherit","False","Tensions","1","1","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.WireNode, AmplifyShaderEditor","id":604,"pos":[-3792,-2976],"params":["Inherit","False","Tensions","1","1","1","0","COLOR","0,0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":82,"pos":[-3488,-2560],"params":["Inherit","False","Property","_Specular","Specular","1","0","Create","True","0","0","0","False","0","False","Object","-1","","0,0,0,0","0.6,0.2,0.6,0","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.WireNode, AmplifyShaderEditor","id":605,"pos":[-3792,-2896],"params":["Inherit","False","Tensions","1","1","1","0","COLOR","0,0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.WireNode, AmplifyShaderEditor","id":603,"pos":[-3536,-3376],"params":["Inherit","False","Tensions","1","1","1","0","COLOR","0,0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.WireNode, AmplifyShaderEditor","id":609,"pos":[-3760,-3312],"params":["Inherit","False","Tensions","1","1","1","0","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":176,"pos":[-2944,-3072],"params":["Inherit","False","139","Global Light Scale","1","0","OBJECT","","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":370,"pos":[-2912,-2112],"params":["Inherit","True","Property","_HDR","HDR","18","0","Create","True","0","0","0","False","0","False","Object","-1","","1","1","1","1000","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":634,"pos":[-3584,-2816],"params":["Inherit","True","Blinn Phong Specular (Amplify Shader Editor)","-1","","61412","0d9f1343fd295844e9ab4da8a467178a","0","1","14","FLOAT","50","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":88,"pos":[-3552,-2304],"params":["Inherit","True","Property","_SpecularIntensity","Specular Intensity","15","1","[Header]","Create","True","1","Custom Effects Settings","0","0","False","0","False","Object","-1","","1","1","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":323,"pos":[-6912,-5664],"params":["Inherit","False","Alpha Clip Threshold","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":197,"pos":[-3392,-1920],"params":["Inherit","False","48","Ambient Blend Factor","1","0","OBJECT","","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":196,"pos":[-3488,-2048],"params":["Inherit","False","268","Additional Lights","1","0","OBJECT","","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.StickyNoteNode, AmplifyShaderEditor","id":342,"pos":[-5344,-6112],"params":["Inherit","False","575.6002","991.2004","Notes","","1,1,0,1","==Material Color==\nDiffuse = Material color.\n\nSpecular = Color of light reflection/glow.\n\nAmbient = (It affects the model's color and lighting too so I think it's like a raycast)\n\nOpaque = Alpha value.\n\nReflection = Reflection value.\n\n==Rendering==\n2-SIDE = Renders both sides of the mesh. [Equivalent to Render Face/_Cull]\n\nG-SHAD = Shadow on the ground. [Equivalent to Cast Shadows/ShaderPass\"SHADOWCASTER\"]\n\nS-MAP = Shadow on the mesh. (Including herself) [Equivalent to Receive Shadows/_ReceiveShadows/Keyword\"_RECEIVE_SHADOWS_OFF\"]\n\nS-SHAD = Receives shade only from himself.\n\n==Edge (Outline)==\nOn = Activate the outline.\n\nColor = Contour color including transparesis.\n\nSize = Outline size/distance.\n\n==Texture/Memo==\nTexture = Material texture.\n\nToon = Complements the remains of the object.\n\nSPH = Artificial reflection to compromise Specular.\n\n***Effects***\nIt uses the SPH texture.\n\nDisabled = does not do anything.\n\nMulti-Sphere = It multiplies a glowing sphere map. (It gives me a feeling of being a metallic reflection)\n\nAdd-Sphere = It creates a glowing sphere map. (It gives me a feeling of being a reflection of practical)\n\nSub-Tex = It changes the SPH from 'Cube Texture' to 'Texture' to allow the use of Subtexture to place more than one texture on the same material.\nThe new texture is applied to another UV Layer allowing the creation of more complex effects. (This function replaces Add-Sphere and Multi-Sphere)","0","0"]}
{"type":"AmplifyShaderEditor.WireNode, AmplifyShaderEditor","id":607,"pos":[-1776,-2640],"params":["Inherit","False","Tensions","1","1","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":325,"pos":[-1632,-2624],"params":["Inherit","False","323","Alpha Clip Threshold","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":612,"pos":[-6304,-5760],"params":["Inherit","False","248","Sgurface","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":224,"pos":[-7200,-6464],"params":["Inherit","True","Property","_Blend","Blending Mode","23","1","[HideInInspector]","Create","False","0","0","0","True","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":225,"pos":[-6976,-6464],"params":["Inherit","True","Property","_Cull","Render Face","24","1","[HideInInspector]","Create","False","0","0","0","True","0","False","Object","-1","","2","2","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":232,"pos":[-7648,-6208],"params":["Inherit","True","Property","_SrcBlend","Src Blend (Auto)","25","1","[HideInInspector]","Create","False","0","0","0","True","0","False","Object","-1","","1","5","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":226,"pos":[-7424,-6208],"params":["Inherit","True","Property","_DstBlend","Dst Blend (Auto)","26","1","[HideInInspector]","Create","False","0","0","0","True","0","False","Object","-1","","0","10","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":230,"pos":[-7168,-6208],"params":["Inherit","True","Property","_ZWriteControl","Depth Write Mode","27","1","[HideInInspector]","Create","False","0","0","0","True","0","False","Object","-1","","1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":231,"pos":[-6912,-6208],"params":["Inherit","True","Property","_ZWrite","ZWrite (Internal)","28","1","[HideInInspector]","Create","False","0","0","0","True","0","False","Object","-1","","1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":229,"pos":[-7648,-5952],"params":["Inherit","True","Property","_ZTest","Depth Test","29","1","[HideInInspector]","Create","False","0","0","0","True","0","False","Object","-1","","4","4","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":221,"pos":[-7424,-5952],"params":["Inherit","True","Property","_CastShadows","Cast Shadows","32","1","[HideInInspector]","Create","False","0","0","0","True","0","False","Object","-1","","1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor","id":510,"pos":[-7200,-5952],"params":["Inherit","True","Property","_Fog","Fog","21","0","Create","True","0","0","0","True","0","False","","1","1","1","True","_FOG_ON","Toggle","2","Key0","Key1","Create","False","False","All","False","False","True","False","0","9","1","FLOAT","0","False","0","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","4","FLOAT","0","False","5","FLOAT","0","False","6","FLOAT","0","False","7","FLOAT","0","False","8","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":438,"pos":[-6560,-5696],"params":["Inherit","True","Property","_On","On","6","2","[Header]","[ToggleUI]","Create","True","1","Edge (Outline)","0","0","False","0","False","Object","-1","","0","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":208,"pos":[-6560,-5440],"params":["Inherit","False","Property","_OutlineColor","Color","7","0","Create","False","0","0","0","False","0","False","Object","-1","","0,0,0,1","0,0,0,0.5019608","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":201,"pos":[-6272,-5376],"params":["Inherit","True","Property","_EdgeSize","Size","8","0","Create","False","0","0","0","False","0","False","Object","-1","","0","0.1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":636,"pos":[-6048,-5632],"params":["Inherit","True","Outline Control (Amplify Shader Editor)","-1","","61413","9b89aaf063c597e47936ca5e506b1b8f","0","4","28","FLOAT","0","False","32","FLOAT","0","False","25","COLOR","0,0,0,1","False","24","FLOAT","0","False","3","FLOAT3","29","FLOAT","0","FLOAT3","30"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":638,"pos":[-2592,-2816],"params":["Inherit","True","Final Lighting Composition (Amplify Shader Editor)","-1","","61414","cc1fc2fda045d8b4aa23e1107f6b1fd6","0","11","29","FLOAT3","0.6,0.6,0.6","False","31","COLOR","0,0,0,0","False","28","FLOAT3","0,0,0","False","37","COLOR","0,0,0,0","False","32","COLOR","0,0,0,0","False","33","FLOAT","0","False","34","COLOR","0,0,0,0","False","35","FLOAT","1","False","38","FLOAT3","0,0,0","False","39","FLOAT3","0,0,0","False","41","FLOAT","1","False","1","COLOR","0"]}
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
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":615,"pos":[-1376,-2696],"params":["Float","False","False","-1","3","UnityEditor.ShaderGraphUnlitGUI","0","1","New Amplify Shader","2992e84f91cbeb14eab234972e07ea9d","True","GBuffer","0","12","GBuffer","0","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","True","1","False","","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Unlit","True","5","True","14","all","0","True","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","True","","True","3","True","","True","True","0","False","","0","False","","False","True","1","LightMode=UniversalGBuffer","False","True","12","d3d11","gles","metal","vulkan","xboxone","xboxseries","playstation","ps4","ps5","switch","switch2","webgpu","0","False","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":499,"pos":[-1376,-2816],"params":["Float","False","True","-1","2","MMDCollection.ShaderMMD.MMDMaterial_ASE","0","19","MMD Collection/URP/MMD (Amplify Shader Editor)","2992e84f91cbeb14eab234972e07ea9d","True","Unlit","0","1","Unlit","12","True","True","1","1","True","_SrcBlend","0","True","_DstBlend","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","True","True","0","True","_Cull","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","True","1","False","","True","5","RenderPipeline=UniversalPipeline","RenderType=_Surface=RenderType","Queue=Overlay=Queue=-2000","UniversalMaterialType=Unlit","AlwaysRenderMotionVectors=false","True","7","True","14","all","0","True","0","False","","True","True","1","1","True","_SrcBlend","0","True","_DstBlend","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","True","True","1","True","_ZWrite","True","3","True","_ZTest","True","True","0","False","","0","False","","False","True","1","LightMode=UniversalForwardOnly","False","False","7","Include","","False","","Native","False","0","0","","Pragma","multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE","False","","Custom","False","0","0","","Pragma","multi_compile_fragment _ _SHADOWS_SOFT","False","","Custom","False","0","0","","Pragma","multi_compile _ SHADOWS_SHADOWMASK","False","","Custom","False","0","0","","Custom","#ifndef _FOG_ON","False","","Custom","False","0","0","","Custom","#undef ASE_FOG","False","","Custom","False","0","0","","Custom","#endif","False","","Custom","False","0","0","","False","Universal Render Pipeline/Unlit","0","0","Standard","38","Surface","0","0","  Keep Alpha","1","639051702240721720","  Blend","0","0","Double-Sided","0","0","Alpha Clipping","2","639051685394695303","  Use Shadow Threshold","0","0","Fragment Normal Space","0","0","Forward Only","0","0","Cast Shadows","1","0","Receive Shadows","2","639051685057082009","Default Decal Blending","1","0","Motion Vectors","0","638670679113611176","  Additional Motion Vectors","1","0","  Alembic Motion Vectors","0","0","  XR Motion Vectors","0","0","Meta Pass","0","0","Extra Pre Pass","1","638670624603007853","Tessellation","0","0","  Phong","0","0","  Strength","0.5,False,","0","  Type","0","0","  Tess","16,False,","0","  Min","10,False,","0","  Max","25,False,","0","  Edge Length","20,False,","0","  Max Displacement","25,False,","0","Write Depth","0","0","  Conservative","0","0","Vertex Position","1","0","Rendering Layers","1","0","Decals","1","0","Receive SSAO","1","0","Debug Display","1","0","GPU Instancing","1","0","DOTS Instancing","1","0","LOD CrossFade","1","0","Built-in Fog","1","639308852304843522","  Receive Fog","0","0","0","13","ExtraPrePass","True","Unlit","True","ShadowCaster","True","DepthOnly","True","Meta","False","Universal2D","False","SceneSelectionPass","True","ScenePickingPass","True","DepthNormals","True","DepthNormalsOnly","False","MotionVectors","False","XRMotionVectors","False","GBuffer","True","False","","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":498,"pos":[-5664,-5632],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphUnlitGUI","0","19","New Amplify Shader","2992e84f91cbeb14eab234972e07ea9d","True","ExtraPrePass","0","0","OutlinePass","6","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","True","1","False","","True","5","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Unlit","AlwaysRenderMotionVectors=false","True","5","True","14","all","0","True","0","False","","True","False","False","False","False","False","False","False","False","False","False","False","False","True","True","1","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","True","True","1","True","_On","True","3","True","_ZTest","True","True","0","False","","0","False","","False","True","0","False","False","4","Include","","False","","Native","False","0","0","","Custom","#ifndef _FOG_ON","False","","Custom","False","0","0","","Custom","#undef ASE_FOG","False","","Custom","False","0","0","","Custom","#endif","False","","Custom","False","0","0","","False","","0","0","Standard","0","False","0"]}
{"wire":[621,12,625,1]}
{"wire":[621,11,625,2]}
{"wire":[621,13,28,0]}
{"wire":[622,7,621,0]}
{"wire":[48,0,622,0]}
{"wire":[624,2,623,0]}
{"wire":[624,3,48,0]}
{"wire":[144,0,624,0]}
{"wire":[626,22,139,0]}
{"wire":[626,23,145,0]}
{"wire":[626,20,28,0]}
{"wire":[626,21,11,0]}
{"wire":[601,0,626,0]}
{"wire":[633,19,292,0]}
{"wire":[633,20,631,0]}
{"wire":[248,0,223,0]}
{"wire":[602,0,601,0]}
{"wire":[289,0,207,0]}
{"wire":[40,1,627,0]}
{"wire":[591,0,633,22]}
{"wire":[632,1,633,22]}
{"wire":[639,15,307,0]}
{"wire":[639,13,623,0]}
{"wire":[628,38,289,0]}
{"wire":[628,40,640,0]}
{"wire":[628,45,602,0]}
{"wire":[628,43,40,0]}
{"wire":[628,44,56,0]}
{"wire":[628,47,478,0]}
{"wire":[628,42,10,0]}
{"wire":[139,0,625,0]}
{"wire":[630,16,628,37]}
{"wire":[630,15,10,0]}
{"wire":[630,17,410,0]}
{"wire":[630,18,16,0]}
{"wire":[630,19,249,0]}
{"wire":[635,23,429,0]}
{"wire":[635,25,47,0]}
{"wire":[635,26,558,0]}
{"wire":[635,29,632,0]}
{"wire":[635,22,591,0]}
{"wire":[637,12,633,18]}
{"wire":[629,7,228,0]}
{"wire":[629,6,227,0]}
{"wire":[268,0,639,0]}
{"wire":[606,0,630,0]}
{"wire":[604,0,628,0]}
{"wire":[605,0,628,1]}
{"wire":[603,0,635,0]}
{"wire":[609,0,637,0]}
{"wire":[634,14,122,0]}
{"wire":[323,0,629,0]}
{"wire":[607,0,606,0]}
{"wire":[636,28,612,0]}
{"wire":[636,32,438,0]}
{"wire":[636,25,208,0]}
{"wire":[636,24,201,0]}
{"wire":[638,29,176,0]}
{"wire":[638,31,603,0]}
{"wire":[638,28,609,0]}
{"wire":[638,37,604,0]}
{"wire":[638,32,605,0]}
{"wire":[638,33,634,0]}
{"wire":[638,34,82,0]}
{"wire":[638,35,88,0]}
{"wire":[638,38,196,0]}
{"wire":[638,39,197,0]}
{"wire":[638,41,370,0]}
{"wire":[499,2,638,0]}
{"wire":[499,3,607,0]}
{"wire":[499,4,325,0]}
{"wire":[498,0,636,29]}
{"wire":[498,1,636,0]}
{"wire":[498,3,636,30]}
ASEEND*/
//CHKSM=0CAF41C52B9773FD6CE25A787E2AB23EB0B2AEB0