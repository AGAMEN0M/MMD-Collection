/*
 * ---------------------------------------------------------------------------
 * Description: This script is a custom extension for the Material Editor in Unity, providing advanced functionality 
 *              for inspecting and modifying materials using custom shaders. It extends the ShaderGUI class, allowing 
 *              fine-grained control over various properties of shaders and materials directly in the editor.
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/
using UnityEngine;
using UnityEditor;
using System;

namespace MMDCollectionEditor
{
    // Utility class for custom inspectors.
    public class CustomInspectorUtilityEditor : ShaderGUI
    {
        // Load existing material data into the inspector fields.
        public static void LoadData(CustomMMDData customMMDMaterialData, Material currentMaterial, out string materialNameJP, out string materialNameEN, out string materialMeno, out bool showSystemsDefault)
        {
            materialNameJP = "";
            materialNameEN = "";
            materialMeno = "";
            showSystemsDefault = false;

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

        // Save current material data from the inspector fields.
        public static void SaveData(CustomMMDData customMMDMaterialData, Material currentMaterial, string materialNameJP, string materialNameEN, string materialMeno, bool showSystemsDefault)
        {
            if (DetectChanges(customMMDMaterialData, currentMaterial, materialNameJP, materialNameEN, materialMeno, showSystemsDefault))
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

        // Detect if any changes have been made to the material data.
        public static bool DetectChanges(CustomMMDData customMMDMaterialData, Material currentMaterial, string materialNameJP, string materialNameEN, string materialMeno, bool showSystemsDefault)
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

        // Render options for surface properties.
        public static void RenderSurfaceOptions(MaterialProperty[] materialProperties, Material currentMaterial)
        {
            GUILayout.Label("Surface Options", EditorStyles.boldLabel);
            RenderSurfaceTypeDropdown(materialProperties, currentMaterial);
            CheckBlendingMode(materialProperties, currentMaterial);
            if (IsToggleUIPropertyEnabled(materialProperties, "_Surface"))
            {
                RenderBlendingModeDropdown(materialProperties, currentMaterial);
            }
            RenderDropdownProperty(materialProperties, currentMaterial, "_Cull", "Render Face", new string[] { "Both", "Back", "Front" }, new float[] { 0, 1, 2 }, EditorGUIUtility.labelWidth, EditorGUIUtility.fieldWidth, true);
            RenderDepthWriteDropdown(materialProperties, currentMaterial);
            RenderDropdownProperty(materialProperties, currentMaterial, "_ZTest", "Depth Test", new string[] { "Never", "Less", "Equal", "LEquaI", "Greater", "NotEqual", "GEqual", "Always" }, new float[] { 1, 2, 3, 4, 5, 6, 7, 8 }, EditorGUIUtility.labelWidth, EditorGUIUtility.fieldWidth, true);
            RenderKeywordToggle(materialProperties, currentMaterial, "_AlphaClip", "Alpha Clipping", "_ALPHATEST_ON", false, EditorGUIUtility.labelWidth);
            if (IsToggleUIPropertyEnabled(materialProperties, "_AlphaClip"))
            {
                EditorGUILayout.BeginHorizontal();
                GUILayout.Space(15f);
                RenderSliderFloatProperty(materialProperties, "_Cutoff", "Threshold", 0f, 1f, EditorGUIUtility.labelWidth - 15, EditorGUIUtility.fieldWidth, true);
                EditorGUILayout.EndHorizontal();
            }
            RenderShaderPassToggle(currentMaterial, "SHADOWCASTER", "Cast Shadows", EditorGUIUtility.labelWidth);
            RenderKeywordToggle(materialProperties, currentMaterial, "_ReceiveShadows", "Receive Shadows", "_RECEIVE_SHADOWS_OFF", true, EditorGUIUtility.labelWidth);
            GUILayout.Space(10f);
        }

        // Render options for lightmap flags.
        public static void RenderLightmapFlags(Material currentMaterial)
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
                Undo.RecordObject(currentMaterial, "Change Global Illumination Flag");
                currentMaterial.globalIlluminationFlags = flagOptions[selectedIndex];
                EditorUtility.SetDirty(currentMaterial);
            }

            EditorGUILayout.EndHorizontal();
        }

        // Render a color property with a label.
        public static void RenderColorProperty(MaterialProperty[] materialProperties, string propertyName, string label)
        {
            EditorGUILayout.BeginHorizontal();
            GUILayout.Label(label, GUILayout.Width(100f));
            MaterialProperty colorProperty = FindProperty(propertyName, materialProperties);
            EditorGUI.BeginChangeCheck();
            Color color = EditorGUILayout.ColorField(GUIContent.none, colorProperty.colorValue, false, true, false, GUILayout.Width(50f));

            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObject(colorProperty.targets[0], "Change Color");
                colorProperty.colorValue = color;
                EditorUtility.SetDirty(colorProperty.targets[0]);
            }

            GUILayout.Space(20f);
            GUILayout.Label("R", GUILayout.Width(15f));
            float r = EditorGUILayout.FloatField(color.r, GUILayout.Width(50f));
            GUILayout.Label("G", GUILayout.Width(15f));
            float g = EditorGUILayout.FloatField(color.g, GUILayout.Width(50f));
            GUILayout.Label("B", GUILayout.Width(15f));
            float b = EditorGUILayout.FloatField(color.b, GUILayout.Width(50f));

            if (r != color.r || g != color.g || b != color.b)
            {
                Undo.RecordObject(colorProperty.targets[0], "Change Color Channels");
                colorProperty.colorValue = new Color(r, g, b, color.a);
                EditorUtility.SetDirty(colorProperty.targets[0]);
            }

            EditorGUILayout.EndHorizontal();
        }

        // Render a float property as a slider.
        public static void RenderSliderFloatProperty(MaterialProperty[] materialProperties, string propertyName, string label, float minValue, float maxValue, float space, float sliderSpace, bool expand = false)
        {
            EditorGUILayout.BeginHorizontal();
            GUILayout.Label(label, GUILayout.Width(space));
            MaterialProperty property = FindProperty(propertyName, materialProperties);

            EditorGUI.BeginChangeCheck(); // Start change detection.
            float newValue;

            if (!expand)
            {
                newValue = EditorGUILayout.Slider(property.floatValue, minValue, maxValue, GUILayout.Width(sliderSpace));
            }
            else
            {
                newValue = EditorGUILayout.Slider(property.floatValue, minValue, maxValue, GUILayout.Width(sliderSpace), GUILayout.ExpandWidth(true));
            }

            if (EditorGUI.EndChangeCheck()) // Check if there has been any change.
            {
                Undo.RecordObject(property.targets[0], "Change Float Property"); // Register material before moving.
                property.floatValue = newValue; // Apply the new change.
                EditorUtility.SetDirty(property.targets[0]); // Mark material as modified.
            }

            EditorGUILayout.EndHorizontal();
        }

        // Render a toggle for double-sided rendering.
        public static void RenderDoubleSidedToggle(MaterialProperty[] materialProperties)
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

            EditorGUI.BeginChangeCheck();
            bool toggleValue = EditorGUILayout.Toggle(isTwoSided, GUILayout.Width(10f));
            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObject(cullProperty.targets[0], "Change Cull Property");
                cullProperty.floatValue = toggleValue ? 0 : 2;
                EditorUtility.SetDirty(cullProperty.targets[0]);
            }

            EditorGUI.showMixedValue = false;
            EditorGUI.EndDisabledGroup();

            EditorGUILayout.EndHorizontal();
            GUI.backgroundColor = Color.white;
        }

        // Render a shader pass toggle.
        public static void RenderShaderPassToggle(Material currentMaterial, string passName, string label, float space)
        {
            EditorGUILayout.BeginHorizontal();
            GUILayout.Label(label, GUILayout.Width(space));
            bool oldValue = currentMaterial.GetShaderPassEnabled(passName);
            bool newValue = EditorGUILayout.Toggle(oldValue, GUILayout.Width(10f));
            EditorGUILayout.EndHorizontal();
            if (oldValue != newValue)
            {
                Undo.RecordObject(currentMaterial, $"Change Shader Pass: {passName}"); // Register material before moving.
                currentMaterial.SetShaderPassEnabled(passName, newValue); // Apply the change.
                EditorUtility.SetDirty(currentMaterial); // Mark material as modified.
            }
        }

        // Render a keyword toggle.
        public static void RenderKeywordToggle(MaterialProperty[] materialProperties, Material currentMaterial, string propertyName, string label, string tag, bool invert, float space)
        {
            EditorGUILayout.BeginHorizontal();
            GUILayout.Label(label, GUILayout.Width(space));
            MaterialProperty property = FindProperty(propertyName, materialProperties);
            EditorGUI.showMixedValue = property.hasMixedValue;

            // Use EditorGUI.BeginChangeCheck to detect changes.
            EditorGUI.BeginChangeCheck();
            bool toggleValue = EditorGUILayout.Toggle(property.floatValue != 0, GUILayout.Width(10f));
            EditorGUI.showMixedValue = false;

            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObject(currentMaterial, $"Change Keyword: {tag}");
                property.floatValue = toggleValue ? 1 : 0; // Updates property value.
                if (invert) { toggleValue = !toggleValue; } // Apply the password change.

                if (toggleValue)
                {
                    currentMaterial.EnableKeyword(tag);
                }
                else
                {
                    currentMaterial.DisableKeyword(tag);
                }

                EditorUtility.SetDirty(currentMaterial); // Mark material as modified.
            }

            EditorGUILayout.EndHorizontal();
        }

        // Render a disabled toggle.
        public static void RenderDisabledToggle(GUIStyle redLabelStyle)
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

        // Render a UI toggle.
        public static void RenderUIToggle(MaterialProperty[] materialProperties, string propertyName, string label, float space)
        {
            EditorGUILayout.BeginHorizontal();
            GUILayout.Label(label, GUILayout.Width(space));
            MaterialProperty property = FindProperty(propertyName, materialProperties);
            EditorGUI.showMixedValue = property.hasMixedValue;

            EditorGUI.BeginChangeCheck();
            bool toggleValue = EditorGUILayout.Toggle(property.floatValue != 0, GUILayout.Width(10f));
            EditorGUI.showMixedValue = false;

            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObject(property.targets[0], $"Change {label}");
                property.floatValue = toggleValue ? 1 : 0;
                EditorUtility.SetDirty(property.targets[0]);
            }
            EditorGUILayout.EndHorizontal();
        }

        // Render a UI color property.
        public static void RenderUIColorProperty(MaterialProperty[] materialProperties, string propertyName)
        {
            EditorGUILayout.BeginHorizontal();
            MaterialProperty colorProperty = FindProperty(propertyName, materialProperties);
            EditorGUI.BeginChangeCheck();
            Color color = EditorGUILayout.ColorField(GUIContent.none, colorProperty.colorValue, false, true, false, GUILayout.Width(50f));
            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObject(colorProperty.targets[0], $"Change {propertyName}");
                colorProperty.colorValue = color;
                EditorUtility.SetDirty(colorProperty.targets[0]);
            }
            EditorGUILayout.EndHorizontal();
        }

        // Render a float property with a label.
        public static void RenderFloatProperty(MaterialProperty[] materialProperties, string propertyName, string label, float space)
        {
            EditorGUILayout.BeginHorizontal();
            GUILayout.Label(label, GUILayout.Width(space));
            MaterialProperty property = FindProperty(propertyName, materialProperties);
            EditorGUI.BeginChangeCheck();
            float newValue = EditorGUILayout.FloatField(property.floatValue, GUILayout.Width(50f));
            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObject(property.targets[0], $"Change {propertyName}");
                property.floatValue = newValue;
                EditorUtility.SetDirty(property.targets[0]);
            }
            EditorGUILayout.EndHorizontal();
        }

        // Render a Vector4 property.
        public static void RenderVector4Property(MaterialProperty[] materialProperties, string propertyName)
        {
            EditorGUILayout.BeginHorizontal();
            MaterialProperty vectorProperty = FindProperty(propertyName, materialProperties);
            EditorGUI.BeginChangeCheck();
            Color color = vectorProperty.colorValue; // Capture the current value of the property as a color.

            // Fields for editing RGBA components.
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
                Undo.RecordObject(vectorProperty.targets[0], $"Change {propertyName}");
                vectorProperty.colorValue = new Color(r, g, b, a);
                EditorUtility.SetDirty(vectorProperty.targets[0]);
            }
            EditorGUILayout.EndHorizontal();
        }

        // Render a dropdown property.
        public static void RenderDropdownProperty(MaterialProperty[] materialProperties, Material currentMaterial, string propertyName, string label, string[] displayOptions, float[] numberOptions, float space, float dropdownSpace, bool expand = false, string[] keywordOptions = null)
        {
            if (displayOptions.Length != numberOptions.Length)
            {
                throw new ArgumentException("displayOptions and numberOptions must have the same length");
            }

            EditorGUILayout.BeginHorizontal();
            GUILayout.Label(label, GUILayout.Width(space));
            MaterialProperty dropdownProperty = FindProperty(propertyName, materialProperties);
            EditorGUI.BeginChangeCheck();

            // Find the selected index based on the current value.
            int selectedIndex = Array.IndexOf(numberOptions, dropdownProperty.floatValue);
            if (selectedIndex == -1) { selectedIndex = 0; }

            // Display the dropdown.
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
                Undo.RecordObject(currentMaterial, $"Change {propertyName}");
                dropdownProperty.floatValue = numberOptions[selectedIndex];

                // Update the material's keywords.
                if (keywordOptions != null)
                {
                    foreach (string keyword in keywordOptions)
                    {
                        if (currentMaterial.IsKeywordEnabled(keyword))
                        {
                            currentMaterial.DisableKeyword(keyword);
                        }
                    }
                    currentMaterial.EnableKeyword(keywordOptions[selectedIndex]);
                }
                EditorUtility.SetDirty(currentMaterial);
            }
            EditorGUILayout.EndHorizontal();
        }

        // Render a texture property with a label.
        public static void RenderTextureProperty(MaterialProperty[] materialProperties, string propertyName, string label)
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
                Undo.RecordObject(textureProperty.targets[0], $"Change {propertyName}");
                textureProperty.textureValue = texture;
                EditorUtility.SetDirty(textureProperty.targets[0]);
            }
            EditorGUI.showMixedValue = false;
            EditorGUILayout.EndHorizontal();
        }

        // Render a cubemap property with a label.
        public static void RenderCubemapProperty(MaterialProperty[] materialProperties, string propertyName, string label)
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
                Undo.RecordObject(cubemapProperty.targets[0], $"Change {propertyName}");
                cubemapProperty.textureValue = cubemap;
                EditorUtility.SetDirty(cubemapProperty.targets[0]);
            }
            EditorGUI.showMixedValue = false;
            EditorGUILayout.EndHorizontal();
        }

        // Render a Vector3 property with a label.
        public static void RenderVector3Property(MaterialProperty[] materialProperties, string propertyName, string label, float space)
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
                Undo.RecordObject(vectorProperty.targets[0], $"Change {propertyName}");
                vectorProperty.vectorValue = new Vector3(x, y, z);
                EditorUtility.SetDirty(vectorProperty.targets[0]);
            }
            EditorGUILayout.EndHorizontal();
        }

        // Check if a toggle UI property is enabled.
        public static bool IsToggleUIPropertyEnabled(MaterialProperty[] materialProperties, string propertyName)
        {
            MaterialProperty property = FindProperty(propertyName, materialProperties);

            if (property.floatValue == 1f)
            {
                return true;
            }

            return false;
        }

        // Check if a float property has a specific value.
        public static bool HasFloatPropertyValue(MaterialProperty[] materialProperties, string propertyName, float value)
        {
            MaterialProperty property = FindProperty(propertyName, materialProperties);

            if (property.floatValue == value)
            {
                return true;
            }

            return false;
        }

        // Render a dropdown for depth write options.
        public static void RenderDepthWriteDropdown(MaterialProperty[] materialProperties, Material currentMaterial)
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
                Undo.RecordObject(currentMaterial, "Change Depth Write Settings");
                zWrite.floatValue = newZWrite;
                zWriteControl.floatValue = newZWriteControl;
                currentMaterial.SetShaderPassEnabled("DepthOnly", newValue);
                EditorUtility.SetDirty(currentMaterial);
            }
            EditorGUILayout.EndHorizontal();
        }

        // Render a dropdown for blending mode options.
        public static void RenderBlendingModeDropdown(MaterialProperty[] materialProperties, Material currentMaterial)
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
                Undo.RecordObject(currentMaterial, "Change Blending Mode");

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

                EditorUtility.SetDirty(currentMaterial);
            }

            EditorGUILayout.EndHorizontal();
        }

        // Check and update blending mode based on properties.
        public static void CheckBlendingMode(MaterialProperty[] materialProperties, Material currentMaterial)
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

        // Render a dropdown for surface type options.
        public static void RenderSurfaceTypeDropdown(MaterialProperty[] materialProperties, Material currentMaterial)
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
                Undo.RecordObject(currentMaterial, "Change Surface Type");

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

                EditorUtility.SetDirty(currentMaterial);
            }

            EditorGUILayout.EndHorizontal();
        }
    }
}