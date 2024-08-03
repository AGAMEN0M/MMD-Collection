using UnityEngine;
using System.Linq;

#if UNITY_EDITOR
using UnityEditor;
#endif

[AddComponentMenu("MMD Collection/Manage Objects")]
public class ManageObjects : MonoBehaviour
{
#if UNITY_EDITOR
    // Array of ManageObjectsList items to hold game objects and their states.
    public ManageObjectsList[] manageObjects = new ManageObjectsList[0];

    [HideInInspector] public bool state = false;        // State to toggle visibility of all objects.
    [HideInInspector] public bool hide = false;         // Whether to hide objects in the inspector.
    [HideInInspector] public bool hideInspector = true; // Whether to hide the default inspector.

    // Toggles the visibility of a specific object in the list.
    public void Toggle(int i)
    {
        Undo.RecordObject(this, $"Toggle Visibility of Object"); // Record action for undo.
        Undo.RecordObject(manageObjects[i].gameObjects, $"Toggle Object - {manageObjects[i].gameObjects.name}");
        manageObjects[i].objectState = !manageObjects[i].objectState; // Toggle state.
        manageObjects[i].gameObjects.SetActive(manageObjects[i].objectState); // Apply state to the GameObject.
    }

    public void ToggleAll()
    {
        Undo.RecordObject(this, "Toggle Visibility of All Objects"); // Record action for undo.
        Undo.RecordObjects(manageObjects.Select(m => m.gameObjects).ToArray(), "Toggle All Objects Visibility");
        state = !state; // Toggle the global state.

        foreach (var item in manageObjects)
        {
            item.objectState = state; // Set the state for each object.
            item.gameObjects.SetActive(state); // Apply the state to the GameObject.
        }
    }

    // Removes an object from the list by index.
    public void RemoveItem(int i)
    {
        if (i >= 0 && i < manageObjects.Length)
        {
            // Record action for undo.
            Undo.RecordObject(this, $"Remove Object {manageObjects[i].gameObjects.name} from List");
            ArrayUtility.RemoveAt(ref manageObjects, i); // Remove item from the array.
        }
    }
#endif
}

#if UNITY_EDITOR
[CustomEditor(typeof(ManageObjects))]
public class ManageObjectsEditor : Editor
{
    public override void OnInspectorGUI()
    {
        serializedObject.Update();
        ManageObjects script = (ManageObjects)target;

        script.manageObjects ??= new ManageObjectsList[0]; // Initialize manageObjects if null.

        EditorGUILayout.Space(10f);

        EditorGUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        // Button to toggle visibility of all objects.
        if (GUILayout.Button($"Toggle All ({script.state})", GUILayout.Width(150), GUILayout.Height(40)))
        {
            script.ToggleAll();
        }
        GUILayout.FlexibleSpace();

        EditorGUILayout.Space(10f);

        GUILayout.FlexibleSpace();
        DrawObjectBox(script); // Draw the drag-and-drop area for adding objects.
        GUILayout.FlexibleSpace();
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space(10f);

        EditorGUILayout.LabelField("Objects Settings", EditorStyles.boldLabel);

        EditorGUILayout.Space(5f);

        EditorGUILayout.BeginHorizontal();
        // Toggle to hide or show objects in the inspector.
        bool newHide = EditorGUILayout.Toggle("Hide Objects:", script.hide);
        if (newHide != script.hide)
        {
            Undo.RecordObject(script, $"Set Hide to {newHide}"); // Record action for undo.
            script.hide = newHide;
        }

        EditorGUILayout.Space(10f);

        // Toggle to hide or show the default inspector.
        bool newHideInspector = EditorGUILayout.Toggle("Hide Default Inspector:", script.hideInspector);
        if (newHideInspector != script.hideInspector)
        {
            Undo.RecordObject(script, $"Set Hide Inspector to {newHideInspector}"); // Record action for undo.
            script.hideInspector = newHideInspector;
        }
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space(5f);

        // Draw buttons for toggling individual objects if not hidden.
        if (!script.hide)
        {
            DrawDisplayButtons(script);
        }

        EditorGUILayout.Space(15f);

        // Draw the default inspector if not hidden.
        if (!script.hideInspector)
        {
            DrawDefaultInspector();
        }

        serializedObject.ApplyModifiedProperties();
    }

    // Draws buttons for each object to toggle visibility or remove it from the list.
    private void DrawDisplayButtons(ManageObjects script)
    {
        if (script.manageObjects.Length > 0)
        {
            bool objectsFound = false;

            for (int i = 0; i < script.manageObjects.Length; i++)
            {
                if (script.manageObjects[i].gameObjects != null)
                {
                    objectsFound = true;
                    Color defaultColor = GUI.backgroundColor;

                    EditorGUILayout.BeginHorizontal();

                    // Set button color based on object state.
                    GUI.backgroundColor = script.manageObjects[i].objectState ? Color.green : Color.red;

                    // Button to toggle visibility of the object.
                    if (GUILayout.Button($"Toggle: {script.manageObjects[i].gameObjects.name}"))
                    {
                        script.Toggle(i);
                    }

                    GUI.backgroundColor = defaultColor;

                    // Button to remove the object from the list.
                    if (GUILayout.Button("-", GUILayout.Width(20), GUILayout.Height(20)))
                    {
                        script.RemoveItem(i);
                        break;
                    }

                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.Space(5f);
                }
            }

            if (!objectsFound)
            {
                EditorGUILayout.HelpBox("No objects found.", MessageType.Warning);
            }
        }
        else
        {
            EditorGUILayout.HelpBox("No objects found.", MessageType.Warning);
        }
    }

    // Draws a box for dragging and dropping GameObjects.
    private void DrawObjectBox(ManageObjects script)
    {
        EditorGUILayout.BeginVertical(GUI.skin.box);
        Event evt = Event.current;
        Rect dropArea = GUILayoutUtility.GetRect(145, 35, GUILayout.Width(145), GUILayout.Height(35));

        GUIStyle centeredStyle = new (EditorStyles.helpBox)
        {
            alignment = TextAnchor.MiddleCenter
        };

        GUI.Box(dropArea, "Drop Objects Here", centeredStyle);

        switch (evt.type)
        {
            case EventType.DragUpdated:
            case EventType.DragPerform:
                if (!dropArea.Contains(evt.mousePosition))
                {
                    break;
                }

                DragAndDrop.visualMode = DragAndDropVisualMode.Copy;

                if (evt.type == EventType.DragPerform)
                {
                    DragAndDrop.AcceptDrag();

                    // Add each dragged GameObject to the list if not already present.
                    foreach (Object draggedObject in DragAndDrop.objectReferences)
                    {
                        GameObject gameObject = draggedObject as GameObject;
                        if (gameObject != null && !IsObjectInList(script, gameObject))
                        {
                            Undo.RecordObject(script, $"Add Object {gameObject.name} to List"); // Record action for undo.
                            ArrayUtility.Add(ref script.manageObjects, new ManageObjectsList { gameObjects = gameObject, objectState = gameObject.activeSelf });
                        }
                    }
                }
                Event.current.Use();
                break;
        }

        EditorGUILayout.EndVertical();
    }

    // Checks if the GameObject is already in the list.
    private bool IsObjectInList(ManageObjects script, GameObject gameObject)
    {
        foreach (var item in script.manageObjects)
        {
            if (item.gameObjects == gameObject)
            {
                return true;
            }
        }
        return false;
    }
}

[System.Serializable]
public class ManageObjectsList
{
    public GameObject gameObjects; // Reference to the GameObject.
    public bool objectState; // State to manage the visibility of the GameObject.
}
#endif