using UnityEngine;

/// <summary>
/// 桶行扭曲，模拟回忆过去场景
/// </summary>
public class BarrelDistortion : MonoBehaviour
{
    Material material;

    private void Awake()
    {
        if (!material)
        {
            material = new Material(Shader.Find("Custom/AfterEffects/BarrelDistortion"));
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, material);
    }

}
