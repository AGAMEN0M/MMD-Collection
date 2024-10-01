/*
 * ---------------------------------------------------------------------------
 * Description: This script checks for global shader keywords in selected materials.
 *              It provides a menu item in Unity's Asset context menu to perform this check.
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/
using UnityEngine;
using UnityEditor;
using System.Reflection;

public class ShaderKeywordChecker
{
    // Adds a menu item under "Assets/MMD Collection" to check shader keywords.
    [MenuItem("Assets/MMD Collection/Check Shader Keywords")]
    public static void CheckShaderKeywords()
    {
        // Iterate through all selected objects in the Unity editor.
        foreach (Object selectedObject in Selection.objects)
        {
            // Check if the selected object is a material.
            if (selectedObject is Material material)
            {
                Shader shader = material.shader;

                // If the material does not have an associated shader, log an error.
                if (shader == null)
                {
                    Debug.LogError($"The material '{material.name}' does not have a shader.");
                    continue;
                }

                // Call the method to check for global shader keywords.
                CheckGlobalShaderKeywords(shader);
            }
            else
            {
                // Warn if the selected object is not a material.
                Debug.LogWarning($"Selected object '{selectedObject.name}' is not a material.");
            }
        }
    }

    // Method to check for global shader keywords of a given shader.
    private static void CheckGlobalShaderKeywords(Shader shader)
    {
        // Use reflection to access the internal 'GetShaderGlobalKeywords' method from ShaderUtil.
        var getKeywordsMethod = typeof(ShaderUtil).GetMethod("GetShaderGlobalKeywords", BindingFlags.Static | BindingFlags.NonPublic);

        // If the method is found, retrieve and log the global shader keywords.
        if (getKeywordsMethod != null)
        {
            string[] globalKeywords = (string[])getKeywordsMethod.Invoke(null, new object[] { shader });
            Debug.Log($"Global keywords for shader '{shader.name}': {string.Join(", ", globalKeywords)}");
        }
        else
        {
            // Log an error if the ShaderUtil method cannot be found.
            Debug.LogError("Failed to retrieve global shader keywords. ShaderUtil method not found.");
        }
    }
}