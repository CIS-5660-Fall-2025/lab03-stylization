void GetMainLight_float(float3 WorldPos, out float3 Color, out float3 Direction, out float DistanceAtten, out float ShadowAtten) {
#ifdef SHADERGRAPH_PREVIEW
    Direction = normalize(float3(0.5, 0.5, 0));
    Color = 1;
    DistanceAtten = 1;
    ShadowAtten = 1;
#else
    #if SHADOWS_SCREEN
        float4 clipPos = TransformWorldToClip(WorldPos);
        float4 shadowCoord = ComputeScreenPos(clipPos);
    #else
        float4 shadowCoord = TransformWorldToShadowCoord(WorldPos);
    #endif

    Light mainLight = GetMainLight(shadowCoord);
    Direction = mainLight.direction;
    Color = mainLight.color;
    DistanceAtten = mainLight.distanceAttenuation;
    ShadowAtten = mainLight.shadowAttenuation;
#endif
}

void ChooseColor_float(float3 Highlight, float3 Midtone, float3 Shadow, float Diffuse, float Threshold1, float Threshold2, float Smoothness, out float3 OUT)
{
    float t2 = smoothstep(Threshold2 - Smoothness, Threshold2 + Smoothness, Diffuse);
    
    if (Diffuse < (Threshold1 + Threshold2) / 2.0f)
    {
        float t1 = smoothstep(Threshold1 - Smoothness, Threshold1 + Smoothness, Diffuse);
        OUT = lerp(Shadow, Midtone, t1);
    }
    else
    {
        float t2 = smoothstep(Threshold2 - Smoothness, Threshold2 + Smoothness, Diffuse);
        OUT = lerp(Midtone, Highlight, t2);
    }
    /*
    if (Diffuse < Threshold1)
    {
        OUT = Shadow;
    }
    else if (Diffuse < Threshold2)
    {
        OUT = Midtone;
    }
    else
    {
        OUT = Highlight;

    }
*/
}