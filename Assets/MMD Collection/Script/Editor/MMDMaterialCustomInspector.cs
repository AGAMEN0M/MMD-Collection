using UnityEngine;
using UnityEditor;
using System;

// Custom inspector for MMD (MikuMikuDance) materials.
public class MMDMaterialCustomInspector : ShaderGUI
{
    // Fields for storing material information.
    private string materialNameJP; // Material name in Japanese.
    private string materialNameEN; // Material name in English.
    private string materialMeno;   // Memo for the material.
    private bool showMoreSystems;  // Toggle to show more systems in the inspector.

    private CustomMMDData customMMDData; // Reference to CustomMMDData asset.

    // Override method for rendering the material inspector GUI.
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        // Show toggle for showing more systems.
        GUILayout.BeginHorizontal();
        GUILayout.Label("Show More Systems:", EditorStyles.boldLabel, GUILayout.Width(130f));
        showMoreSystems = EditorGUILayout.Toggle(showMoreSystems);
        GUILayout.EndHorizontal();
        GUILayout.Space(5f);

        // Load CustomMMDData asset if not loaded.
        if (customMMDData == null)
        {
            customMMDData = CustomMMDDataUtilityEditor.GetOrCreateCustomMMDData();
            CustomMMDDataUtilityEditor.RemoveInvalidMaterials(customMMDData);
            LoadData(materialEditor);
        }

        // Render custom or default material inspector based on showMoreSystems toggle.
        if (!showMoreSystems)
        {
            DrawCustomMaterialInspector(materialEditor, properties);
        }
        else
        {
            GUILayout.Space(30f);
            DrawSurfaceOptions(materialEditor, properties);
            base.OnGUI(materialEditor, properties); // Render default material inspector.
            DrawLightmapFlagsProperty(materialEditor);
        }

