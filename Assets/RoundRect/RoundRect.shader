Shader "Custom/RoundRect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		_Radius ("Radius", Range(0,0.5)) = 0.1
	}
	SubShader
	{
		Tags 
		{
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent"
			"CanUseSpriteAtlas"="True"
		}
		Blend SrcAlpha OneMinusSrcAlpha

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

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			fixed4 _Color;
			float _Radius;

			fixed4 frag (v2f i) : COLOR
			{
				fixed4 col = tex2D(_MainTex, i.uv)*_Color;
				
				float2 center = float2(0.5, 0.5);
				float2 uv = abs(i.uv.xy - center);
				float2 cirUV = uv - float2(0.5-_Radius, 0.5-_Radius);
				bool alpha = uv.x <= 0.5-_Radius || uv.y <= 0.5-_Radius || length(cirUV) <= _Radius;
				col.a = col.a *alpha;
				return col;
			}
			ENDCG
		}
	}
}
