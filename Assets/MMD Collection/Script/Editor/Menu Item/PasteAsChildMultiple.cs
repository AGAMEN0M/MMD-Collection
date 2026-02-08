/*
 * ---------------------------------------------------------------------------
 * Description: Optimized Unity editor tool to paste a selected prefab or scene object
 *              as a child of multiple selected objects. Supports name enumeration,
 *              Undo, and automatically expands hierarchy.
 *              
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;

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
    [MenuItem("GameObject/MMD Collection/Paste as Multiple Children", false, 2)]
    private static void Init()
    {
        var window = GetWindow<PasteAsChildMultiple>();
        window.titleContent = new GUIContent("Paste as Multiple Children");
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
        objectToCopy = EditorGUILayout.ObjectField("Object to Copy:", objectToCopy, typeof(GameObject), true) as GameObject;
        enumerate = EditorGUILayout.Toggle("Enumerate Names:", enumerate); // Toggle for enumerating names.

        GUILayout.Space(30f);

        // Disable button if no object is selected.
        EditorGUI.BeginDisabledGroup(objectToCopy == null);
        if (GUILayout.Button("Paste As Child", GUILayout.Height(40))) PasteAsChild();
        EditorGUI.EndDisabledGroup();
    }

    #endregion

    #region === Core Functionality ===

    /// <summary>
    /// Pastes the selected prefab or scene object as a child of all selected objects.
    /// Supports Undo, name enumeration, and hierarchy expansion.
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
                    Undo.RegisterCreatedObjectUndo(newObj, "Paste As Child Multiple");
                }

                if (newObj == null) continue;

                // Parent the object and reset transform relative to parent.
                newObj.transform.SetParent(parent.transform, false);
                newObj.transform.SetLocalPositionAndRotation(Vector3.zero, Quaternion.identity);
                newObj.transform.localScale = Vector3.one;

                // Enumerate names if enabled.
                if (enumerate) newObj.name = $"{objectToCopy.name} ({globalCount++})";

                Undo.RegisterCreatedObjectUndo(newObj, "Paste As Child Multiple");

                createdObjects.Add(newObj);
                ExpandHierarchy(parent); // Expand the hierarchy to show new child.
            }
            catch (Exception e)
            {
                Debug.LogError($"Error pasting object as child: {e.Message}");
            }
        }

        // Select newly created objects in the editor.
        if (createdObjects.Count > 0) Selection.objects = createdObjects.ToArray();

        Close(); // Close the editor window after pasting.
    }

    #endregion

    #region === Helper Methods ===

    /// <summary>
    /// Expands the hierarchy in the editor for the given GameObject.
    /// Uses reflection to access internal SceneHierarchyWindow methods.
    /// </summary>
    /// <param name="obj">The parent object whose hierarchy to expand.</param>
    private void ExpandHierarchy(GameObject obj)
    {
        try
        {
            var hierarchyType = typeof(EditorWindow).Assembly.GetType("UnityEditor.SceneHierarchyWindow");
            var window = GetWindow(hierarchyType);
            var expandMethod = hierarchyType?.GetMethod("SetExpandedRecursive");

            expandMethod?.Invoke(window, new object[] { obj.GetInstanceID(), true });
        }
        catch (Exception e)
        {
            Debug.LogError($"Error expanding hierarchy: {e.Message}");
        }
    }

    #endregion
}