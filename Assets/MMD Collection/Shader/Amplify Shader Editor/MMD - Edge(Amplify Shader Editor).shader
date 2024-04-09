// Made with Amplify Shader Editor v1.9.3.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMD Collection/MMD - Edge (Amplify Shader Editor)"
{
	Properties
	{
		_Color("Diffuse", Color) = (0.8,0.8,0.8,1)
		_Specular("Specular", Color) = (0,0,0,0)
		_Ambient("Ambient", Color) = (1,1,1,0)
		_Shininess("Shininess", Float) = 1
		_ShadowLum("ShadowLum", Range( 0 , 10)) = 1.5
		_AmbientToDiffuse("AmbientToDiffuse", Float) = 5
		_EdgeColor("EdgeColor", Color) = (0,0,0,1)
		_EdgeScale("EdgeScale", Range( 0 , 2)) = 0.001
		_EdgeSize("EdgeSize", Float) = 0.001
		_MainTex("MainTex", 2D) = "white" {}
		_ToonTex("ToonTex", 2D) = "white" {}
		_SphereCube("SphereCube", CUBE) = "white" {}
		_Emissive("Emissive", Color) = (0,0,0,0)
		_ALPower("ALPower", Float) = 0
		_AddLightToonCen("AddLightToonCen", Float) = -0.1
		_AddLightToonMin("AddLightToonMin", Float) = 0.5
		_ToonTone("ToonTone", Vector) = (1,0.5,0.5,0)
		_NoShadowCasting("__NoShadowCasting", Float) = 0
		_TessEdgeLength("Tess Edge length", Range( 2 , 50)) = 5
		_TessPhongStrength("Tess Phong Strengh", Range( 0 , 1)) = 0.5
		_TessExtrusionAmount("TessExtrusionAmount", Float) = 0
		_Revision("Revision", Float) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#pragma target 4.6
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:deferred 
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			float3 uv_texcoord;
		};

		uniform float4 _Color;
		uniform float4 _Specular;
		uniform float4 _Ambient;
		uniform float _Shininess;
		uniform float _ShadowLum;
		uniform float _AmbientToDiffuse;
		uniform float4 _EdgeColor;
		uniform float _EdgeScale;
		uniform float _EdgeSize;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform sampler2D _ToonTex;
		uniform float4 _ToonTex_ST;
		uniform samplerCUBE _SphereCube;
		uniform float4 _SphereCube_ST;
		uniform float4 _Emissive;
		uniform float _ALPower;
		uniform float _AddLightToonCen;
		uniform float _AddLightToonMin;
		uniform float4 _ToonTone;
		uniform float _NoShadowCasting;
		uniform float _TessEdgeLength;
		uniform float _TessPhongStrength;
		uniform float _TessExtrusionAmount;
		uniform float _Revision;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 uv_ToonTex = i.uv_texcoord * _ToonTex_ST.xy + _ToonTex_ST.zw;
			float3 uv_SphereCube3 = i.uv_texcoord;
			uv_SphereCube3.xy = i.uv_texcoord.xy * _SphereCube_ST.xy + _SphereCube_ST.zw;
			o.Normal = ( ( ( _Color + _Specular + _Ambient + _Shininess + _ShadowLum + _AmbientToDiffuse + _EdgeColor + _EdgeScale + _EdgeSize + tex2D( _MainTex, uv_MainTex ) ) + tex2D( _ToonTex, uv_ToonTex ) + texCUBE( _SphereCube, uv_SphereCube3 ) + _Emissive + _ALPower + _AddLightToonCen + _AddLightToonMin + _ToonTone + _NoShadowCasting + _TessEdgeLength ) + _TessPhongStrength + _TessExtrusionAmount + _Revision ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19302
Node;AmplifyShaderEditor.ColorNode;222;-464.282,-274.4622;Inherit;False;Property;_Color;Diffuse;0;0;Create;False;0;0;0;False;0;False;0.8,0.8,0.8,1;0.8,0.8,0.8,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;223;-455.7934,-88.98836;Inherit;False;Property;_Specular;Specular;1;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;225;-400.9231,258.3318;Inherit;False;Property;_Shininess;Shininess;3;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;224;-464.077,82.8961;Inherit;False;Property;_Ambient;Ambient;2;0;Create;False;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;226;-531.6158,332.5477;Inherit;False;Property;_ShadowLum;ShadowLum;4;0;Create;False;0;0;0;False;0;False;1.5;1.5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;229;-534.9702,669.2214;Inherit;False;Property;_EdgeScale;EdgeScale;7;0;Create;False;0;0;0;False;0;False;0.001;0.001;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;227;-470.0158,409.3479;Inherit;False;Property;_AmbientToDiffuse;AmbientToDiffuse;5;0;Create;False;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;231;-550.6003,829.3516;Inherit;True;Property;_MainTex;MainTex;9;0;Create;False;0;0;0;False;0;False;-1;411aff420f000be4193cf070f223d094;411aff420f000be4193cf070f223d094;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;228;-473.1413,491.6518;Inherit;False;Property;_EdgeColor;EdgeColor;6;0;Create;False;0;0;0;False;0;False;0,0,0,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;230;-444.2333,747.2958;Inherit;False;Property;_EdgeSize;EdgeSize;8;0;Create;False;0;0;0;False;0;False;0.001;0.001;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;232;-552.2003,1026.951;Inherit;True;Property;_ToonTex;ToonTex;10;0;Create;False;0;0;0;False;0;False;-1;d76c4ad9aa865bb4890ec43af5df8e8d;d76c4ad9aa865bb4890ec43af5df8e8d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;233;-551.0873,1221.233;Inherit;True;Property;_SphereCube;SphereCube;11;0;Create;False;0;0;0;False;0;False;-1;e71647fec12d2c945997b86cf47b4ef6;e71647fec12d2c945997b86cf47b4ef6;True;0;False;white;Auto;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;234;-485.9294,1417.844;Inherit;False;Property;_Emissive;Emissive;12;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;236;-492.0758,1660.687;Inherit;False;Property;_AddLightToonCen;AddLightToonCen;14;0;Create;False;0;0;0;False;0;False;-0.1;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;237;-495.2759,1734.287;Inherit;False;Property;_AddLightToonMin;AddLightToonMin;15;0;Create;False;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;238;-491.7962,1814.387;Inherit;False;Property;_ToonTone;ToonTone;16;0;Create;False;0;0;0;False;0;False;1,0.5,0.5,0;1,0.5,0.5,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;235;-425.2144,1587.977;Inherit;False;Property;_ALPower;ALPower;13;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;239;-491.7962,1985.188;Inherit;False;Property;_NoShadowCasting;__NoShadowCasting;17;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;240;-556.5962,2059.989;Inherit;False;Property;_TessEdgeLength;Tess Edge length;18;0;Create;False;0;0;0;False;0;False;5;5;2;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;244;-162.6843,230.2676;Inherit;False;10;10;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;COLOR;0,0,0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;241;-556.5962,2134.389;Inherit;False;Property;_TessPhongStrength;Tess Phong Strengh;19;0;Create;False;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;242;-525.3962,2209.592;Inherit;False;Property;_TessExtrusionAmount;TessExtrusionAmount;20;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;243;-428.5961,2284.79;Inherit;False;Property;_Revision;Revision;21;0;Create;False;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;245;-34.64603,1147.401;Inherit;False;10;10;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;246;107.1957,1489.27;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.IntNode;248;268.7867,231.4388;Inherit;False;Constant;_Int1;Int 0;23;1;[Enum];Create;True;0;4;SELFSHADOW_ON;0;SPECULAR_ON;1;SPHEREMAP_ADD;2;SPHEREMAP_MUL;3;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;138;267.0066,-236.3069;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;MMD Collection/MMD - Edge (Amplify Shader Editor);False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Transparent;;Geometry;ForwardOnly;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;22;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;244;0;222;0
WireConnection;244;1;223;0
WireConnection;244;2;224;0
WireConnection;244;3;225;0
WireConnection;244;4;226;0
WireConnection;244;5;227;0
WireConnection;244;6;228;0
WireConnection;244;7;229;0
WireConnection;244;8;230;0
WireConnection;244;9;231;0
WireConnection;245;0;244;0
WireConnection;245;1;232;0
WireConnection;245;2;233;0
WireConnection;245;3;234;0
WireConnection;245;4;235;0
WireConnection;245;5;236;0
WireConnection;245;6;237;0
WireConnection;245;7;238;0
WireConnection;245;8;239;0
WireConnection;245;9;240;0
WireConnection;246;0;245;0
WireConnection;246;1;241;0
WireConnection;246;2;242;0
WireConnection;246;3;243;0
WireConnection;138;1;246;0
ASEEND*/
//CHKSM=629A49A3F2D3E383D81DABCC39FF52B6B043A410