# Unity Shader Repository

Use Unity Version > 5 当前使用Unity版本大于5


**Table of Contents**

[TOCM]


## 1. [Forge 雾效](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/Forge)
### 1.1 
![](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/Forge/forgeResult.png "Forge Render Effect")

## 2. [Mask 裁剪](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/UIMask)
### 2.1 Rotate Mask 旋转裁剪
```ShaderLab
    fixed4 frag (v2f i) : COLOR
    {
        float2 center = float2(_CenterX, _CenterY);//自定义旋转中心点
        float2 uv = i.uv.xy - center;//当前点对应中心点的相对坐标
        // 旋转矩阵的公式: (cos - sin, sin + cos)顺时针
        float cosVal = cos(_RotateSpeed*_Time.y);
        float sinVal = sin(_RotateSpeed*_Time.y);
        uv = mul(uv, float2x2(cosVal, -sinVal, sinVal, cosVal)) + center;

        fixed4 color = tex2D(_MainTex, i.uv.xy)*_Color;
        color.a = color.a * tex2D(_MaskTex, uv).a;//用MaskTex的a做裁剪
        return color;
    }
```
![](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/UIMask/rotateMask.gif "Rotate Mask Render Effect")

### 2.2 Rect Soft Mask 矩形软裁剪
```ShaderLab
    if (_UseClipRect) 
    {
        //根据世界坐标计算，源自NGUI
        float2 factor = float2(0.0,0.0);
        float2 tempXY = (i.worldPos.xy - _ClipRect.xy)/float2(_SoftClipLeft, _SoftClipBottom)*step(_ClipRect.xy, i.worldPos.xy);
        factor = max(factor,tempXY);
        float2 tempZW = (_ClipRect.zw-i.worldPos.xy)/float2(_SoftClipRight, _SoftClipTop)*step(i.worldPos.xy,_ClipRect.zw);
        factor = min(factor,tempZW);
        color.a *= clamp(min(factor.x,factor.y),0.0,1.0);
    }
```
![](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/UIMask/rectMask.png "Rect Mask Render Effect")
![](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/UIMask/rectMaskInspector.png "Rect Mask Image Inspector")

### 2.3 Custom Soft Mask 自定义形状软裁剪，支持反转
Mask need Component "Rect Mask 2D" in parent, Only one DrawCall. Base on <SuperText>.

![](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/UIMask/soft1.png "Mask Render Effect")
![](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/UIMask/soft11.png "Mask Render Effect")
![](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/UIMask/soft2.png "Mask Render Effect")
![](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/UIMask/soft22.png "Mask Render Effect")

## 3 [Toon 卡通](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/Toon)
### 3.1 Source from [Candycat1992](https://github.com/candycat1992) 
![](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/Toon/toon.png "Toon Render Effect")
### 3.2 [ToonShading](https://github.com/Kink3d/ToonShading)
![](https://camo.githubusercontent.com/049675b7900f1901b6d40a88a37877163c6d1ca4/68747470733a2f2f63646e612e61727473746174696f6e2e636f6d2f702f6173736574732f696d616765732f696d616765732f3030372f3132342f3634342f6c617267652f6d6174742d6465616e2d73637265656e73686f7430312e6a70673f31353033383732333234)


## 4 Rain Effect 雨效
### 4.1 Souce from [RainDropEffect](https://github.com/EdoFrank/RainDropEffect)
![](https://raw.githubusercontent.com/EdoFrank/bin/master/RainDropEffect2/rde1.jpg)


## 5 [Grey Effect 灰度化效果](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/Grey)
### 5.1 Image Grey, Support UGUI Mask and RectMask2D 图片灰度化，支持UGUI的Mask和RectMask2D下有效
### 5.2 Grey Effect, can reserve a *Rect* color window. Can use on Image and Camera effect.
![](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/Grey/imageGrey.png "Image Grey")
![](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/Grey/greyEffect.png "Grey Effect")
### 5.3 Modify Image Grey, support animation. 修改图片灰度化，支持混合模式及缓动灰度化效果

## 6 [Particle Mask 粒子裁剪](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/UIParticleMask)
### 6.1 See [This, Particle Mask](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/UIParticleMask)
![](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/UIParticleMask/clip.png)

## 7 [Rounded Rect 圆角矩形](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/RoundRect)
![](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/RoundRect/roundRect.png)