/*
 * ---------------------------------------------------------------------------
 * Description: This Unity component provides an editor-only object visibility management tool
 *              designed to streamline scene organization, debugging, and workflow control.
 * 
 *              It allows developers to register multiple GameObjects and toggle their active
 *              state individually or collectively directly from a custom inspector UI.
 *              Objects can be added via drag-and-drop, removed safely with undo support, and
 *              optionally hidden from the Inspector to reduce visual clutter.
 * 
 *              The component is strictly editor-facing. In non-editor builds, it automatically
 *              destroys itself at runtime to ensure zero overhead in production environments.
 * 
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
 */

using UnityEngine;

#if UNITY_EDITOR
using System.Linq;
using UnityEditor;
using System;
#endif

namespace MMDCollection
{
    [AddComponentMenu("MMD Collection/Tools/Scene/Manage Objects")]
    public class ManageObjects : MonoBehaviour
    {
    #if UNITY_EDITOR

        #region === Serialized Fields ===

        [Tooltip("List of managed GameObjects and their current visibility states.")]
        public ManageObjectsItem[] manageObjects = Array.Empty<ManageObjectsItem>();

        [HideInInspector, Tooltip("Global visibility state applied when toggling all managed objects.")]
        public bool GlobalState;

        [HideInInspector, Tooltip("If enabled, hides the managed object list from the custom inspector UI.")]
        public bool HideObjects;

        [HideInInspector, Tooltip("If enabled, hides the default MonoBehaviour inspector.")]
        public bool HideDefaultInspector = true;

        #endregion

        #region === Public API ===

        /// <summary>
        /// Toggles the active state of a single managed GameObject.
        /// </summary>
        /// <param name="index">Index of the managed object in the list.</param>
        public void ToggleObject(int index)
        {
            if (!IsValidIndex(index)) return; // Validate index and object reference before proceeding.

            var item = manageObjects[index];

            // Record undo operations for both the component and the target GameObject.
            Undo.RecordObject(this, "Toggle Managed Object State");
            Undo.RecordObject(item.gameObject, $"Toggle {item.gameObject.name}");

            // Toggle cached state and apply it to the GameObject.
            item.state = !item.state;
            item.gameObject.SetActive(item.state);
        }

        /// <summary>
        /// Toggles the active state of all managed GameObjects at once.
        /// </summary>
        public void ToggleAll()
        {
            // Record undo for this component itself (GlobalState change).
            Undo.RecordObject(this, "Toggle All Managed Objects");

            // Collect only valid GameObjects to avoid null references in Undo.
            var validObjects = manageObjects.Where(item => item != null && item.gameObject != null).Select(item => item.gameObject).ToArray();

            // Record undo only if there are valid objects.
            if (validObjects.Length > 0) Undo.RecordObjects(validObjects, "Toggle All Objects");

            // Flip the global state.
            GlobalState = !GlobalState;

            // Apply the new state to every managed object.
            foreach (var item in manageObjects)
            {
                // Skip invalid or missing references safely.
                if (item == null || item.gameObject == null) continue;

                item.state = GlobalState;
                item.gameObject.SetActive(GlobalState);
            }
        }

        /// <summary>
        /// Removes a managed GameObject from the list by index.
        /// </summary>
        /// <param name="index">Index of the object to remove.</param>
        public void RemoveObject(int index)
        {
            if (!IsValidIndex(index)) return; // Validate index before attempting removal.

            Undo.RecordObject(this, $"Remove {manageObjects[index].gameObject.name}"); // Record undo operation for list modification.

            ArrayUtility.RemoveAt(ref manageObjects, index); // Remove the item from the managed list.
        }

        #endregion

        #region === Validation ===

        /// <summary>
        /// Validates whether the provided index references a valid managed object.
        /// </summary>
        /// <param name="index">Index to validate.</param>
        /// <returns>True if the index is valid and references a GameObject.</returns>
        private bool IsValidIndex(int index) => index >= 0 && index < manageObjects.Length && manageObjects[index] != null && manageObjects[index].gameObject != null;

        #endregion

    #else
        private void Start() => Destroy(this); // Automatically removes this component in non-editor builds.
    #endif
    }

#if UNITY_EDITOR

    #region === Custom Editor ===

    /// <summary>
    /// Custom inspector for the ManageObjects component with full multi-object support.
    /// </summary>
    [CanEditMultipleObjects]
    [CustomEditor(typeof(ManageObjects))]
    public sealed class ManageObjectsEditor : Editor
    {
        /// <summary>
        /// Draws the custom inspector GUI with proper multi-object handling.
        /// </summary>
        public override void OnInspectorGUI()
        {
            var scripts = targets.Cast<ManageObjects>().ToArray();

            DrawDropArea(scripts); // Draw drag-and-drop area for registering GameObjects.

            EditorGUILayout.Space(10f);

            // Check if selected components have different GlobalState values.
            bool hasMixedValues = scripts.Select(s => s.GlobalState).Distinct().Count() > 1;

            // Set background color based on state.
            GUI.backgroundColor = hasMixedValues ? Color.yellow : scripts[0].GlobalState ? Color.green : Color.red;

            // Draw global toggle button.
            var content = new GUIContent("Toggle All Managed Objects", "Toggles all registered GameObjects in every selected component.");

            if (GUILayout.Button(content, GUILayout.Height(35)))
            {
                foreach (var script in scripts) script.ToggleAll();
            }

            GUI.backgroundColor = Color.white;

            EditorGUILayout.Space(10f);

            EditorGUILayout.BeginHorizontal();

            // Toggle to hide or show the managed object list.
            DrawBooleanMultiToggle(scripts, s => s.HideObjects, (s, v) => s.HideObjects = v, "Hide Object List", "If enabled, hides the managed object list UI.");

            EditorGUILayout.Space(10f);

            // Toggle to hide or show the default inspector.
            DrawBooleanMultiToggle(scripts, s => s.HideDefaultInspector, (s, v) => s.HideDefaultInspector = v, "Hide Default Inspector", "If enabled, hides the default MonoBehaviour inspector.");

            EditorGUILayout.EndHorizontal();

            // If multiple objects are selected, do not attempt to draw object lists.
            if (scripts.Length == 1)
            {
                var script = scripts[0];

                // Draw managed object list if enabled.
                if (!script.HideObjects)
                {
                    EditorGUILayout.Space(10f);
                    DrawObjectList(script);
                }

                // Draw default inspector if enabled.
                if (!script.HideDefaultInspector)
                {
                    EditorGUILayout.Space(10f);
                    DrawDefaultInspector();
                }
            }
            else
            {
                EditorGUILayout.Space(10f);
                GUI.color = Color.yellow;
                EditorGUILayout.HelpBox("Object list editing is disabled when multiple ManageObjects components are selected.", MessageType.Warning);
                GUI.color = Color.white;
            }
        }

