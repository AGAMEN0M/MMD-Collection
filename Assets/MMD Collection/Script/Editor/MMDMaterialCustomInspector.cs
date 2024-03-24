using UnityEngine;
using UnityEditor;

// Custom inspector for MMD (MikuMikuDance) materials.
public class MMDMaterialCustomInspector : ShaderGUI
{
    // Fields for storing material information.
    private string materialNameJP; // Material name in Japanese.
    private string materialNameEN; // Material name in English.
    private string materialMeno;   // Memo for the material.
    private bool useSlider;        // Toggle to use sliders for float properties.
    private bool showMoreSystems;  // Toggle to show more systems in the inspector.

    private CustomMMDData customMMDData; // Reference to CustomMMDData asset.

    // Override method for rendering the material inspector GUI.
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        // Show toggle for showing more systems.
        GUILayout.BeginHorizontal();
        GUILayout.Label("Show More Systems:", GUILayout.Width(130f));
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
            base.OnGUI(materialEditor, properties); // Render default material inspector.
        }

        SaveData(materialEditor); // Save any changes made.
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
                useSlider = existingMaterialInfo.useSlider;           // Load useSlider toggle.
            }
            else
            {
                // If no existing material info is found, initialize fields to default values.
                materialNameJP = ""; // Japanese material name is empty.
                materialNameEN = ""; // English material name is empty.
                materialMeno = "";   // Memo is empty.
                useSlider = false;   // Slider usage is set to false.
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
                existingMaterialInfo.useSlider = useSlider;           // Update useSlider toggle.
            }
            else
            {
                // If no existing material info is found, create a new material info and add it to the list.
                MMDMaterialInfo newMaterialInfo = new()
                {
                    mmdMaterial = material,          // Set the material reference.
                    materialNameJP = materialNameJP, // Set Japanese material name.
                    materialNameEN = materialNameEN, // Set English material name.
                    materialMeno = materialMeno,     // Set memo.
                    useSlider = useSlider            // Set useSlider toggle.
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
                if (existingMaterialInfo.materialNameJP != materialNameJP || existingMaterialInfo.materialNameEN != materialNameEN || existingMaterialInfo.materialMeno != materialMeno || existingMaterialInfo.useSlider != useSlider)
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
        GUILayout.Label("Mat-Name: (JP)", GUILayout.Width(100f));
        materialNameJP = EditorGUILayout.TextField(materialNameJP);
        GUILayout.Label("(EN)", GUILayout.Width(30f));
        materialNameEN = EditorGUILayout.TextField(materialNameEN);
        GUILayout.EndHorizontal();
        EditorGUILayout.EndHorizontal();

        GUILayout.Space(10f);

        // Render properties for material color, opacity, reflection, and rendering.
        GUILayout.Label("Material Color");
        DrawColorProperty(properties, "_Diffuse", "Diffuse:");
        DrawColorProperty(properties, "_Specular", "Specular:");
        DrawColorProperty(properties, "_Ambient", "Ambient:");
        GUILayout.Space(10f);

        // Add a toggle control to choose between sliders and text fields.
        GUILayout.BeginHorizontal();
        GUILayout.Label("Use Slider:", GUILayout.Width(100f));
        useSlider = EditorGUILayout.Toggle(useSlider);
        GUILayout.EndHorizontal();
        GUILayout.Space(5f);

        if (!useSlider)
        {
            // Use text fields for the _Opaque and _Reflection properties.
            DrawFloatProperty(properties, "_Opaque", "Opaque:", 100f);
            DrawFloatProperty(properties, "_Reflection", "Reflection:", 100f);
        }
        else
        {
            // Use sliders for the _Opaque and _Reflection properties.
            DrawSliderFloatProperty(properties, "_Opaque", "Opaque:", 0f, 1f);
            DrawSliderFloatProperty(properties, "_Reflection", "Reflection:", 0f, 1f);
        }

        GUILayout.Space(10f);

        GUILayout.Label("Rendering");
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

        GUILayout.Space(10f);

        // Render properties for edge (outline).
        GUILayout.Label("Edge (Outline)");
        EditorGUILayout.BeginHorizontal();
        GUILayout.BeginHorizontal(GUILayout.Width(100));
        DrawToggleUIProperty(properties, "_On", "On:", 30f);
        GUILayout.Space(30f);
        DrawColorUIProperty(properties, "_Color");
        GUILayout.Space(30f);
        DrawFloatProperty(properties, "_Size", "Size:", 40f);
        GUILayout.EndHorizontal();
        EditorGUILayout.EndHorizontal();
        DrawVector4Property(properties, "_Color");

        GUILayout.Space(10f);

        // Render properties for texture and memo.
        GUILayout.Label("Texture/Memo");
        DrawDropdownProperty(properties, "_EFFECTS", "Effects:", new string[] { "- Disabled", "x Multi-Sphere", "+ Add-Sphere", "Sub-Tex" });
        GUILayout.Space(5f);
        DrawTextureProperty(properties, "_Texture", "Texture:");
        DrawTextureProperty(properties, "_Toon", "Toon:");
        DrawCubemapProperty(properties, "_SPH", "SPH:");
        GUILayout.Space(10f);
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Memo:", GUILayout.Width(50f));
        materialMeno = EditorGUILayout.TextArea(materialMeno, GUILayout.Height(80f));
        EditorGUILayout.EndHorizontal();

        GUILayout.Space(30f);

        // Renders Fog, Lighting, and Unity default properties.
        GUILayout.Label("Unity Tools");
        DrawDropdownProperty(properties, "_FOG", "Fog:", new string[] { "On", "Off" });
        DrawDropdownProperty(properties, "_LIGHTING", "Lighting:", new string[] { "On", "Off" });
        GUILayout.Space(20f);
        materialEditor.RenderQueueField();
        materialEditor.EnableInstancingField();
        materialEditor.DoubleSidedGIField();
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
        Texture texture = EditorGUILayout.ObjectField(label, textureProperty.textureValue, typeof(Texture), false) as Texture;
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
        Cubemap cubemap = EditorGUILayout.ObjectField(label, cubemapProperty.textureValue, typeof(Cubemap), false) as Cubemap;
        if (EditorGUI.EndChangeCheck())
        {
            cubemapProperty.textureValue = cubemap;
        }
        EditorGUI.showMixedValue = false;
        EditorGUILayout.EndHorizontal();
    }

    // Helper method to draw dropdown property.
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

    // Helper method to draw float property with slider.
    private void DrawSliderFloatProperty(MaterialProperty[] properties, string propertyName, string label, float minValue, float maxValue)
    {
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label(label, GUILayout.Width(100f));
        MaterialProperty property = FindProperty(propertyName, properties);
        property.floatValue = EditorGUILayout.Slider(property.floatValue, minValue, maxValue, GUILayout.Width(290f));
        EditorGUILayout.EndHorizontal();
    }
}