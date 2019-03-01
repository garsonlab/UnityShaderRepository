Shader "Custom/AfterEffects/Disturbance"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_WaterBumb ("WaterBump", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		ZTest Always Cull Off ZWrite Off
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _WaterBumb;
			float4 _WaterBumb_ST;
			
			v2f vert (appdata_tan v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col1 = tex2D(_WaterBumb, i.uv + float2(_Time.x, 0));
				fixed4 col2 = tex2D(_WaterBumb, float2(i.uv.y, i.uv.x) + float2(_Time.x, 0));
				fixed4 col = (col1 + col2) * 0.5;
				float3 N = normalize(UnpackNormal(col));
				float offsetXY = dot(N, fixed3(0, 1, 0));
				i.uv += offsetXY * 0.02;
				fixed4 finalColor = tex2D(_MainTex, i.uv);
				return finalColor;
			}
			ENDCG
		}
	}
}
