//http://www.imatest.com/docs/distortion_instructions/
//https://en.wikipedia.org/wiki/Distortion_(optics)
Shader "Custom/AfterEffects/BarrelDistortion"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct a2v
			{
				half4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				half2 uv : TEXCOORD0;
				half4 pos : SV_POSITION;
			};

			sampler2D _MainTex;
			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.vertex.xy;
				return o;
			}
			
			fixed2 barrelDistortion(fixed2 coord)
			{
				fixed2 h = coord - fixed2(0.5, 0.5);
				fixed r2 = h.x * h.x + h.y * h.y;
				fixed f = 1 + r2 * (-0.9 * sqrt(r2));
				
				return f * h + 0.5;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				half2 dis = i.uv - 0.5;
				half len = pow(length(dis), 2);
				half2 barrelUV = barrelDistortion(i.uv+ len * dis * (_SinTime.w * 3 - 3) * 0.05);
				fixed4 col = tex2D(_MainTex, barrelUV);
				fixed4 baseCol = col;
				col.r = 0.393 * col.r + 0.769 * col.g + 0.189 * col.b;
				col.g = 0.349 * col.r + 0.686 * col.g + 0.168 * col.b;
				col.b = 0.272 * col.r + 0.534 * col.g + 0.131 * col.b;
				
				return col * 0.8;
			}
			ENDCG
		}
	}
}
