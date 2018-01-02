using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

/// <summary>
/// Introduction: Png图片的一些操作，主要功能包含：
///         1>  裁剪图片
///                 裁剪多余空白成 n*n （ n=2^m）
///         2>  缩放图片，
///                 提供按比例缩放和缩放成最终尺寸两张方法
///         3>  扩充图片，
///                 提供如 以中心为准向四周填充空白、以左上为起点向右下填充空白等 9 中方法
///                 填充结果为 图片尺寸 = n * m （n = 2^a， m = 2^b）
/// Author: 	刘家诚
/// Time: 2017/11/23
/// </summary>
public class PngSerialize : EditorWindow
{


    #region Zoom Method
    [MenuItem("Tools/PngOperate")]
    static void TextureOperateWindow()
    {
        GetWindow<PngSerialize>("Texture Operate").Show();
    }

    private int selectIndex = 0;
    private string[] menus = new string[]{"Expand", "Zoom", "Cut"};
    string[] directions = new string[] { "↖", "↑", "↗", "←", "□", "→", "↙", "↓", "↘" };
    private int[] expendResult = new []{79, 7, 295, 73, 0, 292, 457, 448, 484};
    private int expendFlag = 0;
    private bool isZoomSize = true;
    static Vector2 zoom = Vector2.one;
    static Vector2 zoomSize = Vector2.one*128;

    void OnGUI()
    {
        GUILayout.BeginVertical();
        GUILayout.Label("Select textures to operate funtions berfore checked attribute ‘Read/Write Enable’");
        GUILayout.Space(10);
        selectIndex = GUILayout.Toolbar(selectIndex, menus);

        if (selectIndex == 0)
        {
            DrawExpandGUI();
        }
        else if (selectIndex == 1)
        {
            DrawZoomGUI();
        }
        else if (selectIndex == 2)
        {
            DrawCutGUI();
        }

        GUILayout.EndVertical();
    }

    private void DrawExpandGUI()
    {
        GUILayout.Space(20);
        GUILayout.Label("Select Expand Direction, Expend result size is n*n (n = 2^m). ");

        for (int i = 0; i < 3; i++)
        {
            GUILayout.BeginHorizontal();
            for (int j = 0; j < 3; j++)
            {
                if ((expendFlag & (int) Mathf.Pow(2, i*3 + j)) > 0)
                {
                    GUI.enabled = false;
                    if (GUILayout.Button(directions[i*3 + j], GUILayout.Width(30), GUILayout.Height(30)))
                    {
                        expendFlag = expendResult[i*3 + j];
                    }
                    GUI.enabled = true;
                }
                else
                {
                    if (GUILayout.Button(directions[i * 3 + j], GUILayout.Width(30), GUILayout.Height(30)))
                    {
                        expendFlag = expendResult[i * 3 + j];
                    }
                }
            }
            GUILayout.EndHorizontal();
        }

        GUILayout.Space(10);
        if (GUILayout.Button("Expand", GUILayout.Width(100)))
        {
            for (int i = 0; i < expendResult.Length; i++)
            {
                if (expendFlag == expendResult[i])
                {
                    SelectToExpand((TextAnchor)i);
                    break;
                }
            }
        }
    }

    private void DrawZoomGUI()
    {
        GUILayout.Space(10);
        isZoomSize = EditorGUILayout.Toggle("Is Zoom Size", isZoomSize);

        GUILayout.Space(20);
        if (isZoomSize)
            GUI.enabled = false;
        zoom = EditorGUILayout.Vector2Field("Zoom By Ratio", zoom);
        if (zoom.x <= 0) zoom.x = 0.1f;
        if (zoom.y <= 0) zoom.y = 0.1f;
        if (!isZoomSize)
            GUI.enabled = false;
        else
            GUI.enabled = true;
        GUILayout.Space(10);
        zoomSize = EditorGUILayout.Vector2Field("Zoom To Size", zoomSize);
        if (zoomSize.x < 4)
            zoomSize.x = 4;
        if (zoomSize.y < 4)
            zoomSize.y = 4;
        zoomSize.x = Mathf.CeilToInt(zoomSize.x);
        zoomSize.y = Mathf.CeilToInt(zoomSize.y);

        GUI.enabled = true;
        GUILayout.Space(10);
        if (GUILayout.Button("Zoom", GUILayout.Width(100)))
        {
            if (isZoomSize)
            {
                SelectToZoom(zoomSize, true);
            }
            else
            {
                SelectToZoom(zoom);
            }
        }

    }

