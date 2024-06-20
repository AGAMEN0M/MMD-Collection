using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

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
}