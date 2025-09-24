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

void ChooseColor_float(float3 Highlight, float3 Shadow, float Diffuse, float Threshold, out float3 OUT)
{
    if (Diffuse < Threshold)
    {
        OUT = Shadow;
    }
    else
    {
        OUT = Highlight;
    }
}

// Three-step toon: Shadow / Mid / Highlight via two thresholds (t1 < t2)
void ChooseColor3_float(
    float3 Highlight, float3 Mid, float3 Shadow,
    float Diffuse, float t1, float t2,
    out float3 OUT)
{
    if (t1 > t2) { float tmp = t1; t1 = t2; t2 = tmp; }

    if (Diffuse < t1)
        OUT = Shadow;
    else if (Diffuse < t2)
        OUT = Mid;
    else
        OUT = Highlight;
}



void ChooseColor3Smooth_float(
    float3 Highlight, float3 Mid, float3 Shadow,
    float Diffuse, float t1, float t2, float w1, float w2,
    out float3 OUT)
{
    if (t1 > t2) { float tmp = t1; t1 = t2; t2 = tmp; }


    if (Diffuse < t1)
        OUT = Shadow;
    else if (Diffuse < t2)
        OUT = Mid;
    else
        OUT = Highlight;

    // Soft mix near t1: Shadow and Mid
    if (w1 > 0.0)
    {
        float a1 = smoothstep(t1 - 0.5 * w1, t1 + 0.5 * w1, Diffuse);
        float3 sm12 = lerp(Shadow, Mid, a1);
        if (Diffuse > (t1 - w1) && Diffuse < (t1 + w1)) OUT = sm12;
    }

    // Soft mix near t2: Mid and Highlight
    if (w2 > 0.0)
    {
        float a2 = smoothstep(t2 - 0.5 * w2, t2 + 0.5 * w2, Diffuse);
        float3 sm23 = lerp(Mid, Highlight, a2);
        if (Diffuse > (t2 - w2) && Diffuse < (t2 + w2)) OUT = sm23;
    }
}