        // Apply surface type keywords and save any changes made.
        SaveData(materialEditor);
    }

    // Load material data from CustomMMDData asset.
    private void LoadData(MaterialEditor materialEditor)
    {
        Material material = materialEditor.target as Material; // Get the material being edited.

        // Check if the CustomMMDData asset and its material info list are valid.
        if (customMMDData != null && customMMDData.materialInfoList != null)
        {
            showMoreSystems = customMMDData.showMoreSystems; // Load the showMoreSystems toggle state from the CustomMMDData.
            MMDMaterialInfo existingMaterialInfo = customMMDData.materialInfoList.Find(info => info.mmdMaterial == material); // Find the material info corresponding to the current material being edited.

            // If an existing material info is found, load its data into the inspector fields.
            if (existingMaterialInfo != null)
            {
                materialNameJP = existingMaterialInfo.materialNameJP; // Load Japanese material name.
                materialNameEN = existingMaterialInfo.materialNameEN; // Load English material name.
                materialMeno = existingMaterialInfo.materialMeno;     // Load memo.
            }
            else
            {
                // If no existing material info is found, initialize fields to default values.
                materialNameJP = ""; // Japanese material name is empty.
                materialNameEN = ""; // English material name is empty.
                materialMeno = "";   // Memo is empty.
            }
        }
    }

    // Save material data to CustomMMDData asset.
    private void SaveData(MaterialEditor materialEditor)
    {
        // Check if there are any changes that need to be saved.
        if (CheckForChanges(materialEditor))
        {
            customMMDData.showMoreSystems = showMoreSystems; // Update the showMoreSystems toggle state in CustomMMDData.
            Material material = materialEditor.target as Material; // Get the material being edited.
            MMDMaterialInfo existingMaterialInfo = customMMDData.materialInfoList.Find(info => info.mmdMaterial == material); // Find the material info corresponding to the current material being edited.

            // If an existing material info is found, update its data.
            if (existingMaterialInfo != null)
            {
                // Update material info with current values from the inspector fields.
                existingMaterialInfo.materialNameJP = materialNameJP; // Update Japanese material name.
                existingMaterialInfo.materialNameEN = materialNameEN; // Update English material name.
                existingMaterialInfo.materialMeno = materialMeno;     // Update memo.
            }
            else
            {
                // If no existing material info is found, create a new material info and add it to the list.
                MMDMaterialInfo newMaterialInfo = new()
                {
                    mmdMaterial = material,          // Set the material reference.
                    materialNameJP = materialNameJP, // Set Japanese material name.
                    materialNameEN = materialNameEN, // Set English material name.
                    materialMeno = materialMeno     // Set memo.
                };

                customMMDData.materialInfoList.Add(newMaterialInfo); // Add new material info to the list.
            }

            EditorUtility.SetDirty(customMMDData); // Mark the CustomMMDData asset as dirty to trigger serialization.
            AssetDatabase.SaveAssets(); // Save changes to assets.
            AssetDatabase.Refresh(); // Refresh asset database to reflect changes.
        }
    }

    // Check for changes in material data.
    private bool CheckForChanges(MaterialEditor materialEditor)
    {
        // Check if the CustomMMDData asset is valid.
        if (customMMDData != null)
        {
            Material material = materialEditor.target as Material; // Get the material being edited.

            // Find the material info corresponding to the current material being edited.
            MMDMaterialInfo existingMaterialInfo = customMMDData.materialInfoList.Find(info => info.mmdMaterial == material);

            // If an existing material info is found, compare its data with the current inspector fields.
            if (existingMaterialInfo != null)
            {
                // Check if any of the material properties have changed.
                if (existingMaterialInfo.materialNameJP != materialNameJP
                    || existingMaterialInfo.materialNameEN != materialNameEN
                    || existingMaterialInfo.materialMeno != materialMeno)
                {
                    return true; // Changes detected.
                }
            }
            else
            {
                return true; // New material.
            }

            // Check if the showMoreSystems toggle state has changed.
            if (customMMDData.showMoreSystems != showMoreSystems)
            {
                return true; // Toggle state changed.
            }
        }

        return false; // No changes detected.
    }

    // Render the custom material inspector UI.
    private void DrawCustomMaterialInspector(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        // Render fields for material names and memo.
        EditorGUILayout.BeginHorizontal();
        GUILayout.BeginHorizontal(GUILayout.Width(400));
        GUILayout.Label("Mat-Name: (JP)", EditorStyles.boldLabel, GUILayout.Width(100f));
        materialNameJP = EditorGUILayout.TextField(materialNameJP);
        GUILayout.Label("(EN)", EditorStyles.boldLabel, GUILayout.Width(30f));
        materialNameEN = EditorGUILayout.TextField(materialNameEN);
        GUILayout.EndHorizontal();
        EditorGUILayout.EndHorizontal();

        GUILayout.Space(10f);

        // Render properties for material color, opacity, reflection, and rendering.
        GUILayout.Label("Material Color", EditorStyles.boldLabel);
        DrawColorProperty(properties, "_Color", "Diffuse:");
        DrawColorProperty(properties, "_Specular", "Specular:");
        DrawColorProperty(properties, "_Ambient", "Ambient:");
        GUILayout.Space(10f);

        DrawSliderFloatProperty(properties, "_Opaque", "Opaque:", 0f, 1f, 100f, 290f);
        DrawFloatProperty(properties, "_Shininess", "Reflection:", 100f);
        GUILayout.Space(10f);

        GUILayout.Label("Rendering", EditorStyles.boldLabel);
        /*
        EditorGUILayout.BeginHorizontal();
        GUILayout.BeginHorizontal(GUILayout.Width(100));
        DrawToggleUIProperty(properties, "_2_SIDE", "2-SIDE:", 60f);
        GUILayout.Space(30f);
        DrawToggleUIProperty(properties, "_G_SHAD", "G-SHAD:", 60f);
        GUILayout.EndHorizontal();
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.BeginHorizontal();
        GUILayout.BeginHorizontal(GUILayout.Width(100));
        DrawToggleUIProperty(properties, "_S_MAP", "S-MAP:", 60f);
        GUILayout.Space(30f);
        DrawToggleUIProperty(properties, "_S_SHAD", "S-SHAD:", 60f);
        GUILayout.EndHorizontal();
        EditorGUILayout.EndHorizontal();
        */
        GUILayout.Space(10f);

        // Render properties for edge (outline).
        GUILayout.Label("Edge (Outline)", EditorStyles.boldLabel);
        EditorGUILayout.BeginHorizontal();
        GUILayout.BeginHorizontal(GUILayout.Width(100));
        DrawToggleUIProperty(properties, "_On", "On:", 30f);
        GUILayout.Space(30f);
        DrawColorUIProperty(properties, "_OutlineColor");
        GUILayout.Space(30f);
        DrawFloatProperty(properties, "_EdgeSize", "Size:", 40f);
        GUILayout.EndHorizontal();
        EditorGUILayout.EndHorizontal();
        DrawVector4Property(properties, "_OutlineColor");
        GUILayout.Space(10f);

        // Render properties for texture and memo.
        GUILayout.Label("Texture/Memo", EditorStyles.boldLabel);
        GUI.backgroundColor = GetFloatProperty(properties, "_Effects", 3) ? Color.red : Color.white;
        DrawDropdownProperty(properties, "_Effects", "Effects:", new string[] { "- Disabled", "x Multi-Sphere", "+ Add-Sphere", "Sub-Tex" }, new float[] { 0, 2, 1, 3 }, 100, 150);
        GUI.backgroundColor = Color.white;
        GUILayout.Space(5f);
        DrawTextureProperty(properties, "_MainTex", "Texture:");
        DrawTextureProperty(properties, "_ToonTex", "Toon:");
        DrawCubemapProperty(properties, "_SphereCube", "SPH:");
        GUILayout.Space(10f);

        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Memo:", EditorStyles.boldLabel, GUILayout.Width(50f));
        materialMeno = EditorGUILayout.TextArea(materialMeno, GUILayout.Height(80f));
        EditorGUILayout.EndHorizontal();
        GUILayout.Space(10f);

        // Renders Fog, Lighting, SurfaceType, and Unity default properties.
        GUILayout.Label("Custom Effects Settings", EditorStyles.boldLabel);
        DrawSliderFloatProperty(properties, "_SpecularIntensity", "Specular Intensity:", 0f, 1f, 145f, 245f);
        DrawSliderFloatProperty(properties, "_SPHOpacity", "SPH Opacity:", 0f, 1f, 145f, 245f);
        DrawSliderFloatProperty(properties, "_ShadowLum", "Shadow Luminescence:", 0f, 10f, 145f, 245f);
        DrawVector3Property(properties, "_ToonTone", "Toon Tone:", 145f);
        DrawToggleUIProperty(properties, "_MultipleLights", "Multiple Lights:", 145f);
        GUILayout.Space(10f);

        DrawSurfaceOptions(materialEditor, properties);

        GUILayout.Label("Advanced Options", EditorStyles.boldLabel);
        materialEditor.RenderQueueField();
        materialEditor.EnableInstancingField();
        materialEditor.DoubleSidedGIField();
        DrawLightmapFlagsProperty(materialEditor);
    }

    private void DrawSurfaceOptions(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        GUILayout.Label("Surface Options", EditorStyles.boldLabel);
        DrawDropdownProperty(properties, "_Surface", "Surface Type", new string[] { "Opaque", "Transparent" }, new float[] { 0, 1 }, EditorGUIUtility.labelWidth, EditorGUIUtility.fieldWidth, true); // manuteção
        if (GetToggleUIProperty(properties, "_Surface"))
        {
            DrawDropdownProperty(properties, "_Blend", "Blending Mode", new string[] { "Alpha", "Premultiply", "Additive", "Multiply" }, new float[] { 0, 1, 2, 3 }, EditorGUIUtility.labelWidth, EditorGUIUtility.fieldWidth, true); // manuteção _SrcBlend _DstBlend "_ALPHAMODULATE_ON"
        }
        DrawDropdownProperty(properties, "_Cull", "Render Face", new string[] { "Both", "Back", "Front" }, new float[] { 0, 1, 2 }, EditorGUIUtility.labelWidth, EditorGUIUtility.fieldWidth, true);
        DrawDropdownProperty(properties, "_ZWriteControl", "Depth Write", new string[] { "Auto", "ForceEnabled", "ForceDisabIed" }, new float[] { 0, 1, 2 }, EditorGUIUtility.labelWidth, EditorGUIUtility.fieldWidth, true); // manuteção _ZWrite (DepthOnly)
        DrawDropdownProperty(properties, "_ZTest", "Depth Test", new string[] { "Never", "Less", "Equal", "LEquaI", "Greater", "NotEqual", "GEqual", "Always" }, new float[] { 1, 2, 3, 4, 5, 6, 7, 8 }, EditorGUIUtility.labelWidth, EditorGUIUtility.fieldWidth, true);
        DrawToggleUIKeyword(materialEditor, properties, "_AlphaClip", "Alpha Clipping", "_ALPHATEST_ON", false, EditorGUIUtility.labelWidth);
        if (GetToggleUIProperty(properties, "_AlphaClip"))
        {
            EditorGUILayout.BeginHorizontal();
            GUILayout.Space(15f);
            DrawSliderFloatProperty(properties, "_Cutoff", "Threshold", 0f, 1f, EditorGUIUtility.labelWidth - 15, EditorGUIUtility.fieldWidth, true);
            EditorGUILayout.EndHorizontal();
        }
        DrawToggleUIShaderPass(materialEditor, "SHADOWCASTER", "Cast Shadows", EditorGUIUtility.labelWidth);
        DrawToggleUIKeyword(materialEditor, properties, "_ReceiveShadows", "Receive Shadows", "_RECEIVE_SHADOWS_OFF", true, EditorGUIUtility.labelWidth);
        GUILayout.Space(10f);
    }

    // Helper method to draw color property.
    private void DrawColorProperty(MaterialProperty[] properties, string propertyName, string label)
    {
        // Render color field and text fields for RGB values.
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label(label, GUILayout.Width(100f));
        MaterialProperty colorProperty = FindProperty(propertyName, properties);
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

    // Helper method to draw float property.
    private void DrawFloatProperty(MaterialProperty[] properties, string propertyName, string label, float space)
    {
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label(label, GUILayout.Width(space));
        MaterialProperty property = FindProperty(propertyName, properties);
        property.floatValue = EditorGUILayout.FloatField(property.floatValue, GUILayout.Width(50f));
        EditorGUILayout.EndHorizontal();
    }

    // Helper method to draw toggle UI property.
    private void DrawToggleUIProperty(MaterialProperty[] properties, string propertyName, string label, float space)
    {
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label(label, GUILayout.Width(space));

        MaterialProperty property = FindProperty(propertyName, properties);
        EditorGUI.showMixedValue = property.hasMixedValue;
        var toggleValue = EditorGUILayout.Toggle(property.floatValue != 0, GUILayout.Width(10f));
        EditorGUI.showMixedValue = false;
        property.floatValue = toggleValue ? 1 : 0;
        EditorGUILayout.EndHorizontal();
    }
    
    private bool GetFloatProperty(MaterialProperty[] properties, string propertyName, float value)
    {
        MaterialProperty property = FindProperty(propertyName, properties);

        if (property.floatValue == value)
        {
            return true;
        }

        return false;
    }

    private bool GetToggleUIProperty(MaterialProperty[] properties, string propertyName)
    {
        MaterialProperty property = FindProperty(propertyName, properties);

        if (property.floatValue == 1f)
        {
            return true;
        }

        return false;
    }

    private void DrawToggleUIShaderPass(MaterialEditor materialEditor, string passName, string label, float space)
    {
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label(label, GUILayout.Width(space));
        Material material = (Material)materialEditor.target;
        bool oldValue = material.GetShaderPassEnabled(passName);
        bool newValue = EditorGUILayout.Toggle(oldValue, GUILayout.Width(10f));
        EditorGUILayout.EndHorizontal();
        material.SetShaderPassEnabled(passName, newValue);
    }

    // Helper method to draw toggle UI property.
    private void DrawToggleUIKeyword(MaterialEditor materialEditor, MaterialProperty[] properties, string propertyName, string label, string tag, bool invert, float space)
    {
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label(label, GUILayout.Width(space));
        MaterialProperty property = FindProperty(propertyName, properties);
        EditorGUI.showMixedValue = property.hasMixedValue;
        var toggleValue = EditorGUILayout.Toggle(property.floatValue != 0, GUILayout.Width(10f));
        EditorGUI.showMixedValue = false;
        property.floatValue = toggleValue ? 1 : 0;
        EditorGUILayout.EndHorizontal();

        Material material = (Material)materialEditor.target;
        if (invert)
        {
            toggleValue = !toggleValue; // Inverte o valor do toggle
        }

        if (toggleValue)
        {
            material.EnableKeyword(tag);
        }
        else
        {
            material.DisableKeyword(tag);
        }
    }

    // Helper method to draw color UI property.
    private void DrawColorUIProperty(MaterialProperty[] properties, string propertyName)
    {
        EditorGUILayout.BeginHorizontal();
        MaterialProperty colorProperty = FindProperty(propertyName, properties);
        EditorGUI.BeginChangeCheck();
        Color color = EditorGUILayout.ColorField(GUIContent.none, colorProperty.colorValue, false, true, false, GUILayout.Width(50f));
        if (EditorGUI.EndChangeCheck())
        {
            colorProperty.colorValue = color;
        }
        EditorGUILayout.EndHorizontal();
    }

    private void DrawVector3Property(MaterialProperty[] properties, string propertyName, string label, float space)
    {
        EditorGUILayout.BeginHorizontal();
        MaterialProperty vectorProperty = FindProperty(propertyName, properties);
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

    // Helper method to draw Vector4 property.
    private void DrawVector4Property(MaterialProperty[] properties, string propertyName)
    {
        EditorGUILayout.BeginHorizontal();
        MaterialProperty vectorProperty = FindProperty(propertyName, properties);
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

    // Helper method to draw texture property.
    private void DrawTextureProperty(MaterialProperty[] properties, string propertyName, string label)
    {
        EditorGUILayout.BeginHorizontal();
        MaterialProperty textureProperty = FindProperty(propertyName, properties);
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

    // Helper method to draw cubemap property.
    private void DrawCubemapProperty(MaterialProperty[] properties, string propertyName, string label)
    {
        EditorGUILayout.BeginHorizontal();
        MaterialProperty cubemapProperty = FindProperty(propertyName, properties);
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

    // Helper method to draw dropdown property.
    private void DrawDropdownProperty(MaterialProperty[] properties, string propertyName, string label, string[] displayOptions, float[] numberOptions, float space, float dropdownSpace, bool expand = false)
    {
        if (displayOptions.Length != numberOptions.Length)
        {
            throw new ArgumentException("displayOptions and numberOptions must have the same length");
        }

        EditorGUILayout.BeginHorizontal();
        GUILayout.Label(label, GUILayout.Width(space));
        MaterialProperty dropdownProperty = FindProperty(propertyName, properties);
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

    // Helper method to draw float property with slider.
    private void DrawSliderFloatProperty(MaterialProperty[] properties, string propertyName, string label, float minValue, float maxValue, float space, float sliderSpace, bool expand = false)
    {
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label(label, GUILayout.Width(space));
        MaterialProperty property = FindProperty(propertyName, properties);
        
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

    private void DrawLightmapFlagsProperty(MaterialEditor materialEditor)
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
        
        Material material = (Material)materialEditor.target;
        MaterialGlobalIlluminationFlags currentFlag = material.globalIlluminationFlags;
        int selectedIndex = Array.IndexOf(flagOptions, currentFlag);

        EditorGUI.BeginChangeCheck();
        selectedIndex = EditorGUILayout.Popup(selectedIndex, displayOptions);
        if (EditorGUI.EndChangeCheck())
        {
            material.globalIlluminationFlags = flagOptions[selectedIndex];
        }

        EditorGUILayout.EndHorizontal();
    }

    /*
    private void DrawToggleUIProperty(MaterialProperty[] properties, string propertyName, string label, float space)
    {
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label(label, GUILayout.Width(space));
        MaterialProperty property = FindProperty(propertyName, properties);
        EditorGUI.showMixedValue = property.hasMixedValue;
        var toggleValue = property.floatValue != 0;
        EditorGUI.BeginChangeCheck();
        toggleValue = EditorGUILayout.Toggle(toggleValue, GUILayout.Width(10f));
        if (EditorGUI.EndChangeCheck())
        {
            property.floatValue = toggleValue ? 1 : 0;
        }
        EditorGUI.showMixedValue = false;
        EditorGUILayout.EndHorizontal();
    }

    private void DrawDropdownProperty(MaterialProperty[] properties, string propertyName, string label, string[] displayOptions)
    {
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label(label, GUILayout.Width(100f));
        MaterialProperty dropdownProperty = FindProperty(propertyName, properties);
        EditorGUI.BeginChangeCheck();
        int selectedIndex = (int)dropdownProperty.floatValue;
        selectedIndex = EditorGUILayout.Popup(selectedIndex, displayOptions, GUILayout.Width(150f));
        if (EditorGUI.EndChangeCheck())
        {
            dropdownProperty.floatValue = selectedIndex;
        }
        EditorGUILayout.EndHorizontal();
    }
    */
}