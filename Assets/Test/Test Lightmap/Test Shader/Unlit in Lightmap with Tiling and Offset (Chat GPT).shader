Shader "Unlit/Unlit in Lightmap with Tiling and Offset (Chat GPT)"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1; // UV do lightmap
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1; // UV do lightmap
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2 = v.uv2; // Garante que estamos usando TEXCOORD1 para lightmap
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            #pragma multi_compile _ LIGHTMAP_ON

            fixed4 frag (v2f i) : SV_Target
            {
                // Amostra a textura principal
                fixed4 col = tex2D(_MainTex, i.uv);

                #ifdef LIGHTMAP_ON
                    // Ajusta as UVs do lightmap com Tiling e Offset (usando unity_LightmapST)
                    float2 lightmapUV = i.uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
                    
                    // Amostra o lightmap usando as UVs ajustadas
                    fixed4 lightmapCol = UNITY_SAMPLE_TEX2D(unity_Lightmap, lightmapUV);
                    
                    // Multiplica a cor do lightmap com a cor da textura
                    col.rgb *= lightmapCol.rgb;
                #endif

                // Aplica o fog
                UNITY_APPLY_FOG(i.fogCoord, col);

                return col;
            }
            ENDCG
        }
    }
}