using UnityEngine;
using UnityEditor;

// Custom inspector for MMD (MikuMikuDance) materials using Amplify Shader Editor.
public class MMDMaterialCustomInspector_AmplifyShaderEditor : ShaderGUI
{
    // Fields for storing material names and memo.
    private string materialNameJP;
    private string materialNameEN;
    private string materialMeno;
    private bool showSystemsDefault;

    private CustomMMDData customMMDMaterialData; // Custom data structure for MMD materials.

    // References to material editor, properties, and current material.
    private MaterialEditor materialInspector;
    private MaterialProperty[] materialProperties;
    private Material currentMaterial;

    // Main GUI function for rendering the custom inspector.
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        // Initialize material inspector and properties.
        materialInspector = materialEditor;
        materialProperties = properties;
        currentMaterial = materialEditor.target as Material;

        // Toggle for showing default systems.
        GUILayout.BeginHorizontal();
        GUILayout.Label("Show Default Systems:", EditorStyles.boldLabel, GUILayout.Width(145f));
        showSystemsDefault = EditorGUILayout.Toggle(showSystemsDefault);
        GUILayout.EndHorizontal();
        GUILayout.Space(5f);

        // Load custom MMD material data if not already loaded.
        if (customMMDMaterialData == null)
        {
            customMMDMaterialData = CustomMMDDataUtilityEditor.GetOrCreateCustomMMDData();
            CustomMMDDataUtilityEditor.RemoveInvalidMaterials(customMMDMaterialData);
            CustomInspectorUtilityEditor.LoadData(customMMDMaterialData, currentMaterial, out materialNameJP, out materialNameEN, out materialMeno, out showSystemsDefault);
        }

        // Render either the custom inspector or the default inspector based on the toggle.
        if (!showSystemsDefault)
        {
            RenderCustomMaterialInspector();
        }
        else
        {
            GUILayout.Space(20f);
            CustomInspectorUtilityEditor.RenderSurfaceOptions(materialProperties, currentMaterial);
            base.OnGUI(materialInspector, materialProperties);
            CustomInspectorUtilityEditor.RenderLightmapFlags(currentMaterial);
        }

