// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/UISoftMask" {
	Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        [HideInInspector]_StencilComp ("Stencil Comparison", Float) = 8
        [HideInInspector]_Stencil ("Stencil ID", Float) = 0
        [HideInInspector]_StencilOp ("Stencil Operation", Float) = 0
        [HideInInspector]_StencilWriteMask ("Stencil Write Mask", Float) = 255
        [HideInInspector]_StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [HideInInspector]_ClipRect			("Clip Rect", Vector) = (-32767, -32767, 32767, 32767)
		_MaskSoftnessX		("Mask SoftnessX", Float) = 0
		_MaskSoftnessY		("Mask SoftnessY", Float) = 0
		_MaskTex			("Mask Texture", 2D) = "white" {}
		_MaskEdgeColor		("Edge Color", Color) = (1,1,1,1)
		_MaskEdgeSoftness	("Edge Softness", Range(0, 1)) = 0.01
		_MaskWipeControl	("Wipe Position", Range(0, 1)) = 0.5
		[Toggle]_MaskInverse("Inverse", Float) = 0
    }

    SubShader
    {
        Tags {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile __ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float4 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                half4	mask	: TEXCOORD2;// Position in clip space(xy), Softness(zw)
                UNITY_VERTEX_OUTPUT_STEREO
            };

            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;

            sampler2D _MaskTex;
            float _MaskSoftnessX;
            float _MaskSoftnessY;
            float _MaskWipeControl;
			float _MaskEdgeSoftness;
			fixed4 _MaskEdgeColor;
			bool _MaskInverse;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.texcoord.xy = v.texcoord.xy;

                float4 clampedRect = _ClipRect;//clamp(_ClipRect, -2e10, 2e10);
                float2 maskUV = (v.vertex.xy - clampedRect.xy) / (clampedRect.zw - clampedRect.xy);
                float2 pixelSize = OUT.vertex.w;
				pixelSize /= abs(mul((float2x2)UNITY_MATRIX_P, _ScreenParams.xy));

				OUT.texcoord.zw = maskUV;
                OUT.color = v.color * _Color;
                OUT.mask = half4(v.vertex.xy * 2 - clampedRect.xy - clampedRect.zw, 0.25 / (0.25 * half2(_MaskSoftnessX, _MaskSoftnessY) + pixelSize.xy));
                return OUT;
            }

            sampler2D _MainTex;

            fixed4 frag(v2f IN) : SV_Target
            {
                half4 c = (tex2D(_MainTex, IN.texcoord.xy) + _TextureSampleAdd) * IN.color;

                half2 m = saturate((_ClipRect.zw - _ClipRect.xy - abs(IN.mask.xy)) * IN.mask.zw);
                c *= m.x * m.y;
                float a = abs(_MaskInverse - tex2D(_MaskTex, IN.texcoord.zw).a);
				float t = a + (1 - _MaskWipeControl) * _MaskEdgeSoftness - _MaskWipeControl;
				a = saturate(t / _MaskEdgeSoftness);
				c.rgb = lerp(_MaskEdgeColor.rgb, c.rgb, a);
				c *= a;

                return c;
            }
        ENDCG
        }
    }
	FallBack "UI/Default"
}
