#include "MMDCustomNodeTools.hlsl"

void MMDMaterial_float(
float3 Diffuse, float3 Specular, float3 Ambient, float Opaque, float Reflection,
bool Two_SIDE, bool G_SHAD, bool S_MAP, bool S_SHAD,
bool On, float4 Color, float Size,
Texture2D Texture, Texture2D Toon, UnityTextureCube SPH,
bool Disabled, bool Add_Sphere, bool Multi_Sphere, bool Sub_Tex,
out float4 RGBA, out float R, out float G, out float B, out float A)
{
    MMDMaterialColor_float(Diffuse, Specular, Ambient, Opaque, Reflection, RGBA);

	float4 result = float4(0, 0, 0, 0);
    MMDRendering_float(Two_SIDE, G_SHAD, S_MAP, S_SHAD, result);
    R = result.x;

	EdgeOutline_float(On, Color, Size, G);
	TextureMemo_float(Texture, Toon, SPH, B);
    Effects_float(Disabled, Add_Sphere, Multi_Sphere, Sub_Tex, A);
}