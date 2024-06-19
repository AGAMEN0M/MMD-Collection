using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

public class PasteAsChildMultiple : EditorWindow
{
    private GameObject objectToCopy;
    private bool enumerate;
    #pragma warning disable IDE0044
    private List<GameObject> newObjects = new();
    #pragma warning restore IDE0044

    [MenuItem("GameObject/Paste as Multiple Children")]
    private static void Init()
    {
        PasteAsChildMultiple window = (PasteAsChildMultiple)GetWindow(typeof(PasteAsChildMultiple));
        window.titleContent = new GUIContent("Paste as Multiple Children");
        window.minSize = new Vector2(350, 200);
        window.maxSize = new Vector2(350, 200);
        window.Show();
    }

    private void OnGUI()
    {
        GUIStyle boldLargeStyle = new(GUI.skin.label)
        {
            fontSize = 15,
            fontStyle = FontStyle.Bold
        };

        GUILayout.Label("Select Prefab to Copy", boldLargeStyle);

        GUILayout.Space(10f);

        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Object to Copy:", GUILayout.Width(100f));
        objectToCopy = EditorGUILayout.ObjectField(objectToCopy, typeof(GameObject), true) as GameObject;
        EditorGUILayout.EndHorizontal();

        GUILayout.Space(10f);

        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Enumerate:", GUILayout.Width(100f));
        enumerate = EditorGUILayout.Toggle(enumerate);
        EditorGUILayout.EndHorizontal();

        GUILayout.Space(35f);

        EditorGUI.BeginDisabledGroup(objectToCopy == null);

        GUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        if (GUILayout.Button("Paste As Child", GUILayout.Width(150), GUILayout.Height(40)))
        {
            PasteAsChild();
        }
        GUILayout.FlexibleSpace();
        GUILayout.EndHorizontal();
    }

    private void PasteAsChild()
    {
        GameObject[] selectedObjects = Selection.gameObjects;

        if (selectedObjects.Length == 0)
        {
            Debug.LogWarning("No objects selected.");
            return;
        }

        if (objectToCopy == null)
        {
            Debug.LogWarning("No object selected to copy.");
            return;
        }

        int count = 1;

        foreach (GameObject selectedObject in selectedObjects)
        {
            GameObject newObject = PrefabUtility.InstantiatePrefab(objectToCopy) as GameObject;
            if (newObject != null)
            {
                newObject.transform.parent = selectedObject.transform;
                newObject.transform.SetLocalPositionAndRotation(Vector3.zero, Quaternion.identity);
                newObject.transform.localScale = Vector3.one;

                if (enumerate)
                {
                    newObject.name = $"{objectToCopy.name} ({count++})";
                }

                Undo.RegisterCreatedObjectUndo(newObject, "Paste As Child Multiple");

                newObjects.Add(newObject);

                ExpandHierarchy(selectedObject);
            }
            else
            {
                Debug.LogError("Failed to paste object as child.");
            }
        }

        if (newObjects.Count > 0)
        {
            Selection.objects = newObjects.ToArray();
        }

        Close();
    }

    private void ExpandHierarchy(GameObject obj)
    {
        var type = typeof(EditorWindow).Assembly.GetType("UnityEditor.SceneHierarchyWindow");
        var hierarchyWindow = GetWindow(type);
        var expandMethod = type.GetMethod("SetExpandedRecursive");

        if (hierarchyWindow != null && expandMethod != null)
        {
            expandMethod.Invoke(hierarchyWindow, new object[] { obj.GetInstanceID(), true });
        }
    }
}