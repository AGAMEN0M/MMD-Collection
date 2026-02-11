/*
 * ---------------------------------------------------------------------------
 * Description: This script checks for global shader keywords in selected materials.
 *              It provides a menu item in Unity's Asset context menu to perform this check.
 *              
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

using System.Reflection;
using UnityEngine;
using UnityEditor;

namespace MMDCollection.Editor
{
    public static class ShaderKeywordChecker
    {
        #region === Variables ===

        private static MethodInfo getShaderGlobalKeywordsMethod; // Cached reference to ShaderUtil.GetShaderGlobalKeywords to avoid repeated reflection calls.

        #endregion

        #region === Menu Methods ===

        /// <summary>
        /// Menu item to check global shader keywords for selected materials.
        /// </summary>
        [MenuItem("Assets/MMD Collection/Check Shader Keywords", false, 1)]
        public static void CheckShaderKeywords()
        {
            // Iterate through all selected objects in the Unity editor.
            foreach (var selectedObject in Selection.objects)
            {
                // Ensure the selected object is a material.
                if (selectedObject is Material material)
                {
                    var shader = material.shader;

                    // Validate the material has an assigned shader.
                    if (shader == null)
                    {
                        Debug.LogError($"The material '{material.name}' does not have a shader assigned.", material);
                        continue;
                    }

                    LogGlobalShaderKeywords(shader); // Check and log global shader keywords for this shader.
                }
                else
                {
                    Debug.LogWarning($"Selected object '{selectedObject.name}' is not a material.", selectedObject);
                }
            }
        }

        #endregion

        #region === Utility Methods ===

        /// <summary>
        /// Retrieves and logs all global shader keywords for the specified shader.
        /// </summary>
        /// <param name="shader">The shader to check.</param>
        private static void LogGlobalShaderKeywords(Shader shader)
        {
            if (shader == null) return;

            // Initialize the cached reflection method if it hasn't been set yet.
            if (getShaderGlobalKeywordsMethod == null)
            {
                // Get the internal Unity method 'GetShaderGlobalKeywords' via reflection.
                getShaderGlobalKeywordsMethod = typeof(ShaderUtil).GetMethod("GetShaderGlobalKeywords", BindingFlags.Static | BindingFlags.NonPublic);

                // Log an error if the method could not be found.
                if (getShaderGlobalKeywordsMethod == null)
                {
                    Debug.LogError("Failed to retrieve ShaderUtil.GetShaderGlobalKeywords method. Reflection failed.", shader);
                    return;
                }
            }

            // Invoke the cached method to get the global shader keywords for this shader.
            object result = getShaderGlobalKeywordsMethod.Invoke(null, new object[] { shader });

            // Safely cast the result to a string array.
            // Check if the shader has any global keywords.
            if (result is not string[] globalKeywords || globalKeywords.Length == 0)
            {
                Debug.Log($"Shader '{shader.name}' has no global keywords.", shader);
            }
            else
            {
                string keywordsString = string.Join("\n", globalKeywords);
                Debug.Log($"Global keywords for shader '{shader.name}':\n{keywordsString}", shader);
            }
        }

        #endregion
    }
}