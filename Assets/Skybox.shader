Shader "Skybox/Whale"
{
	Properties
	{
		_SpeedFactor("Speed Factor", Float) = 1
		_RayColor1("Ray Color 1", Color) = (1, 1, 1, 0)
		_RayColor2("Ray Color 2", Color) = (1, 1, 1, 0)
		_RayIntensity("Ray Intensity", Range(0.001, 0.1)) = 0.01
		_RayDistanceMin("Ray Distance Min", Float) = 1
		_RayDistanceMax("Ray Distance Max", Float) = 1
		_RayLength("Ray Length", Float) = 1
		_FarDistanceFront("Far Distance Front", Float) = 50
		_FarDistanceBack("Far Distance Back", Float) = -50
		_Background("Background", Cube) = "white" {}
	}

		CGINCLUDE

#include "UnityCG.cginc"

		struct appdata
	{
		float4 position : POSITION;
		float3 texcoord : TEXCOORD0;
	};

	struct v2f
	{
		float4 position : SV_POSITION;
		float3 texcoord : TEXCOORD0;
	};

	half _SpeedFactor;
	half3 _RayColor1;
	half3 _RayColor2;
	half _RayIntensity;
	half _RayDistanceMin;
	half _RayDistanceMax;
	half _RayLength;
	half _FarDistanceFront;
	half _FarDistanceBack;
	samplerCUBE _Background;

#define STARS 256.

#define rand(x) frac(sin(x)*1e4)

	float2x2 rot(float a)
	{
		float c = cos(a),
			s = sin(a);
		return float2x2(c, s, -s, c);
	}

	v2f vert(appdata v)
	{
		v2f o;
		o.position = UnityObjectToClipPos(v.position);
		o.texcoord = v.texcoord;
		return o;
	}

	fixed4 frag(v2f i) : COLOR
	{
		half3 cd = normalize(i.texcoord);

		float3 acc = texCUBE(_Background, i.texcoord).rgb * .5;
		for (float f = 0; f < STARS; ++f) {
			float r = rand(f) * STARS + _Time.y * _SpeedFactor,
				fr = frac(r),
				fl = floor(r);
			half3 rr = rand(fl + half3(0., 3., 5.));
			half3 ro = half3(mul(rot(rr.x*6.2835), half2(lerp(_RayDistanceMin, _RayDistanceMax, rr.y), 0.)), 0.),
				rd = half3(0, 0, 1),
				coro = -ro,
				n = normalize(cross(cd, rd)),
				nc = cross(n, cd),
				nr = cross(n, rd);
			float d = dot(coro, n),
				tc = -dot(coro, nr) / dot(cd, nr),
				tr = dot(coro, nc) / dot(rd, nc);
			acc += lerp(_RayColor1, _RayColor2, rr.z) * (_RayIntensity / d / d * step(0, tc) * smoothstep(_RayLength, 0, abs(tr - lerp(_FarDistanceFront, _FarDistanceBack, fr))) * min(fr * 1., 1.));
		}

		return fixed4(acc, 1.);
	}

		ENDCG

		SubShader
	{
		Tags{ "RenderType" = "Background" "Queue" = "Background" }
			Pass
		{
			ZWrite Off
			Cull Off
			Fog{ Mode Off }
			CGPROGRAM
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}