        #region === UI Sections ===

        /// <summary>
        /// Draws the list of managed objects with toggle and remove controls.
        /// </summary>
        /// <param name="script">Target ManageObjects component.</param>
        private void DrawObjectList(ManageObjects script)
        {
            if (script.manageObjects.Length == 0)
            {
                EditorGUILayout.HelpBox("No managed objects registered.", MessageType.Info);
                return;
            }

            for (int i = 0; i < script.manageObjects.Length; i++)
            {
                var item = script.manageObjects[i];
                if (item.gameObject == null) continue;

                EditorGUILayout.BeginHorizontal();

                // Change button color based on active state.
                GUI.backgroundColor = item.state ? Color.green : Color.red;

                if (GUILayout.Button(new GUIContent(item.gameObject.name, "Toggle this GameObject.")))
                {
                    script.ToggleObject(i);
                }

                GUI.backgroundColor = Color.white;

                if (GUILayout.Button(new GUIContent("X", "Remove this object."), GUILayout.Width(22)))
                {
                    script.RemoveObject(i);
                    break;
                }

                EditorGUILayout.EndHorizontal();
            }
        }

        #endregion

        #region === Helpers ===

        /// <summary>
        /// Draws a boolean toggle that correctly supports mixed values across multiple targets.
        /// </summary>
        private void DrawBooleanMultiToggle(ManageObjects[] scripts, Func<ManageObjects, bool> getter, Action<ManageObjects, bool> setter, string label, string tooltip)
        {
            // Determine whether selected objects have different values.
            bool hasMixedValues = scripts.Select(getter).Distinct().Count() > 1;

            // Enable Unity mixed-value visual state.
            EditorGUI.showMixedValue = hasMixedValues;

            // Begin change detection.
            EditorGUI.BeginChangeCheck();

            // Draw the toggle using the first object's value as reference.
            bool newValue = EditorGUILayout.Toggle(new GUIContent(label, tooltip), getter(scripts[0]));

            // Reset mixed state immediately after drawing the control.
            EditorGUI.showMixedValue = false;

            // If the user did not interact with the toggle, exit early.
            if (!EditorGUI.EndChangeCheck()) return;

            // Register undo for all selected objects.
            Undo.RecordObjects(scripts, $"Toggle {label}");

            // Apply the new value to all targets.
            foreach (var script in scripts) setter(script, newValue);
        }

        #endregion

        #region === Drag & Drop ===

        /// <summary>
        /// Draws the drag-and-drop area and registers GameObjects on all selected components.
        /// </summary>
        /// <param name="script">Target ManageObjects component.</param>
        private void DrawDropArea(ManageObjects[] scripts)
        {
            GUIStyle centeredStyle = new(EditorStyles.helpBox)
            {
                alignment = TextAnchor.MiddleCenter,
                fontStyle = FontStyle.Bold,
                fontSize = 20
            };

            Rect dropArea = GUILayoutUtility.GetRect(0f, 50f, GUILayout.ExpandWidth(true));
            GUI.Box(dropArea, new GUIContent("Drag & Drop GameObjects Here", "Adds objects to all selected components."), centeredStyle);

            var evt = Event.current;

            if (!dropArea.Contains(evt.mousePosition)) return; // Ignore events outside the drop area.

            if (evt.type == EventType.DragUpdated || evt.type == EventType.DragPerform)
            {
                DragAndDrop.visualMode = DragAndDropVisualMode.Copy;

                if (evt.type == EventType.DragPerform)
                {
                    DragAndDrop.AcceptDrag();

                    Undo.RecordObjects(scripts, "Add Managed Objects");

                    // Add dragged GameObjects if they are not already registered.
                    foreach (var obj in DragAndDrop.objectReferences.OfType<GameObject>())
                    {
                        foreach (var script in scripts)
                        {
                            if (script.manageObjects.Any(o => o.gameObject == obj)) continue;

                            ArrayUtility.Add(ref script.manageObjects, new ManageObjectsItem
                            {
                                gameObject = obj,
                                state = obj.activeSelf
                            });
                        }
                    }
                }

                evt.Use();
            }
        }

        #endregion
    }

    #endregion

    #region === Data Model ===

    /// <summary>
    /// Serializable data container representing a managed GameObject and its state.
    /// </summary>
    [Serializable]
    public sealed class ManageObjectsItem
    {
        [Tooltip("Managed GameObject reference.")]
        public GameObject gameObject;

        [Tooltip("Current active state of the GameObject.")]
        public bool state;
    }

    #endregion

#endif
}