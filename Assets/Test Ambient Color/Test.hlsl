#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

// Calculates the direction of light in world space.
void vLight_float(float3 normal, out float3 OutLight)
{
    OutLight = SampleSH(normal);
}

#endif