Shader "Unlit/MMD - Multiple Outline (Code)"
{
    Properties
    {
        _OutlineColor("Color", Color) = (0,0,0,1)
        _EdgeSize("Size", Float) = 0.1
    }
    SubShader
    {
        Tags { "RenderType" = "Overlay" "Queue"="Overlay-1000" }
        LOD 200

        Cull Off
        ZWrite Off
        ZTest LEqual
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask RGBA

        Pass
        {
            Name "Outline T1"
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float4 color : COLOR;
            };

            uniform float _EdgeSize;
            uniform float4 _OutlineColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex + v.normal * _EdgeSize);
                o.color = _OutlineColor;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }

        Pass
        {
            Name "Outline T2"
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float4 color : COLOR;
            };

            uniform float _EdgeSize;
            uniform float4 _OutlineColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex + v.normal * (_EdgeSize * 0.5));
                o.color = _OutlineColor;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }

        Pass
        {
            Name "Outline T3"
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float4 color : COLOR;
            };

            uniform float _EdgeSize;
            uniform float4 _OutlineColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex + v.normal * (_EdgeSize * 1.0));
                o.color = _OutlineColor;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }

        Pass
        {
            Name "Outline T4"
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float4 color : COLOR;
            };

            uniform float _EdgeSize;
            uniform float4 _OutlineColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex + v.normal * (_EdgeSize * 1.5));
                o.color = _OutlineColor;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }

        Pass
        {
            Name "Outline T5"
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float4 color : COLOR;
            };

            uniform float _EdgeSize;
            uniform float4 _OutlineColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex + v.normal * (_EdgeSize * 2.0));
                o.color = _OutlineColor;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }

        Pass
        {
            Name "Outline T6"
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float4 color : COLOR;
            };

            uniform float _EdgeSize;
            uniform float4 _OutlineColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex + v.normal * (_EdgeSize * 2.5));
                o.color = _OutlineColor;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }

        Pass
        {
            Name "Outline T7"
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float4 color : COLOR;
            };

            uniform float _EdgeSize;
            uniform float4 _OutlineColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex + v.normal * (_EdgeSize * 3.0));
                o.color = _OutlineColor;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }

        Pass
        {
            Name "Outline T8"
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float4 color : COLOR;
            };

            uniform float _EdgeSize;
            uniform float4 _OutlineColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex + v.normal * (_EdgeSize * 3.5));
                o.color = _OutlineColor;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
}