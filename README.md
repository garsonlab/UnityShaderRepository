## Unity Shader Repository

Use Unity Version 2017.2




### Forge
![](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/Forge/forgeResult.png "Forge Render Effect")

### Mask
##### Rotate Mask
```cpp
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

##### Rect Soft Mask
```cpp
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

##### Custom Soft Mask
Mask need Component "Rect Mask 2D", Only one DrawCall.

![](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/UIMask/soft1.png "Mask Render Effect")
![](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/UIMask/soft11.png "Mask Render Effect")
![](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/UIMask/soft2.png "Mask Render Effect")
![](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/UIMask/soft22.png "Mask Render Effect")

