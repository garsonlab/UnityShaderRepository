Shader "Hidden/ImageGrey"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}//UI Image上选择的图片
		_Color ("Tint", Color) = (1,1,1,1)
		_Blend ("Blend", Range(0,1)) = 1
		[Toggle] _IsAnimate ("Is Animate", Float) = 0
		_Speed ("Speed", float) = 2.5
		[Space(20)]

		// Required for UI.Mask
		_StencilComp("Stencil Comparison", Float) = 8
		_Stencil("Stencil ID", Float) = 0
		_StencilOp("Stencil Operation", Float) = 0
		_StencilWriteMask("Stencil Write Mask", Float) = 255
		_StencilReadMask("Stencil Read Mask", Float) = 255
		_ColorMask("Color Mask", Float) = 15
	}
	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}
		// 源rgba*源a + 背景rgba*(1-源A值)
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			Stencil//要支持Mask必须，否则在Mask下不会被裁剪
            {
                Ref[_Stencil]
                Comp[_StencilComp]
                Pass[_StencilOp]
                ReadMask[_StencilReadMask]
                WriteMask[_StencilWriteMask]
            }
            ColorMask[_ColorMask]

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
			};

			fixed4 _Color;
			float _Blend;
			bool _IsAnimate;
			float _Speed;		

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);//转换坐标空间
				o.uv = v.texcoord;
				#ifdef UNITY_HALF_TEXEL_OFFSET
				o.vertex.xy -= (_ScreenParams.zw-1.0);
				#endif
				o.color = v.color*_Color;
				return o;
			}
			
			sampler2D _MainTex;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.uv) * i.color;
				fixed3 grey = dot(color.rgb, fixed3(0.22, 0.707, 0.071));
				float blend = _Blend*(!_IsAnimate)+abs(sin(_Time.y*_Speed))*_IsAnimate;
				color.rgb = lerp(color.rgb, grey, blend);
				return color;
			}
			ENDCG
		}
	}
}
