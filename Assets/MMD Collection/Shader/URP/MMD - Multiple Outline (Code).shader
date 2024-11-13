// Shader definition, specifying a name for the shader.
Shader "MMD Collection/URP/MMD - Multiple Outline (Code)"
{
    Properties
    {
        // Warning: URP has limitations for this shader.
        [Header(Warning Shader doesnt work in URP because URP )]
        [Header(only draws the pass if it has a different LightMode )]
        [Header(than the other and URP only has two modes.)]
        [Header(_)]

        [Enum(4 Layers,0,8 Layers,1)]_OutlineLayers("Outline Layers", Float) = 0 // Outline layers property, allowing for either 4 or 8 layers.
        _OutlineColor("Color", Color) = (0,0,0,1) // Outline color setting.
        _OutlineSize("Size", Float) = 0 // Size of the outline.
    }
    SubShader // Begin the subshader block.
    {
        // Define rendering order and transparency settings.
        Tags { "RenderType" = "Overlay" "Queue"="Transparent" }
        LOD 200 // Level of detail for the shader.

        // First rendering pass for an outline layer.
        Pass
        {
            Name "Outline T1" // Pass name.

            //Tags { "LightMode"="???" } // Placeholder, defining light mode can be important in URP.

            Cull Front // Render only front-facing polygons.
            ZWrite Off // Disable depth writing.
            ZTest LEqual // Only draw if the current fragment depth is less than or equal to the existing depth.
            Blend SrcAlpha OneMinusSrcAlpha // Alpha blending for transparency.
            ColorMask RGBA // Output all color channels.

            CGPROGRAM // Begin Cg shader program.
            #pragma vertex vert // Define the vertex function.
            #pragma fragment frag // Define the fragment function.
            #include "UnityCG.cginc" // Include Unity helper functions.

            // Define input data from the application.
            struct appdata
            {
                float4 vertex : POSITION; // Vertex position.
                float3 normal : NORMAL; // Normal vector.
            };

            // Define output data for the vertex function.
            struct v2f
            {
                float4 pos : POSITION; // Final screen position.
                float4 color : COLOR; // Color, including alpha.
            };

            // Define uniform variables for edge size, color, and layers.
            uniform float _OutlineSize;
            uniform float4 _OutlineColor;
            uniform float _OutlineLayers;

            // Vertex function, computing outline offset and alpha based on view angle.
            v2f vert(appdata v)
            {
                v2f o; // Output structure for vertex shader.
                o.color = _OutlineColor; // Set the outline color from the property.
                half3 viewDir = normalize((half3) WorldSpaceViewDir(v.vertex)); // Compute view direction.
                half r = saturate(dot(-viewDir, mul((float3x3) unity_ObjectToWorld, SCALED_NORMAL))); // Determine intensity based on view direction and normal.

                // Set scale based on the number of outline layers.
                float vertexScale = (_OutlineSize * (4.0 / 4.0));
                float alphaScale = (1.0 / 4.0);

                if (_OutlineLayers == 1)
                {
                    vertexScale = (_OutlineSize * (8.0 / 8.0));
                    alphaScale = (1.0 / 8.0);
                }

                o.pos = UnityObjectToClipPos(v.vertex + v.normal * vertexScale); // Offset the vertex position outward to create an outline effect.
                o.color.a *= r * alphaScale; // Modify alpha based on outline intensity.

                return o; // Return the modified output.
            }

            // Fragment shader function, returns the color.
            half4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG // End Cg shader program.
        }

        Pass
        {
            Name "Outline T2"

            //Tags { "LightMode"="???" }

            Cull Front
            ZWrite Off
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGBA

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

            uniform float _OutlineSize;
            uniform float4 _OutlineColor;
            uniform float _OutlineLayers;

            v2f vert(appdata v)
            {
                v2f o;
                o.color = _OutlineColor;
                half3 viewDir = normalize((half3) WorldSpaceViewDir(v.vertex));
                half r = saturate(dot(-viewDir, mul((float3x3) unity_ObjectToWorld, SCALED_NORMAL)));

                float vertexScale = (_OutlineSize * (3.0 / 4.0));
                float alphaScale = (2.0 / 4.0);

                if (_OutlineLayers == 1)
                {
                    vertexScale = (_OutlineSize * (7.0 / 8.0));
                    alphaScale = (2.0 / 8.0);
                }

                o.pos = UnityObjectToClipPos(v.vertex + v.normal * vertexScale);
                o.color.a *= r * alphaScale;

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

            //Tags { "LightMode"="???" }

            Cull Front
            ZWrite Off
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGBA

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

            uniform float _OutlineSize;
            uniform float4 _OutlineColor;
            uniform float _OutlineLayers;

            v2f vert(appdata v)
            {
                v2f o;
                o.color = _OutlineColor;
                half3 viewDir = normalize((half3) WorldSpaceViewDir(v.vertex));
                half r = saturate(dot(-viewDir, mul((float3x3) unity_ObjectToWorld, SCALED_NORMAL)));

                float vertexScale = (_OutlineSize * (2.0 / 4.0));
                float alphaScale = (3.0 / 4.0);

                if (_OutlineLayers == 1)
                {
                    vertexScale = (_OutlineSize * (6.0 / 8.0));
                    alphaScale = (3.0 / 8.0);
                }

                o.pos = UnityObjectToClipPos(v.vertex + v.normal * vertexScale);
                o.color.a *= r * alphaScale;

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

            //Tags { "LightMode"="???" }

            Cull Front
            ZWrite Off
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGBA

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

            uniform float _OutlineSize;
            uniform float4 _OutlineColor;
            uniform float _OutlineLayers;

            v2f vert(appdata v)
            {
                v2f o;
                o.color = _OutlineColor;
                half3 viewDir = normalize((half3) WorldSpaceViewDir(v.vertex));
                half r = saturate(dot(-viewDir, mul((float3x3) unity_ObjectToWorld, SCALED_NORMAL)));

                float vertexScale = (_OutlineSize * (1.0 / 4.0));
                float alphaScale = (4.0 / 4.0);

                if (_OutlineLayers == 1)
                {
                    vertexScale = (_OutlineSize * (5.0 / 8.0));
                    alphaScale = (4.0 / 8.0);
                }

                o.pos = UnityObjectToClipPos(v.vertex + v.normal * vertexScale);
                o.color.a *= r * alphaScale;

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
            Name "Outline T5" // Pass name.

            //Tags { "LightMode"="???" } // Placeholder, defining light mode can be important in URP.

            Cull Front // Render only front-facing polygons.
            ZWrite Off // Disable depth writing.
            ZTest LEqual // Only draw if the current fragment depth is less than or equal to the existing depth.
            Blend SrcAlpha OneMinusSrcAlpha // Alpha blending for transparency.
            ColorMask RGBA // Output all color channels.

            CGPROGRAM // Begin Cg shader program.
            #pragma vertex vert // Define the vertex function.
            #pragma fragment frag // Define the fragment function.
            #include "UnityCG.cginc" // Include Unity helper functions.

            // Define input data from the application.
            struct appdata
            {
                float4 vertex : POSITION; // Vertex position.
                float3 normal : NORMAL; // Normal vector.
            };

            // Define output data for the vertex function.
            struct v2f
            {
                float4 pos : POSITION; // Final screen position.
                float4 color : COLOR; // Color, including alpha.
            };

            // Define uniform variables for edge size, color, and layers.
            uniform float _OutlineSize;
            uniform float4 _OutlineColor;
            uniform float _OutlineLayers;

            // Vertex function, computing outline offset and alpha based on view angle.
            v2f vert(appdata v)
            {
                v2f o; // Output structure for vertex shader.
                
                // If _OutlineLayers is set to 0, skip rendering this pass.
                if (_OutlineLayers == 0)
                {
                    o.color = 0; // Set color to zero.
                    o.pos = 0; // Set position to zero.
                    return o; // Return immediately to skip this outline layer.
                }

                o.color = _OutlineColor; // Set the outline color from the property.
                half3 viewDir = normalize((half3) WorldSpaceViewDir(v.vertex)); // Compute view direction.
                half r = saturate(dot(-viewDir, mul((float3x3) unity_ObjectToWorld, SCALED_NORMAL))); // Determine intensity based on view direction and normal.

                o.pos = UnityObjectToClipPos(v.vertex + v.normal * (_OutlineSize * (4.0 / 8.0))); // Offset the vertex position outward based on _OutlineSize, specific to this layer.
                o.color.a *= r * (5.0 / 8.0); // Adjust the outline alpha based on view intensity and layer-specific scale.

                return o; // Return the modified output.
            }

            // Fragment shader function, returns the color.
            half4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG // End Cg shader program.
        }

        Pass
        {
            Name "Outline T6"

            //Tags { "LightMode"="???" }

            Cull Front
            ZWrite Off
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGBA

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

            uniform float _OutlineSize;
            uniform float4 _OutlineColor;
            uniform float _OutlineLayers;

            v2f vert(appdata v)
            {
                v2f o;
                
                if (_OutlineLayers == 0)
                {
                    o.color = 0;
                    o.pos = 0;
                    return o;
                }

                o.color = _OutlineColor;
                half3 viewDir = normalize((half3) WorldSpaceViewDir(v.vertex));
                half r = saturate(dot(-viewDir, mul((float3x3) unity_ObjectToWorld, SCALED_NORMAL)));

                o.pos = UnityObjectToClipPos(v.vertex + v.normal * (_OutlineSize * (3.0 / 8.0)));
                o.color.a *= r * (6.0 / 8.0);

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

            //Tags { "LightMode"="???" }

            Cull Front
            ZWrite Off
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGBA

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

            uniform float _OutlineSize;
            uniform float4 _OutlineColor;
            uniform float _OutlineLayers;

            v2f vert(appdata v)
            {
                v2f o;
                
                if (_OutlineLayers == 0)
                {
                    o.color = 0;
                    o.pos = 0;
                    return o;
                }

                o.color = _OutlineColor;
                half3 viewDir = normalize((half3) WorldSpaceViewDir(v.vertex));
                half r = saturate(dot(-viewDir, mul((float3x3) unity_ObjectToWorld, SCALED_NORMAL)));

                o.pos = UnityObjectToClipPos(v.vertex + v.normal * (_OutlineSize * (2.0 / 8.0)));
                o.color.a *= r * (7.0 / 8.0);

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

            //Tags { "LightMode"="???" }

            Cull Front
            ZWrite Off
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGBA

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

            uniform float _OutlineSize;
            uniform float4 _OutlineColor;
            uniform float _OutlineLayers;

            v2f vert(appdata v)
            {
                v2f o;
                
                if (_OutlineLayers == 0)
                {
                    o.color = 0;
                    o.pos = 0;
                    return o;
                }

                o.color = _OutlineColor;
                half3 viewDir = normalize((half3) WorldSpaceViewDir(v.vertex));
                half r = saturate(dot(-viewDir, mul((float3x3) unity_ObjectToWorld, SCALED_NORMAL)));

                o.pos = UnityObjectToClipPos(v.vertex + v.normal * (_OutlineSize * (1.0 / 8.0)));
                o.color.a *= r * (8.0 / 8.0);

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