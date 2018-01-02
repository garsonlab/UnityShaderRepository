Shader "Hidden/RotateMaskShader"
{
	Properties
	{
		[PerRendererData] _MainTex ("Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		_MaskTex ("Mask Texture", 2D) = "white" {}
		_CenterX ("Mask Center X", Range(0, 1)) = 0.5
		_CenterY ("Mask Center Y", Range(0, 1)) = 0.5
		_RotateSpeed("Rotate Speed",Range(0,10))=5

		//Mask Clip Necessary
		[HideInInspector] _StencilComp ("Stencil Comparison", Float) = 8
		[HideInInspector] _Stencil ("Stencil ID", Float) = 0
		[HideInInspector] _StencilOp ("Stencil Operation", Float) = 0
		[HideInInspector] _StencilWriteMask ("Stencil Write Mask", Float) = 255
		[HideInInspector] _StencilReadMask ("Stencil Read Mask", Float) = 255
		[HideInInspector] _ColorMask ("Color Mask", Float) = 15
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
		Stencil //mask必须，模版缓存
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp] 
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}

		Cull back
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

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
			sampler2D _MaskTex;
			fixed4 _Color;
			float _RotateSpeed;
			float _CenterX;
			float _CenterY;

			fixed4 frag (v2f i) : COLOR
			{
				float2 center = float2(_CenterX, _CenterY);
				float2 uv = i.uv.xy - center;
				// 旋转矩阵的公式: (cos - sin, sin + cos)顺时针
				float cosVal = cos(_RotateSpeed*_Time.y);
				float sinVal = sin(_RotateSpeed*_Time.y);
				uv = mul(uv, float2x2(cosVal, -sinVal, sinVal, cosVal)) + center;

				fixed4 color = tex2D(_MainTex, i.uv.xy)*_Color;
				color.a = color.a * tex2D(_MaskTex, uv).a;
				return color;
			}
			ENDCG
		}
	}
}
