void MMDMaterialColor_float(float3 Diffuse, float3 Specular, float3 Ambient, float Opaque, float Reflection, out float4 RGBA)
{
    float3 mixedColor = Diffuse + Specular + Ambient;
    float4 finalColor = float4(mixedColor, Opaque);
    RGBA = finalColor;
}

void MMDRendering_float(bool Two_SIDE, bool G_SHAD, bool S_MAP, bool S_SHAD, out float4 Value)
{
    float4 result = float4(0, 0, 0, 0);

    if (Two_SIDE)
    {
        result.x = 1;
    }
    
    if (G_SHAD)
    {
        result.y = 1;
    }
    
    if (S_MAP)
    {
        result.z = 1;
    }

    if (S_SHAD)
    {
        result.w = 1;
    }

    Value = result;
}

void EdgeOutline_float(bool On, float4 Color, float Size, out float Value)
{
    Value = Size;
}

void TextureMemo_float(Texture2D Texture, Texture2D Toon, UnityTextureCube SPH, out float Value)
{
    Value = 1;
}

void Effects_float(bool Disabled, bool Add_Sphere, bool Multi_Sphere, bool Sub_Tex, out float Value)
{
    float result = 1;

    if (Disabled)
    {
        result = 1;
    }
    
    if (Add_Sphere)
    {
        result = 3;
    }

    if (Multi_Sphere)
    {
        result = 2;
    }
    
    if (Sub_Tex)
    {
        result = 4;
    }

    Value = result;
}