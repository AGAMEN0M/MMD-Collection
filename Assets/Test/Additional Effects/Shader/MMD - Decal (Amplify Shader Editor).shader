// Made with Amplify Shader Editor v1.9.7
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader  "MMD Collection/URP/Effects/MMD - Decal (Amplify Shader Editor)"
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
        [Header(Texture (Memo))][Enum(Disabled,0,Add Sphere,1,Multi Sphere,2,Sub Tex,3)]_EFFECTS("Effects", Float) = 0
        _MainTex("Texture", 2D) = "white" {}
        [NoScaleOffset]_ToonTex("Toon", 2D) = "white" {}
        [NoScaleOffset]_SphereCube("SPH", CUBE) = "white" {}
        _SubTex("SPH SubTex", 2D) = "white" {}
        [Header(Custom Effects Settings)]_SpecularIntensity("Specular Intensity", Range( 0 , 1)) = 1
        _SPHOpacity("SPH Opacity", Range( 0 , 1)) = 1
        _ShadowLum("Shadow Luminescence", Range( 0 , 10)) = 1.5
        _AddLightBaseColor("Add Light Base Color", Range( 0 , 1)) = 0
        _HDR("HDR", Range( 1 , 1000)) = 1
        _ToonTone("Toon Tone", Vector) = (1,0.5,0.5,0)
        [HideInInspector] _texcoord( "", 2D ) = "white" {}


        [HideInInspector] _DrawOrder("Draw Order", Range(-50, 50)) = 0
        [HideInInspector][Enum(Depth Bias, 0, View Bias, 1)] _DecalMeshBiasType("DecalMesh BiasType", Float) = 0

        [HideInInspector] _DecalMeshDepthBias("DecalMesh DepthBias", Float) = 0
        [HideInInspector] _DecalMeshViewBias("DecalMesh ViewBias", Float) = 0

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}

        [HideInInspector] _DecalAngleFadeSupported("Decal Angle Fade Supported", Float) = 1
    }

    SubShader
    {
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "PreviewType"="Plane" "DisableBatching"="LODFading" "ShaderGraphShader"="true" "ShaderGraphTargetId"="UniversalDecalSubTarget" }

		HLSLINCLUDE
		#pragma target 3.5
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"
		ENDHLSL

		
        Pass
        {
			
            Name "DBufferProjector"
            Tags { "LightMode"="DBufferProjector" }

			Cull Front
			Blend 0 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
			Blend 1 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
			Blend 2 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
			ZTest Greater
			ZWrite Off
			ColorMask RGBA
			ColorMask RGBA 1
			ColorMask RGBA 2

            HLSLPROGRAM

			#define _MATERIAL_AFFECTS_ALBEDO 1
			#define _MATERIAL_AFFECTS_NORMAL 1
			#define _MATERIAL_AFFECTS_NORMAL_BLEND 1
			#define DECAL_ANGLE_FADE 1
			#define ASE_SRP_VERSION 170003


			#pragma vertex Vert
			#pragma fragment Frag

		    #pragma exclude_renderers glcore gles gles3 
			#pragma multi_compile_instancing
			#pragma editor_sync_compilation

			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile _ _DECAL_LAYERS

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #define HAVE_MESH_MODIFICATION
            #define SHADERPASS SHADERPASS_DBUFFER_PROJECTOR

			#if _RENDER_PASS_ENABLED
			#define GBUFFER3 0
			#define GBUFFER4 1
			FRAMEBUFFER_INPUT_X_HALF(GBUFFER3);
			FRAMEBUFFER_INPUT_X_HALF(GBUFFER4);
			#endif

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#include "MMDEffectsCustomNodeScriptAmplifyShaderEditor.hlsl"
			#define ASE_NEEDS_FRAG_NORMAL
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct SurfaceDescription
			{
				float3 BaseColor;
				float Alpha;
				float3 NormalTS;
				float NormalAlpha;
				float Metallic;
				float Occlusion;
				float Smoothness;
				float MAOSAlpha;
			};

			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float4 _Ambient;
			float4 _Color;
			float4 _MainTex_ST;
			float4 _SubTex_ST;
			float4 _Specular;
			float3 _ToonTone;
			float _ShadowLum;
			float _SShad;
			float _AddLightBaseColor;
			float _EFFECTS;
			float _SPHOpacity;
			float _Shininess;
			float _SpecularIntensity;
			float _HDR;
			float _Opaque;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
			#if defined(DECAL_ANGLE_FADE)
			float _DecalAngleFadeSupported;
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


			
            void GetSurfaceData(SurfaceDescription surfaceDescription, float angleFadeFactor, out DecalSurfaceData surfaceData)
            {
                half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);

                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);

                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif

                surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);

                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
						surfaceData.normalWS.xyz = normalize(mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz));
                    #else
						surfaceData.normalWS.xyz = normalize(normalToWorld[2].xyz);
                    #endif
                #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
                        float sgn = input.tangentWS.w;
                        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                        half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
        
                        surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, tangentToWorld));
                    #else
						surfaceData.normalWS.xyz = normalize(half3(input.normalWS));
                    #endif
                #endif

                surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceData.metallic = half(surfaceDescription.Metallic);
					surfaceData.occlusion = half(surfaceDescription.Occlusion);
					surfaceData.smoothness = half(surfaceDescription.Smoothness);
					surfaceData.MAOSAlpha = half(surfaceDescription.MAOSAlpha * fadeFactor);
				#endif
            }

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
            #define DECAL_PROJECTOR
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_MESH
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
            #define DECAL_DBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH)
            #define DECAL_SCREEN_SPACE
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_GBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH)
            #define DECAL_FORWARD_EMISSIVE
            #endif

            #if ((!defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_ALBEDO)) || (defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_NORMAL_BLEND))) && (defined(DECAL_SCREEN_SPACE) || defined(DECAL_GBUFFER))
            #define DECAL_RECONSTRUCT_NORMAL
            #elif defined(DECAL_ANGLE_FADE)
            #define DECAL_LOAD_NORMAL
            #endif

            #ifdef _DECAL_LAYERS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareRenderingLayerTexture.hlsl"
            #endif

            #if defined(DECAL_LOAD_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
            #endif

            #if defined(DECAL_PROJECTOR) || defined(DECAL_RECONSTRUCT_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #endif

            #ifdef DECAL_MESH
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DecalMeshBiasTypeEnum.cs.hlsl"
            #endif

            #ifdef DECAL_RECONSTRUCT_NORMAL
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NormalReconstruction.hlsl"
            #endif

			PackedVaryings Vert(Attributes inputMesh  )
			{
				PackedVaryings packedOutput;
				ZERO_INITIALIZE(PackedVaryings, packedOutput);

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, packedOutput);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(packedOutput);

				inputMesh.tangentOS = float4( 1, 0, 0, -1 );
				inputMesh.normalOS = float3( 0, 1, 0 );

				packedOutput.ase_normal = inputMesh.normalOS;
				packedOutput.ase_texcoord = float4(inputMesh.positionOS,1);

				VertexPositionInputs vertexInput = GetVertexPositionInputs(inputMesh.positionOS.xyz);

				float3 positionWS = TransformObjectToWorld(inputMesh.positionOS);
				packedOutput.positionCS = TransformWorldToHClip(positionWS);

				return packedOutput;
			}

			void Frag(PackedVaryings packedInput,
				OUTPUT_DBUFFER(outDBuffer)
				
			)
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);
				UNITY_SETUP_INSTANCE_ID(packedInput);

				half angleFadeFactor = 1.0;

            #ifdef _DECAL_LAYERS
            #ifdef _RENDER_PASS_ENABLED
				uint surfaceRenderingLayer = DecodeMeshRenderingLayer(LOAD_FRAMEBUFFER_INPUT(GBUFFER4, packedInput.positionCS.xy).r);
            #else
				uint surfaceRenderingLayer = LoadSceneRenderingLayer(packedInput.positionCS.xy);
            #endif
				uint projectorRenderingLayer = uint(UNITY_ACCESS_INSTANCED_PROP(Decal, _DecalLayerMaskFromDecal));
				clip((surfaceRenderingLayer & projectorRenderingLayer) - 0.1);
            #endif

			#if defined(DECAL_PROJECTOR)
			#if UNITY_REVERSED_Z
			#if _RENDER_PASS_ENABLED
				float depth = LOAD_FRAMEBUFFER_X_INPUT(GBUFFER3, packedInput.positionCS.xy).x;
			#else
				float depth = LoadSceneDepth(packedInput.positionCS.xy);
			#endif
			#else
			#if _RENDER_PASS_ENABLED
				float depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, LOAD_FRAMEBUFFER_X_INPUT(GBUFFER3, packedInput.positionCS.xy));
			#else
				float depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, LoadSceneDepth(packedInput.positionCS.xy));
			#endif
			#endif
			#endif

				#if defined(DECAL_RECONSTRUCT_NORMAL)
					#if defined(_DECAL_NORMAL_BLEND_HIGH)
						half3 normalWS = half3(ReconstructNormalTap9(packedInput.positionCS.xy));
					#elif defined(_DECAL_NORMAL_BLEND_MEDIUM)
						half3 normalWS = half3(ReconstructNormalTap5(packedInput.positionCS.xy));
					#else
						half3 normalWS = half3(ReconstructNormalDerivative(packedInput.positionCS.xy));
					#endif
				#elif defined(DECAL_LOAD_NORMAL)
					half3 normalWS = half3(LoadSceneNormals(packedInput.positionCS.xy));
				#endif

				float2 positionSS = FoveatedRemapNonUniformToLinearCS(packedInput.positionCS.xy) * _ScreenSize.zw;

				float3 positionWS = ComputeWorldSpacePosition(positionSS, depth, UNITY_MATRIX_I_VP);


				float3 positionDS = TransformWorldToObject(positionWS);
				positionDS = positionDS * float3(1.0, -1.0, 1.0);

				float clipValue = 0.5 - Max3(abs(positionDS).x, abs(positionDS).y, abs(positionDS).z);
				clip(clipValue);

				float2 texCoord = positionDS.xz + float2(0.5, 0.5);

				float4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
				float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
				float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
				texCoord.xy = texCoord.xy * scale + offset;

				float2 texCoord0 = texCoord;
				float2 texCoord1 = texCoord;
				float2 texCoord2 = texCoord;
				float2 texCoord3 = texCoord;

				float3 worldTangent = TransformObjectToWorldDir(float3(1, 0, 0));
				float3 worldNormal = TransformObjectToWorldDir(float3(0, 1, 0));
				float3 worldBitangent = TransformObjectToWorldDir(float3(0, 0, 1));

				#ifdef DECAL_ANGLE_FADE
					half2 angleFade = half2(normalToWorld[1][3], normalToWorld[2][3]);

					if (angleFade.y < 0.0f)
					{
						half3 decalNormal = half3(normalToWorld[0].z, normalToWorld[1].z, normalToWorld[2].z);
						half dotAngle = dot(normalWS, decalNormal);
						angleFadeFactor = saturate(angleFade.x + angleFade.y * (dotAngle * (dotAngle - 2.0)));
					}
				#endif

				half3 viewDirectionWS = half3(1.0, 1.0, 1.0);
				DecalSurfaceData surfaceData;

				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float4 temp_cast_0 = (1.0).xxxx;
				float4 temp_cast_1 = (1.0).xxxx;
				float3 ToonTone32 = _ToonTone;
				float3 break52 = ToonTone32;
				float3 objToWorldDir84 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_normal, 0 ) ).xyz;
				float3 normalizeResult59 = normalize( objToWorldDir84 );
				float3 normalizeResult60 = normalize( _MainLightPosition.xyz );
				float dotResult62 = dot( normalizeResult59 , normalizeResult60 );
				float NdotL89 = dotResult62;
				float localshadowAtten190 = ( 0.0 );
				float3 objToWorld114 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_texcoord.xyz, 1 ) ).xyz;
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
				float3 originalLightColor174 = ( OutputColor188 + _AddLightBaseColor );
				half3 MMDLIT_GLOBALLIGHTING139 = half3(0.6,0.6,0.6);
				float3 lightColor178 = ( originalLightColor174 * MMDLIT_GLOBALLIGHTING139 );
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
				float3 objToWorldDir141 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_normal, 0 ) ).xyz;
				float3 normal187 = objToWorldDir141;
				float3 Output187 = float3( 0,0,0 );
				vLight_float( normal187 , Output187 );
				float3 appendResult136 = (float3(1.0 , 1.0 , 1.0));
				half3 MMDLIT_CENTERAMBIENT138 = half3(0.5,0.5,0.5);
				float4 break163 = Ambient44;
				float3 appendResult162 = (float3(break163.r , break163.g , break163.b));
				half3 MMDLIT_CENTERAMBIENT_INV171 = ( half3(1,1,1) / 0.5 );
				float3 MMDLit_GetTempAmbientL135 = ( max( ( MMDLIT_CENTERAMBIENT138 - appendResult162 ) , float3(0,0,0) ) * MMDLIT_CENTERAMBIENT_INV171 );
				float3 MMDLit_GetAmbientRate48 = ( appendResult136 - MMDLit_GetTempAmbientL135 );
				float3 MMDLit_GetTempAmbient144 = ( Output187 * MMDLit_GetAmbientRate48 );
				float3 appendResult155 = (float3(0.0 , 0.0 , 0.0));
				float3 MMDLit_GetTempDiffuse160 = max( ( min( ( appendResult150 + ( appendResult152 * MMDLIT_GLOBALLIGHTING139 ) ) , appendResult154 ) - MMDLit_GetTempAmbient144 ) , appendResult155 );
				float2 uv_MainTex = texCoord0 * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 Albedo12 = tex2D( _MainTex, uv_MainTex );
				float4 temp_output_78_0 = ( float4( MMDLit_GetTempDiffuse160 , 0.0 ) * Albedo12 );
				float4 Base399 = temp_output_78_0;
				float3 objToView109 = mul( UNITY_MATRIX_MV, float4( packedInput.ase_texcoord.xyz, 1 ) ).xyz;
				float3 normalizeResult64 = normalize( objToView109 );
				float3 objToViewDir67 = normalize( mul( UNITY_MATRIX_IT_MV, float4( packedInput.ase_normal, 0 ) ).xyz );
				float3 normalizeResult65 = normalize( objToViewDir67 );
				float4 SphereCube37 = texCUBE( _SphereCube, reflect( normalizeResult64 , normalizeResult65 ) );
				float4 temp_output_57_0 = ( SphereCube37 * _SPHOpacity );
				float4 Add399 = ( temp_output_78_0 + temp_output_57_0 );
				float4 temp_output_39_0 = ( temp_output_57_0 * Albedo12 );
				float4 Multi399 = ( temp_output_39_0 * float4( MMDLit_GetTempDiffuse160 , 0.0 ) );
				float2 uv_SubTex = texCoord0 * _SubTex_ST.xy + _SubTex_ST.zw;
				float4 tex2DNode379 = tex2D( _SubTex, uv_SubTex );
				float4 Sub399 = ( float4( MMDLit_GetTempDiffuse160 , 0.0 ) * Albedo12 * tex2DNode379 );
				float4 RGBA399 = float4( 0,0,0,0 );
				effectsControl_float( Layer399 , Base399 , Add399 , Multi399 , Sub399 , RGBA399 );
				float3 objToWorldDir180 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_normal, 0 ) ).xyz;
				float3 normalizeResult181 = normalize( objToWorldDir180 );
				float3 ase_viewVectorWS = ( _WorldSpaceCameraPos.xyz - positionWS );
				float3 ase_viewDirWS = normalize( ase_viewVectorWS );
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
				float4 FinalColor336 = ( ( ( saturate( ( temp_cast_0 - ( _ShadowLum * ( temp_cast_1 - ( _SShad == (float)0 ? tex2DNode92 : lerpResult431 ) ) ) ) ) * float4( lightColor178 , 0.0 ) * RGBA399 ) + ( ( Specular131 * _Specular * float4( lightColor178 , 0.0 ) ) * _SpecularIntensity ) ) + ( baseC73 * float4( MMDLit_GetAmbientRate48 , 0.0 ) ) );
				

				surfaceDescription.BaseColor = ( FinalColor336 * _HDR ).rgb;
				surfaceDescription.Alpha = saturate( ( _Opaque * ( tSphereMapBlend289 == (float)3 ? ( tex2DNode379.a * Albedo12.a ) : Albedo12.a ) ) );
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.NormalAlpha = 1;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceDescription.Metallic = 0;
					surfaceDescription.Occlusion = 1;
					surfaceDescription.Smoothness = 0.5;
					surfaceDescription.MAOSAlpha = 1;
				#endif

				GetSurfaceData(surfaceDescription, angleFadeFactor, surfaceData);
				ENCODE_INTO_DBUFFER(surfaceData, outDBuffer);

			}
            ENDHLSL
        }

		
        Pass
        {
			
            Name "DecalScreenSpaceProjector"
            Tags { "LightMode"="DecalScreenSpaceProjector" }

			Cull Front
			Blend SrcAlpha OneMinusSrcAlpha
			ZTest Greater
			ZWrite Off

			HLSLPROGRAM

			#define _MATERIAL_AFFECTS_ALBEDO 1
			#define _MATERIAL_AFFECTS_NORMAL 1
			#define _MATERIAL_AFFECTS_NORMAL_BLEND 1
			#define DECAL_ANGLE_FADE 1
			#define ASE_SRP_VERSION 170003


			#pragma vertex Vert
			#pragma fragment Frag
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
			#pragma editor_sync_compilation

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
			#pragma multi_compile _ _FORWARD_PLUS
			#pragma multi_compile_fragment _ _LIGHT_COOKIES
			#pragma multi_compile_fragment _ DEBUG_DISPLAY
			#pragma multi_compile _DECAL_NORMAL_BLEND_LOW _DECAL_NORMAL_BLEND_MEDIUM _DECAL_NORMAL_BLEND_HIGH
			#pragma multi_compile _ _DECAL_LAYERS

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_NORMAL_WS
			#define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define VARYINGS_NEED_SH
            #define VARYINGS_NEED_STATIC_LIGHTMAP_UV
            #define VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV

            #define HAVE_MESH_MODIFICATION

            #define SHADERPASS SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR

			#if _RENDER_PASS_ENABLED
			#define GBUFFER3 0
			#define GBUFFER4 1
			FRAMEBUFFER_INPUT_X_HALF(GBUFFER3);
			FRAMEBUFFER_INPUT_X_HALF(GBUFFER4);
			#endif

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"

		    #if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#include "MMDEffectsCustomNodeScriptAmplifyShaderEditor.hlsl"
			#define ASE_NEEDS_FRAG_NORMAL
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct SurfaceDescription
			{
				float3 BaseColor;
				float Alpha;
				float3 NormalTS;
				float NormalAlpha;
				float Metallic;
				float Occlusion;
				float Smoothness;
				float MAOSAlpha;
				float3 Emission;
			};

			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float3 viewDirectionWS : TEXCOORD1;
				float4 lightmapUVs : TEXCOORD2; // @diogo: packs both static (xy) and dynamic (zw)
				float3 sh : TEXCOORD3;
				float4 fogFactorAndVertexLight : TEXCOORD4;
				#ifdef USE_APV_PROBE_OCCLUSION
					float4 probeOcclusion : TEXCOORD5;
				#endif
				float3 ase_normal : NORMAL;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float4 _Ambient;
			float4 _Color;
			float4 _MainTex_ST;
			float4 _SubTex_ST;
			float4 _Specular;
			float3 _ToonTone;
			float _ShadowLum;
			float _SShad;
			float _AddLightBaseColor;
			float _EFFECTS;
			float _SPHOpacity;
			float _Shininess;
			float _SpecularIntensity;
			float _HDR;
			float _Opaque;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
			#if defined(DECAL_ANGLE_FADE)
			float _DecalAngleFadeSupported;
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


			
            void GetSurfaceData(SurfaceDescription surfaceDescription, float angleFadeFactor, out DecalSurfaceData surfaceData)
            {
                half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);

                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);

                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif

				#if defined( _MATERIAL_AFFECTS_EMISSION )
                	surfaceData.emissive.rgb = half3(surfaceDescription.Emission.rgb * fadeFactor);
				#endif

                surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);

                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
						surfaceData.normalWS.xyz = normalize(mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz));
                    #else
						surfaceData.normalWS.xyz = normalize(normalToWorld[2].xyz);
                    #endif
                #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
                        float sgn = input.tangentWS.w;
                        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                        half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
        
                        surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, tangentToWorld));
                    #else
						surfaceData.normalWS.xyz = normalize(half3(input.normalWS));
                    #endif
                #endif

                surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceData.metallic = half(surfaceDescription.Metallic);
					surfaceData.occlusion = half(surfaceDescription.Occlusion);
					surfaceData.smoothness = half(surfaceDescription.Smoothness);
					surfaceData.MAOSAlpha = half(surfaceDescription.MAOSAlpha * fadeFactor);
				#endif
            }

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
            #define DECAL_PROJECTOR
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_MESH
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
            #define DECAL_DBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH)
            #define DECAL_SCREEN_SPACE
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_GBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH)
            #define DECAL_FORWARD_EMISSIVE
            #endif

            #if ((!defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_ALBEDO)) || (defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_NORMAL_BLEND))) && (defined(DECAL_SCREEN_SPACE) || defined(DECAL_GBUFFER))
            #define DECAL_RECONSTRUCT_NORMAL
            #elif defined(DECAL_ANGLE_FADE)
            #define DECAL_LOAD_NORMAL
            #endif

            #ifdef _DECAL_LAYERS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareRenderingLayerTexture.hlsl"
            #endif

            #if defined(DECAL_LOAD_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
            #endif

            #if defined(DECAL_PROJECTOR) || defined(DECAL_RECONSTRUCT_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #endif

            #ifdef DECAL_MESH
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DecalMeshBiasTypeEnum.cs.hlsl"
            #endif

            #ifdef DECAL_RECONSTRUCT_NORMAL
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NormalReconstruction.hlsl"
            #endif

			void InitializeInputData(PackedVaryings input, float3 positionWS, half3 normalWS, half3 viewDirectionWS, out InputData inputData)
			{
				inputData = (InputData)0;

				inputData.positionWS = positionWS;
				inputData.normalWS = normalWS;
				inputData.viewDirectionWS = viewDirectionWS;
				inputData.shadowCoord = float4(0, 0, 0, 0);

				#ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
					inputData.fogCoord = InitializeInputDataFog(float4(positionWS, 1.0), input.fogFactorAndVertexLight.x);
					inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
				#endif

				#if defined(VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV) && defined(DYNAMICLIGHTMAP_ON)
					inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV.xy, half3(input.sh), normalWS);
					#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
					inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
					#endif
				#elif defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
				#if !defined(LIGHTMAP_ON) && (defined(PROBE_VOLUMES_L1) || defined(PROBE_VOLUMES_L2))
    				inputData.bakedGI = SAMPLE_GI(input.sh,
					GetAbsolutePositionWS(inputData.positionWS),
					inputData.normalWS,
					inputData.viewDirectionWS,
					input.positionCS.xy,
					input.probeOcclusion,
					inputData.shadowMask);
				#else
					inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, half3(input.sh), normalWS);
					#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
					inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
					#endif
				#endif
				#endif

				#if defined(DEBUG_DISPLAY)
					#if defined(VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV) && defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = input.dynamicLightmapUV.xy;
					#endif
					#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV) && defined(LIGHTMAP_ON)
						inputData.staticLightmapUV = input.staticLightmapUV
					#elif defined(VARYINGS_NEED_SH)
						inputData.vertexSH = input.sh;
					#endif
					#if defined(USE_APV_PROBE_OCCLUSION)
						inputData.probeOcclusion = input.probeOcclusion;
					#endif
				#endif

				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
			}

			void GetSurface(DecalSurfaceData decalSurfaceData, inout SurfaceData surfaceData)
			{
				surfaceData.albedo = decalSurfaceData.baseColor.rgb;
				surfaceData.metallic = saturate(decalSurfaceData.metallic);
				surfaceData.specular = 0;
				surfaceData.smoothness = saturate(decalSurfaceData.smoothness);
				surfaceData.occlusion = decalSurfaceData.occlusion;
				surfaceData.emission = decalSurfaceData.emissive;
				surfaceData.alpha = saturate(decalSurfaceData.baseColor.w);
				surfaceData.clearCoatMask = 0;
				surfaceData.clearCoatSmoothness = 1;
			}

			PackedVaryings Vert(Attributes inputMesh  )
			{
				PackedVaryings packedOutput;
				ZERO_INITIALIZE(PackedVaryings, packedOutput);

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, packedOutput);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(packedOutput);

				inputMesh.tangentOS = float4( 1, 0, 0, -1 );
				inputMesh.normalOS = float3( 0, 1, 0 );

				packedOutput.ase_normal = inputMesh.normalOS;
				packedOutput.ase_texcoord6 = float4(inputMesh.positionOS,1);

				VertexPositionInputs vertexInput = GetVertexPositionInputs(inputMesh.positionOS.xyz);
				float3 positionWS = TransformObjectToWorld(inputMesh.positionOS);

				float3 normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);

				packedOutput.positionCS = TransformWorldToHClip(positionWS);

				half fogFactor = 0;
				#if !defined(_FOG_FRAGMENT)
					fogFactor = ComputeFogFactor(packedOutput.positionCS.z);
				#endif
				half3 vertexLight = VertexLighting(positionWS, normalWS);
				packedOutput.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

				packedOutput.normalWS.xyz =  normalWS;
				packedOutput.viewDirectionWS.xyz =  GetWorldSpaceViewDir(positionWS);

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV(inputMesh.uv1, unity_LightmapST, packedOutput.staticLightmapUV);
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					packedOutput.dynamicLightmapUV.xy = inputMesh.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if !defined(LIGHTMAP_ON)
					packedOutput.sh.xyz =  float3(SampleSHVertex(half3(normalWS)));
				#endif

				return packedOutput;
			}

			void Frag(PackedVaryings packedInput,
				out half4 outColor : SV_Target0
				
			)
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);
				UNITY_SETUP_INSTANCE_ID(packedInput);

				half angleFadeFactor = 1.0;

            #ifdef _DECAL_LAYERS
            #ifdef _RENDER_PASS_ENABLED
				uint surfaceRenderingLayer = DecodeMeshRenderingLayer(LOAD_FRAMEBUFFER_INPUT(GBUFFER4, packedInput.positionCS.xy).r);
            #else
				uint surfaceRenderingLayer = LoadSceneRenderingLayer(packedInput.positionCS.xy);
            #endif
				uint projectorRenderingLayer = uint(UNITY_ACCESS_INSTANCED_PROP(Decal, _DecalLayerMaskFromDecal));
				clip((surfaceRenderingLayer & projectorRenderingLayer) - 0.1);
            #endif

			#if defined(DECAL_PROJECTOR)
			#if UNITY_REVERSED_Z
			#if _RENDER_PASS_ENABLED
				float depth = LOAD_FRAMEBUFFER_X_INPUT(GBUFFER3, packedInput.positionCS.xy).x;
			#else
				float depth = LoadSceneDepth(packedInput.positionCS.xy);
			#endif
			#else
			#if _RENDER_PASS_ENABLED
				float depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, LOAD_FRAMEBUFFER_X_INPUT(GBUFFER3, packedInput.positionCS.xy));
			#else
				float depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, LoadSceneDepth(packedInput.positionCS.xy));
			#endif
			#endif
			#endif

				#if defined(DECAL_RECONSTRUCT_NORMAL)
					#if defined(_DECAL_NORMAL_BLEND_HIGH)
						half3 normalWS = half3(ReconstructNormalTap9(packedInput.positionCS.xy));
					#elif defined(_DECAL_NORMAL_BLEND_MEDIUM)
						half3 normalWS = half3(ReconstructNormalTap5(packedInput.positionCS.xy));
					#else
						half3 normalWS = half3(ReconstructNormalDerivative(packedInput.positionCS.xy));
					#endif
				#elif defined(DECAL_LOAD_NORMAL)
					half3 normalWS = half3(LoadSceneNormals(packedInput.positionCS.xy));
				#endif

				float2 positionSS = FoveatedRemapNonUniformToLinearCS(packedInput.positionCS.xy) * _ScreenSize.zw;

				float3 positionWS = ComputeWorldSpacePosition(positionSS, depth, UNITY_MATRIX_I_VP);

				float3 positionDS = TransformWorldToObject(positionWS);
				positionDS = positionDS * float3(1.0, -1.0, 1.0);

				float clipValue = 0.5 - Max3(abs(positionDS).x, abs(positionDS).y, abs(positionDS).z);
				clip(clipValue);

				float2 texCoord = positionDS.xz + float2(0.5, 0.5);

				float4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
				float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
				float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
				texCoord.xy = texCoord.xy * scale + offset;

				float2 texCoord0 = texCoord;
				float2 texCoord1 = texCoord;
				float2 texCoord2 = texCoord;
				float2 texCoord3 = texCoord;

				float3 worldTangent = TransformObjectToWorldDir(float3(1, 0, 0));
				float3 worldNormal = TransformObjectToWorldDir(float3(0, 1, 0));
				float3 worldBitangent = TransformObjectToWorldDir(float3(0, 0, 1));

				#ifdef DECAL_ANGLE_FADE
					half2 angleFade = half2(normalToWorld[1][3], normalToWorld[2][3]);

					if (angleFade.y < 0.0f)
					{
						half3 decalNormal = half3(normalToWorld[0].z, normalToWorld[1].z, normalToWorld[2].z);
						half dotAngle = dot(normalWS, decalNormal);
						angleFadeFactor = saturate(angleFade.x + angleFade.y * (dotAngle * (dotAngle - 2.0)));
					}
				#endif

				half3 viewDirectionWS = half3(packedInput.viewDirectionWS);

				DecalSurfaceData surfaceData;

				float4 temp_cast_0 = (1.0).xxxx;
				float4 temp_cast_1 = (1.0).xxxx;
				float3 ToonTone32 = _ToonTone;
				float3 break52 = ToonTone32;
				float3 objToWorldDir84 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_normal, 0 ) ).xyz;
				float3 normalizeResult59 = normalize( objToWorldDir84 );
				float3 normalizeResult60 = normalize( _MainLightPosition.xyz );
				float dotResult62 = dot( normalizeResult59 , normalizeResult60 );
				float NdotL89 = dotResult62;
				float localshadowAtten190 = ( 0.0 );
				float3 objToWorld114 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_texcoord6.xyz, 1 ) ).xyz;
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
				float3 originalLightColor174 = ( OutputColor188 + _AddLightBaseColor );
				half3 MMDLIT_GLOBALLIGHTING139 = half3(0.6,0.6,0.6);
				float3 lightColor178 = ( originalLightColor174 * MMDLIT_GLOBALLIGHTING139 );
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
				float3 objToWorldDir141 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_normal, 0 ) ).xyz;
				float3 normal187 = objToWorldDir141;
				float3 Output187 = float3( 0,0,0 );
				vLight_float( normal187 , Output187 );
				float3 appendResult136 = (float3(1.0 , 1.0 , 1.0));
				half3 MMDLIT_CENTERAMBIENT138 = half3(0.5,0.5,0.5);
				float4 break163 = Ambient44;
				float3 appendResult162 = (float3(break163.r , break163.g , break163.b));
				half3 MMDLIT_CENTERAMBIENT_INV171 = ( half3(1,1,1) / 0.5 );
				float3 MMDLit_GetTempAmbientL135 = ( max( ( MMDLIT_CENTERAMBIENT138 - appendResult162 ) , float3(0,0,0) ) * MMDLIT_CENTERAMBIENT_INV171 );
				float3 MMDLit_GetAmbientRate48 = ( appendResult136 - MMDLit_GetTempAmbientL135 );
				float3 MMDLit_GetTempAmbient144 = ( Output187 * MMDLit_GetAmbientRate48 );
				float3 appendResult155 = (float3(0.0 , 0.0 , 0.0));
				float3 MMDLit_GetTempDiffuse160 = max( ( min( ( appendResult150 + ( appendResult152 * MMDLIT_GLOBALLIGHTING139 ) ) , appendResult154 ) - MMDLit_GetTempAmbient144 ) , appendResult155 );
				float2 uv_MainTex = texCoord0 * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 Albedo12 = tex2D( _MainTex, uv_MainTex );
				float4 temp_output_78_0 = ( float4( MMDLit_GetTempDiffuse160 , 0.0 ) * Albedo12 );
				float4 Base399 = temp_output_78_0;
				float3 objToView109 = mul( UNITY_MATRIX_MV, float4( packedInput.ase_texcoord6.xyz, 1 ) ).xyz;
				float3 normalizeResult64 = normalize( objToView109 );
				float3 objToViewDir67 = normalize( mul( UNITY_MATRIX_IT_MV, float4( packedInput.ase_normal, 0 ) ).xyz );
				float3 normalizeResult65 = normalize( objToViewDir67 );
				float4 SphereCube37 = texCUBE( _SphereCube, reflect( normalizeResult64 , normalizeResult65 ) );
				float4 temp_output_57_0 = ( SphereCube37 * _SPHOpacity );
				float4 Add399 = ( temp_output_78_0 + temp_output_57_0 );
				float4 temp_output_39_0 = ( temp_output_57_0 * Albedo12 );
				float4 Multi399 = ( temp_output_39_0 * float4( MMDLit_GetTempDiffuse160 , 0.0 ) );
				float2 uv_SubTex = texCoord0 * _SubTex_ST.xy + _SubTex_ST.zw;
				float4 tex2DNode379 = tex2D( _SubTex, uv_SubTex );
				float4 Sub399 = ( float4( MMDLit_GetTempDiffuse160 , 0.0 ) * Albedo12 * tex2DNode379 );
				float4 RGBA399 = float4( 0,0,0,0 );
				effectsControl_float( Layer399 , Base399 , Add399 , Multi399 , Sub399 , RGBA399 );
				float3 objToWorldDir180 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_normal, 0 ) ).xyz;
				float3 normalizeResult181 = normalize( objToWorldDir180 );
				float3 ase_viewVectorWS = ( _WorldSpaceCameraPos.xyz - positionWS );
				float3 ase_viewDirWS = normalize( ase_viewVectorWS );
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
				float4 FinalColor336 = ( ( ( saturate( ( temp_cast_0 - ( _ShadowLum * ( temp_cast_1 - ( _SShad == (float)0 ? tex2DNode92 : lerpResult431 ) ) ) ) ) * float4( lightColor178 , 0.0 ) * RGBA399 ) + ( ( Specular131 * _Specular * float4( lightColor178 , 0.0 ) ) * _SpecularIntensity ) ) + ( baseC73 * float4( MMDLit_GetAmbientRate48 , 0.0 ) ) );
				

				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				surfaceDescription.BaseColor = ( FinalColor336 * _HDR ).rgb;
				surfaceDescription.Alpha = saturate( ( _Opaque * ( tSphereMapBlend289 == (float)3 ? ( tex2DNode379.a * Albedo12.a ) : Albedo12.a ) ) );
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.NormalAlpha = 1;
				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceDescription.Metallic = 0;
					surfaceDescription.Occlusion = 1;
					surfaceDescription.Smoothness = 0.5;
					surfaceDescription.MAOSAlpha = 1;
				#endif

				#if defined( _MATERIAL_AFFECTS_EMISSION )
					surfaceDescription.Emission = float3(0, 0, 0);
				#endif

				GetSurfaceData( surfaceDescription, angleFadeFactor, surfaceData);

				half3 normalToPack = surfaceData.normalWS.xyz;
				#ifdef DECAL_RECONSTRUCT_NORMAL
					surfaceData.normalWS.xyz = normalize(lerp(normalWS.xyz, surfaceData.normalWS.xyz, surfaceData.normalWS.w));
				#endif

				InputData inputData;
				InitializeInputData( packedInput, positionWS, surfaceData.normalWS.xyz, viewDirectionWS, inputData);

				SurfaceData surface = (SurfaceData)0;
				GetSurface(surfaceData, surface);

				half4 color = UniversalFragmentPBR(inputData, surface);
				color.rgb = MixFog(color.rgb, inputData.fogCoord);
				outColor = color;

			}
			ENDHLSL
        }

		
        Pass
        {
            
			Name "DecalGBufferProjector"
            Tags { "LightMode"="DecalGBufferProjector" }

			Cull Front
			Blend 0 SrcAlpha OneMinusSrcAlpha
			Blend 1 SrcAlpha OneMinusSrcAlpha
			Blend 2 SrcAlpha OneMinusSrcAlpha
			Blend 3 SrcAlpha OneMinusSrcAlpha
			ZTest Greater
			ZWrite Off
			ColorMask RGB
			ColorMask 0 1
			ColorMask RGB 2
			ColorMask RGB 3

			HLSLPROGRAM

			#define _MATERIAL_AFFECTS_ALBEDO 1
			#define _MATERIAL_AFFECTS_NORMAL 1
			#define _MATERIAL_AFFECTS_NORMAL_BLEND 1
			#define DECAL_ANGLE_FADE 1
			#define ASE_SRP_VERSION 170003


			#pragma vertex Vert
			#pragma fragment Frag
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
			#pragma editor_sync_compilation

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
			#pragma multi_compile _DECAL_NORMAL_BLEND_LOW _DECAL_NORMAL_BLEND_MEDIUM _DECAL_NORMAL_BLEND_HIGH
			#pragma multi_compile _ _DECAL_LAYERS
			#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
			#pragma multi_compile_fragment _ _RENDER_PASS_ENABLED

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TEXCOORD0
			#define VARYINGS_NEED_NORMAL_WS
			#define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_SH
            #define VARYINGS_NEED_STATIC_LIGHTMAP_UV
            #define VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV

            #define HAVE_MESH_MODIFICATION

            #define SHADERPASS SHADERPASS_DECAL_GBUFFER_PROJECTOR

			#if _RENDER_PASS_ENABLED
			#define GBUFFER3 0
			#define GBUFFER4 1
			FRAMEBUFFER_INPUT_X_HALF(GBUFFER3);
			FRAMEBUFFER_INPUT_X_HALF(GBUFFER4);
			#endif

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"

		    #if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#include "MMDEffectsCustomNodeScriptAmplifyShaderEditor.hlsl"
			#define ASE_NEEDS_FRAG_NORMAL
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct SurfaceDescription
			{
				float3 BaseColor;
				float Alpha;
				float3 NormalTS;
				float NormalAlpha;
				float Metallic;
				float Occlusion;
				float Smoothness;
				float MAOSAlpha;
				float3 Emission;
			};

			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float3 viewDirectionWS : TEXCOORD1;
				float4 lightmapUVs : TEXCOORD2; // @diogo: packs both static (xy) and dynamic (zw)
				float3 sh : TEXCOORD3;
				#ifdef USE_APV_PROBE_OCCLUSION
					float4 probeOcclusion : TEXCOORD4;
				#endif
				float3 ase_normal : NORMAL;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float4 _Ambient;
			float4 _Color;
			float4 _MainTex_ST;
			float4 _SubTex_ST;
			float4 _Specular;
			float3 _ToonTone;
			float _ShadowLum;
			float _SShad;
			float _AddLightBaseColor;
			float _EFFECTS;
			float _SPHOpacity;
			float _Shininess;
			float _SpecularIntensity;
			float _HDR;
			float _Opaque;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
			#if defined(DECAL_ANGLE_FADE)
			float _DecalAngleFadeSupported;
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


			
            void GetSurfaceData(SurfaceDescription surfaceDescription, float angleFadeFactor, out DecalSurfaceData surfaceData)
            {
                half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);

                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);

                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif

				#if defined( _MATERIAL_AFFECTS_EMISSION )
					surfaceData.emissive.rgb = half3(surfaceDescription.Emission.rgb * fadeFactor);
				#endif

                surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);

                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
						surfaceData.normalWS.xyz = normalize(mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz));
                    #else
						surfaceData.normalWS.xyz = normalize(normalToWorld[2].xyz);
                    #endif
                #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
                        float sgn = input.tangentWS.w;
                        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                        half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
        
                        surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, tangentToWorld));
                    #else
						surfaceData.normalWS.xyz = normalize(half3(input.normalWS));
                    #endif
                #endif

                surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceData.metallic = half(surfaceDescription.Metallic);
					surfaceData.occlusion = half(surfaceDescription.Occlusion);
					surfaceData.smoothness = half(surfaceDescription.Smoothness);
					surfaceData.MAOSAlpha = half(surfaceDescription.MAOSAlpha * fadeFactor);
				#endif
            }

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
            #define DECAL_PROJECTOR
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_MESH
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
            #define DECAL_DBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH)
            #define DECAL_SCREEN_SPACE
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_GBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH)
            #define DECAL_FORWARD_EMISSIVE
            #endif

            #if ((!defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_ALBEDO)) || (defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_NORMAL_BLEND))) && (defined(DECAL_SCREEN_SPACE) || defined(DECAL_GBUFFER))
            #define DECAL_RECONSTRUCT_NORMAL
            #elif defined(DECAL_ANGLE_FADE)
            #define DECAL_LOAD_NORMAL
            #endif

            #ifdef _DECAL_LAYERS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareRenderingLayerTexture.hlsl"
            #endif

            #if defined(DECAL_LOAD_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
            #endif

            #if defined(DECAL_PROJECTOR) || defined(DECAL_RECONSTRUCT_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #endif

            #ifdef DECAL_MESH
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DecalMeshBiasTypeEnum.cs.hlsl"
            #endif

            #ifdef DECAL_RECONSTRUCT_NORMAL
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NormalReconstruction.hlsl"
            #endif

			void InitializeInputData(PackedVaryings input, float3 positionWS, half3 normalWS, half3 viewDirectionWS, out InputData inputData)
			{
				inputData = (InputData)0;

				inputData.positionWS = positionWS;
				inputData.normalWS = normalWS;
				inputData.viewDirectionWS = viewDirectionWS;
				inputData.shadowCoord = float4(0, 0, 0, 0);

				#ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
					inputData.fogCoord = InitializeInputDataFog(float4(positionWS, 1.0), input.fogFactorAndVertexLight.x);
					inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
				#endif

				#if defined(VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV) && defined(DYNAMICLIGHTMAP_ON)
					inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV.xy, half3(input.sh), normalWS);
					#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
					inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
					#endif
				#elif defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
				#if !defined(LIGHTMAP_ON) && (defined(PROBE_VOLUMES_L1) || defined(PROBE_VOLUMES_L2))
    				inputData.bakedGI = SAMPLE_GI(input.sh,
					GetAbsolutePositionWS(inputData.positionWS),
					inputData.normalWS,
					inputData.viewDirectionWS,
					input.positionCS.xy,
					input.probeOcclusion,
					inputData.shadowMask);
				#else
					inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, half3(input.sh), normalWS);
					#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
					inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
					#endif
				#endif
				#endif

				#if defined(DEBUG_DISPLAY)
					#if defined(VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV) && defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = input.dynamicLightmapUV.xy;
					#endif
					#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV) && defined(LIGHTMAP_ON)
						inputData.staticLightmapUV = input.staticLightmapUV
					#elif defined(VARYINGS_NEED_SH)
						inputData.vertexSH = input.sh;
					#endif
					#if defined(USE_APV_PROBE_OCCLUSION)
						inputData.probeOcclusion = input.probeOcclusion;
					#endif
				#endif

				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
			}

			void GetSurface(DecalSurfaceData decalSurfaceData, inout SurfaceData surfaceData)
			{
				surfaceData.albedo = decalSurfaceData.baseColor.rgb;
				surfaceData.metallic = saturate(decalSurfaceData.metallic);
				surfaceData.specular = 0;
				surfaceData.smoothness = saturate(decalSurfaceData.smoothness);
				surfaceData.occlusion = decalSurfaceData.occlusion;
				surfaceData.emission = decalSurfaceData.emissive;
				surfaceData.alpha = saturate(decalSurfaceData.baseColor.w);
				surfaceData.clearCoatMask = 0;
				surfaceData.clearCoatSmoothness = 1;
			}

			PackedVaryings Vert(Attributes inputMesh  )
			{
				PackedVaryings packedOutput;
				ZERO_INITIALIZE(PackedVaryings, packedOutput);

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, packedOutput);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(packedOutput);

				inputMesh.tangentOS = float4( 1, 0, 0, -1 );
				inputMesh.normalOS = float3( 0, 1, 0 );

				packedOutput.ase_normal = inputMesh.normalOS;
				packedOutput.ase_texcoord5 = float4(inputMesh.positionOS,1);

				float3 positionWS = TransformObjectToWorld(inputMesh.positionOS);
				float3 normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);

				packedOutput.positionCS = TransformWorldToHClip(positionWS);
				packedOutput.normalWS.xyz =  normalWS;
				packedOutput.viewDirectionWS.xyz =  GetWorldSpaceViewDir(positionWS);

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV(inputMesh.uv1, unity_LightmapST, packedOutput.staticLightmapUV);
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					packedOutput.dynamicLightmapUV.xy = inputMesh.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if !defined(LIGHTMAP_ON)
					packedOutput.sh = float3(SampleSHVertex(half3(normalWS)));
				#endif

				return packedOutput;
			}

			void Frag(PackedVaryings packedInput,
				out FragmentOutput fragmentOutput
				
			)
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);
				UNITY_SETUP_INSTANCE_ID(packedInput);

				half angleFadeFactor = 1.0;

            #ifdef _DECAL_LAYERS
            #ifdef _RENDER_PASS_ENABLED
				uint surfaceRenderingLayer = DecodeMeshRenderingLayer(LOAD_FRAMEBUFFER_INPUT(GBUFFER4, packedInput.positionCS.xy).r);
            #else
				uint surfaceRenderingLayer = LoadSceneRenderingLayer(packedInput.positionCS.xy);
            #endif
				uint projectorRenderingLayer = uint(UNITY_ACCESS_INSTANCED_PROP(Decal, _DecalLayerMaskFromDecal));
				clip((surfaceRenderingLayer & projectorRenderingLayer) - 0.1);
            #endif

			#if defined(DECAL_PROJECTOR)
			#if UNITY_REVERSED_Z
			#if _RENDER_PASS_ENABLED
				float depth = LOAD_FRAMEBUFFER_X_INPUT(GBUFFER3, packedInput.positionCS.xy).x;
			#else
				float depth = LoadSceneDepth(packedInput.positionCS.xy);
			#endif
			#else
			#if _RENDER_PASS_ENABLED
				float depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, LOAD_FRAMEBUFFER_X_INPUT(GBUFFER3, packedInput.positionCS.xy));
			#else
				float depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, LoadSceneDepth(packedInput.positionCS.xy));
			#endif
			#endif
			#endif

				#if defined(DECAL_RECONSTRUCT_NORMAL)
					#if defined(_DECAL_NORMAL_BLEND_HIGH)
						half3 normalWS = half3(ReconstructNormalTap9(packedInput.positionCS.xy));
					#elif defined(_DECAL_NORMAL_BLEND_MEDIUM)
						half3 normalWS = half3(ReconstructNormalTap5(packedInput.positionCS.xy));
					#else
						half3 normalWS = half3(ReconstructNormalDerivative(packedInput.positionCS.xy));
					#endif
				#elif defined(DECAL_LOAD_NORMAL)
					half3 normalWS = half3(LoadSceneNormals(packedInput.positionCS.xy));
				#endif

				float2 positionSS = FoveatedRemapNonUniformToLinearCS(packedInput.positionCS.xy) * _ScreenSize.zw;

				float3 positionWS = ComputeWorldSpacePosition(positionSS, depth, UNITY_MATRIX_I_VP);

				float3 positionDS = TransformWorldToObject(positionWS);
				positionDS = positionDS * float3(1.0, -1.0, 1.0);

				float clipValue = 0.5 - Max3(abs(positionDS).x, abs(positionDS).y, abs(positionDS).z);
				clip(clipValue);

				float2 texCoord = positionDS.xz + float2(0.5, 0.5);

				float4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
				float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
				float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
				texCoord.xy = texCoord.xy * scale + offset;

				float2 texCoord0 = texCoord;
				float2 texCoord1 = texCoord;
				float2 texCoord2 = texCoord;
				float2 texCoord3 = texCoord;

				float3 worldTangent = TransformObjectToWorldDir(float3(1, 0, 0));
				float3 worldNormal = TransformObjectToWorldDir(float3(0, 1, 0));
				float3 worldBitangent = TransformObjectToWorldDir(float3(0, 0, 1));

				#ifdef DECAL_ANGLE_FADE
					half2 angleFade = half2(normalToWorld[1][3], normalToWorld[2][3]);

					if (angleFade.y < 0.0f)
					{
						half3 decalNormal = half3(normalToWorld[0].z, normalToWorld[1].z, normalToWorld[2].z);
						half dotAngle = dot(normalWS, decalNormal);
						angleFadeFactor = saturate(angleFade.x + angleFade.y * (dotAngle * (dotAngle - 2.0)));
					}
				#endif

				half3 viewDirectionWS = half3(packedInput.viewDirectionWS);
				DecalSurfaceData surfaceData;

				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float4 temp_cast_0 = (1.0).xxxx;
				float4 temp_cast_1 = (1.0).xxxx;
				float3 ToonTone32 = _ToonTone;
				float3 break52 = ToonTone32;
				float3 objToWorldDir84 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_normal, 0 ) ).xyz;
				float3 normalizeResult59 = normalize( objToWorldDir84 );
				float3 normalizeResult60 = normalize( _MainLightPosition.xyz );
				float dotResult62 = dot( normalizeResult59 , normalizeResult60 );
				float NdotL89 = dotResult62;
				float localshadowAtten190 = ( 0.0 );
				float3 objToWorld114 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_texcoord5.xyz, 1 ) ).xyz;
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
				float3 originalLightColor174 = ( OutputColor188 + _AddLightBaseColor );
				half3 MMDLIT_GLOBALLIGHTING139 = half3(0.6,0.6,0.6);
				float3 lightColor178 = ( originalLightColor174 * MMDLIT_GLOBALLIGHTING139 );
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
				float3 objToWorldDir141 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_normal, 0 ) ).xyz;
				float3 normal187 = objToWorldDir141;
				float3 Output187 = float3( 0,0,0 );
				vLight_float( normal187 , Output187 );
				float3 appendResult136 = (float3(1.0 , 1.0 , 1.0));
				half3 MMDLIT_CENTERAMBIENT138 = half3(0.5,0.5,0.5);
				float4 break163 = Ambient44;
				float3 appendResult162 = (float3(break163.r , break163.g , break163.b));
				half3 MMDLIT_CENTERAMBIENT_INV171 = ( half3(1,1,1) / 0.5 );
				float3 MMDLit_GetTempAmbientL135 = ( max( ( MMDLIT_CENTERAMBIENT138 - appendResult162 ) , float3(0,0,0) ) * MMDLIT_CENTERAMBIENT_INV171 );
				float3 MMDLit_GetAmbientRate48 = ( appendResult136 - MMDLit_GetTempAmbientL135 );
				float3 MMDLit_GetTempAmbient144 = ( Output187 * MMDLit_GetAmbientRate48 );
				float3 appendResult155 = (float3(0.0 , 0.0 , 0.0));
				float3 MMDLit_GetTempDiffuse160 = max( ( min( ( appendResult150 + ( appendResult152 * MMDLIT_GLOBALLIGHTING139 ) ) , appendResult154 ) - MMDLit_GetTempAmbient144 ) , appendResult155 );
				float2 uv_MainTex = texCoord0 * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 Albedo12 = tex2D( _MainTex, uv_MainTex );
				float4 temp_output_78_0 = ( float4( MMDLit_GetTempDiffuse160 , 0.0 ) * Albedo12 );
				float4 Base399 = temp_output_78_0;
				float3 objToView109 = mul( UNITY_MATRIX_MV, float4( packedInput.ase_texcoord5.xyz, 1 ) ).xyz;
				float3 normalizeResult64 = normalize( objToView109 );
				float3 objToViewDir67 = normalize( mul( UNITY_MATRIX_IT_MV, float4( packedInput.ase_normal, 0 ) ).xyz );
				float3 normalizeResult65 = normalize( objToViewDir67 );
				float4 SphereCube37 = texCUBE( _SphereCube, reflect( normalizeResult64 , normalizeResult65 ) );
				float4 temp_output_57_0 = ( SphereCube37 * _SPHOpacity );
				float4 Add399 = ( temp_output_78_0 + temp_output_57_0 );
				float4 temp_output_39_0 = ( temp_output_57_0 * Albedo12 );
				float4 Multi399 = ( temp_output_39_0 * float4( MMDLit_GetTempDiffuse160 , 0.0 ) );
				float2 uv_SubTex = texCoord0 * _SubTex_ST.xy + _SubTex_ST.zw;
				float4 tex2DNode379 = tex2D( _SubTex, uv_SubTex );
				float4 Sub399 = ( float4( MMDLit_GetTempDiffuse160 , 0.0 ) * Albedo12 * tex2DNode379 );
				float4 RGBA399 = float4( 0,0,0,0 );
				effectsControl_float( Layer399 , Base399 , Add399 , Multi399 , Sub399 , RGBA399 );
				float3 objToWorldDir180 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_normal, 0 ) ).xyz;
				float3 normalizeResult181 = normalize( objToWorldDir180 );
				float3 ase_viewVectorWS = ( _WorldSpaceCameraPos.xyz - positionWS );
				float3 ase_viewDirWS = normalize( ase_viewVectorWS );
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
				float4 FinalColor336 = ( ( ( saturate( ( temp_cast_0 - ( _ShadowLum * ( temp_cast_1 - ( _SShad == (float)0 ? tex2DNode92 : lerpResult431 ) ) ) ) ) * float4( lightColor178 , 0.0 ) * RGBA399 ) + ( ( Specular131 * _Specular * float4( lightColor178 , 0.0 ) ) * _SpecularIntensity ) ) + ( baseC73 * float4( MMDLit_GetAmbientRate48 , 0.0 ) ) );
				

				surfaceDescription.BaseColor = ( FinalColor336 * _HDR ).rgb;
				surfaceDescription.Alpha = saturate( ( _Opaque * ( tSphereMapBlend289 == (float)3 ? ( tex2DNode379.a * Albedo12.a ) : Albedo12.a ) ) );
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.NormalAlpha = 1;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceDescription.Metallic = 0;
					surfaceDescription.Occlusion =1;
					surfaceDescription.Smoothness = 0.5;
					surfaceDescription.MAOSAlpha = 1;
				#endif

				#if defined( _MATERIAL_AFFECTS_EMISSION )
					surfaceDescription.Emission = float3(0, 0, 0);
				#endif

				GetSurfaceData(surfaceDescription, angleFadeFactor, surfaceData);

				half3 normalToPack = surfaceData.normalWS.xyz;
				#ifdef DECAL_RECONSTRUCT_NORMAL
					surfaceData.normalWS.xyz = normalize(lerp(normalWS.xyz, surfaceData.normalWS.xyz, surfaceData.normalWS.w));
				#endif

					InputData inputData;
					InitializeInputData(packedInput, positionWS, surfaceData.normalWS.xyz, viewDirectionWS, inputData);

					SurfaceData surface = (SurfaceData)0;
					GetSurface(surfaceData, surface);

					BRDFData brdfData;
					InitializeBRDFData(surface.albedo, surface.metallic, 0, surface.smoothness, surface.alpha, brdfData);

				#ifdef _MATERIAL_AFFECTS_ALBEDO
					Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, inputData.shadowMask);
					MixRealtimeAndBakedGI(mainLight, surfaceData.normalWS.xyz, inputData.bakedGI, inputData.shadowMask);
					half3 color = GlobalIllumination(brdfData, inputData.bakedGI, surface.occlusion, surfaceData.normalWS.xyz, inputData.viewDirectionWS);
				#else
					half3 color = 0;
				#endif

				#pragma warning (disable : 3578) // The output value isn't completely initialized.
				half3 packedNormalWS = PackNormal(normalToPack);
				fragmentOutput.GBuffer0 = half4(surfaceData.baseColor.rgb, surfaceData.baseColor.a);
				fragmentOutput.GBuffer1 = 0;
				fragmentOutput.GBuffer2 = half4(packedNormalWS, surfaceData.normalWS.a);
				fragmentOutput.GBuffer3 = half4(surfaceData.emissive + color, surfaceData.baseColor.a);
				#if OUTPUT_SHADOWMASK
					fragmentOutput.GBuffer4 = inputData.shadowMask; // will have unity_ProbesOcclusion value if subtractive lighting is used (baked)
				#endif
				#pragma warning (default : 3578) // Restore output value isn't completely initialized.

			}
            ENDHLSL
        }

		
        Pass
        {
            
			Name "DBufferMesh"
            Tags { "LightMode"="DBufferMesh" }

			Blend 0 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
			Blend 1 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
			Blend 2 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
			ZTest LEqual
			ZWrite Off
			ColorMask RGBA
			ColorMask RGBA 1
			ColorMask RGBA 2

			HLSLPROGRAM

			#define _MATERIAL_AFFECTS_ALBEDO 1
			#define _MATERIAL_AFFECTS_NORMAL 1
			#define _MATERIAL_AFFECTS_NORMAL_BLEND 1
			#define ASE_SRP_VERSION 170003


			#pragma vertex Vert
			#pragma fragment Frag
			#pragma multi_compile_instancing
			#pragma editor_sync_compilation

			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile _ _DECAL_LAYERS

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0

            #define HAVE_MESH_MODIFICATION

            #define SHADERPASS SHADERPASS_DBUFFER_MESH

			#if _RENDER_PASS_ENABLED
			#define GBUFFER3 0
			#define GBUFFER4 1
			FRAMEBUFFER_INPUT_X_HALF(GBUFFER3);
			FRAMEBUFFER_INPUT_X_HALF(GBUFFER4);
			#endif

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

            #include "MMDEffectsCustomNodeScriptAmplifyShaderEditor.hlsl"
            #define ASE_NEEDS_FRAG_NORMAL
            #define ASE_NEEDS_FRAG_POSITION


			struct SurfaceDescription
			{
				float3 BaseColor;
				float Alpha;
				float3 NormalTS;
				float NormalAlpha;
				float Metallic;
				float Occlusion;
				float Smoothness;
				float MAOSAlpha;
			};

			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 uv1 : TEXCOORD1;
				float4 uv2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float3 normalWS : TEXCOORD1;
				float4 tangentWS : TEXCOORD2;
				float4 texCoord0 : TEXCOORD3;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float4 _Ambient;
			float4 _Color;
			float4 _MainTex_ST;
			float4 _SubTex_ST;
			float4 _Specular;
			float3 _ToonTone;
			float _ShadowLum;
			float _SShad;
			float _AddLightBaseColor;
			float _EFFECTS;
			float _SPHOpacity;
			float _Shininess;
			float _SpecularIntensity;
			float _HDR;
			float _Opaque;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
			#if defined(DECAL_ANGLE_FADE)
			float _DecalAngleFadeSupported;
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


			
            void GetSurfaceData(PackedVaryings input, SurfaceDescription surfaceDescription, out DecalSurfaceData surfaceData)
            {
                #if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
                #endif

                half fadeFactor = half(1.0);

                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);

                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif

                surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);

                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
						surfaceData.normalWS.xyz = normalize(mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz));
                    #else
						surfaceData.normalWS.xyz = normalize(normalToWorld[2].xyz);
                    #endif
                #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
                        float sgn = input.tangentWS.w;
                        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                        half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
        
                        surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, tangentToWorld));
                    #else
						surfaceData.normalWS.xyz = normalize(half3(input.normalWS));
                    #endif
                #endif

                surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceData.metallic = half(surfaceDescription.Metallic);
					surfaceData.occlusion = half(surfaceDescription.Occlusion);
					surfaceData.smoothness = half(surfaceDescription.Smoothness);
					surfaceData.MAOSAlpha = half(surfaceDescription.MAOSAlpha * fadeFactor);
				#endif
            }

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
            #define DECAL_PROJECTOR
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_MESH
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
            #define DECAL_DBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH)
            #define DECAL_SCREEN_SPACE
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_GBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH)
            #define DECAL_FORWARD_EMISSIVE
            #endif

            #if ((!defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_ALBEDO)) || (defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_NORMAL_BLEND))) && (defined(DECAL_SCREEN_SPACE) || defined(DECAL_GBUFFER))
            #define DECAL_RECONSTRUCT_NORMAL
            #elif defined(DECAL_ANGLE_FADE)
            #define DECAL_LOAD_NORMAL
            #endif

            #ifdef _DECAL_LAYERS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareRenderingLayerTexture.hlsl"
            #endif

            #if defined(DECAL_LOAD_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
            #endif

            #if defined(DECAL_PROJECTOR) || defined(DECAL_RECONSTRUCT_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #endif

            #ifdef DECAL_MESH
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DecalMeshBiasTypeEnum.cs.hlsl"
            #endif

            #ifdef DECAL_RECONSTRUCT_NORMAL
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NormalReconstruction.hlsl"
            #endif

			void MeshDecalsPositionZBias(inout PackedVaryings input)
			{
            #if UNITY_REVERSED_Z
				input.positionCS.z -= _DecalMeshDepthBias;
            #else
				input.positionCS.z += _DecalMeshDepthBias;
            #endif
			}

			PackedVaryings Vert(Attributes inputMesh  )
			{
				if (_DecalMeshBiasType == DECALMESHDEPTHBIASTYPE_VIEW_BIAS)
				{
					float3 viewDirectionOS = GetObjectSpaceNormalizeViewDir(inputMesh.positionOS);
					inputMesh.positionOS += viewDirectionOS * (_DecalMeshViewBias);
				}

				PackedVaryings packedOutput;
				ZERO_INITIALIZE(PackedVaryings, packedOutput);

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, packedOutput);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(packedOutput);

				inputMesh.tangentOS = float4( 1, 0, 0, -1 );
				inputMesh.normalOS = float3( 0, 1, 0 );

				packedOutput.ase_normal = inputMesh.normalOS;
				packedOutput.ase_texcoord4 = float4(inputMesh.positionOS,1);

				VertexPositionInputs vertexInput = GetVertexPositionInputs(inputMesh.positionOS.xyz);

				float3 positionWS = TransformObjectToWorld(inputMesh.positionOS);

				float3 normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);
				float4 tangentWS = float4(TransformObjectToWorldDir(inputMesh.tangentOS.xyz), inputMesh.tangentOS.w);

				packedOutput.positionWS.xyz =  positionWS;
				packedOutput.normalWS.xyz =  normalWS;
				packedOutput.tangentWS.xyzw =  tangentWS;
				packedOutput.texCoord0.xyzw =  inputMesh.uv0;
				packedOutput.positionCS = TransformWorldToHClip(positionWS);

				if (_DecalMeshBiasType == DECALMESHDEPTHBIASTYPE_DEPTH_BIAS)
				{
					MeshDecalsPositionZBias(packedOutput);
				}

				return packedOutput;
			}

			void Frag(PackedVaryings packedInput,
				OUTPUT_DBUFFER(outDBuffer)
				
			)
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);
				UNITY_SETUP_INSTANCE_ID(packedInput);

				half angleFadeFactor = 1.0;

            #ifdef _DECAL_LAYERS
            #ifdef _RENDER_PASS_ENABLED
				uint surfaceRenderingLayer = DecodeMeshRenderingLayer(LOAD_FRAMEBUFFER_INPUT(GBUFFER4, packedInput.positionCS.xy).r);
            #else
				uint surfaceRenderingLayer = LoadSceneRenderingLayer(packedInput.positionCS.xy);
            #endif
				uint projectorRenderingLayer = uint(UNITY_ACCESS_INSTANCED_PROP(Decal, _DecalLayerMaskFromDecal));
				clip((surfaceRenderingLayer & projectorRenderingLayer) - 0.1);
            #endif

				#if defined(DECAL_RECONSTRUCT_NORMAL)
					#if defined(_DECAL_NORMAL_BLEND_HIGH)
						half3 normalWS = half3(ReconstructNormalTap9(packedInput.positionCS.xy));
					#elif defined(_DECAL_NORMAL_BLEND_MEDIUM)
						half3 normalWS = half3(ReconstructNormalTap5(packedInput.positionCS.xy));
					#else
						half3 normalWS = half3(ReconstructNormalDerivative(packedInput.positionCS.xy));
					#endif
				#elif defined(DECAL_LOAD_NORMAL)
					half3 normalWS = half3(LoadSceneNormals(packedInput.positionCS.xy));
				#endif

				float2 positionSS = FoveatedRemapNonUniformToLinearCS(packedInput.positionCS.xy) * _ScreenSize.zw;

				float3 positionWS = packedInput.positionWS.xyz;
				half3 viewDirectionWS = half3(1.0, 1.0, 1.0);

				DecalSurfaceData surfaceData;
				SurfaceDescription surfaceDescription;

				float4 temp_cast_0 = (1.0).xxxx;
				float4 temp_cast_1 = (1.0).xxxx;
				float3 ToonTone32 = _ToonTone;
				float3 break52 = ToonTone32;
				float3 objToWorldDir84 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_normal, 0 ) ).xyz;
				float3 normalizeResult59 = normalize( objToWorldDir84 );
				float3 normalizeResult60 = normalize( _MainLightPosition.xyz );
				float dotResult62 = dot( normalizeResult59 , normalizeResult60 );
				float NdotL89 = dotResult62;
				float localshadowAtten190 = ( 0.0 );
				float3 objToWorld114 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_texcoord4.xyz, 1 ) ).xyz;
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
				float3 originalLightColor174 = ( OutputColor188 + _AddLightBaseColor );
				half3 MMDLIT_GLOBALLIGHTING139 = half3(0.6,0.6,0.6);
				float3 lightColor178 = ( originalLightColor174 * MMDLIT_GLOBALLIGHTING139 );
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
				float3 objToWorldDir141 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_normal, 0 ) ).xyz;
				float3 normal187 = objToWorldDir141;
				float3 Output187 = float3( 0,0,0 );
				vLight_float( normal187 , Output187 );
				float3 appendResult136 = (float3(1.0 , 1.0 , 1.0));
				half3 MMDLIT_CENTERAMBIENT138 = half3(0.5,0.5,0.5);
				float4 break163 = Ambient44;
				float3 appendResult162 = (float3(break163.r , break163.g , break163.b));
				half3 MMDLIT_CENTERAMBIENT_INV171 = ( half3(1,1,1) / 0.5 );
				float3 MMDLit_GetTempAmbientL135 = ( max( ( MMDLIT_CENTERAMBIENT138 - appendResult162 ) , float3(0,0,0) ) * MMDLIT_CENTERAMBIENT_INV171 );
				float3 MMDLit_GetAmbientRate48 = ( appendResult136 - MMDLit_GetTempAmbientL135 );
				float3 MMDLit_GetTempAmbient144 = ( Output187 * MMDLit_GetAmbientRate48 );
				float3 appendResult155 = (float3(0.0 , 0.0 , 0.0));
				float3 MMDLit_GetTempDiffuse160 = max( ( min( ( appendResult150 + ( appendResult152 * MMDLIT_GLOBALLIGHTING139 ) ) , appendResult154 ) - MMDLit_GetTempAmbient144 ) , appendResult155 );
				float2 uv_MainTex = packedInput.texCoord0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 Albedo12 = tex2D( _MainTex, uv_MainTex );
				float4 temp_output_78_0 = ( float4( MMDLit_GetTempDiffuse160 , 0.0 ) * Albedo12 );
				float4 Base399 = temp_output_78_0;
				float3 objToView109 = mul( UNITY_MATRIX_MV, float4( packedInput.ase_texcoord4.xyz, 1 ) ).xyz;
				float3 normalizeResult64 = normalize( objToView109 );
				float3 objToViewDir67 = normalize( mul( UNITY_MATRIX_IT_MV, float4( packedInput.ase_normal, 0 ) ).xyz );
				float3 normalizeResult65 = normalize( objToViewDir67 );
				float4 SphereCube37 = texCUBE( _SphereCube, reflect( normalizeResult64 , normalizeResult65 ) );
				float4 temp_output_57_0 = ( SphereCube37 * _SPHOpacity );
				float4 Add399 = ( temp_output_78_0 + temp_output_57_0 );
				float4 temp_output_39_0 = ( temp_output_57_0 * Albedo12 );
				float4 Multi399 = ( temp_output_39_0 * float4( MMDLit_GetTempDiffuse160 , 0.0 ) );
				float2 uv_SubTex = packedInput.texCoord0.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float4 tex2DNode379 = tex2D( _SubTex, uv_SubTex );
				float4 Sub399 = ( float4( MMDLit_GetTempDiffuse160 , 0.0 ) * Albedo12 * tex2DNode379 );
				float4 RGBA399 = float4( 0,0,0,0 );
				effectsControl_float( Layer399 , Base399 , Add399 , Multi399 , Sub399 , RGBA399 );
				float3 objToWorldDir180 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_normal, 0 ) ).xyz;
				float3 normalizeResult181 = normalize( objToWorldDir180 );
				float3 ase_viewVectorWS = ( _WorldSpaceCameraPos.xyz - packedInput.positionWS );
				float3 ase_viewDirWS = normalize( ase_viewVectorWS );
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
				float4 FinalColor336 = ( ( ( saturate( ( temp_cast_0 - ( _ShadowLum * ( temp_cast_1 - ( _SShad == (float)0 ? tex2DNode92 : lerpResult431 ) ) ) ) ) * float4( lightColor178 , 0.0 ) * RGBA399 ) + ( ( Specular131 * _Specular * float4( lightColor178 , 0.0 ) ) * _SpecularIntensity ) ) + ( baseC73 * float4( MMDLit_GetAmbientRate48 , 0.0 ) ) );
				

				surfaceDescription.BaseColor = ( FinalColor336 * _HDR ).rgb;
				surfaceDescription.Alpha = saturate( ( _Opaque * ( tSphereMapBlend289 == (float)3 ? ( tex2DNode379.a * Albedo12.a ) : Albedo12.a ) ) );
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.NormalAlpha = 1;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceDescription.Metallic = 0;
					surfaceDescription.Occlusion = 1;
					surfaceDescription.Smoothness = 0.5;
					surfaceDescription.MAOSAlpha = 1;
				#endif

				GetSurfaceData(packedInput, surfaceDescription, surfaceData);
				ENCODE_INTO_DBUFFER(surfaceData, outDBuffer);

			}

            ENDHLSL
        }

		
        Pass
        {
            
			Name "DecalScreenSpaceMesh"
            Tags { "LightMode"="DecalScreenSpaceMesh" }

			Blend SrcAlpha OneMinusSrcAlpha
			ZTest LEqual
			ZWrite Off

			HLSLPROGRAM

			#define _MATERIAL_AFFECTS_ALBEDO 1
			#define _MATERIAL_AFFECTS_NORMAL 1
			#define _MATERIAL_AFFECTS_NORMAL_BLEND 1
			#define ASE_SRP_VERSION 170003


			#pragma vertex Vert
			#pragma fragment Frag
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
			#pragma editor_sync_compilation

			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ USE_LEGACY_LIGHTMAPS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ _FORWARD_PLUS
			#pragma multi_compile _DECAL_NORMAL_BLEND_LOW _DECAL_NORMAL_BLEND_MEDIUM _DECAL_NORMAL_BLEND_HIGH
			#pragma multi_compile_fragment _ DEBUG_DISPLAY
			#pragma multi_compile _ _DECAL_LAYERS

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define VARYINGS_NEED_SH
            #define VARYINGS_NEED_STATIC_LIGHTMAP_UV
            #define VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV

            #define HAVE_MESH_MODIFICATION

            #define SHADERPASS SHADERPASS_DECAL_SCREEN_SPACE_MESH

			#if _RENDER_PASS_ENABLED
			#define GBUFFER3 0
			#define GBUFFER4 1
			FRAMEBUFFER_INPUT_X_HALF(GBUFFER3);
			FRAMEBUFFER_INPUT_X_HALF(GBUFFER4);
			#endif

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#include "MMDEffectsCustomNodeScriptAmplifyShaderEditor.hlsl"
			#define ASE_NEEDS_FRAG_NORMAL
			#define ASE_NEEDS_FRAG_POSITION


            struct SurfaceDescription
			{
				float3 BaseColor;
				float Alpha;
				float3 NormalTS;
				float NormalAlpha;
				float Metallic;
				float Occlusion;
				float Smoothness;
				float MAOSAlpha;
				float3 Emission;
			};

            struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 uv1 : TEXCOORD1;
				float4 uv2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float3 normalWS : TEXCOORD1;
				float4 tangentWS : TEXCOORD2;
				float4 texCoord0 : TEXCOORD3;
				float3 viewDirectionWS : TEXCOORD4;
				float4 lightmapUVs : TEXCOORD5; // @diogo: packs both static (xy) and dynamic (zw)
				float3 sh : TEXCOORD6;
				float4 fogFactorAndVertexLight : TEXCOORD7;
				#ifdef USE_APV_PROBE_OCCLUSION
					float4 probeOcclusion : TEXCOORD8;
				#endif
				float3 ase_normal : NORMAL;
				float4 ase_texcoord9 : TEXCOORD9;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float4 _Ambient;
			float4 _Color;
			float4 _MainTex_ST;
			float4 _SubTex_ST;
			float4 _Specular;
			float3 _ToonTone;
			float _ShadowLum;
			float _SShad;
			float _AddLightBaseColor;
			float _EFFECTS;
			float _SPHOpacity;
			float _Shininess;
			float _SpecularIntensity;
			float _HDR;
			float _Opaque;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
			#if defined(DECAL_ANGLE_FADE)
			float _DecalAngleFadeSupported;
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


			
            void GetSurfaceData(PackedVaryings input, SurfaceDescription surfaceDescription, out DecalSurfaceData surfaceData)
            {
                #if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
                #endif

                half fadeFactor = half(1.0);

                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);

                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif

				#if defined( _MATERIAL_AFFECTS_EMISSION )
					surfaceData.emissive.rgb = half3(surfaceDescription.Emission.rgb * fadeFactor);
				#endif

                surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);

                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
						surfaceData.normalWS.xyz = normalize(mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz));
                    #else
						surfaceData.normalWS.xyz = normalize(normalToWorld[2].xyz);
                    #endif
                #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
                        float sgn = input.tangentWS.w;
                        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                        half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
        
                        surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, tangentToWorld));
                    #else
						surfaceData.normalWS.xyz = normalize(half3(input.normalWS));
                    #endif
                #endif

                surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceData.metallic = half(surfaceDescription.Metallic);
					surfaceData.occlusion = half(surfaceDescription.Occlusion);
					surfaceData.smoothness = half(surfaceDescription.Smoothness);
					surfaceData.MAOSAlpha = half(surfaceDescription.MAOSAlpha * fadeFactor);
				#endif
            }


            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
            #define DECAL_PROJECTOR
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_MESH
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
            #define DECAL_DBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH)
            #define DECAL_SCREEN_SPACE
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_GBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH)
            #define DECAL_FORWARD_EMISSIVE
            #endif

            #if ((!defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_ALBEDO)) || (defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_NORMAL_BLEND))) && (defined(DECAL_SCREEN_SPACE) || defined(DECAL_GBUFFER))
            #define DECAL_RECONSTRUCT_NORMAL
            #elif defined(DECAL_ANGLE_FADE)
            #define DECAL_LOAD_NORMAL
            #endif

            #ifdef _DECAL_LAYERS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareRenderingLayerTexture.hlsl"
            #endif

            #if defined(DECAL_LOAD_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
            #endif

            #if defined(DECAL_PROJECTOR) || defined(DECAL_RECONSTRUCT_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #endif

            #ifdef DECAL_MESH
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DecalMeshBiasTypeEnum.cs.hlsl"
            #endif

            #ifdef DECAL_RECONSTRUCT_NORMAL
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NormalReconstruction.hlsl"
            #endif

			void MeshDecalsPositionZBias(inout PackedVaryings input)
			{
			#if UNITY_REVERSED_Z
				input.positionCS.z -= _DecalMeshDepthBias;
			#else
				input.positionCS.z += _DecalMeshDepthBias;
			#endif
			}

			void InitializeInputData(PackedVaryings input, float3 positionWS, half3 normalWS, half3 viewDirectionWS, out InputData inputData)
			{
				inputData = (InputData)0;

				inputData.positionWS = positionWS;
				inputData.normalWS = normalWS;
				inputData.viewDirectionWS = viewDirectionWS;
				inputData.shadowCoord = float4(0, 0, 0, 0);

				#ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
					inputData.fogCoord = InitializeInputDataFog(float4(positionWS, 1.0), input.fogFactorAndVertexLight.x);
					inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
				#endif

				#if defined(VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV) && defined(DYNAMICLIGHTMAP_ON)
					inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV.xy, half3(input.sh), normalWS);
					#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
					inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
					#endif
				#elif defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
				#if !defined(LIGHTMAP_ON) && (defined(PROBE_VOLUMES_L1) || defined(PROBE_VOLUMES_L2))
    				inputData.bakedGI = SAMPLE_GI(input.sh,
					GetAbsolutePositionWS(inputData.positionWS),
					inputData.normalWS,
					inputData.viewDirectionWS,
					input.positionCS.xy,
					input.probeOcclusion,
					inputData.shadowMask);
				#else
					inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, half3(input.sh), normalWS);
					#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
					inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
					#endif
				#endif
				#endif

				#if defined(DEBUG_DISPLAY)
					#if defined(VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV) && defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = input.dynamicLightmapUV.xy;
					#endif
					#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV) && defined(LIGHTMAP_ON)
						inputData.staticLightmapUV = input.staticLightmapUV
					#elif defined(VARYINGS_NEED_SH)
						inputData.vertexSH = input.sh;
					#endif
					#if defined(USE_APV_PROBE_OCCLUSION)
						inputData.probeOcclusion = input.probeOcclusion;
					#endif
				#endif

				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
			}

			void GetSurface(DecalSurfaceData decalSurfaceData, inout SurfaceData surfaceData)
			{
				surfaceData.albedo = decalSurfaceData.baseColor.rgb;
				surfaceData.metallic = saturate(decalSurfaceData.metallic);
				surfaceData.specular = 0;
				surfaceData.smoothness = saturate(decalSurfaceData.smoothness);
				surfaceData.occlusion = decalSurfaceData.occlusion;
				surfaceData.emission = decalSurfaceData.emissive;
				surfaceData.alpha = saturate(decalSurfaceData.baseColor.w);
				surfaceData.clearCoatMask = 0;
				surfaceData.clearCoatSmoothness = 1;
			}

			PackedVaryings Vert(Attributes inputMesh  )
			{
				if (_DecalMeshBiasType == DECALMESHDEPTHBIASTYPE_VIEW_BIAS)
				{
					float3 viewDirectionOS = GetObjectSpaceNormalizeViewDir(inputMesh.positionOS);
					inputMesh.positionOS += viewDirectionOS * (_DecalMeshViewBias);
				}

				PackedVaryings packedOutput;
				ZERO_INITIALIZE(PackedVaryings, packedOutput);

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, packedOutput);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(packedOutput);

				inputMesh.tangentOS = float4( 1, 0, 0, -1 );
				inputMesh.normalOS = float3( 0, 1, 0 );

				packedOutput.ase_normal = inputMesh.normalOS;
				packedOutput.ase_texcoord9 = float4(inputMesh.positionOS,1);

				VertexPositionInputs vertexInput = GetVertexPositionInputs(inputMesh.positionOS.xyz);
				float3 positionWS = TransformObjectToWorld(inputMesh.positionOS);
				float3 normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);
				float4 tangentWS = float4(TransformObjectToWorldDir(inputMesh.tangentOS.xyz), inputMesh.tangentOS.w);

				packedOutput.positionCS = TransformWorldToHClip(positionWS);

				half fogFactor = 0;
				#if !defined(_FOG_FRAGMENT)
					fogFactor = ComputeFogFactor(packedOutput.positionCS.z);
				#endif

				half3 vertexLight = VertexLighting(positionWS, normalWS);
				packedOutput.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

				if (_DecalMeshBiasType == DECALMESHDEPTHBIASTYPE_DEPTH_BIAS)
				{
					MeshDecalsPositionZBias(packedOutput);
				}

				packedOutput.positionWS.xyz = positionWS;
				packedOutput.normalWS.xyz =  normalWS;
				packedOutput.tangentWS.xyzw =  tangentWS;
				packedOutput.texCoord0.xyzw =  inputMesh.uv0;
				packedOutput.viewDirectionWS.xyz =  GetWorldSpaceViewDir(positionWS);

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV(inputMesh.uv1, unity_LightmapST, packedOutput.staticLightmapUV);
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					packedOutput.dynamicLightmapUV.xy = inputMesh.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if !defined(LIGHTMAP_ON)
					packedOutput.sh = float3(SampleSHVertex(half3(normalWS)));
				#endif

				return packedOutput;
			}

			void Frag(PackedVaryings packedInput,
						out half4 outColor : SV_Target0
						
					)
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);
				UNITY_SETUP_INSTANCE_ID(packedInput);

				half angleFadeFactor = 1.0;

            #ifdef _DECAL_LAYERS
            #ifdef _RENDER_PASS_ENABLED
				uint surfaceRenderingLayer = DecodeMeshRenderingLayer(LOAD_FRAMEBUFFER_INPUT(GBUFFER4, packedInput.positionCS.xy).r);
            #else
				uint surfaceRenderingLayer = LoadSceneRenderingLayer(packedInput.positionCS.xy);
            #endif
				uint projectorRenderingLayer = uint(UNITY_ACCESS_INSTANCED_PROP(Decal, _DecalLayerMaskFromDecal));
				clip((surfaceRenderingLayer & projectorRenderingLayer) - 0.1);
            #endif

				#if defined(DECAL_RECONSTRUCT_NORMAL)
					#if defined(_DECAL_NORMAL_BLEND_HIGH)
						half3 normalWS = half3(ReconstructNormalTap9(packedInput.positionCS.xy));
					#elif defined(_DECAL_NORMAL_BLEND_MEDIUM)
						half3 normalWS = half3(ReconstructNormalTap5(packedInput.positionCS.xy));
					#else
						half3 normalWS = half3(ReconstructNormalDerivative(packedInput.positionCS.xy));
					#endif
				#elif defined(DECAL_LOAD_NORMAL)
					half3 normalWS = half3(LoadSceneNormals(packedInput.positionCS.xy));
				#endif

				float2 positionSS = FoveatedRemapNonUniformToLinearCS(packedInput.positionCS.xy) * _ScreenSize.zw;

				float3 positionWS = packedInput.positionWS.xyz;
				half3 viewDirectionWS = half3(packedInput.viewDirectionWS);

				DecalSurfaceData surfaceData;
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float4 temp_cast_0 = (1.0).xxxx;
				float4 temp_cast_1 = (1.0).xxxx;
				float3 ToonTone32 = _ToonTone;
				float3 break52 = ToonTone32;
				float3 objToWorldDir84 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_normal, 0 ) ).xyz;
				float3 normalizeResult59 = normalize( objToWorldDir84 );
				float3 normalizeResult60 = normalize( _MainLightPosition.xyz );
				float dotResult62 = dot( normalizeResult59 , normalizeResult60 );
				float NdotL89 = dotResult62;
				float localshadowAtten190 = ( 0.0 );
				float3 objToWorld114 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_texcoord9.xyz, 1 ) ).xyz;
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
				float3 originalLightColor174 = ( OutputColor188 + _AddLightBaseColor );
				half3 MMDLIT_GLOBALLIGHTING139 = half3(0.6,0.6,0.6);
				float3 lightColor178 = ( originalLightColor174 * MMDLIT_GLOBALLIGHTING139 );
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
				float3 objToWorldDir141 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_normal, 0 ) ).xyz;
				float3 normal187 = objToWorldDir141;
				float3 Output187 = float3( 0,0,0 );
				vLight_float( normal187 , Output187 );
				float3 appendResult136 = (float3(1.0 , 1.0 , 1.0));
				half3 MMDLIT_CENTERAMBIENT138 = half3(0.5,0.5,0.5);
				float4 break163 = Ambient44;
				float3 appendResult162 = (float3(break163.r , break163.g , break163.b));
				half3 MMDLIT_CENTERAMBIENT_INV171 = ( half3(1,1,1) / 0.5 );
				float3 MMDLit_GetTempAmbientL135 = ( max( ( MMDLIT_CENTERAMBIENT138 - appendResult162 ) , float3(0,0,0) ) * MMDLIT_CENTERAMBIENT_INV171 );
				float3 MMDLit_GetAmbientRate48 = ( appendResult136 - MMDLit_GetTempAmbientL135 );
				float3 MMDLit_GetTempAmbient144 = ( Output187 * MMDLit_GetAmbientRate48 );
				float3 appendResult155 = (float3(0.0 , 0.0 , 0.0));
				float3 MMDLit_GetTempDiffuse160 = max( ( min( ( appendResult150 + ( appendResult152 * MMDLIT_GLOBALLIGHTING139 ) ) , appendResult154 ) - MMDLit_GetTempAmbient144 ) , appendResult155 );
				float2 uv_MainTex = packedInput.texCoord0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 Albedo12 = tex2D( _MainTex, uv_MainTex );
				float4 temp_output_78_0 = ( float4( MMDLit_GetTempDiffuse160 , 0.0 ) * Albedo12 );
				float4 Base399 = temp_output_78_0;
				float3 objToView109 = mul( UNITY_MATRIX_MV, float4( packedInput.ase_texcoord9.xyz, 1 ) ).xyz;
				float3 normalizeResult64 = normalize( objToView109 );
				float3 objToViewDir67 = normalize( mul( UNITY_MATRIX_IT_MV, float4( packedInput.ase_normal, 0 ) ).xyz );
				float3 normalizeResult65 = normalize( objToViewDir67 );
				float4 SphereCube37 = texCUBE( _SphereCube, reflect( normalizeResult64 , normalizeResult65 ) );
				float4 temp_output_57_0 = ( SphereCube37 * _SPHOpacity );
				float4 Add399 = ( temp_output_78_0 + temp_output_57_0 );
				float4 temp_output_39_0 = ( temp_output_57_0 * Albedo12 );
				float4 Multi399 = ( temp_output_39_0 * float4( MMDLit_GetTempDiffuse160 , 0.0 ) );
				float2 uv_SubTex = packedInput.texCoord0.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float4 tex2DNode379 = tex2D( _SubTex, uv_SubTex );
				float4 Sub399 = ( float4( MMDLit_GetTempDiffuse160 , 0.0 ) * Albedo12 * tex2DNode379 );
				float4 RGBA399 = float4( 0,0,0,0 );
				effectsControl_float( Layer399 , Base399 , Add399 , Multi399 , Sub399 , RGBA399 );
				float3 objToWorldDir180 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_normal, 0 ) ).xyz;
				float3 normalizeResult181 = normalize( objToWorldDir180 );
				float3 ase_viewVectorWS = ( _WorldSpaceCameraPos.xyz - packedInput.positionWS );
				float3 ase_viewDirWS = normalize( ase_viewVectorWS );
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
				float4 FinalColor336 = ( ( ( saturate( ( temp_cast_0 - ( _ShadowLum * ( temp_cast_1 - ( _SShad == (float)0 ? tex2DNode92 : lerpResult431 ) ) ) ) ) * float4( lightColor178 , 0.0 ) * RGBA399 ) + ( ( Specular131 * _Specular * float4( lightColor178 , 0.0 ) ) * _SpecularIntensity ) ) + ( baseC73 * float4( MMDLit_GetAmbientRate48 , 0.0 ) ) );
				

				surfaceDescription.BaseColor = ( FinalColor336 * _HDR ).rgb;
				surfaceDescription.Alpha = saturate( ( _Opaque * ( tSphereMapBlend289 == (float)3 ? ( tex2DNode379.a * Albedo12.a ) : Albedo12.a ) ) );
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.NormalAlpha = 1;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceDescription.Metallic = 0;
					surfaceDescription.Occlusion = 1;
					surfaceDescription.Smoothness = 0.5;
					surfaceDescription.MAOSAlpha = 1;
				#endif

				#if defined( _MATERIAL_AFFECTS_EMISSION )
					surfaceDescription.Emission = float3(0, 0, 0);
				#endif

				GetSurfaceData(packedInput, surfaceDescription, surfaceData);

				half3 normalToPack = surfaceData.normalWS.xyz;
				#ifdef DECAL_RECONSTRUCT_NORMAL
					surfaceData.normalWS.xyz = normalize(lerp(normalWS.xyz, surfaceData.normalWS.xyz, surfaceData.normalWS.w));
				#endif

				InputData inputData;
				InitializeInputData(packedInput, positionWS, surfaceData.normalWS.xyz, viewDirectionWS, inputData);

				SurfaceData surface = (SurfaceData)0;
				GetSurface(surfaceData, surface);

				half4 color = UniversalFragmentPBR(inputData, surface);
				color.rgb = MixFog(color.rgb, inputData.fogCoord);
				outColor = color;

			}
            ENDHLSL
        }

		
        Pass
        {
            
			Name "DecalGBufferMesh"
            Tags { "LightMode"="DecalGBufferMesh" }

			Blend 0 SrcAlpha OneMinusSrcAlpha
			Blend 1 SrcAlpha OneMinusSrcAlpha
			Blend 2 SrcAlpha OneMinusSrcAlpha
			Blend 3 SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ColorMask RGB
			ColorMask 0 1
			ColorMask RGB 2
			ColorMask RGB 3

			HLSLPROGRAM

			#define _MATERIAL_AFFECTS_ALBEDO 1
			#define _MATERIAL_AFFECTS_NORMAL 1
			#define _MATERIAL_AFFECTS_NORMAL_BLEND 1
			#define ASE_SRP_VERSION 170003


			#pragma vertex Vert
			#pragma fragment Frag
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
			#pragma editor_sync_compilation

			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ USE_LEGACY_LIGHTMAPS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			#pragma multi_compile _DECAL_NORMAL_BLEND_LOW _DECAL_NORMAL_BLEND_MEDIUM _DECAL_NORMAL_BLEND_HIGH
			#pragma multi_compile _ _DECAL_LAYERS
			#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
			#pragma multi_compile_fragment _ _RENDER_PASS_ENABLED

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define VARYINGS_NEED_SH
            #define VARYINGS_NEED_STATIC_LIGHTMAP_UV
            #define VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV

            #define HAVE_MESH_MODIFICATION

            #define SHADERPASS SHADERPASS_DECAL_GBUFFER_MESH

			#if _RENDER_PASS_ENABLED
			#define GBUFFER3 0
			#define GBUFFER4 1
			FRAMEBUFFER_INPUT_X_HALF(GBUFFER3);
			FRAMEBUFFER_INPUT_X_HALF(GBUFFER4);
			#endif

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#include "MMDEffectsCustomNodeScriptAmplifyShaderEditor.hlsl"
			#define ASE_NEEDS_FRAG_NORMAL
			#define ASE_NEEDS_FRAG_POSITION


			struct SurfaceDescription
			{
				float3 BaseColor;
				float Alpha;
				float3 NormalTS;
				float NormalAlpha;
				float Metallic;
				float Occlusion;
				float Smoothness;
				float MAOSAlpha;
				float3 Emission;
			};

            struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 uv1 : TEXCOORD1;
				float4 uv2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float3 normalWS : TEXCOORD1;
				float4 tangentWS : TEXCOORD2;
				float4 texCoord0 : TEXCOORD3;
				float3 viewDirectionWS : TEXCOORD4;
				float4 lightmapUVs : TEXCOORD5; // @diogo: packs both static (xy) and dynamic (zw)
				float3 sh : TEXCOORD6;
				float4 fogFactorAndVertexLight : TEXCOORD7;
				#ifdef USE_APV_PROBE_OCCLUSION
					float4 probeOcclusion : TEXCOORD10;
				#endif
				float3 ase_normal : NORMAL;
				float4 ase_texcoord9 : TEXCOORD9;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float4 _Ambient;
			float4 _Color;
			float4 _MainTex_ST;
			float4 _SubTex_ST;
			float4 _Specular;
			float3 _ToonTone;
			float _ShadowLum;
			float _SShad;
			float _AddLightBaseColor;
			float _EFFECTS;
			float _SPHOpacity;
			float _Shininess;
			float _SpecularIntensity;
			float _HDR;
			float _Opaque;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
			#if defined(DECAL_ANGLE_FADE)
			float _DecalAngleFadeSupported;
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


			
            void GetSurfaceData(PackedVaryings input, SurfaceDescription surfaceDescription, out DecalSurfaceData surfaceData)
            {
                #if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
                #endif

                half fadeFactor = half(1.0);

                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);

                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif

				#if defined( _MATERIAL_AFFECTS_EMISSION )
					surfaceData.emissive.rgb = half3(surfaceDescription.Emission.rgb * fadeFactor);
				#endif

                surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);

                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
						surfaceData.normalWS.xyz = normalize(mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz));
                    #else
						surfaceData.normalWS.xyz = normalize(normalToWorld[2].xyz);
                    #endif
                #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
                        float sgn = input.tangentWS.w;
                        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                        half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
        
                        surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, tangentToWorld));
                    #else
						surfaceData.normalWS.xyz = normalize(half3(input.normalWS));
                    #endif
                #endif

                surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceData.metallic = half(surfaceDescription.Metallic);
					surfaceData.occlusion = half(surfaceDescription.Occlusion);
					surfaceData.smoothness = half(surfaceDescription.Smoothness);
					surfaceData.MAOSAlpha = half(surfaceDescription.MAOSAlpha * fadeFactor);
				#endif
            }

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
            #define DECAL_PROJECTOR
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_MESH
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
            #define DECAL_DBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH)
            #define DECAL_SCREEN_SPACE
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_GBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH)
            #define DECAL_FORWARD_EMISSIVE
            #endif

            #if ((!defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_ALBEDO)) || (defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_NORMAL_BLEND))) && (defined(DECAL_SCREEN_SPACE) || defined(DECAL_GBUFFER))
            #define DECAL_RECONSTRUCT_NORMAL
            #elif defined(DECAL_ANGLE_FADE)
            #define DECAL_LOAD_NORMAL
            #endif

            #ifdef _DECAL_LAYERS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareRenderingLayerTexture.hlsl"
            #endif

            #if defined(DECAL_LOAD_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
            #endif

            #if defined(DECAL_PROJECTOR) || defined(DECAL_RECONSTRUCT_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #endif

            #ifdef DECAL_MESH
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DecalMeshBiasTypeEnum.cs.hlsl"
            #endif

            #ifdef DECAL_RECONSTRUCT_NORMAL
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NormalReconstruction.hlsl"
            #endif

			void MeshDecalsPositionZBias(inout PackedVaryings input)
			{
			#if UNITY_REVERSED_Z
				input.positionCS.z -= _DecalMeshDepthBias;
			#else
				input.positionCS.z += _DecalMeshDepthBias;
			#endif
			}

			void InitializeInputData(PackedVaryings input, float3 positionWS, half3 normalWS, half3 viewDirectionWS, out InputData inputData)
			{
				inputData = (InputData)0;

				inputData.positionWS = positionWS;
				inputData.normalWS = normalWS;
				inputData.viewDirectionWS = viewDirectionWS;
				inputData.shadowCoord = float4(0, 0, 0, 0);

				#ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
					inputData.fogCoord = InitializeInputDataFog(float4(positionWS, 1.0), input.fogFactorAndVertexLight.x);
					inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
				#endif

				#if defined(VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV) && defined(DYNAMICLIGHTMAP_ON)
					inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV.xy, half3(input.sh), normalWS);
					#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
					inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
					#endif
				#elif defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
				#if !defined(LIGHTMAP_ON) && (defined(PROBE_VOLUMES_L1) || defined(PROBE_VOLUMES_L2))
    				inputData.bakedGI = SAMPLE_GI(input.sh,
					GetAbsolutePositionWS(inputData.positionWS),
					inputData.normalWS,
					inputData.viewDirectionWS,
					input.positionCS.xy,
					input.probeOcclusion,
					inputData.shadowMask);
				#else
					inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, half3(input.sh), normalWS);
					#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
					inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
					#endif
				#endif
				#endif

				#if defined(DEBUG_DISPLAY)
					#if defined(VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV) && defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = input.dynamicLightmapUV.xy;
					#endif
					#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV) && defined(LIGHTMAP_ON)
						inputData.staticLightmapUV = input.staticLightmapUV
					#elif defined(VARYINGS_NEED_SH)
						inputData.vertexSH = input.sh;
					#endif
					#if defined(USE_APV_PROBE_OCCLUSION)
						inputData.probeOcclusion = input.probeOcclusion;
					#endif
				#endif

				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
			}

			void GetSurface(DecalSurfaceData decalSurfaceData, inout SurfaceData surfaceData)
			{
				surfaceData.albedo = decalSurfaceData.baseColor.rgb;
				surfaceData.metallic = saturate(decalSurfaceData.metallic);
				surfaceData.specular = 0;
				surfaceData.smoothness = saturate(decalSurfaceData.smoothness);
				surfaceData.occlusion = decalSurfaceData.occlusion;
				surfaceData.emission = decalSurfaceData.emissive;
				surfaceData.alpha = saturate(decalSurfaceData.baseColor.w);
				surfaceData.clearCoatMask = 0;
				surfaceData.clearCoatSmoothness = 1;
			}

			PackedVaryings Vert(Attributes inputMesh  )
			{
				if (_DecalMeshBiasType == DECALMESHDEPTHBIASTYPE_VIEW_BIAS)
				{
					float3 viewDirectionOS = GetObjectSpaceNormalizeViewDir(inputMesh.positionOS);
					inputMesh.positionOS += viewDirectionOS * (_DecalMeshViewBias);
				}

				PackedVaryings packedOutput;
				ZERO_INITIALIZE(PackedVaryings, packedOutput);

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, packedOutput);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(packedOutput);

				inputMesh.tangentOS = float4( 1, 0, 0, -1 );
				inputMesh.normalOS = float3( 0, 1, 0 );

				packedOutput.ase_normal = inputMesh.normalOS;
				packedOutput.ase_texcoord9 = float4(inputMesh.positionOS,1);

				VertexPositionInputs vertexInput = GetVertexPositionInputs(inputMesh.positionOS.xyz);

				float3 positionWS = TransformObjectToWorld(inputMesh.positionOS);
				float3 normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);
				float4 tangentWS = float4(TransformObjectToWorldDir(inputMesh.tangentOS.xyz), inputMesh.tangentOS.w);

				packedOutput.positionCS = TransformWorldToHClip(positionWS);

				if (_DecalMeshBiasType == DECALMESHDEPTHBIASTYPE_DEPTH_BIAS)
				{
					MeshDecalsPositionZBias(packedOutput);
				}

				packedOutput.positionWS.xyz = positionWS;
				packedOutput.normalWS.xyz =  normalWS;
				packedOutput.tangentWS.xyzw =  tangentWS;
				packedOutput.texCoord0.xyzw =  inputMesh.uv0;
				packedOutput.viewDirectionWS.xyz =  GetWorldSpaceViewDir(positionWS);

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV(inputMesh.uv1, unity_LightmapST, packedOutput.staticLightmapUV);
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					packedOutput.dynamicLightmapUV.xy = inputMesh.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if !defined(LIGHTMAP_ON)
					packedOutput.sh.xyz =  float3(SampleSHVertex(half3(normalWS)));
				#endif

				half fogFactor = 0;
				#if !defined(_FOG_FRAGMENT)
						fogFactor = ComputeFogFactor(packedOutput.positionCS.z);
				#endif

				half3 vertexLight = VertexLighting(positionWS, normalWS);
				packedOutput.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

				return packedOutput;
			}

			void Frag(PackedVaryings packedInput,
				out FragmentOutput fragmentOutput
				
			)
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);
				UNITY_SETUP_INSTANCE_ID(packedInput);

				half angleFadeFactor = 1.0;

            #ifdef _DECAL_LAYERS
            #ifdef _RENDER_PASS_ENABLED
				uint surfaceRenderingLayer = DecodeMeshRenderingLayer(LOAD_FRAMEBUFFER_INPUT(GBUFFER4, packedInput.positionCS.xy).r);
            #else
				uint surfaceRenderingLayer = LoadSceneRenderingLayer(packedInput.positionCS.xy);
            #endif
				uint projectorRenderingLayer = uint(UNITY_ACCESS_INSTANCED_PROP(Decal, _DecalLayerMaskFromDecal));
				clip((surfaceRenderingLayer & projectorRenderingLayer) - 0.1);
            #endif

			#if defined(DECAL_RECONSTRUCT_NORMAL)
				#if defined(_DECAL_NORMAL_BLEND_HIGH)
					half3 normalWS = half3(ReconstructNormalTap9(packedInput.positionCS.xy));
				#elif defined(_DECAL_NORMAL_BLEND_MEDIUM)
					half3 normalWS = half3(ReconstructNormalTap5(packedInput.positionCS.xy));
				#else
					half3 normalWS = half3(ReconstructNormalDerivative(packedInput.positionCS.xy));
				#endif
			#elif defined(DECAL_LOAD_NORMAL)
				half3 normalWS = half3(LoadSceneNormals(packedInput.positionCS.xy));
			#endif

				float2 positionSS = FoveatedRemapNonUniformToLinearCS(packedInput.positionCS.xy) * _ScreenSize.zw;

				float3 positionWS = packedInput.positionWS.xyz;
				half3 viewDirectionWS = half3(packedInput.viewDirectionWS);

				DecalSurfaceData surfaceData;
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float4 temp_cast_0 = (1.0).xxxx;
				float4 temp_cast_1 = (1.0).xxxx;
				float3 ToonTone32 = _ToonTone;
				float3 break52 = ToonTone32;
				float3 objToWorldDir84 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_normal, 0 ) ).xyz;
				float3 normalizeResult59 = normalize( objToWorldDir84 );
				float3 normalizeResult60 = normalize( _MainLightPosition.xyz );
				float dotResult62 = dot( normalizeResult59 , normalizeResult60 );
				float NdotL89 = dotResult62;
				float localshadowAtten190 = ( 0.0 );
				float3 objToWorld114 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_texcoord9.xyz, 1 ) ).xyz;
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
				float3 originalLightColor174 = ( OutputColor188 + _AddLightBaseColor );
				half3 MMDLIT_GLOBALLIGHTING139 = half3(0.6,0.6,0.6);
				float3 lightColor178 = ( originalLightColor174 * MMDLIT_GLOBALLIGHTING139 );
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
				float3 objToWorldDir141 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_normal, 0 ) ).xyz;
				float3 normal187 = objToWorldDir141;
				float3 Output187 = float3( 0,0,0 );
				vLight_float( normal187 , Output187 );
				float3 appendResult136 = (float3(1.0 , 1.0 , 1.0));
				half3 MMDLIT_CENTERAMBIENT138 = half3(0.5,0.5,0.5);
				float4 break163 = Ambient44;
				float3 appendResult162 = (float3(break163.r , break163.g , break163.b));
				half3 MMDLIT_CENTERAMBIENT_INV171 = ( half3(1,1,1) / 0.5 );
				float3 MMDLit_GetTempAmbientL135 = ( max( ( MMDLIT_CENTERAMBIENT138 - appendResult162 ) , float3(0,0,0) ) * MMDLIT_CENTERAMBIENT_INV171 );
				float3 MMDLit_GetAmbientRate48 = ( appendResult136 - MMDLit_GetTempAmbientL135 );
				float3 MMDLit_GetTempAmbient144 = ( Output187 * MMDLit_GetAmbientRate48 );
				float3 appendResult155 = (float3(0.0 , 0.0 , 0.0));
				float3 MMDLit_GetTempDiffuse160 = max( ( min( ( appendResult150 + ( appendResult152 * MMDLIT_GLOBALLIGHTING139 ) ) , appendResult154 ) - MMDLit_GetTempAmbient144 ) , appendResult155 );
				float2 uv_MainTex = packedInput.texCoord0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 Albedo12 = tex2D( _MainTex, uv_MainTex );
				float4 temp_output_78_0 = ( float4( MMDLit_GetTempDiffuse160 , 0.0 ) * Albedo12 );
				float4 Base399 = temp_output_78_0;
				float3 objToView109 = mul( UNITY_MATRIX_MV, float4( packedInput.ase_texcoord9.xyz, 1 ) ).xyz;
				float3 normalizeResult64 = normalize( objToView109 );
				float3 objToViewDir67 = normalize( mul( UNITY_MATRIX_IT_MV, float4( packedInput.ase_normal, 0 ) ).xyz );
				float3 normalizeResult65 = normalize( objToViewDir67 );
				float4 SphereCube37 = texCUBE( _SphereCube, reflect( normalizeResult64 , normalizeResult65 ) );
				float4 temp_output_57_0 = ( SphereCube37 * _SPHOpacity );
				float4 Add399 = ( temp_output_78_0 + temp_output_57_0 );
				float4 temp_output_39_0 = ( temp_output_57_0 * Albedo12 );
				float4 Multi399 = ( temp_output_39_0 * float4( MMDLit_GetTempDiffuse160 , 0.0 ) );
				float2 uv_SubTex = packedInput.texCoord0.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float4 tex2DNode379 = tex2D( _SubTex, uv_SubTex );
				float4 Sub399 = ( float4( MMDLit_GetTempDiffuse160 , 0.0 ) * Albedo12 * tex2DNode379 );
				float4 RGBA399 = float4( 0,0,0,0 );
				effectsControl_float( Layer399 , Base399 , Add399 , Multi399 , Sub399 , RGBA399 );
				float3 objToWorldDir180 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_normal, 0 ) ).xyz;
				float3 normalizeResult181 = normalize( objToWorldDir180 );
				float3 ase_viewVectorWS = ( _WorldSpaceCameraPos.xyz - packedInput.positionWS );
				float3 ase_viewDirWS = normalize( ase_viewVectorWS );
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
				float4 FinalColor336 = ( ( ( saturate( ( temp_cast_0 - ( _ShadowLum * ( temp_cast_1 - ( _SShad == (float)0 ? tex2DNode92 : lerpResult431 ) ) ) ) ) * float4( lightColor178 , 0.0 ) * RGBA399 ) + ( ( Specular131 * _Specular * float4( lightColor178 , 0.0 ) ) * _SpecularIntensity ) ) + ( baseC73 * float4( MMDLit_GetAmbientRate48 , 0.0 ) ) );
				

				surfaceDescription.BaseColor = ( FinalColor336 * _HDR ).rgb;
				surfaceDescription.Alpha = saturate( ( _Opaque * ( tSphereMapBlend289 == (float)3 ? ( tex2DNode379.a * Albedo12.a ) : Albedo12.a ) ) );
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.NormalAlpha = 1;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceDescription.Metallic = 0;
					surfaceDescription.Occlusion = 1;
					surfaceDescription.Smoothness = 0.5;
					surfaceDescription.MAOSAlpha = 1;
				#endif

				#if defined( _MATERIAL_AFFECTS_EMISSION )
					surfaceDescription.Emission = float3(0, 0, 0);
				#endif

				GetSurfaceData(packedInput, surfaceDescription, surfaceData);

				half3 normalToPack = surfaceData.normalWS.xyz;
				#ifdef DECAL_RECONSTRUCT_NORMAL
					surfaceData.normalWS.xyz = normalize(lerp(normalWS.xyz, surfaceData.normalWS.xyz, surfaceData.normalWS.w));
				#endif

					InputData inputData;
					InitializeInputData(packedInput, positionWS, surfaceData.normalWS.xyz, viewDirectionWS, inputData);

					SurfaceData surface = (SurfaceData)0;
					GetSurface(surfaceData, surface);

					BRDFData brdfData;
					InitializeBRDFData(surface.albedo, surface.metallic, 0, surface.smoothness, surface.alpha, brdfData);

				#ifdef _MATERIAL_AFFECTS_ALBEDO
					Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, inputData.shadowMask);
					MixRealtimeAndBakedGI(mainLight, surfaceData.normalWS.xyz, inputData.bakedGI, inputData.shadowMask);
					half3 color = GlobalIllumination(brdfData, inputData.bakedGI, surface.occlusion, surfaceData.normalWS.xyz, inputData.viewDirectionWS);
				#else
					half3 color = 0;
				#endif

				#pragma warning (disable : 3578) // The output value isn't completely initialized.
				half3 packedNormalWS = PackNormal(normalToPack);
				fragmentOutput.GBuffer0 = half4(surfaceData.baseColor.rgb, surfaceData.baseColor.a);
				fragmentOutput.GBuffer1 = 0;
				fragmentOutput.GBuffer2 = half4(packedNormalWS, surfaceData.normalWS.a);
				fragmentOutput.GBuffer3 = half4(surfaceData.emissive + color, surfaceData.baseColor.a);
				#if OUTPUT_SHADOWMASK
					fragmentOutput.GBuffer4 = inputData.shadowMask; // will have unity_ProbesOcclusion value if subtractive lighting is used (baked)
				#endif
				#pragma warning (default : 3578) // Restore output value isn't completely initialized.

			}

            ENDHLSL
        }

		
        Pass
        {
            
			Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }

            Cull Back

			HLSLPROGRAM

			#define _MATERIAL_AFFECTS_ALBEDO 1
			#define _MATERIAL_AFFECTS_NORMAL 1
			#define _MATERIAL_AFFECTS_NORMAL_BLEND 1
			#define ASE_SRP_VERSION 170003


			#pragma multi_compile_instancing
			#pragma editor_sync_compilation
			#pragma vertex Vert
			#pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #define HAVE_MESH_MODIFICATION

            #define SHADERPASS SHADERPASS_DEPTHONLY
			#define SCENEPICKINGPASS 1

			#if _RENDER_PASS_ENABLED
			#define GBUFFER3 0
			#define GBUFFER4 1
			FRAMEBUFFER_INPUT_X_HALF(GBUFFER3);
			FRAMEBUFFER_INPUT_X_HALF(GBUFFER4);
			#endif

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"

			#include "MMDEffectsCustomNodeScriptAmplifyShaderEditor.hlsl"
			#define ASE_NEEDS_FRAG_NORMAL
			#define ASE_NEEDS_FRAG_POSITION


			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float4 _Ambient;
			float4 _Color;
			float4 _MainTex_ST;
			float4 _SubTex_ST;
			float4 _Specular;
			float3 _ToonTone;
			float _ShadowLum;
			float _SShad;
			float _AddLightBaseColor;
			float _EFFECTS;
			float _SPHOpacity;
			float _Shininess;
			float _SpecularIntensity;
			float _HDR;
			float _Opaque;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
			#if defined(DECAL_ANGLE_FADE)
			float _DecalAngleFadeSupported;
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


			
            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
            #define DECAL_PROJECTOR
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_MESH
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
            #define DECAL_DBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH)
            #define DECAL_SCREEN_SPACE
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_GBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH)
            #define DECAL_FORWARD_EMISSIVE
            #endif

            #if ((!defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_ALBEDO)) || (defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_NORMAL_BLEND))) && (defined(DECAL_SCREEN_SPACE) || defined(DECAL_GBUFFER))
            #define DECAL_RECONSTRUCT_NORMAL
            #elif defined(DECAL_ANGLE_FADE)
            #define DECAL_LOAD_NORMAL
            #endif

            #ifdef _DECAL_LAYERS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareRenderingLayerTexture.hlsl"
            #endif

            #if defined(DECAL_LOAD_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
            #endif

            #if defined(DECAL_PROJECTOR) || defined(DECAL_RECONSTRUCT_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #endif

            #ifdef DECAL_MESH
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DecalMeshBiasTypeEnum.cs.hlsl"
            #endif

            #ifdef DECAL_RECONSTRUCT_NORMAL
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NormalReconstruction.hlsl"
            #endif

			PackedVaryings Vert(Attributes inputMesh  )
			{
				PackedVaryings packedOutput;
				ZERO_INITIALIZE(PackedVaryings, packedOutput);

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, packedOutput);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(packedOutput);

				inputMesh.tangentOS = float4( 1, 0, 0, -1 );
				inputMesh.normalOS = float3( 0, 1, 0 );

				float3 ase_worldPos = TransformObjectToWorld( (inputMesh.positionOS).xyz );
				packedOutput.ase_texcoord2.xyz = ase_worldPos;
				
				packedOutput.ase_normal = inputMesh.normalOS;
				packedOutput.ase_texcoord = float4(inputMesh.positionOS,1);
				packedOutput.ase_texcoord1.xyz = inputMesh.ase_texcoord.xyz;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				packedOutput.ase_texcoord1.w = 0;
				packedOutput.ase_texcoord2.w = 0;

				float3 positionWS = TransformObjectToWorld(inputMesh.positionOS);
				packedOutput.positionCS = TransformWorldToHClip(positionWS);

				return packedOutput;
			}

			void Frag(PackedVaryings packedInput,
				out float4 outColor : SV_Target0
				
			)
			{
				float4 temp_cast_0 = (1.0).xxxx;
				float4 temp_cast_1 = (1.0).xxxx;
				float3 ToonTone32 = _ToonTone;
				float3 break52 = ToonTone32;
				float3 objToWorldDir84 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_normal, 0 ) ).xyz;
				float3 normalizeResult59 = normalize( objToWorldDir84 );
				float3 normalizeResult60 = normalize( _MainLightPosition.xyz );
				float dotResult62 = dot( normalizeResult59 , normalizeResult60 );
				float NdotL89 = dotResult62;
				float localshadowAtten190 = ( 0.0 );
				float3 objToWorld114 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_texcoord.xyz, 1 ) ).xyz;
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
				float3 originalLightColor174 = ( OutputColor188 + _AddLightBaseColor );
				half3 MMDLIT_GLOBALLIGHTING139 = half3(0.6,0.6,0.6);
				float3 lightColor178 = ( originalLightColor174 * MMDLIT_GLOBALLIGHTING139 );
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
				float3 objToWorldDir141 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_normal, 0 ) ).xyz;
				float3 normal187 = objToWorldDir141;
				float3 Output187 = float3( 0,0,0 );
				vLight_float( normal187 , Output187 );
				float3 appendResult136 = (float3(1.0 , 1.0 , 1.0));
				half3 MMDLIT_CENTERAMBIENT138 = half3(0.5,0.5,0.5);
				float4 break163 = Ambient44;
				float3 appendResult162 = (float3(break163.r , break163.g , break163.b));
				half3 MMDLIT_CENTERAMBIENT_INV171 = ( half3(1,1,1) / 0.5 );
				float3 MMDLit_GetTempAmbientL135 = ( max( ( MMDLIT_CENTERAMBIENT138 - appendResult162 ) , float3(0,0,0) ) * MMDLIT_CENTERAMBIENT_INV171 );
				float3 MMDLit_GetAmbientRate48 = ( appendResult136 - MMDLit_GetTempAmbientL135 );
				float3 MMDLit_GetTempAmbient144 = ( Output187 * MMDLit_GetAmbientRate48 );
				float3 appendResult155 = (float3(0.0 , 0.0 , 0.0));
				float3 MMDLit_GetTempDiffuse160 = max( ( min( ( appendResult150 + ( appendResult152 * MMDLIT_GLOBALLIGHTING139 ) ) , appendResult154 ) - MMDLit_GetTempAmbient144 ) , appendResult155 );
				float2 uv_MainTex = packedInput.ase_texcoord1.xyz.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 Albedo12 = tex2D( _MainTex, uv_MainTex );
				float4 temp_output_78_0 = ( float4( MMDLit_GetTempDiffuse160 , 0.0 ) * Albedo12 );
				float4 Base399 = temp_output_78_0;
				float3 objToView109 = mul( UNITY_MATRIX_MV, float4( packedInput.ase_texcoord.xyz, 1 ) ).xyz;
				float3 normalizeResult64 = normalize( objToView109 );
				float3 objToViewDir67 = normalize( mul( UNITY_MATRIX_IT_MV, float4( packedInput.ase_normal, 0 ) ).xyz );
				float3 normalizeResult65 = normalize( objToViewDir67 );
				float4 SphereCube37 = texCUBE( _SphereCube, reflect( normalizeResult64 , normalizeResult65 ) );
				float4 temp_output_57_0 = ( SphereCube37 * _SPHOpacity );
				float4 Add399 = ( temp_output_78_0 + temp_output_57_0 );
				float4 temp_output_39_0 = ( temp_output_57_0 * Albedo12 );
				float4 Multi399 = ( temp_output_39_0 * float4( MMDLit_GetTempDiffuse160 , 0.0 ) );
				float2 uv_SubTex = packedInput.ase_texcoord1.xyz.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float4 tex2DNode379 = tex2D( _SubTex, uv_SubTex );
				float4 Sub399 = ( float4( MMDLit_GetTempDiffuse160 , 0.0 ) * Albedo12 * tex2DNode379 );
				float4 RGBA399 = float4( 0,0,0,0 );
				effectsControl_float( Layer399 , Base399 , Add399 , Multi399 , Sub399 , RGBA399 );
				float3 objToWorldDir180 = mul( GetObjectToWorldMatrix(), float4( packedInput.ase_normal, 0 ) ).xyz;
				float3 normalizeResult181 = normalize( objToWorldDir180 );
				float3 ase_worldPos = packedInput.ase_texcoord2.xyz;
				float3 ase_viewVectorWS = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				float3 ase_viewDirWS = normalize( ase_viewVectorWS );
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
				float4 FinalColor336 = ( ( ( saturate( ( temp_cast_0 - ( _ShadowLum * ( temp_cast_1 - ( _SShad == (float)0 ? tex2DNode92 : lerpResult431 ) ) ) ) ) * float4( lightColor178 , 0.0 ) * RGBA399 ) + ( ( Specular131 * _Specular * float4( lightColor178 , 0.0 ) ) * _SpecularIntensity ) ) + ( baseC73 * float4( MMDLit_GetAmbientRate48 , 0.0 ) ) );
				

				float3 BaseColor = ( FinalColor336 * _HDR ).rgb;

				outColor = _SelectionID;
			}
			ENDHLSL
        }
    }
	CustomEditor "UnityEditor.Rendering.Universal.DecalShaderGraphGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19700
