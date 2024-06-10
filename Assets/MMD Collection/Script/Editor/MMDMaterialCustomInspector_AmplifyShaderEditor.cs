using UnityEngine;
using UnityEditor;
using System;

// Custom inspector for MMD (MikuMikuDance) materials.
public class MMDMaterialCustomInspector_AmplifyShaderEditor : ShaderGUI
{
    private string materialNameJP;
    private string materialNameEN;
    private string materialMeno;
    private bool showSystemsDefault;

    private CustomMMDData customMMDMaterialData;

    private MaterialEditor materialInspector;
    private MaterialProperty[] materialProperties;
    private Material currentMaterial;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        materialInspector = materialEditor;
        materialProperties = properties;
        currentMaterial = materialEditor.target as Material;

        GUILayout.BeginHorizontal();
        GUILayout.Label("Show Default Systems:", EditorStyles.boldLabel, GUILayout.Width(145f));
        showSystemsDefault = EditorGUILayout.Toggle(showSystemsDefault);
        GUILayout.EndHorizontal();
        GUILayout.Space(5f);

        if (customMMDMaterialData == null)
        {
            customMMDMaterialData = CustomMMDDataUtilityEditor.GetOrCreateCustomMMDData();
            CustomMMDDataUtilityEditor.RemoveInvalidMaterials(customMMDMaterialData);
            LoadData();
        }

        if (!showSystemsDefault)
        {
            RenderCustomMaterialInspector();
        }
        else
        {
            GUILayout.Space(20f);
            RenderSurfaceOptions();
            base.OnGUI(materialInspector, materialProperties);
            RenderLightmapFlags();
        }

