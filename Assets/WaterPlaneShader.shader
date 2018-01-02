// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/WaterPlaneShader" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_SpeedX ("Speed X Axia", Range(0,1)) = 0.5
		_SpeedY ("Speed Y Axia", Range(0,1)) = 0.5 
	}
	SubShader{
		Tags{"Queue"="Transparent" "RenderType"="Transparent"}
		Pass{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;
			fixed4 _Color;
			half _SpeedX;
			half _SpeedY;

			struct a2v{
				float4 vertex	:	POSITION;
				float4 texcoord :	TEXCOORD0;
			};

			struct v2f{
				float4 pos 	:	SV_POSITION;
				float2 uv	:	TEXCOORD0;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy;
				//float 
				return o;
			}

			fixed4 frag(v2f i) : COLOR0{

				i.uv.x *= _SpeedX * _Time;
				i.uv.y *= _SpeedY * _Time;
				return tex2D(_MainTex, i.uv);
			}


			ENDCG
		}
	}
}
