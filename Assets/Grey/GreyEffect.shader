Shader "Unlit/GreyEffect"
{
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_Blend ("Blend", Range(0,1)) = 0
		_Rect ("Color Rect", Vector) = (0,0,0,0)
	}
	SubShader {
		Pass {
			CGPROGRAM
			#pragma vertex vert_img //Unity提供的标准输出函数
			#pragma fragment frag
			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			uniform float _Blend;
			uniform float4 _Rect;

			fixed4 frag(v2f_img i) : COLOR {
				fixed4 color = tex2D(_MainTex, i.uv);
				bool inner = (i.uv.x > _Rect.x && i.uv.y > _Rect.y) && (i.uv.x < _Rect.z && i.uv.y < _Rect.w);//是否在包围盒内
				fixed3 gray = dot(color.rgb, fixed3(0.299, 0.587, 0.114));
				
				gray = color.rgb*inner + gray*(!inner);//转换为最终的颜色是否需要灰度化
				color.rgb = lerp(color.rgb, gray, _Blend);//差值
				
				return color;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
