/*
 * ---------------------------------------------------------------------------
 * Description: Optimized Unity editor tool to paste a selected prefab or scene object
 *              as a child of multiple selected objects. Supports name enumeration,
 *              Undo, and improved selection feedback without using internal Unity APIs.
 *              
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;

namespace MMDCollection.Editor
{
    public class PasteAsChildMultiple : EditorWindow
    {
        #region === Fields ===

        private GameObject objectToCopy; // Prefab or scene object to copy.
        private bool enumerate; // Whether to enumerate new object names.

        #endregion

        #region === Editor Window Setup ===

        /// <summary>
        /// Initializes and shows the custom editor window.
        /// </summary>
        [MenuItem("GameObject/Tools/MMD Collection/Paste as Multiple Children")]
        private static void Init()
        {
            var window = (PasteAsChildMultiple)GetWindow(typeof(PasteAsChildMultiple), true, "Paste as Multiple Children");
            window.minSize = new Vector2(350, 200);
            window.maxSize = new Vector2(350, 200);
            window.Show();
        }

        /// <summary>
        /// Defines the GUI layout of the editor window.
        /// </summary>
        private void OnGUI()
        {
            GUIStyle boldStyle = new(GUI.skin.label) { fontSize = 15, fontStyle = FontStyle.Bold };
            GUILayout.Label("Select Prefab or Scene Object to Copy", boldStyle);
            GUILayout.Space(10f);

            // Object field for selecting the prefab or scene object.
            objectToCopy = EditorGUILayout.ObjectField(new GUIContent("Object to Copy", "The GameObject (prefab or scene object) that will be duplicated."), objectToCopy, typeof(GameObject), true) as GameObject;
            enumerate = EditorGUILayout.Toggle(new GUIContent("Enumerate Names", "If enabled, adds a numeric suffix to each created object name."), enumerate);

            GUILayout.Space(30f);

            // Disable button if no object is selected.
            EditorGUI.BeginDisabledGroup(objectToCopy == null);
            if (GUILayout.Button(new GUIContent("Paste As Child", "Creates a copy of the selected object under all selected GameObjects."), GUILayout.Height(40))) PasteAsChild();
            EditorGUI.EndDisabledGroup();
        }

        #endregion

        #region === Core Functionality ===

        /// <summary>
        /// Pastes the selected prefab or scene object as a child of all selected objects.
        /// Supports Undo, name enumeration, and improved selection feedback.
        /// </summary>
        private void PasteAsChild()
        {
            var parents = Selection.gameObjects;

            if (parents.Length == 0)
            {
                Debug.LogWarning("No parent objects selected.");
                return;
            }

            if (objectToCopy == null)
            {
                Debug.LogWarning("No object selected to copy.");
                return;
            }

            List<GameObject> createdObjects = new();
            int globalCount = 1;

            Undo.IncrementCurrentGroup();
            int undoGroup = Undo.GetCurrentGroup();

            foreach (var parent in parents)
            {
                try
                {
                    GameObject newObj;

                    // Instantiate prefab or clone scene object.
                    if (PrefabUtility.IsPartOfPrefabAsset(objectToCopy))
                    {
                        newObj = PrefabUtility.InstantiatePrefab(objectToCopy) as GameObject;
                    }
                    else
                    {
                        newObj = Instantiate(objectToCopy);
                    }

                    if (newObj == null) continue;

                    Undo.RegisterCreatedObjectUndo(newObj, "Paste As Child Multiple");

                    // Parent the object and reset transform relative to parent.
                    newObj.transform.SetParent(parent.transform, false);
                    newObj.transform.SetLocalPositionAndRotation(Vector3.zero, Quaternion.identity);
                    newObj.transform.localScale = Vector3.one;

                    // Enumerate names if enabled.
                    if (enumerate) newObj.name = $"{objectToCopy.name} ({globalCount++})";

                    createdObjects.Add(newObj);

                    // Better UX: Unity auto-expands hierarchy when selecting parent + child exists.
                    Selection.activeGameObject = parent;
                    EditorGUIUtility.PingObject(newObj);
                }
                catch (Exception e)
                {
                    Debug.LogError($"Error pasting object as child: {e.Message}");
                }
            }

            // Select newly created objects in the editor.
            if (createdObjects.Count > 0) Selection.objects = createdObjects.ToArray();

            Undo.CollapseUndoOperations(undoGroup);

            Close(); // Close the editor window after pasting.
        }

        #endregion
    }
}