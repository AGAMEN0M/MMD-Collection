#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

public class MaterialShaderConverter : MonoBehaviour
{
    // This method is called when the menu item is selected in the Unity Editor.
    [MenuItem("Assets/MMD Collection/Convert Material Shader (MMD4Mecanim)")]
    public static void ConvertShader()
    {
        // Iterate over selected objects.
        foreach (Object selectedObject in Selection.objects)
        {
            // Check if the selected object is a material.
            if (selectedObject is Material)
            {
                Material materialToConvert = selectedObject as Material; // Convert the selected object to a material.

                // Check the current shader of the material and convert it to the appropriate shader.
                switch (materialToConvert.shader.name)
                {
                    case "MMD4Mecanim/MMDLit":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", false);
                        break;
                    case "MMD4Mecanim/MMDLit-BothFaces":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-BothFaces-Edge":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-BothFaces-Transparent":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-BothFaces-Transparent-Edge":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-Dummy":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", true);
                        break;
                    case "MMD4Mecanim/MMDLit-NEXTEdge-Pass4":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-NEXTEdge-Pass8":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-BothFaces":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-BothFaces-Edge":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-BothFaces-Transparent":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-BothFaces-Transparent-Edge":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-Edge":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-Transparent":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-Transparent-Edge":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-Tess":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-BothFaces":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-BothFaces-Edge":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-BothFaces-Transparent":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-BothFaces-Transparent-Edge":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-Edge":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-BothFaces":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-BothFaces-Edge":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-BothFaces-Transparent":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-BothFaces-Transparent-Edge":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-Edge":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-Transparent":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-Transparent-Edge":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-Transparent":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-Transparent-Edge":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-Transparent":
                        //ChangeShader(materialToConvert, "");
                        break;
                    case "MMD4Mecanim/MMDLit-Transparent-Edge":
                        //ChangeShader(materialToConvert, "");
                        break;
                    default:
                        Debug.LogWarning($"Unable to convert shader: {materialToConvert.shader.name}");
                        break;
                }
            }
        }
    }

