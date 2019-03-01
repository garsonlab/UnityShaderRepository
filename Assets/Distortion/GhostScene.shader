Shader "Custom/AfterEffects/GhostScene"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white"{}
		_Strength("Strength", Range(0, 0.05)) = 0.01
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"}
		ZTest Always
		Cull Off
		ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex:POSITION;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _Strength;

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				fixed4 s1 = fixed4(0, 0, 0, 0);
				fixed2 dis = i.uv - fixed2(0.5, 0.5);
				half len = length(dis) * 4;
				s1 = tex2D(_MainTex, i.uv + dis * (_SinTime.w * 0.5 - 0.5) * len * _Strength);
				s1 = lerp(fixed4(0, 0, 0, 0), s1, len * 5);
				
				fixed r = max(0.5, s1.r);
				s1.rgb = lerp(s1.r, r, len);
				s1.r *= 0.1;
				fixed4 texCol = tex2D(_MainTex, i.uv);
				fixed4 finalCol = (texCol + s1 * 0.1) * 0.5;
				finalCol = lerp(texCol, finalCol, len);

				return finalCol;
			}

			ENDCG
		}
	}
}