        SaveData();
    }

    private void LoadData()
    {
        if (customMMDMaterialData != null && customMMDMaterialData.materialInfoList != null)
        {
            showSystemsDefault = customMMDMaterialData.showSystemsDefault;
            MMDMaterialInfo existingMaterialInfo = customMMDMaterialData.materialInfoList.Find(info => info.mmdMaterial == currentMaterial);

            if (existingMaterialInfo != null)
            {
                materialNameJP = existingMaterialInfo.materialNameJP;
                materialNameEN = existingMaterialInfo.materialNameEN;
                materialMeno = existingMaterialInfo.materialMeno;
            }
            else
            {
                materialNameJP = "";
                materialNameEN = "";
                materialMeno = "";
            }
        }
    }

    private void SaveData()
    {
        if (DetectChanges())
        {
            customMMDMaterialData.showSystemsDefault = showSystemsDefault;
            MMDMaterialInfo existingMaterialInfo = customMMDMaterialData.materialInfoList.Find(info => info.mmdMaterial == currentMaterial);

            if (existingMaterialInfo != null)
            {
                existingMaterialInfo.materialNameJP = materialNameJP;
                existingMaterialInfo.materialNameEN = materialNameEN;
                existingMaterialInfo.materialMeno = materialMeno;
            }
            else
            {
                MMDMaterialInfo newMaterialInfo = new()
                {
                    mmdMaterial = currentMaterial,
                    materialNameJP = materialNameJP,
                    materialNameEN = materialNameEN,
                    materialMeno = materialMeno
                };

                customMMDMaterialData.materialInfoList.Add(newMaterialInfo);
            }

            EditorUtility.SetDirty(customMMDMaterialData);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }
    }

    private bool DetectChanges()
    {
        if (customMMDMaterialData != null)
        {
            MMDMaterialInfo existingMaterialInfo = customMMDMaterialData.materialInfoList.Find(info => info.mmdMaterial == currentMaterial);

            if (existingMaterialInfo != null)
            {
                if (existingMaterialInfo.materialNameJP != materialNameJP || existingMaterialInfo.materialNameEN != materialNameEN || existingMaterialInfo.materialMeno != materialMeno)
                {
                    return true;
                }
            }
            else
            {
                return true;
            }

            if (customMMDMaterialData.showSystemsDefault != showSystemsDefault)
            {
                return true;
            }
        }

        return false;
    }

    private void RenderSurfaceOptions()
    {
        GUILayout.Label("Surface Options", EditorStyles.boldLabel);
        RenderSurfaceTypeDropdown();
        CheckBlendingMode();
        if (IsToggleUIPropertyEnabled("_Surface"))
        {
            RenderBlendingModeDropdown();
        }
        RenderDropdownProperty("_Cull", "Render Face", new string[] { "Both", "Back", "Front" }, new float[] { 0, 1, 2 }, EditorGUIUtility.labelWidth, EditorGUIUtility.fieldWidth, true);
        RenderDepthWriteDropdown();
        RenderDropdownProperty("_ZTest", "Depth Test", new string[] { "Never", "Less", "Equal", "LEquaI", "Greater", "NotEqual", "GEqual", "Always" }, new float[] { 1, 2, 3, 4, 5, 6, 7, 8 }, EditorGUIUtility.labelWidth, EditorGUIUtility.fieldWidth, true);
        RenderKeywordToggle("_AlphaClip", "Alpha Clipping", "_ALPHATEST_ON", false, EditorGUIUtility.labelWidth);
        if (IsToggleUIPropertyEnabled("_AlphaClip"))
        {
            EditorGUILayout.BeginHorizontal();
            GUILayout.Space(15f);
            RenderSliderFloatProperty("_Cutoff", "Threshold", 0f, 1f, EditorGUIUtility.labelWidth - 15, EditorGUIUtility.fieldWidth, true);
            EditorGUILayout.EndHorizontal();
        }
        RenderShaderPassToggle("SHADOWCASTER", "Cast Shadows", EditorGUIUtility.labelWidth);
        RenderKeywordToggle("_ReceiveShadows", "Receive Shadows", "_RECEIVE_SHADOWS_OFF", true, EditorGUIUtility.labelWidth);
        GUILayout.Space(10f);
    }

    private void RenderLightmapFlags()
    {
        string[] displayOptions = { "None", "Realtime", "Baked", "Emissive" };
        MaterialGlobalIlluminationFlags[] flagOptions = {
            MaterialGlobalIlluminationFlags.None,
            MaterialGlobalIlluminationFlags.RealtimeEmissive,
            MaterialGlobalIlluminationFlags.BakedEmissive,
            MaterialGlobalIlluminationFlags.EmissiveIsBlack
        };

        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Global Illumination", GUILayout.Width(EditorGUIUtility.labelWidth));

        MaterialGlobalIlluminationFlags currentFlag = currentMaterial.globalIlluminationFlags;
        int selectedIndex = Array.IndexOf(flagOptions, currentFlag);

        EditorGUI.BeginChangeCheck();
        selectedIndex = EditorGUILayout.Popup(selectedIndex, displayOptions);
        if (EditorGUI.EndChangeCheck())
        {
            currentMaterial.globalIlluminationFlags = flagOptions[selectedIndex];
        }

        EditorGUILayout.EndHorizontal();
    }

    private void RenderCustomMaterialInspector()
    {
        GUIStyle redLabelStyle = new(GUI.skin.label);
        redLabelStyle.normal.textColor = Color.red;

        EditorGUILayout.BeginHorizontal();
        GUILayout.BeginHorizontal(GUILayout.Width(400));
        GUILayout.Label("Mat-Name: (JP)", EditorStyles.boldLabel, GUILayout.Width(100f));
        materialNameJP = EditorGUILayout.TextField(materialNameJP);
        GUILayout.Label("(EN)", EditorStyles.boldLabel, GUILayout.Width(30f));
        materialNameEN = EditorGUILayout.TextField(materialNameEN);
        GUILayout.EndHorizontal();
        EditorGUILayout.EndHorizontal();
        GUILayout.Space(10f);

        GUILayout.Label("Material Color", EditorStyles.boldLabel);
        RenderColorProperty("_Color", "Diffuse:");
        RenderColorProperty("_Specular", "Specular:");
        RenderColorProperty("_Ambient", "Ambient:");
        GUILayout.Space(10f);

        RenderSliderFloatProperty("_Opaque", "Opaque:", 0f, 1f, 100f, 290f);
        RenderFloatProperty("_Shininess", "Reflection:", 100f);
        GUILayout.Space(10f);

        GUILayout.Label("Rendering", EditorStyles.boldLabel);
        EditorGUILayout.BeginHorizontal();
        GUILayout.BeginHorizontal(GUILayout.Width(100));
        RenderDoubleSidedToggle();
        GUILayout.Space(30f);
        RenderShaderPassToggle("SHADOWCASTER", "G-SHAD:", 60f);
        GUILayout.EndHorizontal();
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.BeginHorizontal();
        GUILayout.BeginHorizontal(GUILayout.Width(100));
        RenderKeywordToggle("_ReceiveShadows", "S-MAP:", "_RECEIVE_SHADOWS_OFF", true, 60f);
        GUILayout.Space(30f);
        RenderDisabledToggle(redLabelStyle);
        GUILayout.EndHorizontal();
        EditorGUILayout.EndHorizontal();
        GUILayout.Space(10f);

        GUILayout.Label("Edge (Outline)", EditorStyles.boldLabel);
        EditorGUILayout.BeginHorizontal();
        GUILayout.BeginHorizontal(GUILayout.Width(100));
        RenderUIToggle("_On", "On:", 30f);
        GUILayout.Space(30f);
        RenderUIColorProperty("_OutlineColor");
        GUILayout.Space(30f);
        RenderFloatProperty("_EdgeSize", "Size:", 40f);
        GUILayout.EndHorizontal();
        EditorGUILayout.EndHorizontal();
        RenderVector4Property("_OutlineColor");
        GUILayout.Space(10f);

        GUILayout.Label("Texture/Memo", EditorStyles.boldLabel);
        GUI.backgroundColor = HasFloatPropertyValue("_Effects", 3) ? Color.red : Color.white;
        if (HasFloatPropertyValue("_Effects", 3)) GUILayout.Label("We do not have knowledge about this function to replicate", redLabelStyle);
        RenderDropdownProperty("_Effects", "Effects:", new string[] { "- Disabled", "x Multi-Sphere", "+ Add-Sphere", "Sub-Tex" }, new float[] { 0, 2, 1, 3 }, 100, 150);
        GUI.backgroundColor = Color.white;
        GUILayout.Space(5f);
        RenderTextureProperty("_MainTex", "Texture:");
        RenderTextureProperty("_ToonTex", "Toon:");
        RenderCubemapProperty("_SphereCube", "SPH:");
        GUILayout.Space(10f);

        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Memo:", EditorStyles.boldLabel, GUILayout.Width(50f));
        materialMeno = EditorGUILayout.TextArea(materialMeno, GUILayout.Height(80f));
        EditorGUILayout.EndHorizontal();
        GUILayout.Space(10f);

        GUILayout.Label("Custom Effects Settings", EditorStyles.boldLabel);
        RenderSliderFloatProperty("_SpecularIntensity", "Specular Intensity:", 0f, 1f, 145f, 245f);
        RenderSliderFloatProperty("_SPHOpacity", "SPH Opacity:", 0f, 1f, 145f, 245f);
        RenderSliderFloatProperty("_ShadowLum", "Shadow Luminescence:", 0f, 10f, 145f, 245f);
        RenderVector3Property("_ToonTone", "Toon Tone:", 145f);
        RenderUIToggle("_MultipleLights", "Multiple Lights:", 145f);
        GUILayout.Space(10f);

        RenderSurfaceOptions();

        GUILayout.Label("Advanced Options", EditorStyles.boldLabel);
        materialInspector.RenderQueueField();
        materialInspector.EnableInstancingField();
        materialInspector.DoubleSidedGIField();
        RenderLightmapFlags();
    }

    private void RenderColorProperty(string propertyName, string label)
    {
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label(label, GUILayout.Width(100f));
        MaterialProperty colorProperty = FindProperty(propertyName, materialProperties);
        EditorGUI.BeginChangeCheck();
        Color color = EditorGUILayout.ColorField(GUIContent.none, colorProperty.colorValue, false, true, false, GUILayout.Width(50f));
        if (EditorGUI.EndChangeCheck())
        {
            colorProperty.colorValue = color;
        }
        GUILayout.Space(20f);
        GUILayout.Label("R", GUILayout.Width(15f));
        float r = EditorGUILayout.FloatField(color.r, GUILayout.Width(50f));
        GUILayout.Label("G", GUILayout.Width(15f));
        float g = EditorGUILayout.FloatField(color.g, GUILayout.Width(50f));
        GUILayout.Label("B", GUILayout.Width(15f));
        float b = EditorGUILayout.FloatField(color.b, GUILayout.Width(50f));
        colorProperty.colorValue = new Color(r, g, b, 0);
        EditorGUILayout.EndHorizontal();
    }

    private void RenderSliderFloatProperty(string propertyName, string label, float minValue, float maxValue, float space, float sliderSpace, bool expand = false)
    {
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label(label, GUILayout.Width(space));
        MaterialProperty property = FindProperty(propertyName, materialProperties);

        if (!expand)
        {
            property.floatValue = EditorGUILayout.Slider(property.floatValue, minValue, maxValue, GUILayout.Width(sliderSpace));
        }
        else
        {
            property.floatValue = EditorGUILayout.Slider(property.floatValue, minValue, maxValue, GUILayout.Width(sliderSpace), GUILayout.ExpandWidth(true));
        }

        EditorGUILayout.EndHorizontal();
    }

    private void RenderDoubleSidedToggle()
    {
        MaterialProperty cullProperty = FindProperty("_Cull", materialProperties);
        GUIStyle highlightStyle = new(GUI.skin.label);
        Color originalTextColor = highlightStyle.normal.textColor;
        Color highlightColor = Color.yellow;

        if (cullProperty.floatValue == 1)
        {
            highlightStyle.normal.textColor = highlightColor;
            GUI.backgroundColor = highlightColor;
        }
        else
        {
            highlightStyle.normal.textColor = originalTextColor;
            GUI.backgroundColor = Color.white;
        }

        EditorGUILayout.BeginHorizontal();
        EditorGUI.BeginDisabledGroup(cullProperty.floatValue == 1);
        GUIContent labelContent = new("2-SIDE:", "<color=yellow>If necessary, you can use Render Face 'Back' manually</color>");
        GUILayout.Label(labelContent, highlightStyle, GUILayout.Width(60f));
        EditorGUI.showMixedValue = cullProperty.hasMixedValue;
        bool isTwoSided = (cullProperty.floatValue == 0);
        bool toggleValue = EditorGUILayout.Toggle(isTwoSided, GUILayout.Width(10f));
        EditorGUI.showMixedValue = false;
        EditorGUI.EndDisabledGroup();

        if (cullProperty.floatValue != 1)
        {
            cullProperty.floatValue = toggleValue ? 0 : 2;
        }

        EditorGUILayout.EndHorizontal();
        GUI.backgroundColor = Color.white;
    }

    private void RenderShaderPassToggle(string passName, string label, float space)
    {
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label(label, GUILayout.Width(space));
        bool oldValue = currentMaterial.GetShaderPassEnabled(passName);
        bool newValue = EditorGUILayout.Toggle(oldValue, GUILayout.Width(10f));
        EditorGUILayout.EndHorizontal();
        currentMaterial.SetShaderPassEnabled(passName, newValue);
    }

    private void RenderKeywordToggle(string propertyName, string label, string tag, bool invert, float space)
    {
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label(label, GUILayout.Width(space));
        MaterialProperty property = FindProperty(propertyName, materialProperties);
        EditorGUI.showMixedValue = property.hasMixedValue;
        var toggleValue = EditorGUILayout.Toggle(property.floatValue != 0, GUILayout.Width(10f));
        EditorGUI.showMixedValue = false;
        property.floatValue = toggleValue ? 1 : 0;
        EditorGUILayout.EndHorizontal();

        if (invert)
        {
            toggleValue = !toggleValue;
        }

        if (toggleValue)
        {
            currentMaterial.EnableKeyword(tag);
        }
        else
        {
            currentMaterial.DisableKeyword(tag);
        }
    }

    private void RenderDisabledToggle(GUIStyle redLabelStyle)
    {
        EditorGUI.BeginDisabledGroup(true);
        GUI.backgroundColor = Color.red;
        EditorGUILayout.BeginHorizontal();
        GUIContent labelContent = new("S-SHAD:", "<color=red>Apparently the Unity graphics engine does not allow or is not capable of reproducing this</color>");
        GUILayout.Label(labelContent, redLabelStyle, GUILayout.Width(60f));
        bool value = false;
        EditorGUILayout.Toggle(value, GUILayout.Width(10f));
        EditorGUILayout.EndHorizontal();
        GUI.backgroundColor = Color.white;
        EditorGUI.EndDisabledGroup();
    }

    private void RenderUIToggle(string propertyName, string label, float space)
    {
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label(label, GUILayout.Width(space));
        MaterialProperty property = FindProperty(propertyName, materialProperties);
        EditorGUI.showMixedValue = property.hasMixedValue;
        var toggleValue = EditorGUILayout.Toggle(property.floatValue != 0, GUILayout.Width(10f));
        EditorGUI.showMixedValue = false;
        property.floatValue = toggleValue ? 1 : 0;
        EditorGUILayout.EndHorizontal();
    }

    private void RenderUIColorProperty(string propertyName)
    {
        EditorGUILayout.BeginHorizontal();
        MaterialProperty colorProperty = FindProperty(propertyName, materialProperties);
        EditorGUI.BeginChangeCheck();
        Color color = EditorGUILayout.ColorField(GUIContent.none, colorProperty.colorValue, false, true, false, GUILayout.Width(50f));
        if (EditorGUI.EndChangeCheck())
        {
            colorProperty.colorValue = color;
        }
        EditorGUILayout.EndHorizontal();
    }

    private void RenderFloatProperty(string propertyName, string label, float space)
    {
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label(label, GUILayout.Width(space));
        MaterialProperty property = FindProperty(propertyName, materialProperties);
        property.floatValue = EditorGUILayout.FloatField(property.floatValue, GUILayout.Width(50f));
        EditorGUILayout.EndHorizontal();
    }

    private void RenderVector4Property(string propertyName)
    {
        EditorGUILayout.BeginHorizontal();
        MaterialProperty vectorProperty = FindProperty(propertyName, materialProperties);
        Color color = vectorProperty.colorValue;
        EditorGUI.BeginChangeCheck();
        GUILayout.Space(80f);
        float r = EditorGUILayout.FloatField(color.r, GUILayout.Width(50f));
        GUILayout.Space(10f);
        float g = EditorGUILayout.FloatField(color.g, GUILayout.Width(50f));
        GUILayout.Space(10f);
        float b = EditorGUILayout.FloatField(color.b, GUILayout.Width(50f));
        GUILayout.Space(10f);
        float a = EditorGUILayout.FloatField(color.a, GUILayout.Width(50f));
        if (EditorGUI.EndChangeCheck())
        {
            vectorProperty.colorValue = new Color(r, g, b, a);
        }
        EditorGUILayout.EndHorizontal();
    }

    private void RenderDropdownProperty(string propertyName, string label, string[] displayOptions, float[] numberOptions, float space, float dropdownSpace, bool expand = false)
    {
        if (displayOptions.Length != numberOptions.Length)
        {
            throw new ArgumentException("displayOptions and numberOptions must have the same length");
        }

        EditorGUILayout.BeginHorizontal();
        GUILayout.Label(label, GUILayout.Width(space));
        MaterialProperty dropdownProperty = FindProperty(propertyName, materialProperties);
        EditorGUI.BeginChangeCheck();
        int selectedIndex = Array.IndexOf(numberOptions, dropdownProperty.floatValue);

        if (selectedIndex == -1)
        {
            selectedIndex = 0;
        }

        if (!expand)
        {
            selectedIndex = EditorGUILayout.Popup(selectedIndex, displayOptions, GUILayout.Width(dropdownSpace));
        }
        else
        {
            selectedIndex = EditorGUILayout.Popup(selectedIndex, displayOptions, GUILayout.Width(dropdownSpace), GUILayout.ExpandWidth(true));
        }

        if (EditorGUI.EndChangeCheck())
        {
            dropdownProperty.floatValue = numberOptions[selectedIndex];
        }

        EditorGUILayout.EndHorizontal();
    }

    private void RenderTextureProperty(string propertyName, string label)
    {
        EditorGUILayout.BeginHorizontal();
        MaterialProperty textureProperty = FindProperty(propertyName, materialProperties);
        EditorGUI.BeginChangeCheck();
        EditorGUI.showMixedValue = textureProperty.hasMixedValue;
        GUILayout.BeginHorizontal();
        GUILayout.Label(label, GUILayout.Width(100f));
        Texture texture = EditorGUILayout.ObjectField("", textureProperty.textureValue, typeof(Texture), false, GUILayout.Width(60f)) as Texture;
        GUILayout.EndHorizontal();
        if (EditorGUI.EndChangeCheck())
        {
            textureProperty.textureValue = texture;
        }
        EditorGUI.showMixedValue = false;
        EditorGUILayout.EndHorizontal();
    }

    private void RenderCubemapProperty(string propertyName, string label)
    {
        EditorGUILayout.BeginHorizontal();
        MaterialProperty cubemapProperty = FindProperty(propertyName, materialProperties);
        EditorGUI.BeginChangeCheck();
        EditorGUI.showMixedValue = cubemapProperty.hasMixedValue;
        GUILayout.BeginHorizontal();
        GUILayout.Label(label, GUILayout.Width(100f));
        Cubemap cubemap = EditorGUILayout.ObjectField("", cubemapProperty.textureValue, typeof(Cubemap), false, GUILayout.Width(60f)) as Cubemap;
        GUILayout.EndHorizontal();
        if (EditorGUI.EndChangeCheck())
        {
            cubemapProperty.textureValue = cubemap;
        }
        EditorGUI.showMixedValue = false;
        EditorGUILayout.EndHorizontal();
    }

    private void RenderVector3Property(string propertyName, string label, float space)
    {
        EditorGUILayout.BeginHorizontal();
        MaterialProperty vectorProperty = FindProperty(propertyName, materialProperties);
        Vector4 vector3Value = vectorProperty.vectorValue;
        GUILayout.Label(label, GUILayout.Width(space));
        EditorGUI.BeginChangeCheck();
        float x = EditorGUILayout.FloatField(vector3Value.x, GUILayout.Width(50f));
        GUILayout.Space(10f);
        float y = EditorGUILayout.FloatField(vector3Value.y, GUILayout.Width(50f));
        GUILayout.Space(10f);
        float z = EditorGUILayout.FloatField(vector3Value.z, GUILayout.Width(50f));
        if (EditorGUI.EndChangeCheck())
        {
            vectorProperty.vectorValue = new Vector3(x, y, z);
        }
        EditorGUILayout.EndHorizontal();
    }

    private bool IsToggleUIPropertyEnabled(string propertyName)
    {
        MaterialProperty property = FindProperty(propertyName, materialProperties);

        if (property.floatValue == 1f)
        {
            return true;
        }

        return false;
    }

    private bool HasFloatPropertyValue(string propertyName, float value)
    {
        MaterialProperty property = FindProperty(propertyName, materialProperties);

        if (property.floatValue == value)
        {
            return true;
        }

        return false;
    }

    private void RenderDepthWriteDropdown()
    {
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Depth Write", GUILayout.Width(EditorGUIUtility.labelWidth));

        MaterialProperty zWriteControl = FindProperty("_ZWriteControl", materialProperties);
        MaterialProperty zWrite = FindProperty("_ZWrite", materialProperties);

        EditorGUI.BeginChangeCheck();

        int selectedIndex = 0;
        bool newValue = false;
        float newZWriteControl = zWriteControl.floatValue;
        float newZWrite = zWrite.floatValue;

        if (newZWriteControl == 0 && newZWrite == 0) selectedIndex = 0;
        if (newZWriteControl == 1 && newZWrite == 1) selectedIndex = 1;
        if (newZWriteControl == 2 && newZWrite == 0) selectedIndex = 2;

        string[] displayOptions = new string[] { "Auto", "ForceEnabled", "ForceDisabIed" };
        selectedIndex = EditorGUILayout.Popup(selectedIndex, displayOptions, GUILayout.Width(EditorGUIUtility.fieldWidth), GUILayout.ExpandWidth(true));

        if (selectedIndex == 0)
        {
            newZWriteControl = 0;
            newZWrite = 0;
            newValue = false;
        }
        else if (selectedIndex == 1)
        {
            newZWriteControl = 1;
            newZWrite = 1;
            newValue = true;
        }
        else if (selectedIndex == 2)
        {
            newZWriteControl = 2;
            newZWrite = 0;
            newValue = false;
        }

        if (EditorGUI.EndChangeCheck())
        {
            zWrite.floatValue = newZWrite;
            zWriteControl.floatValue = newZWriteControl;
            currentMaterial.SetShaderPassEnabled("DepthOnly", newValue);
        }
        EditorGUILayout.EndHorizontal();
    }

    private void RenderBlendingModeDropdown()
    {
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Blending Mode", GUILayout.Width(EditorGUIUtility.labelWidth));

        MaterialProperty blend = FindProperty("_Blend", materialProperties);
        MaterialProperty srcBlend = FindProperty("_SrcBlend", materialProperties);
        MaterialProperty dstBlend = FindProperty("_DstBlend", materialProperties);

        EditorGUI.BeginChangeCheck();

        int selectedIndex = (int)blend.floatValue;

        string[] displayOptions = new string[] { "Alpha", "Premultiply", "Additive", "Multiply" };
        selectedIndex = EditorGUILayout.Popup(selectedIndex, displayOptions, GUILayout.Width(EditorGUIUtility.fieldWidth), GUILayout.ExpandWidth(true));

        if (EditorGUI.EndChangeCheck())
        {
            switch (selectedIndex)
            {
                case 1: // Premultiply.
                    blend.floatValue = 1;
                    srcBlend.floatValue = 1;
                    dstBlend.floatValue = 10;
                    currentMaterial.DisableKeyword("_ALPHAMODULATE_ON");
                    break;
                case 2: // Additive.
                    blend.floatValue = 2;
                    srcBlend.floatValue = 5;
                    dstBlend.floatValue = 1;
                    currentMaterial.DisableKeyword("_ALPHAMODULATE_ON");
                    break;
                case 3: // Multiply.
                    blend.floatValue = 3;
                    srcBlend.floatValue = 2;
                    dstBlend.floatValue = 0;
                    currentMaterial.EnableKeyword("_ALPHAMODULATE_ON");
                    break;
                default: // Alpha.
                    blend.floatValue = 0;
                    srcBlend.floatValue = 5;
                    dstBlend.floatValue = 10;
                    currentMaterial.DisableKeyword("_ALPHAMODULATE_ON");
                    break;
            }
        }

        EditorGUILayout.EndHorizontal();
    }

    private void CheckBlendingMode()
    {
        MaterialProperty surface = FindProperty("_Surface", materialProperties);
        MaterialProperty blend = FindProperty("_Blend", materialProperties);
        MaterialProperty srcBlend = FindProperty("_SrcBlend", materialProperties);
        MaterialProperty dstBlend = FindProperty("_DstBlend", materialProperties);

        int selectedIndex = (int)blend.floatValue;
        bool surfaceOn = (surface.floatValue == 1);

        switch (selectedIndex)
        {
            case 1: // Premultiply.
                blend.floatValue = 1;
                srcBlend.floatValue = 1;
                dstBlend.floatValue = surfaceOn ? 10 : 0;
                currentMaterial.DisableKeyword("_ALPHAMODULATE_ON");
                break;
            case 2: // Additive.
                blend.floatValue = 2;
                srcBlend.floatValue = surfaceOn ? 5 : 1;
                dstBlend.floatValue = surfaceOn ? 1 : 0;
                currentMaterial.DisableKeyword("_ALPHAMODULATE_ON");
                break;
            case 3: // Multiply.
                blend.floatValue = 3;
                srcBlend.floatValue = surfaceOn ? 2 : 1;
                dstBlend.floatValue = 0;
                if (surfaceOn)
                {
                    currentMaterial.EnableKeyword("_ALPHAMODULATE_ON");
                }
                else
                {
                    currentMaterial.DisableKeyword("_ALPHAMODULATE_ON");
                }
                break;
            default: // Alpha.
                blend.floatValue = 0;
                srcBlend.floatValue = surfaceOn ? 5 : 1;
                dstBlend.floatValue = surfaceOn ? 10 : 0;
                currentMaterial.DisableKeyword("_ALPHAMODULATE_ON");
                break;
        }
    }

    private void RenderSurfaceTypeDropdown()
    {
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Surface Type", GUILayout.Width(EditorGUIUtility.labelWidth));

        MaterialProperty surface = FindProperty("_Surface", materialProperties);

        EditorGUI.BeginChangeCheck();

        int selectedIndex = (int)surface.floatValue;

        string[] displayOptions = new string[] { "Opaque", "Transparent" };
        selectedIndex = EditorGUILayout.Popup(selectedIndex, displayOptions, GUILayout.Width(EditorGUIUtility.fieldWidth), GUILayout.ExpandWidth(true));

        if (EditorGUI.EndChangeCheck())
        {
            switch (selectedIndex)
            {
                case 1: // Transparent.
                    currentMaterial.SetFloat("_Surface", 1);
                    currentMaterial.SetOverrideTag("RenderType", "Transparent");
                    currentMaterial.EnableKeyword("_SURFACE_TYPE_TRANSPARENT");
                    break;
                default: // Opaque.
                    currentMaterial.SetFloat("_Surface", 0);
                    currentMaterial.SetOverrideTag("RenderType", "Opaque");
                    currentMaterial.DisableKeyword("_SURFACE_TYPE_TRANSPARENT");
                    break;
            }
        }

        EditorGUILayout.EndHorizontal();
    }
}