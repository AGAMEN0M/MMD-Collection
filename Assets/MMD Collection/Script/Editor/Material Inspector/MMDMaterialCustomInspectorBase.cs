/*
 * ---------------------------------------------------------------------------
 * Description: Base class for custom MMD material inspectors.
 *              This class provides shared infrastructure for:
 *              - Custom header and memo handling via CustomMMDData.
 *              - Multi-material editing with mixed-value support.
 *              - Undo/Redo safety.
 *              - Common rendering rule hooks.
 *              - Optional fallback to Unity's default material inspector.
 * 
 *              All MMD-specific inspectors should inherit from this class.
 * 
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

using UnityEditor;
using UnityEngine;
using System.Linq;

namespace MMDCollection.Editor
{
    /// <summary>
    /// Base ShaderGUI implementation for all MMD custom material inspectors.
    /// Provides shared UI, data handling, and rule application.
    /// </summary>
    public abstract class MMDMaterialCustomInspectorBase : ShaderGUI
    {
        #region === Context ===

        /// <summary>
        /// Reference to Unity's MaterialEditor used to draw standard controls.
        /// </summary>
        protected MaterialEditor materialEditor;

        /// <summary>
        /// Cached array of material properties provided by Unity.
        /// </summary>
        protected MaterialProperty[] properties;

        /// <summary>
        /// All selected targets in the inspector.
        /// Usually contains one or more Materials.
        /// </summary>
        protected Object[] targets;

        #endregion

        #region === MMD Custom Data ===

        /// <summary>
        /// Shared ScriptableObject storing MMD-specific metadata.
        /// </summary>
        protected CustomMMDData mmdData;

        /// <summary>
        /// Cached Japanese material name.
        /// </summary>
        protected string nameJP;

        /// <summary>
        /// Cached English material name.
        /// </summary>
        protected string nameEN;

        /// <summary>
        /// Cached memo text.
        /// </summary>
        protected string memo;

        /// <summary>
        /// Indicates whether Unity's default material inspector should be shown.
        /// </summary>
        protected bool showDefault;

        #endregion

        #region === Unity Callbacks ===

        /// <summary>
        /// Main entry point for drawing the material inspector UI.
        /// </summary>
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            // Cache references provided by Unity.
            this.materialEditor = materialEditor;
            this.properties = properties;
            this.targets = materialEditor.targets;

            EnsureCustomDataLoaded(); // Ensure custom MMD data is loaded and valid.
            EnsureUndoHook(); // Ensure Undo/Redo callback is registered.

            EditorGUI.BeginChangeCheck(); // Begin tracking changes in the inspector.

            // Draw the MMD header section.
            HeaderGroupGUI.DrawGroup(new GUIContent("MMD Data", "Stores metadata used by MMD, such as material names and memos."), () => DrawHeaderUI());

            GUIContent label = new("Surface Options", "Controls how URP Renders the material on screen.");

            if (!showDefault)
            {
                DrawUI(); // Draw custom MMD-specific UI.

                // Draw shared URP surface options.
                HeaderGroupGUI.DrawGroup(label, () => MaterialUtility.DrawSurfaceOptions(properties));

                // Draw advanced rendering options.
                HeaderGroupGUI.DrawGroup(new GUIContent("Advanced Options", "These settings affect behind-the-scenes rendering and underlying calculations."), () =>
                {
                    materialEditor.RenderQueueField();
                    materialEditor.EnableInstancingField();
                    materialEditor.DoubleSidedGIField();
                    MaterialUtility.RenderLightmapFlags(targets.OfType<Material>().ToArray());
                });
            }
            else
            {
                // Show only Unity's default surface options.
                HeaderGroupGUI.DrawGroup(label, () => MaterialUtility.DrawSurfaceOptions(properties));

                // Fallback to Unity's default inspector.
                HeaderGroupGUI.DrawGroup(new GUIContent("Default GUI", "Fallback default Unity material inspector, used when Show Default Systems is enabled."), () =>
                {
                    base.OnGUI(materialEditor, properties);
                    MaterialUtility.RenderLightmapFlags(targets.OfType<Material>().ToArray());
                });
            }

            // Apply rules only if something changed.
            if (EditorGUI.EndChangeCheck())
            {
                MaterialUtility.CheckBlendingMode(properties); // Synchronize blending mode related properties.
                ApplyCommonRules(); // Apply shared rendering rules.
                ApplyShaderSpecificRules(); // Apply shader-specific rules.
            }
        }

        #endregion

        #region === Undo / Redo ===

        /// <summary>
        /// Ensures Undo/Redo callback is registered exactly once.
        /// </summary>
        protected void EnsureUndoHook()
        {
            Undo.undoRedoPerformed -= OnUndoRedo; // Remove previous registration to avoid duplicates.
            Undo.undoRedoPerformed += OnUndoRedo; // Register Undo/Redo callback.
        }

        /// <summary>
        /// Forces inspector repaint and reloads cached data on Undo/Redo.
        /// </summary>
        protected void OnUndoRedo()
        {
            mmdData = null; // Clear cached data so it is reloaded.

            // Repaint the inspector if available.
            if (materialEditor != null) materialEditor.Repaint();

            // Force editor refresh in case focus was lost.
            EditorApplication.QueuePlayerLoopUpdate();
            SceneView.RepaintAll();
        }

        #endregion

        #region === Header UI ===

        /// <summary>
        /// Draws the MMD header UI including names and system toggle.
        /// </summary>
        protected virtual void DrawHeaderUI()
        {
            GUILayout.BeginHorizontal();

            // Toggle label for default inspector mode.
            GUILayout.Label(new GUIContent("Show Default Systems", "When enabled, the inspector will display Unity's default material controls instead of the custom MMD-specific options."), EditorStyles.boldLabel);

            EditorGUI.BeginChangeCheck();
            bool newShowDefault = EditorGUILayout.Toggle(showDefault);

            // Handle toggle changes.
            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObject(mmdData, "Toggle Show Default Systems");

                foreach (var t in targets)
                {
                    if (t is not Material mat) continue;

                    // Reload current data.
                    MaterialUtility.LoadData(mmdData, mat, out string jp, out string en, out string m, out _);

                    // Save updated flag.
                    MaterialUtility.SaveData(mmdData, mat, jp, en, m, newShowDefault);
                }

                EditorUtility.SetDirty(mmdData);
                showDefault = newShowDefault;
            }

            GUILayout.EndHorizontal();

            GUILayout.Space(5f);

            EditorGUILayout.BeginHorizontal();

            // Draw Japanese and English material name fields.
            DrawMixedMaterialStringField(new GUIContent("Mat-Name (JP)", "Japanese material name used by MMD."), isJP: true, ref nameJP, width: 100f);
            DrawMixedMaterialStringField(new GUIContent("(EN)", "English material name for readability."), isJP: false, ref nameEN, width: 30f);

            EditorGUILayout.EndHorizontal();

            GUILayout.Space(10f);
        }

        #endregion

        #region === Memo UI ===

        /// <summary>
        /// Draws the memo field stored in CustomMMDData.
        /// Fully multi-object safe and Undo-safe.
        /// </summary>
        protected void DrawMemoData()
        {
            bool hasMixedValue = false;

            // Detect mixed memo values across selected materials.
            for (int i = 1; i < targets.Length; i++)
            {
                if (targets[i] is not Material mat) continue;

                MaterialUtility.LoadData(mmdData, mat, out _, out _, out string m, out _);

                if (m != memo)
                {
                    hasMixedValue = true;
                    break;
                }
            }

            EditorGUILayout.BeginHorizontal();

            // Memo label.
            GUILayout.Label(new GUIContent("Memo:", "Optional notes or descriptions about this material, stored in CustomMMDData."), EditorStyles.boldLabel, GUILayout.Width(50f));

            // Enable mixed-value state if needed.
            EditorGUI.showMixedValue = hasMixedValue;
            EditorGUI.BeginChangeCheck();

            string newMemo = EditorGUILayout.TextArea(memo, GUILayout.Height(80f)); // Editable memo text area.

            EditorGUI.showMixedValue = false; // Reset mixed-value state.

            // Apply changes.
            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObject(mmdData, "Change MMD Memo");

                foreach (var t in targets)
                {
                    if (t is not Material mat) continue;

                    MaterialUtility.LoadData(mmdData, mat, out string jp, out string en, out _, out bool sd);
                    MaterialUtility.SaveData(mmdData, mat, jp, en, newMemo, sd);
                }

                EditorUtility.SetDirty(mmdData);
                memo = newMemo;
            }

            EditorGUILayout.EndHorizontal();
        }

        #endregion

        #region === Mixed String Field ===

        /// <summary>
        /// Draws a mixed-value-aware string field backed by CustomMMDData.
        /// Fully Undo-safe and multi-object safe.
        /// </summary>
        protected void DrawMixedMaterialStringField(GUIContent label, bool isJP, ref string cachedValue, float width = 0)
        {
            bool hasMixedValue = false;

            // Detect mixed values across selected materials.
            for (int i = 1; i < targets.Length; i++)
            {
                if (targets[i] is not Material mat) continue;

                MaterialUtility.LoadData(mmdData,mat, out string jp, out string en, out _, out _);

                if ((isJP ? jp : en) != cachedValue)
                {
                    hasMixedValue = true;
                    break;
                }
            }

            // Draw label with optional width.
            if (width > 0)
            {
                GUILayout.Label(label, EditorStyles.boldLabel, GUILayout.Width(width));
            }
            else
            {
                GUILayout.Label(label, EditorStyles.boldLabel);
            }

            EditorGUI.showMixedValue = hasMixedValue;
            EditorGUI.BeginChangeCheck();

            string newValue = EditorGUILayout.TextField(cachedValue); // Editable text field.

            EditorGUI.showMixedValue = false;

            // Apply changes.
            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObject(mmdData, $"Change {label.text}");

                foreach (var t in targets)
                {
                    if (t is not Material mat) continue;

                    MaterialUtility.LoadData(mmdData, mat, out string jp, out string en, out string m, out bool sd);
                    MaterialUtility.SaveData(mmdData, mat, isJP ? newValue : jp, isJP ? en : newValue, m, sd);
                }

                EditorUtility.SetDirty(mmdData);
                cachedValue = newValue;
            }
        }

        #endregion

        #region === Custom UI ===
        
        /// <summary>
        /// Draws shader-specific custom UI.
        /// Override in derived inspectors.
        /// </summary>
        protected virtual void DrawUI() { }

        #endregion

        #region === Rules ===

        /// <summary>
        /// Applies shared rendering rules.
        /// Override when needed.
        /// </summary>
        protected virtual void ApplyCommonRules() { }

        /// <summary>
        /// Applies shader-specific rendering rules.
        /// Override when needed.
        /// </summary>
        protected virtual void ApplyShaderSpecificRules() { }

        #endregion

        #region === Custom Data Handling ===

        /// <summary>
        /// Loads or creates CustomMMDData and initializes cached values.
        /// </summary>
        protected void EnsureCustomDataLoaded()
        {
            if (mmdData != null) return; // Avoid reloading if already cached.

            mmdData = CustomMMDDataUtilityEditor.GetOrCreateCustomMMDData(); // Load or create shared MMD data asset.
            CustomMMDDataUtilityEditor.RemoveInvalidMaterials(mmdData); // Remove invalid material references.

            // Load initial values from the first selected material.
            if (targets.Length > 0 && targets[0] is Material mat)
            {
                MaterialUtility.LoadData(mmdData, mat, out nameJP, out nameEN, out memo, out showDefault);
            }
        }

        #endregion
    }
}