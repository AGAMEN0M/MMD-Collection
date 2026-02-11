/*
 * ---------------------------------------------------------------------------
 * Description: Utility class that provides shared editor helpers for
 *              MMD custom material inspectors. Includes data persistence,
 *              custom GUI controls, surface options, blending logic,
 *              render queue conversion, and shader keyword synchronization.
 * 
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

using UnityEditor;
using UnityEngine;
using System.Linq;
using System;

namespace MMDCollection.Editor
{
    /// <summary>
    /// Provides shared utility methods for custom MMD material inspectors.
    /// This class centralizes editor GUI logic, material data handling,
    /// surface options, blending rules, and render state synchronization.
    /// </summary>
    public class MaterialUtility
    {
        #region === Custom MMD Data Handling ===

        /// <summary>
        /// Loads MMD metadata for a material from CustomMMDData.
        /// </summary>
        /// <param name="data">Custom MMD data container.</param>
        /// <param name="material">Target material.</param>
        /// <param name="nameJP">Output Japanese material name.</param>
        /// <param name="nameEN">Output English material name.</param>
        /// <param name="memo">Output material memo.</param>
        /// <param name="showSystemsDefault">Output flag for default inspector usage.</param>
        public static void LoadData(CustomMMDData data, Material material, out string nameJP, out string nameEN, out string memo, out bool showSystemsDefault)
        {
            // Initialize outputs with safe defaults.
            nameJP = string.Empty;
            nameEN = string.Empty;
            memo = string.Empty;
            showSystemsDefault = false;

            if (data == null || material == null) return; // Abort if data or material is invalid.
            showSystemsDefault = data.showSystemsDefault; // Read global inspector mode flag.

            // Access stored material info list.
            var list = data.materialInfoList;
            if (list == null) return;

            // Search for matching material entry.
            for (int i = 0; i < list.Count; i++)
            {
                if (list[i].mmdMaterial != material) continue;

                // Copy stored metadata.
                nameJP = list[i].materialNameJP;
                nameEN = list[i].materialNameEN;
                memo = list[i].materialMeno;
                return;
            }
        }

        /// <summary>
        /// Saves MMD metadata for a material into CustomMMDData.
        /// </summary>
        /// <param name="data">Custom MMD data container.</param>
        /// <param name="material">Target material.</param>
        /// <param name="nameJP">Japanese material name.</param>
        /// <param name="nameEN">English material name.</param>
        /// <param name="memo">Material memo.</param>
        /// <param name="showSystemsDefault">Flag for default inspector usage.</param>
        public static void SaveData(CustomMMDData data, Material material, string nameJP, string nameEN, string memo, bool showSystemsDefault)
        {
            if (data == null || material == null) return; // Abort if data or material is invalid.
            data.showSystemsDefault = showSystemsDefault; // Store global inspector mode flag.
            var list = data.materialInfoList;

            // Try to update an existing entry.
            for (int i = 0; i < list.Count; i++)
            {
                if (list[i].mmdMaterial != material) continue;

                list[i].materialNameJP = nameJP;
                list[i].materialNameEN = nameEN;
                list[i].materialMeno = memo;
                return;
            }

            // Create a new entry if none was found.
            list.Add(new MMDMaterialInfo
            {
                mmdMaterial = material,
                materialNameJP = nameJP,
                materialNameEN = nameEN,
                materialMeno = memo
            });
        }

        #endregion

        #region === Global Illumination ===

        /// <summary>
        /// Draws the Global Illumination mode dropdown.
        /// </summary>
        /// <param name="materials">
        /// Array of materials to edit. Supports multi-object editing and mixed values.
        /// </param>
        public static void RenderLightmapFlags(Material[] materials)
        {
            // Safety check to avoid null references or empty selections.
            if (materials == null || materials.Length == 0) return;

            string[] displayOptions = { "None", "Realtime", "Baked", "Emissive" }; // Display names shown in the popup.

            // Corresponding Unity Global Illumination flags.
            MaterialGlobalIlluminationFlags[] flagOptions =
            {
                MaterialGlobalIlluminationFlags.None,
                MaterialGlobalIlluminationFlags.RealtimeEmissive,
                MaterialGlobalIlluminationFlags.BakedEmissive,
                MaterialGlobalIlluminationFlags.EmissiveIsBlack
            };

            // Use the first material as reference for comparison.
            var firstValue = materials[0].globalIlluminationFlags;
            bool hasMixedValue = false;

            // Check if selected materials have different GI modes.
            for (int i = 1; i < materials.Length; i++)
            {
                if (materials[i].globalIlluminationFlags != firstValue)
                {
                    hasMixedValue = true;
                    break;
                }
            }

            EditorGUILayout.BeginHorizontal();

            // Label with detailed tooltip explaining each GI mode.
            GUIContent label = new("Global Illumination",
                "Controls how this material contributes to Global Illumination.\n\n" +
                "None: Does not contribute.\n" +
                "Realtime: Contributes to realtime GI.\n" +
                "Baked: Contributes to baked GI.\n" +
                "Emissive: Treated as black for GI."
                );

            GUILayout.Label(label, GUILayout.Width(EditorGUIUtility.labelWidth));

            EditorGUI.showMixedValue = hasMixedValue; // Enable mixed value display if materials differ.

            int selectedIndex = Array.IndexOf(flagOptions, firstValue); // Convert current flag to popup index.

            EditorGUI.BeginChangeCheck();
            selectedIndex = EditorGUILayout.Popup(selectedIndex, displayOptions);
            EditorGUI.showMixedValue = false;

            // Apply the selected GI mode to all materials.
            if (EditorGUI.EndChangeCheck() && selectedIndex >= 0)
            {
                foreach (var mat in materials)
                {
                    Undo.RecordObject(mat, "Change Global Illumination Flag");
                    mat.globalIlluminationFlags = flagOptions[selectedIndex];
                    EditorUtility.SetDirty(mat);
                }
            }

            EditorGUILayout.EndHorizontal();
        }

        #endregion

        #region === Basic Property Drawers ===
        
        /// <summary>
        /// Draws a color field with optional alpha, HDR support, and per-channel controls.
        /// </summary>
        /// <param name="label">Label and tooltip shown in the inspector.</param>
        /// <param name="properties">Material properties array provided by the inspector.</param>
        /// <param name="propertyName">Name of the color property in the shader.</param>
        /// <param name="alpha">Whether the alpha channel should be exposed.</param>
        /// <param name="hdr">Whether the color field should allow HDR values.</param>
        public static void ColorProperty(GUIContent label, MaterialProperty[] properties, string propertyName, bool alpha = false, bool hdr = false)
        {
            // Retrieve the color property from the selected materials.
            var colorProperty = MaterialEditor.GetMaterialProperty(properties.Select(p => p.targets).FirstOrDefault(), propertyName);

            if (colorProperty == null) return;

            EditorGUILayout.BeginHorizontal();

            GUILayout.Label(label, GUILayout.MinWidth(50f)); // Draw property label.

            // Handle mixed values across multiple materials.
            EditorGUI.showMixedValue = colorProperty.hasMixedValue;
            EditorGUI.BeginChangeCheck();

            // Draw compact color picker.
            Color color = EditorGUILayout.ColorField(
                GUIContent.none,
                colorProperty.colorValue,
                false, // Show eyedropper.
                alpha, // Show alpha channel if requested.
                hdr,   // Enable HDR mode if requested.
                GUILayout.Width(50f));

            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObjects(colorProperty.targets, "Change Color");
                colorProperty.colorValue = color;
            }

            GUILayout.Space(20f);

            EditorGUI.BeginChangeCheck();

            // Per-channel numeric controls.
            GUILayout.Label("R", GUILayout.Width(15f));
            float r = EditorGUILayout.FloatField(color.r, GUILayout.Width(50f));

            GUILayout.Label("G", GUILayout.Width(15f));
            float g = EditorGUILayout.FloatField(color.g, GUILayout.Width(50f));

            GUILayout.Label("B", GUILayout.Width(15f));
            float b = EditorGUILayout.FloatField(color.b, GUILayout.Width(50f));

            float a = color.a;

            // Optional alpha channel.
            if (alpha)
            {
                GUILayout.Label("A", GUILayout.Width(15f));
                a = EditorGUILayout.FloatField(color.a, GUILayout.Width(50f));
            }

            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObjects(colorProperty.targets, $"Change {propertyName}");
                colorProperty.colorValue = new Color(r, g, b, a);
            }

            EditorGUI.showMixedValue = false;
            EditorGUILayout.EndHorizontal();
        }

        /// <summary>
        /// Draws a single float field.
        /// </summary>
        /// <param name="label">Label and tooltip shown in the inspector.</param>
        /// <param name="properties">Material properties array provided by the inspector.</param>
        /// <param name="propertyName">Name of the float property in the shader.</param>
        public static void FloatProperty(GUIContent label, MaterialProperty[] properties, string propertyName)
        {
            // Retrieve the float property.
            var floatProperty = MaterialEditor.GetMaterialProperty(properties.Select(p => p.targets).FirstOrDefault(), propertyName);

            if (floatProperty == null) return;

            EditorGUILayout.BeginHorizontal();

            GUILayout.Label(label, GUILayout.MinWidth(50f)); // Draw property label.

            // Support mixed values.
            EditorGUI.showMixedValue = floatProperty.hasMixedValue;
            EditorGUI.BeginChangeCheck();

            // Draw float field.
            float newValue = EditorGUILayout.FloatField(floatProperty.floatValue, GUILayout.MinWidth(50f), GUILayout.MaxWidth(100f));

            EditorGUI.showMixedValue = false;

            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObjects(floatProperty.targets, $"Change {propertyName}");
                floatProperty.floatValue = newValue;
            }

            EditorGUILayout.EndHorizontal();
        }

        /// <summary>
        /// Draws a float slider with min and max limits.
        /// </summary>
        /// <param name="label">Label and tooltip shown in the inspector.</param>
        /// <param name="properties">Material properties array provided by the inspector.</param>
        /// <param name="propertyName">Name of the float property in the shader.</param>
        /// <param name="min">Minimum slider value.</param>
        /// <param name="max">Maximum slider value.</param>
        public static void FloatSliderProperty(GUIContent label, MaterialProperty[] properties, string propertyName, float min, float max)
        {
            // Retrieve the float property.
            var floatProperty = MaterialEditor.GetMaterialProperty(properties.Select(p => p.targets).FirstOrDefault(), propertyName);

            if (floatProperty == null) return;

            EditorGUILayout.BeginHorizontal();

            GUILayout.Label(label, GUILayout.MinWidth(50f)); // Draw property label.

            // Support mixed values.
            EditorGUI.showMixedValue = floatProperty.hasMixedValue;
            EditorGUI.BeginChangeCheck();

            // Draw slider.
            float newValue = EditorGUILayout.Slider(floatProperty.floatValue, min, max, GUILayout.MinWidth(150), GUILayout.MaxWidth(290f));

            EditorGUI.showMixedValue = false;

            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObjects(floatProperty.targets, $"Change {propertyName}");
                floatProperty.floatValue = newValue;
            }

            EditorGUILayout.EndHorizontal();
        }

        /// <summary>
        /// Draws a Vector2, Vector3, or Vector4 property.
        /// </summary>
        /// <param name="label">Label and tooltip shown in the inspector.</param>
        /// <param name="properties">Material properties array provided by the inspector.</param>
        /// <param name="propertyName">Name of the vector property in the shader.</param>
        /// <param name="dimensions">Number of vector components to display (2 to 4).</param>
        public static void VectorProperty(GUIContent label, MaterialProperty[] properties, string propertyName, int dimensions)
        {
            dimensions = Mathf.Clamp(dimensions, 2, 4); // Clamp supported vector size.

            // Retrieve the vector property across all selected materials.
            var prop = MaterialEditor.GetMaterialProperty(properties.SelectMany(p => p.targets).Distinct().ToArray(), propertyName);

            if (prop == null) return;

            EditorGUILayout.BeginHorizontal();

            GUILayout.Label(label, GUILayout.MinWidth(50f)); // Draw property label.

            // Support mixed values.
            EditorGUI.showMixedValue = prop.hasMixedValue;
            EditorGUI.BeginChangeCheck();

            Vector4 value = prop.vectorValue;

            float x = value.x;
            float y = value.y;
            float z = value.z;
            float w = value.w;

            // X and Y components are always shown.
            GUILayout.Label("X", GUILayout.Width(15f));
            x = EditorGUILayout.FloatField(x, GUILayout.Width(50f));

            GUILayout.Label("Y", GUILayout.Width(15f));
            y = EditorGUILayout.FloatField(y, GUILayout.Width(50f));

            // Optional Z component.
            if (dimensions >= 3)
            {
                GUILayout.Label("Z", GUILayout.Width(15f));
                z = EditorGUILayout.FloatField(z, GUILayout.Width(50f));
            }

            // Optional W component.
            if (dimensions == 4)
            {
                GUILayout.Label("W", GUILayout.Width(15f));
                w = EditorGUILayout.FloatField(w, GUILayout.Width(50f));
            }

            EditorGUI.showMixedValue = false;

            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObjects(prop.targets, $"Change {propertyName}");
                prop.vectorValue = new Vector4(x, y, z, w);
            }

            EditorGUILayout.EndHorizontal();
        }

        #endregion

        #region === Toggle & Keyword Controls ===

        /// <summary>
        /// Draws a double-sided rendering toggle using the _Cull property.
        /// </summary>
        /// <param name="properties">Material properties array used to resolve the _Cull property.</param>
        public static void DoubleToggleProperty(MaterialProperty[] properties)
        {
            const string propertyName = "_Cull";

            // Fetch the culling property from the selected materials.
            var cullProperty = MaterialEditor.GetMaterialProperty(properties.Select(p => p.targets).FirstOrDefault(), propertyName);

            if (cullProperty == null) return;

            EditorGUILayout.BeginHorizontal();

            // If value is not Back (1), the toggle is considered in a forced state.
            bool invalidValue = cullProperty.floatValue != 1;
            GUI.enabled = invalidValue;
            GUI.backgroundColor = invalidValue ? Color.white : Color.yellow;

            GUIContent label = new("2-SIDE", "Enables double-sided rendering.\n<color=yellow>If necessary, you can manually set Render Face to Back.</color>");

            GUILayout.Label(label, GUILayout.MinWidth(50f));

            bool isDoubleSided = cullProperty.floatValue == 0f;

            EditorGUI.showMixedValue = cullProperty.hasMixedValue;

            EditorGUI.BeginChangeCheck();

            bool newValue = EditorGUILayout.Toggle(isDoubleSided);

            EditorGUI.showMixedValue = false;

            GUI.enabled = true;
            GUI.backgroundColor = Color.white;

            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObjects(cullProperty.targets, $"Change {propertyName}");
                cullProperty.floatValue = newValue ? 0f : 2f;
            }

            EditorGUILayout.EndHorizontal();
        }

        /// <summary>
        /// Draws a boolean toggle backed by a float material property.
        /// </summary>
        /// <param name="label">GUI label displayed in the inspector.</param>
        /// <param name="properties">Material properties array used to resolve the float property.</param>
        /// <param name="propertyName">Name of the float property acting as a boolean.</param>
        public static void FloatToggleProperty(GUIContent label, MaterialProperty[] properties, string propertyName)
        {
            var floatProperty = MaterialEditor.GetMaterialProperty(properties.Select(p => p.targets).FirstOrDefault(), propertyName);

            if (floatProperty == null) return;

            EditorGUILayout.BeginHorizontal();

            GUILayout.Label(label, GUILayout.MinWidth(50f));

            EditorGUI.showMixedValue = floatProperty.hasMixedValue;

            EditorGUI.BeginChangeCheck();

            bool newValue = EditorGUILayout.Toggle(floatProperty.floatValue > 0);

            EditorGUI.showMixedValue = false;

            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObjects(floatProperty.targets, $"Change {propertyName}");
                floatProperty.floatValue = newValue ? 1f : 0f;
            }

            EditorGUILayout.EndHorizontal();
        }

        /// <summary>
        /// Draws a toggle that enables or disables a shader pass.
        /// </summary>
        /// <param name="label">GUI label displayed in the inspector.</param>
        /// <param name="properties">Material properties array used to collect target materials.</param>
        /// <param name="passName">Name of the shader pass to toggle.</param>
        public static void PassToggleProperty(GUIContent label, MaterialProperty[] properties, string passName)
        {
            // Collect all unique material targets.
            var materials = properties.SelectMany(p => p.targets).OfType<Material>().Distinct().ToArray();

            if (materials.Length == 0) return;

            // Use the first material as reference.
            bool firstValue = materials[0].GetShaderPassEnabled(passName);

            // Detect mixed values.
            bool hasMixedValue = materials.Any(m => m.GetShaderPassEnabled(passName) != firstValue);

            EditorGUILayout.BeginHorizontal();

            GUILayout.Label(label, GUILayout.MinWidth(50f));

            EditorGUI.showMixedValue = hasMixedValue;
            EditorGUI.BeginChangeCheck();

            bool newValue = EditorGUILayout.Toggle(firstValue);

            EditorGUI.showMixedValue = false;

            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObjects(materials, $"Toggle Shader Pass: {passName}");

                foreach (var mat in materials)
                {
                    mat.SetShaderPassEnabled(passName, newValue);
                    EditorUtility.SetDirty(mat);
                }
            }

            EditorGUILayout.EndHorizontal();
        }

        /// <summary>
        /// Draws a float-backed toggle that also synchronizes a shader keyword.
        /// </summary>
        /// <param name="label">GUI label displayed in the inspector.</param>
        /// <param name="properties">Material properties array used to resolve the float property.</param>
        /// <param name="propertyName">Float property acting as a boolean toggle.</param>
        /// <param name="keywordName">Shader keyword controlled by the toggle.</param>
        /// <param name="invertKeyword">If true, the keyword state is inverted relative to the toggle value.</param>
        public static void KeywordToggleProperty(GUIContent label, MaterialProperty[] properties, string propertyName, string keywordName, bool invertKeyword = false)
        {
            var prop = MaterialEditor.GetMaterialProperty(properties.SelectMany(p => p.targets).Distinct().ToArray(), propertyName);

            if (prop == null) return;

            EditorGUILayout.BeginHorizontal();

            GUILayout.Label(label, GUILayout.MinWidth(50f));

            EditorGUI.showMixedValue = prop.hasMixedValue;
            EditorGUI.BeginChangeCheck();

            bool enabled = prop.floatValue != 0f;
            bool newValue = EditorGUILayout.Toggle(enabled);

            EditorGUI.showMixedValue = false;

            if (EditorGUI.EndChangeCheck())
            {
                // Register Undo for all materials.
                Undo.RecordObjects(prop.targets, $"Toggle {keywordName}");

                float newFloatValue = newValue ? 1f : 0f;
                prop.floatValue = newFloatValue;

                if (invertKeyword) newValue = !newValue;

                // Sync keyword state per material.
                foreach (var obj in prop.targets)
                {
                    if (obj is not Material mat) continue;

                    if (newValue)
                    {
                        mat.EnableKeyword(keywordName);
                    }
                    else
                    {
                        mat.DisableKeyword(keywordName);
                    }

                    EditorUtility.SetDirty(mat);
                }
            }

            EditorGUILayout.EndHorizontal();
        }

        #endregion

        #region === Dropdown Controls ===

        /// <summary>
        /// Draws a float-backed dropdown, behaving like an enum selector.
        /// </summary>
        /// <param name="label">GUI label displayed in the inspector.</param>
        /// <param name="properties">Material properties array used to resolve the target property.</param>
        /// <param name="propertyName">Name of the float property backing the dropdown.</param>
        /// <param name="displayOptions">Display strings shown in the popup.</param>
        /// <param name="valueOptions">Float values mapped to each display option.</param>
        public static void FloatDropdownProperty(GUIContent label, MaterialProperty[] properties, string propertyName, string[] displayOptions, float[] valueOptions)
        {
            // Validate input arrays.
            if (displayOptions == null || valueOptions == null) return;

            if (displayOptions.Length != valueOptions.Length)
            {
                Debug.LogError("displayOptions and valueOptions must have the same length.");
                return;
            }

            // Fetch the material property across all selected materials.
            var prop = MaterialEditor.GetMaterialProperty(properties.SelectMany(p => p.targets).Distinct().ToArray(), propertyName);

            if (prop == null) return;

            EditorGUILayout.BeginHorizontal();

            GUILayout.Label(label, GUILayout.MinWidth(50f));

            // Enable mixed value handling.
            EditorGUI.showMixedValue = prop.hasMixedValue;
            EditorGUI.BeginChangeCheck();

            // Resolve current value index from the float backing value.
            int currentIndex = Array.IndexOf(valueOptions, prop.floatValue);
            if (currentIndex < 0) currentIndex = 0;

            int newIndex = EditorGUILayout.Popup(currentIndex, displayOptions, GUILayout.MinWidth(100f), GUILayout.MaxWidth(200f));

            EditorGUI.showMixedValue = false;

            // Apply selected value.
            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObjects(prop.targets, $"Change {propertyName}");
                prop.floatValue = valueOptions[newIndex];
            }

            EditorGUILayout.EndHorizontal();
        }

        /// <summary>
        /// Draws the surface type dropdown (Opaque / Transparent).
        /// Automatically synchronizes RenderQueue and RenderType tags.
        /// </summary>
        /// <param name="label">GUI label displayed in the inspector.</param>
        /// <param name="properties">Material properties array used to resolve the _Surface property.</param>
        public static void SurfaceTypeDropdownProperty(GUIContent label, MaterialProperty[] properties)
        {
            // Fetch the surface type property across all selected materials.
            var surfaceProp = MaterialEditor.GetMaterialProperty(properties.SelectMany(p => p.targets).Distinct().ToArray(), "_Surface");

            if (surfaceProp == null) return;

            EditorGUILayout.BeginHorizontal();

            GUILayout.Label(label, GUILayout.MinWidth(50f));

            EditorGUI.showMixedValue = surfaceProp.hasMixedValue;
            EditorGUI.BeginChangeCheck();

            // Surface is stored as 0 (Opaque) or 1 (Transparent).
            int currentIndex = Mathf.RoundToInt(surfaceProp.floatValue);
            string[] displayOptions = { "Opaque", "Transparent" };

            int newIndex = EditorGUILayout.Popup(currentIndex, displayOptions, GUILayout.MinWidth(100f), GUILayout.MaxWidth(200f));

            EditorGUI.showMixedValue = false;

            // Apply surface type and update render state.
            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObjects(surfaceProp.targets, "Change Surface Type");

                float newValue = newIndex == 1 ? 1f : 0f;
                surfaceProp.floatValue = newValue;

                foreach (var obj in surfaceProp.targets)
                {
                    if (obj is not Material mat) continue;

                    int rq = mat.renderQueue;

                    if (newIndex == 1)
                    {
                        // Transparent surface configuration.
                        mat.SetOverrideTag("RenderType", "Transparent");
                        mat.renderQueue = ConvertRenderQueueToTransparent(rq);
                    }
                    else
                    {
                        // Opaque surface configuration.
                        mat.SetOverrideTag("RenderType", "Opaque");
                        mat.renderQueue = ConvertRenderQueueToOpaque(rq);
                    }

                    EditorUtility.SetDirty(mat);
                }
            }

            EditorGUILayout.EndHorizontal();
        }

        /// <summary>
        /// Draws the blending mode dropdown and updates blend factors accordingly.
        /// </summary>
        /// <param name="label">GUI label displayed in the inspector.</param>
        /// <param name="properties">Material properties array used to resolve blend properties.</param>
        public static void BlendingModeDropdownProperty(GUIContent label, MaterialProperty[] properties)
        {
            // Collect all unique material targets.
            var targets = properties.SelectMany(p => p.targets).Distinct().ToArray();

            // Fetch blend-related properties.
            var blendProp = MaterialEditor.GetMaterialProperty(targets, "_Blend");
            var srcBlendProp = MaterialEditor.GetMaterialProperty(targets, "_SrcBlend");
            var dstBlendProp = MaterialEditor.GetMaterialProperty(targets, "_DstBlend");

            if (blendProp == null || srcBlendProp == null || dstBlendProp == null) return;

            EditorGUILayout.BeginHorizontal();

            GUILayout.Label(label, GUILayout.MinWidth(50f));

            // Handle mixed values.
            EditorGUI.showMixedValue = blendProp.hasMixedValue;
            EditorGUI.BeginChangeCheck();

            int currentIndex = Mathf.RoundToInt(blendProp.floatValue);
            string[] displayOptions = { "Alpha", "Premultiply", "Additive", "Multiply" };

            int newIndex = EditorGUILayout.Popup(currentIndex, displayOptions, GUILayout.MinWidth(100f), GUILayout.MaxWidth(200f));

            EditorGUI.showMixedValue = false;

            // Apply blend configuration.
            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObjects(targets, "Change Blending Mode");

                float newBlend;
                float newSrc;
                float newDst;

                switch (newIndex)
                {
                    case 1: // Premultiply.
                        newBlend = 1f;
                        newSrc = 1f;
                        newDst = 10f;
                        break;

                    case 2: // Additive.
                        newBlend = 2f;
                        newSrc = 5f;
                        newDst = 1f;
                        break;

                    case 3: // Multiply.
                        newBlend = 3f;
                        newSrc = 2f;
                        newDst = 0f;
                        break;

                    default: // Alpha.
                        newBlend = 0f;
                        newSrc = 5f;
                        newDst = 10f;
                        break;
                }

                // Apply values to all selected materials.
                blendProp.floatValue = newBlend;
                srcBlendProp.floatValue = newSrc;
                dstBlendProp.floatValue = newDst;

                foreach (var obj in targets)
                {
                    if (obj is not Material mat) continue;
                    EditorUtility.SetDirty(mat);
                }
            }

            EditorGUILayout.EndHorizontal();
        }

        /// <summary>
        /// Draws the Depth Write mode dropdown using _ZWriteControl and _ZWrite.
        /// </summary>
        /// <param name="label">GUI label displayed in the inspector.</param>
        /// <param name="properties">Material properties array used to resolve depth write properties.</param>
        public static void DepthWriteDropdownProperty(GUIContent label, MaterialProperty[] properties)
        {
            // Fetch depth write related properties.
            var zWriteControlProp = MaterialEditor.GetMaterialProperty(properties.SelectMany(p => p.targets).Distinct().ToArray(), "_ZWriteControl");
            var zWriteProp = MaterialEditor.GetMaterialProperty(properties.SelectMany(p => p.targets).Distinct().ToArray(), "_ZWrite");

            if (zWriteControlProp == null || zWriteProp == null) return;

            EditorGUILayout.BeginHorizontal();

            GUILayout.Label(label, GUILayout.MinWidth(50f));

            // Mixed value handling across both properties.
            EditorGUI.showMixedValue = zWriteControlProp.hasMixedValue || zWriteProp.hasMixedValue;
            EditorGUI.BeginChangeCheck();

            // Resolve current depth write mode.
            int selectedIndex = 0;

            if (zWriteControlProp.floatValue == 0f && zWriteProp.floatValue == 0f)
            {
                selectedIndex = 0; // Auto.
            }
            else if (zWriteControlProp.floatValue == 1f && zWriteProp.floatValue == 1f)
            {
                selectedIndex = 1; // Force Enabled.
            }
            else if (zWriteControlProp.floatValue == 2f && zWriteProp.floatValue == 0f)
            {
                selectedIndex = 2; // Force Disabled.
            }

            string[] options = { "Auto", "Force Enabled", "Force Disabled" };

            int newIndex = EditorGUILayout.Popup(selectedIndex, options, GUILayout.MinWidth(100f), GUILayout.MaxWidth(200f));

            EditorGUI.showMixedValue = false;

            // Apply depth write configuration.
            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObjects(zWriteControlProp.targets, "Change Depth Write Settings");

                float newZWriteControl = 0f;
                float newZWrite = 0f;
                bool enableDepthOnly = false;

                switch (newIndex)
                {
                    case 0: // Auto.
                        newZWriteControl = 0f;
                        newZWrite = 0f;
                        enableDepthOnly = false;
                        break;

                    case 1: // Force Enabled.
                        newZWriteControl = 1f;
                        newZWrite = 1f;
                        enableDepthOnly = true;
                        break;

                    case 2: // Force Disabled.
                        newZWriteControl = 2f;
                        newZWrite = 0f;
                        enableDepthOnly = false;
                        break;
                }

                zWriteControlProp.floatValue = newZWriteControl;
                zWriteProp.floatValue = newZWrite;

                // Sync DepthOnly pass per material.
                foreach (var obj in zWriteControlProp.targets)
                {
                    if (obj is not Material mat) continue;

                    mat.SetShaderPassEnabled("DepthOnly", enableDepthOnly);
                    EditorUtility.SetDirty(mat);
                }
            }

            EditorGUILayout.EndHorizontal();
        }

        #endregion

        #region === Texture Controls ===

        /// <summary>
        /// Draws a texture field with optional tiling and offset controls.
        /// </summary>
        /// <param name="label">GUI label displayed in the inspector.</param>
        /// <param name="properties">Material properties array used to resolve the texture property.</param>
        /// <param name="propertyName">Name of the texture property.</param>
        /// <param name="cubemap">If true, restricts the field to Cubemap assets.</param>
        /// <param name="showScaleOffset">If true, shows tiling and offset controls below the texture field.</param>
        public static void TextureProperty(GUIContent label, MaterialProperty[] properties, string propertyName, bool cubemap = false, bool showScaleOffset = false)
        {
            // Resolve the texture property across all selected materials.
            var texProp = MaterialEditor.GetMaterialProperty(properties.SelectMany(p => p.targets).Distinct().ToArray(), propertyName);

            if (texProp == null) return; // Abort if the property does not exist.

            EditorGUILayout.BeginHorizontal();

            GUILayout.Label(label, GUILayout.MinWidth(50f)); // Draw the property label.

            // Enable mixed value visualization when multiple materials differ.
            EditorGUI.showMixedValue = texProp.hasMixedValue;
            EditorGUI.BeginChangeCheck();

            Texture newTexture; // Draw the appropriate texture field based on the cubemap flag.

            if (cubemap)
            {
                // Restrict selection to Cubemap assets.
                newTexture = EditorGUILayout.ObjectField("", texProp.textureValue, typeof(Cubemap), false) as Cubemap;
            }
            else
            {
                // Allow any Texture type.
                newTexture = EditorGUILayout.ObjectField("", texProp.textureValue, typeof(Texture), false) as Texture;
            }

            EditorGUI.showMixedValue = false;

            // Apply texture changes if the value was modified.
            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObjects(texProp.targets, $"Change {propertyName}"); // Register Undo for all affected materials.
                texProp.textureValue = newTexture; // Assign the new texture to all selected materials.
            }

            EditorGUILayout.EndHorizontal();

            // Draw tiling and offset controls if requested.
            if (showScaleOffset)
            {
                // Use the first material as a reference for initial values.
                var referenceMat = texProp.targets[0] as Material;
                if (referenceMat == null) return;

                // Fetch current tiling and offset values.
                Vector2 scale = referenceMat.GetTextureScale(propertyName);
                Vector2 offset = referenceMat.GetTextureOffset(propertyName);

                bool mixedScale = false;
                bool mixedOffset = false;

                // Detect mixed tiling or offset values across materials.
                foreach (var obj in texProp.targets)
                {
                    if (obj is not Material mat) continue;
                    if (mat.GetTextureScale(propertyName) != scale) mixedScale = true;
                    if (mat.GetTextureOffset(propertyName) != offset) mixedOffset = true;
                }

                // Get the Rect of the last GUILayout element (the texture field) and adjust.
                Rect objectRect = GUILayoutUtility.GetLastRect();
                objectRect.y += 20f; // Move slightly down.
                objectRect.width = Mathf.Max(0f, objectRect.width - 70f); // Reserve space on the right.

                // Draw tiling and offset fields in this Rect.
                DrawScaleOffsetInRect(objectRect, texProp, propertyName, scale, offset, mixedScale, mixedOffset);
            }
        }

        /// <summary>
        /// Draws Tiling and Offset Vector2 fields inside a specified rectangle, updating the material property values.
        /// </summary>
        /// <param name="boxArea">Rect area where the fields will be drawn.</param>
        /// <param name="texProp">Material property representing the texture.</param>
        /// <param name="propertyName">Name of the texture property.</param>
        /// <param name="scale">Current tiling value of the texture.</param>
        /// <param name="offset">Current offset value of the texture.</param>
        /// <param name="mixedScale">True if multiple materials have different tiling values.</param>
        /// <param name="mixedOffset">True if multiple materials have different offset values.</param>
        private static void DrawScaleOffsetInRect(Rect boxArea, MaterialProperty texProp, string propertyName, Vector2 scale, Vector2 offset, bool mixedScale, bool mixedOffset)
        {
            float lineHeight = EditorGUIUtility.singleLineHeight;
            float spacing = EditorGUIUtility.standardVerticalSpacing;
            float localLabelWidth = 60f; // Width for the labels ("Tiling" and "Offset").

            // ---- Line Rects ----
            Rect tilingLine = new(boxArea.x, boxArea.y, boxArea.width, lineHeight);
            Rect offsetLine = new(boxArea.x, boxArea.y + lineHeight + spacing, boxArea.width, lineHeight);

            // ---- Shared split logic for label and field ----
            Rect GetLabelRect(Rect line) => new(line.x, line.y, localLabelWidth, line.height);

            Rect GetFieldRect(Rect line)
            {
                float minFieldWidth = 80f; // Minimum allowed field width.
                float fieldWidth = line.width - localLabelWidth;
                fieldWidth = Mathf.Max(minFieldWidth, fieldWidth); // Prevent negative or too small width.
                return new Rect(line.x + localLabelWidth, line.y, fieldWidth, line.height);
            }

            // ================= TILING =================
            EditorGUI.showMixedValue = mixedScale;
            EditorGUI.BeginChangeCheck();

            EditorGUI.LabelField(GetLabelRect(tilingLine), "Tiling");
            scale = EditorGUI.Vector2Field(GetFieldRect(tilingLine), GUIContent.none, scale);

            if (EditorGUI.EndChangeCheck())
            {
                // Register Undo for tiling changes.
                Undo.RecordObjects(texProp.targets, $"Change {propertyName} Tiling");

                // Apply tiling to all selected materials.
                foreach (var obj in texProp.targets)
                {
                    if (obj is Material mat)
                    {
                        mat.SetTextureScale(propertyName, scale);
                        EditorUtility.SetDirty(mat);
                    }
                }
            }

            EditorGUI.showMixedValue = false;

            // ================= OFFSET =================
            EditorGUI.showMixedValue = mixedOffset;
            EditorGUI.BeginChangeCheck();

            EditorGUI.LabelField(GetLabelRect(offsetLine), "Offset");
            offset = EditorGUI.Vector2Field(GetFieldRect(offsetLine), GUIContent.none, offset);

            if (EditorGUI.EndChangeCheck())
            {
                // Register Undo for offset changes.
                Undo.RecordObjects(texProp.targets, $"Change {propertyName} Offset");

                // Apply offset to all selected materials.
                foreach (var obj in texProp.targets)
                {
                    if (obj is Material mat)
                    {
                        mat.SetTextureOffset(propertyName, offset);
                        EditorUtility.SetDirty(mat);
                    }
                }
            }

            EditorGUI.showMixedValue = false;
        }

        #endregion

        #region === Surface Options Composite UI ===

        /// <summary>
        /// Draws the standard URP-style surface options block.
        /// Used by all custom MMD inspectors.
        /// </summary>
        /// <param name="properties">
        /// Material properties array used to resolve and synchronize all surface-related options.
        /// Supports multi-object editing.
        /// </param>
        public static void DrawSurfaceOptions(MaterialProperty[] properties)
        {
            // Draws the surface type selector (Opaque / Transparent).
            SurfaceTypeDropdownProperty(new GUIContent("Surface Type", "Select a surface type for your texture.\nChoose between Opaque or Transparent."), properties);

            // Only show blending options if the surface is Transparent (_Surface == 1).
            if (HasFloatPropertyValue(properties, "_Surface", 1))
            {
                // Draws blending mode options for transparent materials.
                BlendingModeDropdownProperty(new GUIContent("Blending Mode", "Controls how the color of the Transparent surface blends with the Material color in the background."), properties);
            }

            // Draws the face culling mode dropdown.
            FloatDropdownProperty(new GUIContent("Render Face", "Specifies which faces to cull from your geometry.\n- Front culls front faces.\n- Back culls back faces.\n- Both means that both sides are rendered."), properties, "_Cull", new string[] { "Both", "Back", "Front" }, new float[] { 0, 1, 2 });

            // Draws the depth write behavior selector.
            DepthWriteDropdownProperty(new GUIContent("Depth Write", "Controls whether the shader writes depth.\nAuto will write only when the shader is opaque."), properties);

            // Draws the depth test comparison mode dropdown.
            FloatDropdownProperty(new GUIContent("Depth Test", "Controls how the shader compares depth values when rendering.\n- Never: Never passes.\n- Less: Passes if the incoming depth is less.\n- Equal: Passes if equal.\n- LEquaI: Passes if less or equal.\n- Greater: Passes if greater.\n- NotEqual: Passes if not equal.\n- GEqual: Passes if greater or equal.\n- Always: Always passes."), properties, "_ZTest", new string[] { "Never", "Less", "Equal", "LEquaI", "Greater", "NotEqual", "GEqual", "Always" }, new float[] { 1, 2, 3, 4, 5, 6, 7, 8 });

            // Draws the alpha clipping toggle.
            FloatToggleProperty(new GUIContent("Alpha Clipping", "Makes your Material act like a Cutout shader.\nUse this to create a transparent effect with hard edges between opaque and transparent areas.\nAvoid using when Alpha is constant for the entire material as enabling in this case could introduce visual artifacts and will add an unnecessary performance cost when used with MSAA (due to AlphaToMask)."), properties, "_AlphaClip");

            // If alpha clipping is enabled, expose the cutoff threshold slider.
            if (HasFloatPropertyValue(properties, "_AlphaClip", 1))
            {
                GUILayout.Space(15f); // Adds spacing to visually separate dependent options.

                // Draws the alpha cutoff threshold slider.
                FloatSliderProperty(new GUIContent("Threshold", "Sets where the Alpha Clipping starts.\nThe higher the value is, the brighter the effect is when clipping starts."), properties, "_Cutoff", 0f, 1f);
            }

            // Toggles the ShadowCaster shader pass.
            PassToggleProperty(new GUIContent("Cast Shadows", "When enabled, this GameObject will cast shadows onto any geometry that can receive them."), properties, "SHADOWCASTER");

            // Toggles shadow receiving using an inverted keyword.
            KeywordToggleProperty(new GUIContent("Receive Shadows", "When enabled, other GameObjects can cast shadows onto this GameObject."), properties, "_ReceiveShadows", "_RECEIVE_SHADOWS_OFF", invertKeyword: true);
        }

        #endregion

        #region === Render Queue Conversion ===

        /// <summary>
        /// Converts an opaque or alpha-tested render queue value into the transparent render queue range.
        /// </summary>
        /// <param name="queue">
        /// Current render queue value of the material.
        /// Expected to be in the Geometry or AlphaTest ranges.
        /// </param>
        /// <returns>
        /// A render queue value mapped to the Transparent range, or the original value if no conversion applies.
        /// </returns>
        public static int ConvertRenderQueueToTransparent(int queue)
        {
            // Geometry (2000–2499) → Transparent
            if (queue >= 2000 && queue <= 2499) return queue + 1000;

            // AlphaTest (2500–2999) → Transparent (um pouco mais baixo)
            if (queue >= 2500 && queue <= 2999) return queue + 500;

            return queue;
        }

        /// <summary>
        /// Converts a transparent render queue value back into an opaque or alpha-tested range.
        /// </summary>
        /// <param name="queue">
        /// Current render queue value of the material.
        /// Expected to be derived from a previous transparent conversion.
        /// </param>
        /// <returns>
        /// A render queue value mapped back to an opaque-compatible range, or the original value if no conversion applies.
        /// </returns>
        public static int ConvertRenderQueueToOpaque(int queue)
        {
            // Transparent derived from Geometry.
            if (queue >= 3000 && queue <= 3499) return queue - 1000;

            // Transparent derived from AlphaTest.
            if (queue >= 3000 && queue <= 3499) return queue - 500;

            return queue;
        }

        #endregion

        #region === Validation & Helpers ===

        /// <summary>
        /// Checks whether all selected materials have a float property set to a specific value.
        /// </summary>
        /// <param name="properties">Material properties array used to resolve the target property across all selected materials.</param>
        /// <param name="propertyName">Name of the float property to check.</param>
        /// <param name="value">Expected float value to compare against.</param>
        /// <returns>
        /// True if all materials share the same value and it matches the requested value.
        /// </returns>
        public static bool HasFloatPropertyValue(MaterialProperty[] properties, string propertyName, float value)
        {
            // Fetch the material property across all selected materials.
            var prop = MaterialEditor.GetMaterialProperty(properties.SelectMany(p => p.targets).Distinct().ToArray(), propertyName);

            if (prop == null) return false; // Property does not exist on the shader.
            if (prop.hasMixedValue) return false; // If values differ between materials, they cannot all match the requested value.
            return Mathf.Approximately(prop.floatValue, value); // Compare using Approximately to avoid floating-point precision issues.
        }

        /// <summary>
        /// Ensures blending-related properties remain consistent based on Surface Type and selected Blend Mode.
        /// </summary>
        /// <param name="properties">Material properties array used to collect and update blend-related properties.</param>
        public static void CheckBlendingMode(MaterialProperty[] properties)
        {
            // Collect all unique material targets.
            var targets = properties.SelectMany(p => p.targets).Distinct().ToArray();

            if (targets.Length == 0) return;

            // Fetch required properties across all selected materials.
            var surfaceProp = MaterialEditor.GetMaterialProperty(targets, "_Surface");
            var blendProp = MaterialEditor.GetMaterialProperty(targets, "_Blend");
            var srcBlendProp = MaterialEditor.GetMaterialProperty(targets, "_SrcBlend");
            var dstBlendProp = MaterialEditor.GetMaterialProperty(targets, "_DstBlend");

            // Abort if any required property is missing.
            if (surfaceProp == null || blendProp == null || srcBlendProp == null || dstBlendProp == null) return;

            // Resolve current surface and blend mode.
            int blendMode = Mathf.RoundToInt(blendProp.floatValue);
            bool surfaceTransparent = surfaceProp.floatValue == 1f;

            float newBlend;
            float newSrc;
            float newDst;

            // Resolve blend factors based on mode and surface transparency.
            switch (blendMode)
            {
                case 1: // Premultiply.
                    newBlend = 1f;
                    newSrc = 1f;
                    newDst = surfaceTransparent ? 10f : 0f;
                    break;

                case 2: // Additive.
                    newBlend = 2f;
                    newSrc = surfaceTransparent ? 5f : 1f;
                    newDst = surfaceTransparent ? 1f : 0f;
                    break;

                case 3: // Multiply.
                    newBlend = 3f;
                    newSrc = surfaceTransparent ? 2f : 1f;
                    newDst = 0f;
                    break;

                default: // Alpha.
                    newBlend = 0f;
                    newSrc = surfaceTransparent ? 5f : 1f;
                    newDst = surfaceTransparent ? 10f : 0f;
                    break;
            }

            // Apply resolved values.
            // MaterialProperty already supports multi-object editing.
            blendProp.floatValue = newBlend;
            srcBlendProp.floatValue = newSrc;
            dstBlendProp.floatValue = newDst;

            // Explicitly mark all affected materials as dirty.
            foreach (var obj in targets)
            {
                if (obj is not Material mat) continue;
                EditorUtility.SetDirty(mat);
            }
        }

        #endregion
    }
}