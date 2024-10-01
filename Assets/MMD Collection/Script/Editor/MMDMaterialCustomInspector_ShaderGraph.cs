/*
 * ---------------------------------------------------------------------------
 * Description: Custom inspector script for managing MMD (MikuMikuDance) materials within Unity using Shader Graph. 
 *              This script allows for detailed customization of material properties, including colors, rendering options, 
 *              and special effects, through a user-friendly interface in the Unity Editor.
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/
using MMDCollectionEditor;
using UnityEngine;
using UnityEditor;

// Custom inspector for MMD (MikuMikuDance) materials using Shader Graph.
public class MMDMaterialCustomInspector_ShaderGraph : ShaderGUI
{
    // Fields for storing material names (Japanese and English) and memo.
    private string materialNameJP;
    private string materialNameEN;
    private string materialMeno; // Field for storing material memo.
    private bool showSystemsDefault; // Toggle for showing system's default inspector.

    private CustomMMDData customMMDMaterialData; // Custom data structure for MMD materials.

    // References to the material editor, properties, and current material being edited.
    private MaterialEditor materialInspector;
    private MaterialProperty[] materialProperties;
    private Material currentMaterial;

    // Main GUI function for rendering the custom inspector.
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        // Initialize material inspector and material properties.
        materialInspector = materialEditor;
        materialProperties = properties;
        currentMaterial = materialEditor.target as Material;

        // Toggle for showing default system inspector or custom inspector.
        GUILayout.BeginHorizontal();
        GUILayout.Label("Show Default Systems:", EditorStyles.boldLabel, GUILayout.Width(145f));
        showSystemsDefault = EditorGUILayout.Toggle(showSystemsDefault);
        GUILayout.EndHorizontal();
        GUILayout.Space(5f);

        // Load custom MMD material data if not already loaded.
        if (customMMDMaterialData == null)
        {
            // Load or create the MMD material data.
            customMMDMaterialData = CustomMMDDataUtilityEditor.GetOrCreateCustomMMDData();
            CustomMMDDataUtilityEditor.RemoveInvalidMaterials(customMMDMaterialData);
            CustomInspectorUtilityEditor.LoadData(customMMDMaterialData, currentMaterial, out materialNameJP, out materialNameEN, out materialMeno, out showSystemsDefault);
        }

        // Render custom inspector if the toggle is off, otherwise render the default inspector.
        if (!showSystemsDefault)
        {
            RenderCustomMaterialInspector(); // Render custom inspector UI for MMD materials.
        }
        else
        {
            // Render the default inspector when the toggle is on.
            GUILayout.Space(20f);
            CustomInspectorUtilityEditor.RenderSurfaceOptions(materialProperties, currentMaterial);
            base.OnGUI(materialInspector, materialProperties);
            CustomInspectorUtilityEditor.RenderLightmapFlags(currentMaterial);
        }

        // Save any changes made to the material data.
        CustomInspectorUtilityEditor.SaveData(customMMDMaterialData, currentMaterial, materialNameJP, materialNameEN, materialMeno, showSystemsDefault);
        CheckMaterialProperties(); // Ensure proper settings and keywords are applied.
    }

    // Render the custom material inspector UI.
    private void RenderCustomMaterialInspector()
    {
        // Render fields for material names (Japanese and English).
        EditorGUILayout.BeginHorizontal();
        GUILayout.BeginHorizontal(GUILayout.Width(400));
        GUILayout.Label("Mat-Name: (JP)", EditorStyles.boldLabel, GUILayout.Width(100f));
        materialNameJP = EditorGUILayout.TextField(materialNameJP);
        GUILayout.Label("(EN)", EditorStyles.boldLabel, GUILayout.Width(30f));
        materialNameEN = EditorGUILayout.TextField(materialNameEN);
        GUILayout.EndHorizontal();
        EditorGUILayout.EndHorizontal();
        GUILayout.Space(10f);

        // Render color properties for the material.
        GUILayout.Label("Material Color", EditorStyles.boldLabel);
        CustomInspectorUtilityEditor.RenderColorProperty(materialProperties, "_Color", "Diffuse:");
        CustomInspectorUtilityEditor.RenderColorProperty(materialProperties, "_Specular", "Specular:");
        CustomInspectorUtilityEditor.RenderColorProperty(materialProperties, "_Ambient", "Ambient:");
        GUILayout.Space(10f);

        // Render opacity and reflection sliders.
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
        CustomInspectorUtilityEditor.RenderUIToggle(materialProperties, "_SShad", "S-SHAD:", 60f);
        GUILayout.EndHorizontal();
        EditorGUILayout.EndHorizontal();
        GUILayout.Space(10f);

        // Render edge (outline) settings.
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
        CustomInspectorUtilityEditor.RenderDropdownProperty(materialProperties, currentMaterial,"_EFFECTS", "Effects:", new string[] { "- Disabled", "x Multi-Sphere", "+ Add-Sphere", "Sub-Tex" }, new float[] { 0, 2, 1, 3 }, 100, 150);
        GUILayout.Space(5f);
        CustomInspectorUtilityEditor.RenderTextureProperty(materialProperties, "_MainTex", "Texture:");
        CustomInspectorUtilityEditor.RenderTextureProperty(materialProperties, "_ToonTex", "Toon:");
        if (CustomInspectorUtilityEditor.HasFloatPropertyValue(materialProperties, "_EFFECTS", 3))
        {
            CustomInspectorUtilityEditor.RenderDropdownProperty(materialProperties, currentMaterial, "_UVLayer", "UV Layer:", new string[] { "Layer 1", "Layer 2", "Layer 3", "Layer 4" }, new float[] { 0, 1, 2, 3 }, 100, 150);
            CustomInspectorUtilityEditor.RenderTextureProperty(materialProperties, "_SubTex", "SPH:");
        }
        else
        {
            CustomInspectorUtilityEditor.RenderCubemapProperty(materialProperties, "_SphereCube", "SPH:");
        }
        GUILayout.Space(10f);

        // Render memo field for additional notes or information about the material.
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Memo:", EditorStyles.boldLabel, GUILayout.Width(50f));
        materialMeno = EditorGUILayout.TextArea(materialMeno, GUILayout.Height(80f));
        EditorGUILayout.EndHorizontal();
        GUILayout.Space(10f);

        // Render additional custom effects settings.
        GUILayout.Label("Custom Effects Settings", EditorStyles.boldLabel);
        CustomInspectorUtilityEditor.RenderSliderFloatProperty(materialProperties, "_SpecularIntensity", "Specular Intensity:", 0f, 1f, 145f, 245f);
        CustomInspectorUtilityEditor.RenderSliderFloatProperty(materialProperties, "_SPHOpacity", "SPH Opacity:", 0f, 1f, 145f, 245f);
        CustomInspectorUtilityEditor.RenderSliderFloatProperty(materialProperties, "_ShadowLum", "Shadow Luminescence:", 0f, 10f, 145f, 245f);
        CustomInspectorUtilityEditor.RenderSliderFloatProperty(materialProperties, "_HDR", "HDR:", 1f, 1000f, 145f, 245f);
        CustomInspectorUtilityEditor.RenderVector3Property(materialProperties, "_ToonTone", "Toon Tone:", 145f);
        CustomInspectorUtilityEditor.RenderUIToggle(materialProperties, "_MultipleLights", "Multiple Lights:", 145f);
        CustomInspectorUtilityEditor.RenderUIToggle(materialProperties, "_Fog", "Fog:", 145f);
        GUILayout.Space(10f);

        // Render surface options from the custom inspector utility.
        CustomInspectorUtilityEditor.RenderSurfaceOptions(materialProperties, currentMaterial);

        // Render advanced options.
        GUILayout.Label("Advanced Options", EditorStyles.boldLabel);
        materialInspector.RenderQueueField(); // Render the queue field.
        materialInspector.EnableInstancingField(); // Enable GPU instancing.
        materialInspector.DoubleSidedGIField(); // Enable double-sided global illumination.
        CustomInspectorUtilityEditor.RenderLightmapFlags(currentMaterial);
    }

    // Check and manage material properties, ensuring appropriate shader keywords are toggled.
    private void CheckMaterialProperties()
    {
        // Check if AlphaClip is enabled and toggle the corresponding keyword.
        MaterialProperty alphaClip = FindProperty("_AlphaClip", materialProperties);
        ToggleKeyword("_ALPHATEST_ON", alphaClip.floatValue == 1);

        // Check surface type and toggle keywords for transparency.
        MaterialProperty surface = FindProperty("_Surface", materialProperties);
        bool surfaceOn = (surface.floatValue == 1);
        ToggleKeyword("_SURFACE_TYPE_TRANSPARENT", surfaceOn);

        // Manage blend modes and corresponding keywords.
        MaterialProperty blend = FindProperty("_Blend", materialProperties);
        int selectedBlendIndex = (int)blend.floatValue;

        if (selectedBlendIndex == 1 || selectedBlendIndex == 2) // Premultiply or Additive blending.
        {
            currentMaterial.DisableKeyword("_ALPHAMODULATE_ON");
        }
        else if (selectedBlendIndex == 3) // Multiply blending.
        {
            ToggleKeyword("_ALPHAMODULATE_ON", surfaceOn);
        }
        else // Default (Alpha blending).
        {
            currentMaterial.DisableKeyword("_ALPHAMODULATE_ON");
        }

        // Handle shadow-related properties and keywords.
        MaterialProperty receiveShadows = FindProperty("_ReceiveShadows", materialProperties);
        MaterialProperty receiveShadowsOff = FindProperty("_RECEIVE_SHADOWS_OFF", materialProperties);
        MaterialProperty mainLightShadowsCascade = FindProperty("_MAIN_LIGHT_SHADOWS_CASCADE", materialProperties);
        MaterialProperty additionalLightShadows = FindProperty("_ADDITIONAL_LIGHT_SHADOWS", materialProperties);
        bool toggleValue = (receiveShadows.floatValue == 1);

        if (toggleValue)
        {
            // Enable shadows and their related properties and keywords.
            receiveShadowsOff.floatValue = 0;
            mainLightShadowsCascade.floatValue = 1;
            additionalLightShadows.floatValue = 1;
            ToggleKeyword("_RECEIVE_SHADOWS_OFF", false);
            ToggleKeyword("_MAIN_LIGHT_SHADOWS_CASCADE", true);
            ToggleKeyword("_ADDITIONAL_LIGHT_SHADOWS", true);
        }
        else
        {
            // Disable shadows and their related properties and keywords.
            receiveShadowsOff.floatValue = 1;
            mainLightShadowsCascade.floatValue = 0;
            additionalLightShadows.floatValue = 0;
            ToggleKeyword("_RECEIVE_SHADOWS_OFF", true);
            ToggleKeyword("_MAIN_LIGHT_SHADOWS_CASCADE", false);
            ToggleKeyword("_ADDITIONAL_LIGHT_SHADOWS", false);
        }
    }

    // Helper method to toggle shader keywords.
    private void ToggleKeyword(string keyword, bool state)
    {
        if (state)
        {
            currentMaterial.EnableKeyword(keyword);
        }
        else
        {
            currentMaterial.DisableKeyword(keyword);
        }
    }
}