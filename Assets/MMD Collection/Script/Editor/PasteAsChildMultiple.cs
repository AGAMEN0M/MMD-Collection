using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System;

public class PasteAsChildMultiple : EditorWindow
{
    private GameObject objectToCopy; // The prefab or object to be copied.
    private bool enumerate; // Flag to determine whether to enumerate new object names.
    #pragma warning disable IDE0044
    private List<GameObject> newObjects = new(); // List to hold references to newly created objects.
    #pragma warning restore IDE0044

    // Initialize and show the custom editor window.
    [MenuItem("GameObject/MMD Collection/Paste as Multiple Children")]
    private static void Init()
    {
        PasteAsChildMultiple window = (PasteAsChildMultiple)GetWindow(typeof(PasteAsChildMultiple));
        window.titleContent = new GUIContent("Paste as Multiple Children");
        window.minSize = new Vector2(350, 200);
        window.maxSize = new Vector2(350, 200);
        window.Show();
    }

    // Define the GUI layout of the editor window.
    private void OnGUI()
    {
        GUIStyle boldLargeStyle = new(GUI.skin.label)
        {
            fontSize = 15,
            fontStyle = FontStyle.Bold
        };

        // Title label.
        GUILayout.Label("Select Prefab to Copy", boldLargeStyle);
        GUILayout.Space(10f);

        // Object field for selecting the prefab to copy.
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Object to Copy:", GUILayout.Width(100f));
        objectToCopy = EditorGUILayout.ObjectField(objectToCopy, typeof(GameObject), true) as GameObject;
        EditorGUILayout.EndHorizontal();
        GUILayout.Space(10f);

        // Toggle for enumeration option.
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Enumerate:", GUILayout.Width(100f));
        enumerate = EditorGUILayout.Toggle(enumerate);
        EditorGUILayout.EndHorizontal();
        GUILayout.Space(35f);

        // Disable the button if no object is selected to copy.
        EditorGUI.BeginDisabledGroup(objectToCopy == null);

        // Button to paste the object as child.
        GUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        if (GUILayout.Button("Paste As Child", GUILayout.Width(150), GUILayout.Height(40)))
        {
            PasteAsChild();
        }
        GUILayout.FlexibleSpace();
        GUILayout.EndHorizontal();

        EditorGUI.EndDisabledGroup();
    }

    // Method to paste the selected prefab as a child of selected objects.
    private void PasteAsChild()
    {
        GameObject[] selectedObjects = Selection.gameObjects;

        // Check if any objects are selected.
        if (selectedObjects.Length == 0)
        {
            Debug.LogWarning("No objects selected.");
            return;
        }

        // Check if an object is selected to copy.
        if (objectToCopy == null)
        {
            Debug.LogWarning("No object selected to copy.");
            return;
        }

        int count = 1;

        // Loop through each selected object and paste the prefab as a child.
        foreach (GameObject selectedObject in selectedObjects)
        {
            try
            {
                GameObject newObject = PrefabUtility.InstantiatePrefab(objectToCopy) as GameObject;
                if (newObject != null)
                {
                    // Set the new object's parent to the selected object and reset its transform.
                    newObject.transform.parent = selectedObject.transform;
                    newObject.transform.SetLocalPositionAndRotation(Vector3.zero, Quaternion.identity);
                    newObject.transform.localScale = Vector3.one;

                    // Enumerate the name if the option is selected.
                    if (enumerate)
                    {
                        newObject.name = $"{objectToCopy.name} ({count++})";
                    }

                    // Register the undo operation for the new object.
                    Undo.RegisterCreatedObjectUndo(newObject, "Paste As Child Multiple");

                    newObjects.Add(newObject); // Add the new object to the list.
                    ExpandHierarchy(selectedObject); // Expand the hierarchy to show the new child object.
                }
                else
                {
                    Debug.LogError("Failed to paste object as child.");
                }
            }
            catch (Exception e)
            {
                Debug.LogError($"Error pasting object as child: {e.Message}");
            }
        }

        // Select the newly created objects in the editor.
        if (newObjects.Count > 0)
        {
            Selection.objects = newObjects.ToArray();
        }

        Close(); // Close the editor window.
    }

    // Method to expand the hierarchy view in the editor.
    private void ExpandHierarchy(GameObject obj)
    {
        try
        {
            // Use reflection to access the SceneHierarchyWindow class and its methods.
            var type = typeof(EditorWindow).Assembly.GetType("UnityEditor.SceneHierarchyWindow");
            var hierarchyWindow = GetWindow(type);
            var expandMethod = type.GetMethod("SetExpandedRecursive");

            // Invoke the method to expand the hierarchy recursively.
            if (hierarchyWindow != null && expandMethod != null)
            {
                expandMethod.Invoke(hierarchyWindow, new object[] { obj.GetInstanceID(), true });
            }
        }
        catch (Exception e)
        {
            Debug.LogError($"Error expanding hierarchy: {e.Message}");
        }
    }
}