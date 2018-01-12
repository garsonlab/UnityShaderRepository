## UGUI粒子裁剪

#### 特效粒子在UI上根据需要，可以调节 **Renderer** 选项下的 *Sorting Layer* 和 *Oeder In Layer* 两个选项的值来控制与UI的层级问题，但是这并不能解决所有问题-.-

#### 在UGUI上粒子的裁剪， 通常有两种做法：
* 使用 *RenderTexture* , 把粒子渲染到一张贴图上，然后赋值给需要的图片层级并裁剪
* 自定义裁剪区域 *Shader* , 一个[栗子^-^](http://www.xuanyusong.com/archives/3518) 奉上，简单的说一下实现： 
    * 属性中自定义一个裁剪的矩形区域，左下角坐标、右上角坐标
    * 在frag中判断当前的点的坐标，如果在裁剪区域内按原alpha显示，否则设置为0
    * 自定义一个脚本，用于启动时传入裁剪区域

#### 此外还有一种方法，也是上面栗子中的另一种解决方案，很方便，使用shader的 Stencil 模版测试来实现，UGUI的*Mask*组建是这种实现方式。由于需要多绘制一次多一次DrawCall，但这对于Mask来说本身也有这个问题，可以忽略，除非你是用RectMask2D，但在此处然并卵。使用方法：
* UI添加一个Mask组件，选择该组建上的Image，为其赋值一个使用 *UIParticle/UIDefaultMask* 的材质
* 在Mask下添加需要被裁剪的粒子，替换使用*UIParticle/*下的Shader

在*UIParticle/UIDefaultMask*中，仅仅是复制了unityShader的 *UI/Default*，在 **Stencil** 下添加：
``` UnityShader
Stencil {
    Ref 1 //设定参考值1与缓冲模版比较
    Comp Always //定义参考值(Ref设定值)与缓冲值（stencilBufferValue）比较的操作函数
    Pass Replace //定义当模板测试（和深度测试）通过时，则根据（stencilOperation值）对模板缓冲值（stencilBufferValue）进行处理
}
```

在其他粒子使用的Shader中加入
``` UnityShader
Stencil {
    Ref 1
    Comp equal
}
```

关于Stencil的解释，可以参考 [Stencil Buffer&Stencil Test](http://blog.csdn.net/u011047171/article/details/46928463?locationNum=1)

然后添加两个常用的粒子Shader: Additive 和 Blend。有一个缺点是当裁剪区域重叠时...
还有一个是如果使用了这个MaskShader， 在其下不使用的则不会显示
效果图![](https://github.com/garsonlab/UnityShaderRepository/raw/master/Assets/UIParticleMask/clip.png)


#### 以上各有优缺点，合适的才是最好的
