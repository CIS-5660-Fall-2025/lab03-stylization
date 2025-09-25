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

void ChooseColor_float(float3 Highlight, float3 Midtone, float3 Shadow, float Diffuse, float LoThreshold, float HiThreshold, float Smoothness, out float3 OUT)
{
    Smoothness += 0.0001;
    
    float shadowMult = smoothstep(LoThreshold+Smoothness*.5, LoThreshold-Smoothness*.5, Diffuse);
    float midtoneMult = smoothstep(LoThreshold-Smoothness*.5, LoThreshold+Smoothness*.5, Diffuse) * smoothstep(HiThreshold+Smoothness*.5, HiThreshold-Smoothness*.5, Diffuse);
    float highlightMult = smoothstep(HiThreshold-Smoothness*.5, HiThreshold+Smoothness*.5, Diffuse);

    OUT =
        shadowMult * Shadow +
        midtoneMult * Midtone +
        highlightMult * Highlight;
}