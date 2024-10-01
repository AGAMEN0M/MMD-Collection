/*
 * ---------------------------------------------------------------------------
 * Description: This script provides a tool for Unity editors to clean up invalid properties from selected Material assets. 
 *              It iterates through all selected materials, compares their properties with the ones defined in their 
 *              associated shaders, and removes any properties that are no longer valid. This helps in maintaining the 
 *              integrity and performance of materials by eliminating unnecessary or obsolete properties.
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEditor;

public class MaterialPropertyCleaner : MonoBehaviour
{
    [MenuItem("Assets/MMD Collection/Clean Invalid Material Properties")]
    public static void CleanMaterialProperties()
    {
        // Display a dialog to confirm the action.
        if (!EditorUtility.DisplayDialog(
            "Confirm Material Clean",
            "Are you sure you want to clear invalid properties from the selected material?\nThis operation cannot be undone.",
            "Yes",
            "No"))
        {
            return; // If the user clicks "No", exit the method.
        }

        // Loop through all selected objects in the Unity editor.
        foreach (Object selectedObject in Selection.objects)
        {
            // Check if the selected object is a Material.
            if (selectedObject is Material material)
            {
                Shader shader = material.shader;

                // If the material does not have a shader, log an error and continue to the next selected object.
                if (shader == null)
                {
                    Debug.LogError($"The material '{material.name}' does not have a shader.");
                    continue; // Skip to the next selected object.
                }

                // Record the material state for Undo.
                Undo.RecordObject(material, "Clean Invalid Material Properties");

                // List of properties we will maintain.
                var validProperties = new HashSet<string>();

                // Iterates through the shader properties and adds them to the list of valid properties.
                for (int i = 0; i < ShaderUtil.GetPropertyCount(shader); i++)
                {
                    string propertyName = ShaderUtil.GetPropertyName(shader, i);
                    validProperties.Add(propertyName);
                }

                // Checks and removes material properties not in the shader.
                var materialSerializedObject = new SerializedObject(material);
                var savedProperties = materialSerializedObject.FindProperty("m_SavedProperties");

                // Clear properties.
                RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_TexEnvs"), validProperties);
                RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_Ints"), validProperties);
                RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_Floats"), validProperties);
                RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_Colors"), validProperties);

                // Apply changes to the material.
                materialSerializedObject.ApplyModifiedProperties();

                // Clean invalid keywords.
                CleanInvalidKeywords(material, shader);

                EditorUtility.SetDirty(material);
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
            }
            else
            {
                Debug.LogWarning($"Selected object '{selectedObject.name}' is not a material.");
            }
        }
    }

    // This method removes properties that are not valid from the material.
    private static void RemoveInvalidProperties(SerializedProperty properties, HashSet<string> validProperties)
    {
        // Loop through the properties in reverse order and remove any that are not in the validProperties set.
        for (int i = properties.arraySize - 1; i >= 0; i--)
        {
            var property = properties.GetArrayElementAtIndex(i);
            string propertyName = property.FindPropertyRelative("first").stringValue;

            // If the property is not valid, remove it.
            if (!validProperties.Contains(propertyName))
            {
                properties.DeleteArrayElementAtIndex(i);
            }
        }
    }

    private static void CleanInvalidKeywords(Material material, Shader shader)
    {
        // Use reflection to access the internal 'GetShaderGlobalKeywords' method from ShaderUtil.
        var getKeywordsMethod = typeof(ShaderUtil).GetMethod("GetShaderGlobalKeywords", BindingFlags.Static | BindingFlags.NonPublic);

        if (getKeywordsMethod != null)
        {
            // Get the keywords currently assigned to the material.
            string[] materialKeywords = material.shaderKeywords;

            // Retrieve global shader keywords.
            string[] globalKeywords = (string[])getKeywordsMethod.Invoke(null, new object[] { shader });

            // Create a HashSet for quick look-up of valid keywords.
            HashSet<string> validKeywords = new(globalKeywords);

            // List to keep track of removed keywords.
            List<string> removedKeywords = new();

            // Loop through the material's keywords and disable the invalid ones.
            foreach (string keyword in materialKeywords)
            {
                if (!validKeywords.Contains(keyword))
                {
                    material.DisableKeyword(keyword); // Disable invalid keyword.
                    removedKeywords.Add(keyword); // Add to the removed keywords list.
                }
            }

            // Log removed keywords if any were found.
            if (removedKeywords.Count > 0)
            {
                Debug.Log($"Removed invalid keywords from material '{material.name}': {string.Join(", ", removedKeywords)}");
            }
        }
        else
        {
            // Log an error if the ShaderUtil method cannot be found.
            Debug.LogError("Failed to retrieve global shader keywords. ShaderUtil method not found.");
        }
    }
}