Shader "custom/HolosightReflectiveTesting"
{
    Properties{

        _reticleTex("Reticle Texture", 2D) = "white" {}
        _reticleColour("Reticle Color", Color) = (1, 0, 0, 1)
        _reticleBrightness("Reticle Brightness", Range(0, 1)) = 1
        _glassColour("Glass Color", Color) = (1, 1, 1, 1)
        _glassTransparency("Glass Transparency", Range(0, 1)) = 0.1
        _uvScale("Reticle Scale", float) = 1
        _Metallic("Metallic", Range(0, 1)) = 0.5 
        _Smoothness("Smoothness", Range(0, 1)) = 0.5 
        _Normal("Normal Map", 2D) = "bump" {} 

    }


SubShader{
    Tags {"Queue" = "Transparent+1" "RenderType" = "Transparent"}

    CGPROGRAM
    #pragma surface surf_reflective_glass_fresnel alpha 
    #pragma target 3.0

    sampler2D _reticleTex;
    float _uvScale, _glassTransparency, _reticleBrightness;
    float4 _reticleColor, _glassColor;
    float _Metallic, _Smoothness;
    sampler2D _Normal; 

    struct Input
    {
        float3 worldPos;
        float3 worldNormal;
    };

    void surf_reflective_glass_fresnel(Input IN, inout SurfaceOutput o) {

        float shortestDistance = dot(_WorldSpaceCameraPos - IN.worldPos, IN.worldNormal);
        float3 closestPoint = _WorldSpaceCameraPos - (shortestDistance * IN.worldNormal);
        float2 uvDelta = (mul((float3x3)unity_WorldToObject, IN.worldPos) - mul((float3x3)unity_WorldToObject, closestPoint)).xy * _uvScale;

        half4 col = tex2D(_reticleTex, (0.5, 0.5) + uvDelta);

        
        fixed3 refl = surf_reflective_glass_fresnel(IN.worldNormal, IN.viewDir, _Metallic, _Smoothness, _Normal);
        o.Albedo = max(col.a * _reticleColor.rgb, _glassTransparency * _glassColor.rgb);
        o.Alpha = max(col.a, _glassTransparency);

        o.Emission = col.a * _reticleColor.rgb * _reticleBrightness;
        o.Metallic = _Metallic;
        o.Smoothness = _Smoothness;
        o.Normal = UnpackNormal(tex2D(_Normal, IN.uv_Normal)); 
        o.Specular = refl; 

    }

    ENDCG
    
    }
}