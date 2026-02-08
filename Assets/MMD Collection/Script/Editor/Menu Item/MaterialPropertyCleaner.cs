/*
 * ---------------------------------------------------------------------------
 * Description: This script provides a tool for Unity editors to clean up invalid properties from selected Material assets. 
 *              It removes obsolete material properties and invalid shader keywords to maintain material integrity.
 *              
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEditor;

/// <summary>
/// Utility class to clean invalid material properties and keywords.
/// </summary>
public static class MaterialPropertyCleaner
{
    #region === Cached Reflection ===

    // Cached reference to ShaderUtil.GetShaderGlobalKeywords to avoid repeated reflection calls.
    private static MethodInfo getShaderGlobalKeywordsMethod;

    #endregion

    #region === Menu Methods ===

    /// <summary>
    /// Cleans invalid properties and keywords from all selected materials.
    /// </summary>
    [MenuItem("Assets/MMD Collection/Clean Invalid Material Properties", false, 2)]
    public static void CleanMaterialProperties()
    {
        // Confirm with user before proceeding.
        if (!EditorUtility.DisplayDialog(
            "Confirm Material Clean",
            "Are you sure you want to clear invalid properties from the selected materials?\nThis operation cannot be undone.",
            "Yes",
            "No"))
        {
            return;
        }

        // Iterate through all selected objects in the editor.
        foreach (var selectedObject in Selection.objects)
        {
            if (selectedObject is Material material)
            {
                Shader shader = material.shader;

                // Skip materials without a shader.
                if (shader == null)
                {
                    Debug.LogError($"The material '{material.name}' does not have a shader assigned.", material);
                    continue;
                }

                Undo.RecordObject(material, "Clean Invalid Material Properties");

                // Gather all valid property names from the shader.
                HashSet<string> validProperties = new();
                for (int i = 0; i < shader.GetPropertyCount(); i++) validProperties.Add(shader.GetPropertyName(i));

                // Access serialized material properties.
                SerializedObject matSO = new(material);
                var savedProps = matSO.FindProperty("m_SavedProperties");

                // Remove invalid properties for textures, ints, floats, and colors.
                RemoveInvalidProperties(savedProps.FindPropertyRelative("m_TexEnvs"), validProperties);
                RemoveInvalidProperties(savedProps.FindPropertyRelative("m_Ints"), validProperties);
                RemoveInvalidProperties(savedProps.FindPropertyRelative("m_Floats"), validProperties);
                RemoveInvalidProperties(savedProps.FindPropertyRelative("m_Colors"), validProperties);

                // Apply serialized changes.
                matSO.ApplyModifiedProperties();

                // Clean invalid shader keywords.
                CleanInvalidKeywords(material, shader);

                EditorUtility.SetDirty(material);
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
            }
            else
            {
                Debug.LogWarning($"Selected object '{selectedObject.name}' is not a Material.", selectedObject);
            }
        }
    }

    #endregion

    #region === Utility Methods ===

    /// <summary>
    /// Removes invalid properties from a serialized property array based on valid property names.
    /// </summary>
    private static void RemoveInvalidProperties(SerializedProperty properties, HashSet<string> validProperties)
    {
        if (properties == null) return;

        // Loop in reverse to safely remove elements from array.
        for (int i = properties.arraySize - 1; i >= 0; i--)
        {
            var prop = properties.GetArrayElementAtIndex(i);
            string propName = prop.FindPropertyRelative("first").stringValue;

            if (!validProperties.Contains(propName)) properties.DeleteArrayElementAtIndex(i);
        }
    }

    /// <summary>
    /// Removes shader keywords from a material that are no longer valid according to its shader.
    /// </summary>
    private static void CleanInvalidKeywords(Material material, Shader shader)
    {
        if (material == null || shader == null) return;

        // Initialize cached reflection method if needed.
        if (getShaderGlobalKeywordsMethod == null)
        {
            getShaderGlobalKeywordsMethod = typeof(ShaderUtil).GetMethod("GetShaderGlobalKeywords", BindingFlags.Static | BindingFlags.NonPublic);

            if (getShaderGlobalKeywordsMethod == null)
            {
                Debug.LogError("Failed to retrieve ShaderUtil.GetShaderGlobalKeywords method. Reflection failed.");
                return;
            }
        }

        // Get global shader keywords via reflection.
        if (getShaderGlobalKeywordsMethod.Invoke(null, new object[] { shader }) is not string[] globalKeywords) return;

        HashSet<string> validKeywords = new(globalKeywords);
        List<string> removedKeywords = new();

        // Check material keywords against valid keywords.
        foreach (var keyword in material.shaderKeywords)
        {
            if (!validKeywords.Contains(keyword))
            {
                material.DisableKeyword(keyword);
                removedKeywords.Add(keyword);
            }
        }

        if (removedKeywords.Count > 0)
        {
            Debug.Log($"Removed invalid keywords from material '{material.name}': {string.Join("\n", removedKeywords)}", material);
        }
    }

    #endregion
}