Shader "Hidden/UIRectSoftMask"
{
	Properties {
		[PerRendererData] _MainTex ("Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)

		//Mask Clip Necessary
		[HideInInspector] _StencilComp ("Stencil Comparison", Float) = 8
		[HideInInspector] _Stencil ("Stencil ID", Float) = 0
		[HideInInspector] _StencilOp ("Stencil Operation", Float) = 0
		[HideInInspector] _StencilWriteMask ("Stencil Write Mask", Float) = 255
		[HideInInspector] _StencilReadMask ("Stencil Read Mask", Float) = 255
		[HideInInspector] _ColorMask ("Color Mask", Float) = 15

		_SoftClipTop ("Clip Top", Range(0,500))=20
		_SoftClipLeft ("Clip Left", Range(0,500))=20
		_SoftClipBottom ("Clip Bottom", Range(0,500))=20
		_SoftClipRight ("Clip Right", Range(0,500))=20
	}

	SubShader {
		Tags {
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Stencil {//Mask Necessary
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

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
				float4 worldPos : TEXCOORD1;
			};


			fixed4 _Color;
			fixed4 _TextureSampleAdd;
			bool _UseClipRect;
			float4 _ClipRect;
			bool _UseAlphaClip;

			v2f vert (appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				o.color = v.color*_Color;
				o.worldPos = v.vertex;

				#ifdef UNITY_HALF_TEXEL_OFFSET
				o.vertex.xy += (_ScreenParams.zw-1.0)*float2(-1,1);
				#endif

				return o;
			}

			sampler2D _MainTex;
			float _SoftClipTop;
			float _SoftClipLeft;
			float _SoftClipBottom;
			float _SoftClipRight;

			fixed4 frag (v2f i) : SV_Target {
				fixed4 color = (tex2D(_MainTex, i.uv) + _TextureSampleAdd) * i.color;
				
				if (_UseClipRect) {
					float2 factor = float2(0.0,0.0);
					float2 tempXY = (i.worldPos.xy - _ClipRect.xy)/float2(_SoftClipLeft, _SoftClipBottom)*step(_ClipRect.xy, i.worldPos.xy);
					factor = max(factor,tempXY);
					float2 tempZW = (_ClipRect.zw-i.worldPos.xy)/float2(_SoftClipRight, _SoftClipTop)*step(i.worldPos.xy,_ClipRect.zw);
					factor = min(factor,tempZW);
					color.a *= clamp(min(factor.x,factor.y),0.0,1.0);
				}

				if (_UseAlphaClip)
					clip (color.a - 0.001);

				return color;
			}
			ENDCG
		}
	}
}