    private void DrawCutGUI()
    {
        GUILayout.Space(20);
        GUILayout.Label("Cut function only support cut a n*n(n=2^m) texture taked the center as the origin.");
        GUILayout.Label("Other functions is Comming!");

        GUILayout.Space(10);
        if (GUILayout.Button("Cut"))
        {
            SelectToShrink();
        }
    }


    static void SelectToShrink()
    {
        int num = 0;
        Object[] selections = (Object[])Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);
        foreach (Object obj in selections)
        {
            string path = AssetDatabase.GetAssetOrScenePath(obj);
            if (!path.ToLower().EndsWith(".png"))
                continue;

            if (!Path.GetExtension(path).ToLower().Equals(".png"))
                continue;

            Texture2D texture = Shrink(obj as Texture2D);
            if (texture != null)
            {
                byte[] bytes = texture.EncodeToPNG();
                string savePath = Application.dataPath.Replace("Assets", "") + path;
                File.WriteAllBytes(savePath, bytes);
            }
            num++;
        }
        AssetDatabase.Refresh();
        Debug.Log("<color=#23fe40>Png缩减结束: " + num + " 成功</color>");
    }


    static void SelectToZoom(Vector2 scaleFactor, bool isSize = false)
    {
        int num = 0;
        Object[] selections = (Object[])Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);
        foreach (Object obj in selections)
        {
            string path = AssetDatabase.GetAssetOrScenePath(obj);
            if (!path.ToLower().EndsWith(".png"))
                continue;

            if (!Path.GetExtension(path).ToLower().Equals(".png"))
                continue;

            Texture2D texture = Zoom(obj as Texture2D, scaleFactor, isSize);
            if (texture != null)
            {
                byte[] bytes = texture.EncodeToPNG();
                string savePath = Application.dataPath.Replace("Assets", "") + path;
                File.WriteAllBytes(savePath, bytes);
            }
            num++;
        }
        AssetDatabase.Refresh();
        Debug.Log("<color=#23fe40>Png缩放结束: " + num + " 成功</color>");
    }
    #endregion


    #region Expand Method
    /*
    [MenuItem("Tools/Png/ExpandTopLeft")]
    static void ExpandTopLeft()
    {
        SelectToExpand(TextAnchor.UpperLeft);
    }
    [MenuItem("Tools/Png/ExpandTopCenter")]
    static void ExpandTopCenter()
    {
        SelectToExpand(TextAnchor.UpperCenter);
    }
    [MenuItem("Tools/Png/ExpandTopRight")]
    static void ExpandTopRight()
    {
        SelectToExpand(TextAnchor.UpperRight);
    }
    [MenuItem("Tools/Png/ExpandMiddleLeft")]
    static void ExpandMiddleLeft()
    {
        SelectToExpand(TextAnchor.MiddleLeft);
    }
    [MenuItem("Assets/ExpandCenter")]
    [MenuItem("Tools/Png/ExpandCenter")]
    static void ExpandCenter()
    {
        SelectToExpand(TextAnchor.MiddleCenter);
    }
    [MenuItem("Tools/Png/ExpandMiddleRight")]
    static void ExpandMiddleRight()
    {
        SelectToExpand(TextAnchor.MiddleRight);
    }
    [MenuItem("Tools/Png/ExpandBottomLeft")]
    static void ExpandBottomLeft()
    {
        SelectToExpand(TextAnchor.LowerLeft);
    }
    [MenuItem("Tools/Png/ExpandBottomCenter")]
    static void ExpandBottomCenter()
    {
        SelectToExpand(TextAnchor.LowerCenter);
    }
    [MenuItem("Tools/Png/ExpandBottomRight")]
    static void ExpandBottomRight()
    {
        SelectToExpand(TextAnchor.LowerRight);
    }
    */
    static void SelectToExpand(TextAnchor anchor)
    {
        int num = 0;
        Object[] selections = (Object[])Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);
        foreach (Object obj in selections)
        {
            string path = AssetDatabase.GetAssetOrScenePath(obj);
            if (!path.ToLower().EndsWith(".png"))
                continue;

            if (!Path.GetExtension(path).ToLower().Equals(".png"))
                continue;

            Texture2D texture = Expand(obj as Texture2D, anchor);
            if (texture != null)
            {
                byte[] bytes = texture.EncodeToPNG();
                string savePath = Application.dataPath.Replace("Assets", "") + path;
                File.WriteAllBytes(savePath, bytes);
            }
            num++;
        }
        AssetDatabase.Refresh();
        Debug.Log("<color=#23fe40>Png扩充结束: " + num + " 成功</color>");
    }

    #endregion



    /// <summary>
    /// 扩充png
    /// </summary>
    /// <param name="texture"></param>
    /// <param name="anchor"></param>
    /// <returns></returns>
    public static Texture2D Expand(Texture2D texture, TextAnchor anchor = TextAnchor.MiddleCenter)
    {
        Vec2Int wrapSize = GetWrapSize(texture.width, texture.height);
        if (wrapSize.Equals(new Vec2Int(texture.width, texture.height)))
            return null;

        bool alphaEnable = GetAlphaEnable(texture);
        Texture2D newTex = new Texture2D(wrapSize.x, wrapSize.y, TextureFormat.ARGB32, false);
        ResetTex(newTex, alphaEnable);

        Vec2Int start = GetStartPos(wrapSize, texture.width, texture.height, anchor);

        Color[] colors = texture.GetPixels();
        newTex.SetPixels(start.x, start.y, texture.width, texture.height, colors);
        return newTex;
    }

    /// <summary>
    /// 裁剪png多余空白
    /// </summary>
    /// <param name="texture"></param>
    /// <returns></returns>
    public static Texture2D Shrink(Texture2D texture)
    {
        Vec2Int size = GetShrinkSize(texture);
        if (texture.width == size.x && texture.height == size.y)
            return null;

        Texture2D newTex = new Texture2D(size.x, size.y, TextureFormat.ARGB32, false);
        int left = (texture.width - size.x) / 2;
        int top = (texture.height - size.y) / 2;

        Color[] colors = texture.GetPixels(left, top, size.x, size.y);
        newTex.SetPixels(colors);
        return newTex;
    }

    /// <summary>
    /// 缩放png
    /// </summary>
    /// <param name="texture"></param>
    /// <param name="scaleFactor"></param>
    /// <returns></returns>
    public static Texture2D Zoom(Texture2D texture, Vector2 scaleFactor, bool isSize)
    {
        if (!isSize && scaleFactor == Vector2.one) return null;
        if (isSize && ((scaleFactor.x == texture.width && scaleFactor.y == texture.height) || scaleFactor.x <= 1 || scaleFactor.y <= 1)) return null;

        int width = isSize ? (int)scaleFactor.x : Mathf.CeilToInt(texture.width*scaleFactor.x);
        int height = isSize ? (int)scaleFactor.y : Mathf.CeilToInt(texture.height*scaleFactor.y);

        Texture2D newTex = new Texture2D(width, height, TextureFormat.ARGB32, false);

        float scaleX = isSize ? (texture.width/scaleFactor.x) : 1.0f / scaleFactor.x;
        float scaleY = isSize ? (texture.height / scaleFactor.y) : 1.0f / scaleFactor.y;
        int maxX = texture.width - 1;  
        int maxY = texture.height - 1;  
        for (int y = 0; y < height; y++)  
        {  
            for (int x = 0; x < width; x++)  
            {  
                // Bilinear Interpolation  
                float targetX = x * scaleX;  
                float targetY = y * scaleY;  
                int x1 = Mathf.Min(maxX, Mathf.FloorToInt(targetX));  
                int y1 = Mathf.Min(maxY, Mathf.FloorToInt(targetY));  
                int x2 = Mathf.Min(maxX, x1 + 1);  
                int y2 = Mathf.Min(maxY, y1 + 1);  
  
                float u = targetX - x1;  
                float v = targetY - y1 ;  
                float w1 = (1 - u) * (1 - v);  
                float w2 = u * (1 - v);  
                float w3 = (1 - u) * v;  
                float w4 = u * v;  
                Color color1 = texture.GetPixel(x1, y1);
                Color color2 = texture.GetPixel(x2, y1);
                Color color3 = texture.GetPixel(x1, y2);
                Color color4 = texture.GetPixel(x2, y2);  
                Color color = new Color(Mathf.Clamp01(color1.r * w1 + color2.r * w2 + color3.r * w3+ color4.r * w4),  
                    Mathf.Clamp01(color1.g * w1 + color2.g * w2 + color3.g * w3 + color4.g * w4),  
                    Mathf.Clamp01(color1.b * w1 + color2.b * w2 + color3.b * w3 + color4.b * w4),  
                    Mathf.Clamp01(color1.a * w1 + color2.a * w2 + color3.a * w3 + color4.a * w4)  
                    );  
                newTex.SetPixel(x, y, color);  
            }  
        }  
  
        return newTex;
    }


    /// <summary>
    /// 查看是否有alpha通道
    /// </summary>
    /// <param name="texture"></param>
    /// <returns></returns>
    public static bool GetAlphaEnable(Texture2D texture)
    {
        int width = texture.width;
        int height = texture.height;
        Color color;
        for (int i = 0; i < width; i++)
        {
            for (int j = 0; j < height; j++)
            {
                color = texture.GetPixel(i, j);
                if (color.a < 1)
                {
                    return true;
                }
            }
        }
        return false;
    }


    #region Functions
    /// <summary>
    /// 查看alpha通道允许
    /// </summary>
    /// <param name="path"></param>
    /// <returns></returns>
    public static bool GetAlphaEnable(string path)
    {
        Texture2D texture = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
        if (texture != null)
        {
            return GetAlphaEnable(texture);
        }
        return true;
    }

    /// <summary>
    /// 是否还须扩展，满足2的n次方不需要
    /// </summary>
    /// <param name="path"></param>
    /// <returns></returns>
    public static bool GetWrapEnable(string path)
    {
        Texture2D texture = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
        if (texture != null)
        {
            Vec2Int wrapSize = GetWrapSize(texture.width, texture.height);
            return wrapSize.Equals(new Vec2Int(texture.width, texture.height));
        }
        return true;
    }

    /// <summary>
    /// 设置初始化alpha通道
    /// </summary>
    /// <param name="newTex"></param>
    static void ResetTex(Texture2D newTex, bool alpha)
    {
        int width = newTex.width;
        int height = newTex.height;
        Color color = new Color(0, 0, 0, alpha ? 0 : 1);
        for (int i = 0; i < width; i++)
        {
            for (int j = 0; j < height; j++)
            {
                newTex.SetPixel(i, j, color);
            }
        }

        newTex.alphaIsTransparency = alpha;
    }

    /// <summary>
    /// 查找最适合尺寸
    /// </summary>
    /// <param name="width"></param>
    /// <param name="height"></param>
    /// <returns></returns>
    static Vec2Int GetWrapSize(int width, int height)
    {
        Vec2Int wrap = new Vec2Int();
        for (int i = 0; i < 30; i++)//int最大值32次方
        {
            if (wrap.x == 0 && Mathf.Pow(2, i) >= width)
                wrap.x = (int)Mathf.Pow(2, i);
            if (wrap.y == 0 && Mathf.Pow(2, i) >= height)
                wrap.y = (int)Mathf.Pow(2, i);

            if(wrap.x > 0 && wrap.y > 0)
                break;
        }
        return wrap;
    }

    /// <summary>
    /// 获取裁剪的非空白最大尺寸
    /// </summary>
    /// <param name="texture"></param>
    /// <returns></returns>
    static Vec2Int GetShrinkSize(Texture2D texture)
    {
        int size = texture.width <= texture.height ? texture.width : texture.height;
        int tem = 1;
        for (int i = 1; i < 30; i++)
        {
            int next = (int)Mathf.Pow(2, i + 1);
            if (tem < size && next >= size)
            {
                size = tem;
                break;
            }
            else
            {
                tem = next;
            }
        }

        int left = (texture.width - size)/2;
        int top = (texture.height - size)/2;
        bool isFirtOperate = true;
        while (true)
        {
            bool isTransparent = true;
            for (int i = left; i < texture.width-left; i++)
            {
                Color c1 = texture.GetPixel(i, top);
                Color c2 = texture.GetPixel(i, texture.height - top);

                if (c1.a > 0 || c2.a > 0)
                {
                    isTransparent = false;
                    break;
                }
            }

            if (isTransparent)
            {
                for (int j = top; j < texture.height-top; j++)
                {
                    Color c1 = texture.GetPixel(left, j);
                    Color c2 = texture.GetPixel(texture.width - left, j);

                    if (c1.a > 0 || c2.a > 0)
                    {
                        isTransparent = false;
                        break;
                    }
                }
            }


            if (isTransparent)
            {
                size = size/2;
                left = (texture.width - size) / 2;
                top = (texture.height - size) / 2;
                isFirtOperate = false;
            }
            else
            {
                size = size*2;
                break;
            }
        }

        if(isFirtOperate)//1次操作都失败
            return new Vec2Int(texture.width, texture.height);

        if (size > texture.height || size > texture.width)
            size = size/2;

        return new Vec2Int(size, size);
    }

    static Vec2Int GetStartPos(Vec2Int wrap, int texWid, int texHei, TextAnchor anchor)
    {
        int left = (wrap.x - texWid) / 2;
        int top = (wrap.y - texHei) / 2;

        Vec2Int start = new Vec2Int();
        switch (anchor)
        {
            case TextAnchor.LowerLeft:
                break;
            case TextAnchor.LowerCenter:
                start.x = left;
                break;
            case TextAnchor.LowerRight:
                start.x = wrap.x - texWid;
                break;
            case TextAnchor.MiddleLeft:
                start.y = top;
                break;
            case TextAnchor.MiddleCenter:
                start.x = left;
                start.y = top;
                break;
            case TextAnchor.MiddleRight:
                start.x = wrap.x - texWid;
                start.y = top;
                break;
            case TextAnchor.UpperLeft:
                start.y = wrap.y - texHei;
                break;
            case TextAnchor.UpperCenter:
                start.x = left;
                start.y = wrap.y - texHei;
                break;
            case TextAnchor.UpperRight:
                start.x = wrap.x - texWid;
                start.y = wrap.y - texHei;
                break;
        }
        return start;
    }

    class Vec2Int
    {
        public int x;
        public int y;

        public Vec2Int()
        {
            this.x = 0;
            this.y = 0;
        }

        public Vec2Int(int x, int y)
        {
            this.x = x;
            this.y = y;
        }

        public override bool Equals(object obj)
        {
            if (obj is Vector2)
            {
                Vector2 vec = (Vector2)obj;
                return this.x == (int)vec.x && this.y == (int)vec.y;
            }
            else if (obj is Vec2Int)
            {
                Vec2Int vec = obj as Vec2Int;
                return this.x == vec.x && this.y == vec.y;
            }

            return false;
        }

        public override int GetHashCode()
        {
            return base.GetHashCode();
        }

    }
    #endregion
}
