/*
 * ---------------------------------------------------------------------------
 * Description: This script finds all GameObjects in the Unity scene that have missing scripts attached. 
 *              It iterates through all GameObjects in the scene, checks each one for null components 
 *              (indicating missing scripts), logs the number found, and selects them in the Unity Editor.
 *              
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditor;

/// <summary>
/// Utility class to find all GameObjects in the scene with missing scripts attached.
/// </summary>
public static class FindMissingScripts
{
    #region === Menu Methods ===

    /// <summary>
    /// Finds all GameObjects in the current scene that have missing scripts and selects them in the Editor.
    /// </summary>
    [MenuItem("GameObject/MMD Collection/Find Missing Scripts", false, 1)]
    private static void FindAllMissingScripts()
    {
        List<GameObject> objectsWithMissingScripts = new(); // List to store all GameObjects with missing scripts.
        var allObjects = Resources.FindObjectsOfTypeAll<GameObject>(); // Find all GameObjects in all loaded scenes.

        // Iterate through all GameObjects.
        foreach (var obj in allObjects)
        {
            // Skip objects that are not part of a valid scene, not loaded, or are hidden/not editable.
            if (!obj.scene.IsValid() || !obj.scene.isLoaded || (obj.hideFlags & (HideFlags.NotEditable | HideFlags.HideAndDontSave)) != 0) continue;

            var components = obj.GetComponents<Component>(); // Get all components attached to the GameObject.

            if (components == null) continue; // Skip if no components are found (shouldn't happen, but added for safety).

            // If any component is null, it indicates a missing script.
            if (components != null && components.Any(c => c == null)) objectsWithMissingScripts.Add(obj);
        }

        Debug.Log($"Found {objectsWithMissingScripts.Count} GameObjects with missing scripts.");
        Selection.objects = objectsWithMissingScripts.ToArray(); // Select the objects in the Editor for easy inspection.
    }

    #endregion
}