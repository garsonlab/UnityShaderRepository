using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 屏幕后期特效，局部灰度化
/// </summary>
[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class GreyEffect : UnityStandardAssets.ImageEffects.PostEffectsBase
{
	public Shader m_Shader;
	private Material m_Material;

	[SerializeField]
	private Vector4 m_Vector;
	[SerializeField]
	[Range(0,1)]
	private float m_Blend;

	public override bool CheckResources()	
    {
        CheckSupport(true);
        m_Material = CheckShaderAndCreateMaterial(m_Shader, m_Material);

        if (!isSupported)
            ReportAutoDisable();
        return isSupported;
    }

    private void OnEnable()
    {
        CheckResources();
    }

	[ContextMenu("SetRect")]
	public void SetRect(Vector4 vector)
	{
		m_Vector = vector;
		m_Material.SetColor("_Rect", m_Vector);
	}

	[ContextMenu("SetBlend")]
	public void SetBlend(float blend)
	{
		m_Blend = Mathf.Clamp01(blend);
		m_Material.SetFloat("_Blend", m_Blend);
	}

	void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (CheckResources() == false)
        {
            Graphics.Blit(source, destination);
            return;
        }
        //Do a full screen pass using material
        Graphics.Blit(source, destination, m_Material);
    }
}