        // Save any changes made to the material data.
        CustomInspectorUtilityEditor.SaveData(customMMDMaterialData, currentMaterial, materialNameJP, materialNameEN, materialMeno, showSystemsDefault);
    }

    // Render the custom material inspector UI.
    private void RenderCustomMaterialInspector()
    {
        GUIStyle redLabelStyle = new(GUI.skin.label);
        redLabelStyle.normal.textColor = Color.red;

        // Render fields for material names.
        EditorGUILayout.BeginHorizontal();
        GUILayout.BeginHorizontal(GUILayout.Width(400));
        GUILayout.Label("Mat-Name: (JP)", EditorStyles.boldLabel, GUILayout.Width(100f));
        materialNameJP = EditorGUILayout.TextField(materialNameJP);
        GUILayout.Label("(EN)", EditorStyles.boldLabel, GUILayout.Width(30f));
        materialNameEN = EditorGUILayout.TextField(materialNameEN);
        GUILayout.EndHorizontal();
        EditorGUILayout.EndHorizontal();
        GUILayout.Space(10f);

        // Render color properties.
        GUILayout.Label("Material Color", EditorStyles.boldLabel);
        CustomInspectorUtilityEditor.RenderColorProperty(materialProperties, "_Color", "Diffuse:");
        CustomInspectorUtilityEditor.RenderColorProperty(materialProperties, "_Specular", "Specular:");
        CustomInspectorUtilityEditor.RenderColorProperty(materialProperties, "_Ambient", "Ambient:");
        GUILayout.Space(10f);

        // Render slider and float properties.
        CustomInspectorUtilityEditor.RenderSliderFloatProperty(materialProperties, "_Opaque", "Opaque:", 0f, 1f, 100f, 290f);
        CustomInspectorUtilityEditor.RenderFloatProperty(materialProperties, "_Shininess", "Reflection:", 100f);
        GUILayout.Space(10f);

        // Render rendering options.
        GUILayout.Label("Rendering", EditorStyles.boldLabel);
        EditorGUILayout.BeginHorizontal();
        GUILayout.BeginHorizontal(GUILayout.Width(100));
        CustomInspectorUtilityEditor.RenderDoubleSidedToggle(materialProperties);
        GUILayout.Space(30f);
        CustomInspectorUtilityEditor.RenderShaderPassToggle(currentMaterial, "SHADOWCASTER", "G-SHAD:", 60f);
        GUILayout.EndHorizontal();
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.BeginHorizontal();
        GUILayout.BeginHorizontal(GUILayout.Width(100));
        CustomInspectorUtilityEditor.RenderKeywordToggle(materialProperties, currentMaterial, "_ReceiveShadows", "S-MAP:", "_RECEIVE_SHADOWS_OFF", true, 60f);
        GUILayout.Space(30f);
        CustomInspectorUtilityEditor.RenderDisabledToggle(redLabelStyle);
        GUILayout.EndHorizontal();
        EditorGUILayout.EndHorizontal();
        GUILayout.Space(10f);

        // Render edge (outline) options.
        GUILayout.Label("Edge (Outline)", EditorStyles.boldLabel);
        EditorGUILayout.BeginHorizontal();
        GUILayout.BeginHorizontal(GUILayout.Width(100));
        CustomInspectorUtilityEditor.RenderUIToggle(materialProperties, "_On", "On:", 30f);
        GUILayout.Space(30f);
        CustomInspectorUtilityEditor.RenderUIColorProperty(materialProperties, "_OutlineColor");
        GUILayout.Space(30f);
        CustomInspectorUtilityEditor.RenderFloatProperty(materialProperties, "_EdgeSize", "Size:", 40f);
        GUILayout.EndHorizontal();
        EditorGUILayout.EndHorizontal();
        CustomInspectorUtilityEditor.RenderVector4Property(materialProperties, "_OutlineColor");
        GUILayout.Space(10f);

        // Render texture and memo fields.
        GUILayout.Label("Texture/Memo", EditorStyles.boldLabel);
        GUI.backgroundColor = CustomInspectorUtilityEditor.HasFloatPropertyValue(materialProperties, "_EFFECTS", 3) ? Color.red : Color.white;
        if (CustomInspectorUtilityEditor.HasFloatPropertyValue(materialProperties, "_EFFECTS", 3)) GUILayout.Label("We do not have knowledge about this function to replicate", redLabelStyle);
        CustomInspectorUtilityEditor.RenderDropdownProperty(materialProperties, currentMaterial, "_EFFECTS", "Effects:", new string[] { "- Disabled", "x Multi-Sphere", "+ Add-Sphere", "Sub-Tex" }, new float[] { 0, 2, 1, 3 }, 100, 150);
        GUI.backgroundColor = Color.white;
        GUILayout.Space(5f);
        CustomInspectorUtilityEditor.RenderTextureProperty(materialProperties, "_MainTex", "Texture:");
        CustomInspectorUtilityEditor.RenderTextureProperty(materialProperties, "_ToonTex", "Toon:");
        CustomInspectorUtilityEditor.RenderCubemapProperty(materialProperties, "_SphereCube", "SPH:");
        GUILayout.Space(10f);

        // Render material memo field.
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Memo:", EditorStyles.boldLabel, GUILayout.Width(50f));
        materialMeno = EditorGUILayout.TextArea(materialMeno, GUILayout.Height(80f));
        EditorGUILayout.EndHorizontal();
        GUILayout.Space(10f);

        // Render custom effects settings section.
        GUILayout.Label("Custom Effects Settings", EditorStyles.boldLabel);
        CustomInspectorUtilityEditor.RenderSliderFloatProperty(materialProperties, "_SpecularIntensity", "Specular Intensity:", 0f, 1f, 145f, 245f);
        CustomInspectorUtilityEditor.RenderSliderFloatProperty(materialProperties, "_SPHOpacity", "SPH Opacity:", 0f, 1f, 145f, 245f);
        CustomInspectorUtilityEditor.RenderSliderFloatProperty(materialProperties, "_ShadowLum", "Shadow Luminescence:", 0f, 10f, 145f, 245f);
        CustomInspectorUtilityEditor.RenderVector3Property(materialProperties, "_ToonTone", "Toon Tone:", 145f);
        CustomInspectorUtilityEditor.RenderUIToggle(materialProperties, "_MultipleLights", "Multiple Lights:", 145f);
        GUILayout.Space(10f);

        // Render surface options provided by the custom inspector utility.
        CustomInspectorUtilityEditor.RenderSurfaceOptions(materialProperties, currentMaterial);

        // Render advanced options section.
        GUILayout.Label("Advanced Options", EditorStyles.boldLabel);
        materialInspector.RenderQueueField();
        materialInspector.EnableInstancingField();
        materialInspector.DoubleSidedGIField();
        CustomInspectorUtilityEditor.RenderLightmapFlags(currentMaterial);
    }
}