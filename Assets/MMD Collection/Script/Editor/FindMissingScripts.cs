using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Linq;

// This class finds all GameObjects in the scene that have missing scripts attached.
public class FindMissingScripts : MonoBehaviour
{
    // Adds a menu item under GameObject -> MMD Collection to trigger the method.
    [MenuItem("GameObject/MMD Collection/Find Missing Scripts")]
    private static void FindAllMissingScripts()
    {
        List<GameObject> objectsWithMissingScripts = new(); // List to store GameObjects with missing scripts.
        GameObject[] allObjects = Resources.FindObjectsOfTypeAll<GameObject>(); // Find all GameObjects in the project, including those not currently loaded in the scene.

        // Iterate through all found GameObjects.
        foreach (GameObject obj in allObjects)
        {
            // Skip objects that are not part of a valid or loaded scene, or are marked to not be editable or savable.
            if (!obj.scene.IsValid() || !obj.scene.isLoaded || (obj.hideFlags & (HideFlags.NotEditable | HideFlags.HideAndDontSave)) != 0)
            {
                continue;
            }

            // Get all components attached to the current GameObject.
            Component[] components = obj.GetComponents<Component>();

            if (components == null) continue; // Skip if no components are found (shouldn't happen, but added for safety).

            if (components.Any(component => component == null))
            {
                objectsWithMissingScripts.Add(obj);
            }
        }

        Debug.Log($"Found {objectsWithMissingScripts.Count} objects with missing scripts.");
        Selection.objects = objectsWithMissingScripts.ToArray(); // Select the objects with missing scripts in the Editor.
    }
}