    // Method to change the shader of a material.
    private static void ChangeShader(Material materialToConvert, string newShaderName, bool Outline)
    {
        Undo.RecordObject(materialToConvert, "Convert Material"); // Record the material change for undo purposes.

        // Get the color from the old shader variable.
        Color oldColor = materialToConvert.GetColor("_Color");
        Color oldSpecular = materialToConvert.GetColor("_Specular");
        Color oldAmbient = materialToConvert.GetColor("_Ambient");

        float oldShininess = materialToConvert.GetFloat("_Shininess");

        //float oldFloat2 = materialToConvert.GetFloat("???");
        //float oldFloat3 = materialToConvert.GetFloat("???");
        //float oldFloat4 = materialToConvert.GetFloat("???");
        //float oldFloat5 = materialToConvert.GetFloat("???");
        
        Color oldEdgeColor = materialToConvert.GetColor("_EdgeColor");
        float oldEdgeSize = materialToConvert.GetFloat("_EdgeSize");

        int oldEFFECTS = 0;
        if (materialToConvert.IsKeywordEnabled("SPHEREMAP_ADD"))
        {
            oldEFFECTS = 1;
        }
        else if (materialToConvert.IsKeywordEnabled("SPHEREMAP_MUL"))
        {
            oldEFFECTS = 2;
        }

        Texture oldMainTex = materialToConvert.GetTexture("_MainTex");
        Texture oldToonTex = materialToConvert.GetTexture("_ToonTex");
        Texture oldSphereCube = materialToConvert.GetTexture("_SphereCube");

        bool isSpecularOn = materialToConvert.IsKeywordEnabled("SPECULAR_ON");
        float oldShadowLum = materialToConvert.GetFloat("_ShadowLum");
        Color oldToonTone = materialToConvert.GetColor("_ToonTone");

        int oldCustomRenderQueue = materialToConvert.renderQueue;
        bool oldEnableInstancingVariants = materialToConvert.enableInstancing;
        bool oldDoubleSidedGI = materialToConvert.doubleSidedGI;
        MaterialGlobalIlluminationFlags oldLightmapFlags = materialToConvert.globalIlluminationFlags;

        materialToConvert.shader = Shader.Find(newShaderName); // Set the new shader for the material.
        CleanMaterialProperties(materialToConvert);

        // Set the variable color in the new shader.
        materialToConvert.SetColor("_Color", new Color(oldColor.r, oldColor.g, oldColor.b, 0));
        materialToConvert.SetColor("_Specular", new Color(oldSpecular.r, oldSpecular.g, oldSpecular.b, 0));
        materialToConvert.SetColor("_Ambient", new Color(oldAmbient.r, oldAmbient.g, oldAmbient.b, 0));

        materialToConvert.SetFloat("_Opaque", oldColor.a);
        materialToConvert.SetFloat("_Shininess", oldShininess);

        //materialToConvert.SetFloat("_2_SIDE", oldFloat2);
        //materialToConvert.SetFloat("_G_SHAD", oldFloat3);
        //materialToConvert.SetFloat("_S_MAP", oldFloat4);
        //materialToConvert.SetFloat("_S_SHAD", oldFloat5);
        
        materialToConvert.SetFloat("_On", Outline ? 1 : 0);
        materialToConvert.SetColor("_OutlineColor", oldEdgeColor);
        materialToConvert.SetFloat("_EdgeSize", oldEdgeSize * 10);

        materialToConvert.SetFloat("_EFFECTS", oldEFFECTS);
        materialToConvert.SetTexture("_MainTex", oldMainTex);
        materialToConvert.SetTexture("_ToonTex", oldToonTex);
        materialToConvert.SetTexture("_SphereCube", oldSphereCube);

        materialToConvert.SetFloat("_SpecularIntensity", isSpecularOn? 1 : 0);
        materialToConvert.SetFloat("_ShadowLum", oldShadowLum);
        materialToConvert.SetColor("_ToonTone", oldToonTone);

        materialToConvert.renderQueue = oldCustomRenderQueue;
        materialToConvert.enableInstancing = oldEnableInstancingVariants;
        materialToConvert.doubleSidedGI = oldDoubleSidedGI;
        materialToConvert.globalIlluminationFlags = oldLightmapFlags;

        EditorUtility.SetDirty(materialToConvert); // Mark the material as dirty to ensure the change is saved.
        Debug.Log($"Material shader converted: {materialToConvert.name}"); // Log a message indicating the material shader has been converted.
    }

    public static void CleanMaterialProperties(Material material)
    {
        Shader shader = material.shader;

        if (shader == null)
        {
            Debug.LogError($"The material '{material.name}' does not have a shader.");
            return;
        }

        var validProperties = new HashSet<string>();

        for (int i = 0; i < ShaderUtil.GetPropertyCount(shader); i++)
        {
            string propertyName = ShaderUtil.GetPropertyName(shader, i);
            validProperties.Add(propertyName);
        }

        var materialSerializedObject = new SerializedObject(material);
        var savedProperties = materialSerializedObject.FindProperty("m_SavedProperties");

        RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_TexEnvs"), validProperties);
        RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_Ints"), validProperties);
        RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_Floats"), validProperties);
        RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_Colors"), validProperties);

        materialSerializedObject.ApplyModifiedProperties();
    }

    private static void RemoveInvalidProperties(SerializedProperty properties, HashSet<string> validProperties)
    {
        for (int i = properties.arraySize - 1; i >= 0; i--)
        {
            var property = properties.GetArrayElementAtIndex(i);
            string propertyName = property.FindPropertyRelative("first").stringValue;

            if (!validProperties.Contains(propertyName))
            {
                properties.DeleteArrayElementAtIndex(i);
            }
        }
    }
}
#endif