Node;AmplifyShaderEditor.CommentaryNode;21;-5984,-4640;Inherit;False;1276.801;543.8008;NdotL;7;89;62;59;60;61;84;68;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;273;-4448,-7424;Inherit;False;1628.8;1278.8;Base Properties;17;12;10;37;40;43;65;64;67;109;66;110;13;11;32;44;28;292;;1,1,1,1;0;0
Node;AmplifyShaderEditor.NormalVertexDataNode;68;-5952,-4576;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;272;-4640,-4640;Inherit;False;1919.175;991.1285;Light Calculation;18;51;53;174;488;491;188;294;54;50;34;112;58;190;52;111;90;114;113;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TransformDirectionNode;84;-5728,-4576;Inherit;True;Object;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;292;-3232,-7360;Inherit;True;Property;_ToonTone;Toon Tone;16;0;Create;False;0;0;0;False;0;False;1,0.5,0.5;1,0.5,0.5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;28;-3264,-6592;Inherit;False;Property;_Ambient;Ambient;2;0;Create;True;1;;0;0;False;0;False;1,1,1,0;1,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;61;-5728,-4320;Inherit;True;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;274;-5312,-7424;Inherit;False;798.9624;1278.231;MMD constants;8;171;170;139;166;169;168;138;167;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;22;-4448,-6080;Inherit;False;1726.917;637.1161;MMDLit_GetTempAmbientL;10;135;164;33;134;31;165;29;41;163;162;;1,1,1,1;0;0
Node;AmplifyShaderEditor.NormalizeNode;60;-5472,-4320;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;59;-5472,-4576;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;-3040,-6592;Inherit;False;Ambient;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-3040,-7360;Inherit;False;ToonTone;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;113;-4608,-4192;Inherit;True;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;62;-5184,-4448;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;167;-5280,-7040;Half;True;Constant;_Vector3;Vector 2;14;0;Create;True;0;0;0;False;0;False;0.5,0.5,0.5;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;164;-4416,-5920;Inherit;False;44;Ambient;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TransformPositionNode;114;-4352,-4192;Inherit;True;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;90;-4160,-4448;Inherit;False;32;ToonTone;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;138;-5056,-7040;Half;False;MMDLIT_CENTERAMBIENT;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;163;-4224,-5920;Inherit;True;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;111;-3776,-4064;Inherit;False;Constant;_Float1;Float 1;5;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;52;-3904,-4448;Inherit;True;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.CustomExpressionNode;190;-3936,-4192;Float;False;#pragma multi_compile _ _MAIN_LIGHT_SHADOWS$#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE$float4 shadowCoord = TransformWorldToShadowCoord(worldPos)@$Light mainLight = GetMainLight(shadowCoord)@$return mainLight.shadowAttenuation@;7;File;2;True;worldPos;FLOAT3;0,0,0;In;;Inherit;False;True;OutputShadowAtten;FLOAT;0;Out;;Inherit;False;shadowAtten;False;False;0;e1babb63bddea7d4eaa42c4d36116b49;True;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;2;FLOAT;0;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;169;-5280,-6400;Inherit;True;Constant;_Float7;Float 7;10;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;168;-5280,-6720;Half;True;Constant;_Vector4;Vector 2;14;0;Create;True;0;0;0;False;0;False;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;89;-4928,-4448;Inherit;False;NdotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;162;-4000,-5920;Inherit;True;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;165;-4064,-6016;Inherit;False;138;MMDLIT_CENTERAMBIENT;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-3520,-4480;Inherit;False;89;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;112;-3552,-4160;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;34;-3568,-4528;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;170;-5056,-6592;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;41;-3776,-5760;Inherit;True;Constant;_Vector0;Vector 0;3;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;29;-3776,-6016;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-3296,-4224;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-3296,-4576;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;294;-3088,-4368;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;171;-4832,-6592;Half;False;MMDLIT_CENTERAMBIENT_INV;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;25;-2304,-4736;Inherit;False;673.5999;319.8001;ToonRefl;3;416;38;36;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;31;-3520,-6016;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;134;-3552,-5760;Inherit;False;171;MMDLIT_CENTERAMBIENT_INV;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-2944,-4576;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;51;-2944,-4320;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-3232,-6016;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMinOpNode;36;-2272,-4672;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;11;-3264,-6368;Inherit;False;Property;_Color;Diffuse;0;1;[Header];Create;False;1;Material Color;0;0;False;0;False;0.8,0.8,0.8,0;0,0,1,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.CommentaryNode;19;-2656,-6080;Inherit;False;703.1996;318.2003;globalAmbient;3;187;141;142;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;23;-2656,-5696;Inherit;False;861.6006;412.5996;MMDLit_GetAmbientRate;4;48;35;161;136;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;26;-5024,-5376;Inherit;False;2302.557;671.2762;MMDLit_GetTempDiffuse;16;160;157;145;153;147;159;158;152;151;149;154;150;155;148;146;156;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;417;-2656,-5216;Inherit;False;1375.195;414.165;MMDLIT_GetToonShadow;8;424;423;421;422;420;418;419;425;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-3040,-6368;Inherit;False;Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;416;-2048,-4672;Inherit;False;toonRefl;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;135;-3008,-6016;Inherit;False;MMDLit_GetTempAmbientL;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;158;-4992,-5056;Inherit;False;13;Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;419;-2624,-5056;Inherit;False;Constant;_Float3;Float 3;33;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;166;-5280,-7360;Half;True;Constant;_Vector2;Vector 2;14;0;Create;True;0;0;0;False;0;False;0.6,0.6,0.6;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;425;-2624,-5152;Inherit;False;416;toonRefl;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;142;-2624,-6016;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;136;-2624,-5632;Inherit;True;FLOAT3;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;161;-2624,-5376;Inherit;False;135;MMDLit_GetTempAmbientL;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;110;-4416,-6816;Inherit;True;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;66;-4416,-6560;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;149;-4992,-5280;Inherit;False;44;Ambient;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;159;-4800,-5056;Inherit;True;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;418;-2400,-5152;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;139;-5056,-7360;Half;False;MMDLIT_GLOBALLIGHTING;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;141;-2400,-6016;Inherit;True;Object;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;35;-2304,-5632;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;24;-1728,-5920;Inherit;False;575.2;317.3999;MMDLit_GetTempAmbient;2;144;70;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TransformPositionNode;109;-4160,-6816;Inherit;True;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformDirectionNode;67;-4160,-6560;Inherit;True;Object;View;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;151;-4800,-5280;Inherit;True;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;152;-4576,-5056;Inherit;True;FLOAT3;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;420;-2176,-5152;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;422;-2112,-4896;Inherit;False;Constant;_Float4;Float 4;33;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-2080,-5632;Inherit;False;MMDLit_GetAmbientRate;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;187;-2176,-6016;Float;False;return SampleSH(normal)@$;7;File;2;True;normal;FLOAT3;0,0,0;In;;Inherit;False;True;Output;FLOAT3;0,0,0;Out;;Inherit;False;vLight;False;False;0;e1babb63bddea7d4eaa42c4d36116b49;True;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;2;FLOAT;0;FLOAT3;3
Node;AmplifyShaderEditor.GetLocalVarNode;153;-4640,-4800;Inherit;False;139;MMDLIT_GLOBALLIGHTING;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;271;-4448,-3584;Inherit;False;1724.8;794.8001;Specular;14;123;125;124;180;129;131;127;179;126;181;122;121;130;128;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;20;-1216,-5216;Inherit;False;2335.284;833.136;RAMP;20;435;437;430;429;427;93;92;436;431;433;432;434;295;94;47;97;96;95;46;426;;1,1,1,1;0;0
Node;AmplifyShaderEditor.NormalizeNode;64;-3904,-6816;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;65;-3904,-6560;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;150;-4576,-5280;Inherit;True;FLOAT3;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;-4320,-5056;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;421;-1920,-5152;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;38;-1824,-4672;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-1696,-5856;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;179;-4416,-3520;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ReflectOpNode;43;-3616,-6816;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;148;-4096,-5280;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;154;-4064,-5024;Inherit;True;FLOAT3;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;423;-1696,-5152;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;93;-1184,-4800;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;427;-1120,-4544;Inherit;False;Constant;_Vector1;Vector 1;32;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.IntNode;430;-1152,-4896;Inherit;False;Constant;_Int1;Int 1;33;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;429;-1152,-5152;Inherit;True;Property;_SShad;S-Shad;5;2;[Header];[ToggleUI];Create;True;1;Rendering;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;125;-4416,-3072;Inherit;True;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;124;-4416,-3296;Inherit;True;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;144;-1472,-5856;Inherit;False;MMDLit_GetTempAmbient;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;126;-4160,-3264;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMinOpNode;146;-3840,-5280;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;-3808,-5024;Inherit;False;144;MMDLit_GetTempAmbient;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;180;-4160,-3520;Inherit;True;Object;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Compare;426;-928,-4928;Inherit;True;0;4;0;FLOAT;0;False;1;INT;0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;40;-3328,-6816;Inherit;True;Property;_SphereCube;SPH;9;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;72a6f54d8d7e13442a02fcc34b43d48a;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RegisterLocalVarNode;424;-1504,-5152;Inherit;False;toonShadow;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;188;-4064,-3936;Float;False;$float4 shadowCoord = TransformWorldToShadowCoord(worldPos)@$Light mainLight = GetMainLight(shadowCoord)@$return mainLight.color@;7;File;2;True;worldPos;FLOAT3;0,0,0;In;;Inherit;False;True;OutputColor;FLOAT3;0,0,0;Out;;Inherit;False;lightColor;False;False;0;e1babb63bddea7d4eaa42c4d36116b49;True;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;2;FLOAT;0;FLOAT3;3
Node;AmplifyShaderEditor.RangedFloatNode;491;-4096,-3808;Inherit;False;Property;_AddLightBaseColor;Add Light Base Color;14;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;282;-2656,-4352;Inherit;False;2112.863;1888.244;Sphere Map Composition - Option to Add, Multiply, Sub Tex, Turn off the effect;26;399;73;400;401;380;80;77;379;408;284;407;377;378;78;39;71;289;406;405;283;75;79;207;57;56;63;;1,1,1,1;0;0
Node;AmplifyShaderEditor.NormalizeNode;181;-3936,-3520;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;127;-3936,-3264;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-3040,-6816;Inherit;False;SphereCube;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;156;-3504,-5280;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;155;-3456,-5024;Inherit;True;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;432;-672,-4672;Inherit;False;Constant;_Vector5;Vector 5;33;0;Create;True;0;0;0;False;0;False;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;433;-672,-4480;Inherit;False;424;toonShadow;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;92;-672,-4928;Inherit;True;Property;_ToonTex;Toon;8;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;e5c69abc421298e47bf21483382e7549;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleAddOpNode;488;-3776,-3904;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;281;-480,-4352;Inherit;False;766.3999;318;Main light color;4;176;177;178;487;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;128;-3648,-3520;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;157;-3232,-5280;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-3648,-3040;Inherit;True;Constant;_smoothness;smoothness;11;0;Create;True;0;0;0;False;0;False;0.001;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;431;-384,-4640;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;436;-208,-5008;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;437;-336,-4752;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.IntNode;435;-320,-4832;Inherit;False;Constant;_Int7;Int 1;33;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-3648,-3264;Inherit;True;Property;_Shininess;Reflection;4;0;Create;False;0;0;0;False;0;False;50;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;10;-3328,-7040;Inherit;True;Property;_MainTex;Texture;7;0;Create;False;1;Texture (Memo);0;0;False;0;False;-1;None;73029f145f0f8b2469831e89ee17037b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.GetLocalVarNode;63;-2560,-3808;Inherit;False;37;SphereCube;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-2624,-3712;Inherit;True;Property;_SPHOpacity;SPH Opacity;12;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;174;-3552,-3904;Inherit;False;originalLightColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;-3040,-7040;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;130;-3424,-3520;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;121;-3456,-3264;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;160;-3008,-5280;Inherit;False;MMDLit_GetTempDiffuse;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;295;32,-4864;Inherit;False;Constant;_Float0;Float 0;40;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;434;-96,-4768;Inherit;True;0;4;0;FLOAT;0;False;1;INT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;176;-448,-4192;Inherit;False;139;MMDLIT_GLOBALLIGHTING;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;487;-448,-4288;Inherit;False;174;originalLightColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-2304,-3808;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;-160,-4288;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;129;-3200,-3520;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;46;192,-4832;Inherit;True;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;47;192,-5088;Inherit;True;Property;_ShadowLum;Shadow Luminescence;13;0;Create;False;0;0;0;False;0;False;1.5;1.5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;207;-1600,-4288;Inherit;True;Property;_EFFECTS;Effects;6;2;[Header];[Enum];Create;False;1;Texture (Memo);4;Disabled;0;Add Sphere;1;Multi Sphere;2;Sub Tex;3;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;-1792,-3552;Inherit;False;160;MMDLit_GetTempDiffuse;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;-1632,-3296;Inherit;False;12;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;283;-2016,-3936;Inherit;False;12;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;405;-2064,-3984;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;406;-2016,-3680;Inherit;False;12;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;280;-480,-3328;Inherit;False;829.5997;573.9999;Specular Final Calculation;6;86;88;82;87;83;85;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;480,-4832;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;94;512,-4928;Inherit;False;Constant;_Float5;Float 5;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;289;-1408,-4288;Inherit;False;tSphereMapBlend;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;71;-1792,-4064;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1792,-3808;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-1408,-3360;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;407;-2064,-3312;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;408;-1408,-3744;Inherit;False;12;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;379;-1536,-2688;Inherit;True;Property;_SubTex;SPH SubTex;10;0;Create;False;0;0;0;False;0;False;-1;None;a4bd0e91e1c27e244a687b69ae743b93;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.GetLocalVarNode;377;-1536,-2784;Inherit;False;12;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;378;-1536,-2880;Inherit;False;160;MMDLit_GetTempDiffuse;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;284;-1408,-4064;Inherit;False;12;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;131;-2944,-3520;Inherit;False;Specular;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;178;64,-4288;Inherit;False;lightColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;-384,-2976;Inherit;False;178;lightColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;-384,-3264;Inherit;False;131;Specular;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;96;704,-4832;Inherit;True;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;82;-448,-3168;Inherit;False;Property;_Specular;Specular;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,1,1,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-1408,-3616;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;80;-1152,-3136;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;380;-1152,-2880;Inherit;True;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;401;-992,-3552;Inherit;False;289;tSphereMapBlend;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;400;-1120,-4000;Float;False;#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS$#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS$#pragma multi_compile_fragment _ _SHADOWS_SOFT$#pragma multi_compile _ SHADOWS_SHADOWMASK$$$#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING$$float3 diffuseColor = 0@$WorldNormal = normalize( WorldNormal)@$$int pixelLightCount = GetAdditionalLightsCount()@$for(int i = 0@  i < pixelLightCount@ i++)${$	Light light = GetAdditionalLight(i, WorldPosition)@$        	half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation)@$        	diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal)@$}$$return diffuseColor@$;7;File;6;True;Layer;FLOAT;0;In;;Inherit;False;True;Base;FLOAT4;0,0,0,0;In;;Inherit;False;True;Add;FLOAT4;0,0,0,0;In;;Inherit;False;True;Multi;FLOAT4;0,0,0,0;In;;Inherit;False;True;Sub;FLOAT4;0,0,0,0;In;;Inherit;False;True;RGBA;FLOAT4;0,0,0,0;Out;;Inherit;False;effectsControl;False;False;0;e1babb63bddea7d4eaa42c4d36116b49;True;7;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;2;FLOAT;0;FLOAT4;7
Node;AmplifyShaderEditor.CommentaryNode;279;-480,-2688;Inherit;False;764.8726;417.5675;Final Calculation Additional Lights;3;197;195;193;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-160,-3264;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;97;928,-4832;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-160,-3008;Inherit;True;Property;_SpecularIntensity;Specular Intensity;11;1;[Header];Create;True;1;Custom Effects Settings;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;399;-736,-3424;Float;False;#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS$#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS$#pragma multi_compile_fragment _ _SHADOWS_SOFT$#pragma multi_compile _ SHADOWS_SHADOWMASK$$$#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING$$float3 diffuseColor = 0@$WorldNormal = normalize( WorldNormal)@$$int pixelLightCount = GetAdditionalLightsCount()@$for(int i = 0@  i < pixelLightCount@ i++)${$	Light light = GetAdditionalLight(i, WorldPosition)@$        	half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation)@$        	diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal)@$}$$return diffuseColor@$;7;File;6;True;Layer;FLOAT;0;In;;Inherit;False;True;Base;FLOAT4;0,0,0,0;In;;Inherit;False;True;Add;FLOAT4;0,0,0,0;In;;Inherit;False;True;Multi;FLOAT4;0,0,0,0;In;;Inherit;False;True;Sub;FLOAT4;0,0,0,0;In;;Inherit;False;True;RGBA;FLOAT4;0,0,0,0;Out;;Inherit;False;effectsControl;False;False;0;e1babb63bddea7d4eaa42c4d36116b49;True;7;0;INT;0;False;1;FLOAT;0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;2;INT;0;FLOAT4;7
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;-928,-4000;Inherit;False;baseC;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;128,-3264;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;195;-128,-2624;Inherit;False;73;baseC;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;197;-224,-2528;Inherit;False;48;MMDLit_GetAmbientRate;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;1280,-4352;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;193;64,-2624;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;69;1664,-3328;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;172;2048,-2688;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;336;2272,-2688;Inherit;False;FinalColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;276;-1216,-1824;Inherit;False;1504.905;863.994;Color Transparency;10;410;205;27;16;412;414;411;413;17;14;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;373;-128,-2208;Inherit;False;336;FinalColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;370;-224,-2080;Inherit;True;Property;_HDR;HDR;15;0;Create;True;0;0;0;False;0;False;1;1;1;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.StickyNoteNode;342;640,-2208;Inherit;False;572.4;1000.8;Notes;;1,1,0,1;==Material Color==$Diffuse = Material color.$$Specular = Color of light reflection/glow.$$Ambient = (It affects the model's color and lighting too so I think it's like a raycast)$$Opaque = Alpha value.$$Reflection = Reflection value.$$==Rendering==$2-SIDE = Renders both sides of the mesh. [Equivalent to Render Face/_Cull]$$G-SHAD = Shadow on the ground. [Equivalent to Cast Shadows/ShaderPass"SHADOWCASTER"]$$S-MAP = Shadow on the mesh. (Including herself) [Equivalent to Receive Shadows/_ReceiveShadows/Keyword"_RECEIVE_SHADOWS_OFF"]$$S-SHAD = Receives shade only from himself.$$==Edge (Outline)==$On = Activate the outline.$$Color = Contour color including transparesis.$$Size = Outline size/distance.$$==Texture/Memo==$Texture = Material texture.$$Toon = Complements the remains of the object.$$SPH = Artificial reflection to compromise Specular.$$***Effects***$It uses the SPH texture.$$Disabled = does not do anything.$$Multi-Sphere = It multiplies a glowing sphere map. (It gives me a feeling of being a metallic reflection)$$Add-Sphere = It creates a glowing sphere map. (It gives me a feeling of being a reflection of practical)$$Sub-Tex = It changes the SPH from 'Cube Texture' to 'Texture' to allow the use of Subtexture to place more than one texture on the same material.$The new texture is applied to another UV Layer allowing the creation of more complex effects. (This function replaces Add-Sphere and Multi-Sphere);0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;371;96,-2208;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.IntNode;413;-704,-1584;Inherit;False;Constant;_Int0;Int 0;32;0;Create;True;0;0;0;False;0;False;3;0;False;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-448,-1760;Inherit;True;Property;_Opaque;Opaque;3;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;410;-768,-1680;Inherit;False;289;tSphereMapBlend;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-128,-1760;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;205;96,-1760;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;412;-416,-1504;Inherit;True;0;4;0;FLOAT;0;False;1;INT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;411;-752,-1504;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;14;-1184,-1344;Inherit;False;12;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;17;-992,-1344;Inherit;True;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.WireNode;414;-528,-1296;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;478;768,-1152;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;1;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;DBufferProjector;0;0;DBufferProjector;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;2;5;False;;10;False;;1;0;False;;10;False;;False;False;True;2;5;False;;10;False;;1;0;False;;10;False;;False;False;True;2;5;False;;10;False;;1;0;False;;10;False;;False;False;False;False;False;False;True;1;False;;False;False;False;True;True;True;True;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;True;2;False;;True;2;False;;False;True;1;LightMode=DBufferProjector;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;479;768,-1152;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;1;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;DecalProjectorForwardEmissive;0;1;DecalProjectorForwardEmissive;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;8;5;False;;1;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;True;2;False;;False;True;1;LightMode=DecalProjectorForwardEmissive;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;481;768,-1152;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;1;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;DecalGBufferProjector;0;3;DecalGBufferProjector;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;False;True;1;False;;False;False;False;True;False;False;False;False;0;False;;False;True;True;True;True;False;0;False;;False;True;True;True;True;False;0;False;;False;False;False;True;2;False;;True;2;False;;False;True;1;LightMode=DecalGBufferProjector;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;482;768,-1152;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;1;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;DBufferMesh;0;4;DBufferMesh;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;2;5;False;;10;False;;1;0;False;;10;False;;False;False;True;2;5;False;;10;False;;1;0;False;;10;False;;False;False;True;2;5;False;;10;False;;1;0;False;;10;False;;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;True;2;False;;True;3;False;;False;True;1;LightMode=DBufferMesh;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;483;768,-1152;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;1;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;DecalMeshForwardEmissive;0;5;DecalMeshForwardEmissive;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;8;5;False;;1;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;True;3;False;;False;True;1;LightMode=DecalMeshForwardEmissive;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;484;768,-1152;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;1;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;DecalScreenSpaceMesh;0;6;DecalScreenSpaceMesh;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;True;3;False;;False;True;1;LightMode=DecalScreenSpaceMesh;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;485;768,-1152;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;1;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;DecalGBufferMesh;0;7;DecalGBufferMesh;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;True;False;False;False;False;0;False;;False;True;True;True;True;False;0;False;;False;True;True;True;True;False;0;False;;False;False;False;True;2;False;;False;False;True;1;LightMode=DecalGBufferMesh;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;486;768,-1152;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;1;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;ScenePickingPass;0;8;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;480;384,-2208;Float;False;True;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;14;MMD Collection/URP/Effects/MMD - Decal (Amplify Shader Editor);c2a467ab6d5391a4ea692226d82ffefd;True;DecalScreenSpaceProjector;0;2;DecalScreenSpaceProjector;9;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;True;2;False;;False;True;1;LightMode=DecalScreenSpaceProjector;False;False;0;;0;0;Standard;7;Affect BaseColor;1;0;Affect Normal;1;0;Blend;1;0;Affect MAOS;0;638651708582434037;Affect Emission;0;638651708685768342;Support LOD CrossFade;0;638651708641779241;Angle Fade;1;0;0;9;True;False;True;True;True;False;True;True;True;False;;False;0
WireConnection;84;0;68;0
WireConnection;60;0;61;0
WireConnection;59;0;84;0
WireConnection;44;0;28;0
WireConnection;32;0;292;0
WireConnection;62;0;59;0
WireConnection;62;1;60;0
WireConnection;114;0;113;0
WireConnection;138;0;167;0
WireConnection;163;0;164;0
WireConnection;52;0;90;0
WireConnection;190;1;114;0
WireConnection;89;0;62;0
WireConnection;162;0;163;0
WireConnection;162;1;163;1
WireConnection;162;2;163;2
WireConnection;112;0;190;3
WireConnection;112;1;111;0
WireConnection;34;0;52;1
WireConnection;170;0;168;0
WireConnection;170;1;169;0
WireConnection;29;0;165;0
WireConnection;29;1;162;0
WireConnection;50;0;52;0
WireConnection;50;1;112;0
WireConnection;54;0;34;0
WireConnection;54;1;58;0
WireConnection;294;0;52;2
WireConnection;171;0;170;0
WireConnection;31;0;29;0
WireConnection;31;1;41;0
WireConnection;53;0;54;0
WireConnection;53;1;294;0
WireConnection;51;0;52;2
WireConnection;51;1;50;0
WireConnection;33;0;31;0
WireConnection;33;1;134;0
WireConnection;36;0;53;0
WireConnection;36;1;51;0
WireConnection;13;0;11;0
WireConnection;416;0;36;0
WireConnection;135;0;33;0
WireConnection;159;0;158;0
WireConnection;418;0;425;0
WireConnection;418;1;419;0
WireConnection;139;0;166;0
WireConnection;141;0;142;0
WireConnection;35;0;136;0
WireConnection;35;1;161;0
WireConnection;109;0;110;0
WireConnection;67;0;66;0
WireConnection;151;0;149;0
WireConnection;152;0;159;0
WireConnection;152;1;159;1
WireConnection;152;2;159;2
WireConnection;420;0;418;0
WireConnection;420;1;418;0
WireConnection;48;0;35;0
WireConnection;187;1;141;0
WireConnection;64;0;109;0
WireConnection;65;0;67;0
WireConnection;150;0;151;0
WireConnection;150;1;151;1
WireConnection;150;2;151;2
WireConnection;147;0;152;0
WireConnection;147;1;153;0
WireConnection;421;0;420;0
WireConnection;421;1;422;0
WireConnection;38;0;416;0
WireConnection;70;0;187;3
WireConnection;70;1;48;0
WireConnection;43;0;64;0
WireConnection;43;1;65;0
WireConnection;148;0;150;0
WireConnection;148;1;147;0
WireConnection;423;0;421;0
WireConnection;93;0;38;0
WireConnection;93;1;38;0
WireConnection;144;0;70;0
WireConnection;126;0;124;0
WireConnection;126;1;125;0
WireConnection;146;0;148;0
WireConnection;146;1;154;0
WireConnection;180;0;179;0
WireConnection;426;0;429;0
WireConnection;426;1;430;0
WireConnection;426;2;93;0
WireConnection;426;3;427;0
WireConnection;40;1;43;0
WireConnection;424;0;423;0
WireConnection;188;1;114;0
WireConnection;181;0;180;0
WireConnection;127;0;126;0
WireConnection;37;0;40;0
WireConnection;156;0;146;0
WireConnection;156;1;145;0
WireConnection;92;1;426;0
WireConnection;488;0;188;3
WireConnection;488;1;491;0
WireConnection;128;0;181;0
WireConnection;128;1;127;0
WireConnection;157;0;156;0
WireConnection;157;1;155;0
WireConnection;431;0;92;0
WireConnection;431;1;432;0
WireConnection;431;2;433;0
WireConnection;436;0;429;0
WireConnection;437;0;92;0
WireConnection;174;0;488;0
WireConnection;12;0;10;0
WireConnection;130;0;128;0
WireConnection;121;0;122;0
WireConnection;121;1;123;0
WireConnection;160;0;157;0
WireConnection;434;0;436;0
WireConnection;434;1;435;0
WireConnection;434;2;437;0
WireConnection;434;3;431;0
WireConnection;57;0;63;0
WireConnection;57;1;56;0
WireConnection;177;0;487;0
WireConnection;177;1;176;0
WireConnection;129;0;130;0
WireConnection;129;1;121;0
WireConnection;46;0;295;0
WireConnection;46;1;434;0
WireConnection;405;0;57;0
WireConnection;95;0;47;0
WireConnection;95;1;46;0
WireConnection;289;0;207;0
WireConnection;71;0;405;0
WireConnection;71;1;283;0
WireConnection;39;0;57;0
WireConnection;39;1;406;0
WireConnection;78;0;79;0
WireConnection;78;1;75;0
WireConnection;407;0;57;0
WireConnection;131;0;129;0
WireConnection;178;0;177;0
WireConnection;96;0;94;0
WireConnection;96;1;95;0
WireConnection;77;0;39;0
WireConnection;77;1;79;0
WireConnection;80;0;78;0
WireConnection;80;1;407;0
WireConnection;380;0;378;0
WireConnection;380;1;377;0
WireConnection;380;2;379;0
WireConnection;400;1;289;0
WireConnection;400;2;284;0
WireConnection;400;3;71;0
WireConnection;400;4;39;0
WireConnection;400;5;408;0
WireConnection;83;0;86;0
WireConnection;83;1;82;0
WireConnection;83;2;85;0
WireConnection;97;0;96;0
WireConnection;399;1;401;0
WireConnection;399;2;78;0
WireConnection;399;3;80;0
WireConnection;399;4;77;0
WireConnection;399;5;380;0
WireConnection;73;0;400;7
WireConnection;87;0;83;0
WireConnection;87;1;88;0
WireConnection;49;0;97;0
WireConnection;49;1;178;0
WireConnection;49;2;399;7
WireConnection;193;0;195;0
WireConnection;193;1;197;0
WireConnection;69;0;49;0
WireConnection;69;1;87;0
WireConnection;172;0;69;0
WireConnection;172;1;193;0
WireConnection;336;0;172;0
WireConnection;371;0;373;0
WireConnection;371;1;370;0
WireConnection;27;0;16;0
WireConnection;27;1;412;0
WireConnection;205;0;27;0
WireConnection;412;0;410;0
WireConnection;412;1;413;0
WireConnection;412;2;411;0
WireConnection;412;3;414;0
WireConnection;411;0;379;4
WireConnection;411;1;17;3
WireConnection;17;0;14;0
WireConnection;414;0;17;3
WireConnection;480;0;371;0
WireConnection;480;1;205;0
ASEEND*/
//CHKSM=1661B37F06377A89AEAD14B42A10255E788627A8