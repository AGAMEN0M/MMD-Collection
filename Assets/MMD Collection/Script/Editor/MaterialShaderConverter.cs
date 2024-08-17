/*
 * ---------------------------------------------------------------------------
 * Description: 
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/
#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class MaterialShaderConverter : MonoBehaviour
{
    // Menu item to convert selected materials' shaders.
    [MenuItem("Assets/MMD Collection/Convert Material Shader (MMD4Mecanim)")]
    public static void ConvertShader()
    {
        // Iterate through each selected object in the Unity Editor.
        foreach (Object selectedObject in Selection.objects)
        {
            // Check if the selected object is a Material.
            if (selectedObject is Material)
            {
                Material materialToConvert = selectedObject as Material;

                // Switch case to handle different shader names.
                switch (materialToConvert.shader.name)
                {
                    // Replace shader based on its name and assign appropriate flags.
                    case "MMD4Mecanim/MMDLit":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", false, false, false, false);
                        break;
                    case "MMD4Mecanim/MMDLit-BothFaces":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", false, false, true, false);
                        break;
                    case "MMD4Mecanim/MMDLit-BothFaces-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", false, true, true, false);
                        break;
                    case "MMD4Mecanim/MMDLit-BothFaces-Transparent":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", true, false, true, false);
                        break;
                    case "MMD4Mecanim/MMDLit-BothFaces-Transparent-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", true, true, true, false);
                        break;
                    case "MMD4Mecanim/MMDLit-Dummy":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", false, true, false, false);
                        break;
                    case "MMD4Mecanim/MMDLit-NEXTEdge-Pass4":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-NEXTEdge-Pass8":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-BothFaces":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-BothFaces-Edge":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-BothFaces-Transparent":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-BothFaces-Transparent-Edge":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-Edge":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-Transparent":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-Transparent-Edge":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-BothFaces":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-BothFaces-Edge":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-BothFaces-Transparent":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-BothFaces-Transparent-Edge":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-Edge":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-BothFaces":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-BothFaces-Edge":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-BothFaces-Transparent":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-BothFaces-Transparent-Edge":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-Edge":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-Transparent":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-Transparent-Edge":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-Transparent":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-Transparent-Edge":
                        //ChangeShader(materialToConvert, "");
                        Error(materialToConvert);
                        break;
                    case "MMD4Mecanim/MMDLit-Transparent":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", true, false, false, false);
                        break;
                    case "MMD4Mecanim/MMDLit-Transparent-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", true, true, false, false);
                        break;
                    default:
                        Debug.LogWarning($"Unable to convert shader: {materialToConvert.shader.name}");
                        break;
                }
            }
        }
    }

    // Logs an error if the shader is not cataloged.
    private static void Error(Material materialToConvert)
    {
        Debug.LogError($"Uncatalogued Shader '{materialToConvert.shader.name}' on material '{materialToConvert.name}'. Please assign a replacement shader manually.");
    }

    // Method to change the shader of the material and transfer properties.
    private static void ChangeShader(Material materialToConvert, string newShaderName, bool transparent, bool outline, bool twoSide, bool gShad)
    {
        Undo.RecordObject(materialToConvert, "Convert Material"); // Record the material state for undo operations.

        // Retrieve and store current material properties.
        Color oldColor = materialToConvert.GetColor("_Color");
        Color oldSpecular = materialToConvert.GetColor("_Specular");
        Color oldAmbient = materialToConvert.GetColor("_Ambient");

        float oldShininess = materialToConvert.GetFloat("_Shininess");

        float sMap = materialToConvert.GetFloat("_NoShadowCasting");
        bool sShad = materialToConvert.IsKeywordEnabled("SELFSHADOW_ON");

        Color oldEdgeColor = materialToConvert.GetColor("_EdgeColor");
        float oldEdgeSize = materialToConvert.GetFloat("_EdgeSize");

        // Determine if any special effects are enabled.
        int oldEFFECTS = 0;
        if (materialToConvert.IsKeywordEnabled("SPHEREMAP_ADD"))
        {
            oldEFFECTS = 1;
        }
        else if (materialToConvert.IsKeywordEnabled("SPHEREMAP_MUL"))
        {
            oldEFFECTS = 2;
        }

        // Retrieve texture properties.
        Texture oldMainTex = materialToConvert.GetTexture("_MainTex");
        Texture oldToonTex = materialToConvert.GetTexture("_ToonTex");
        Texture oldSphereCube = materialToConvert.GetTexture("_SphereCube");

        // Additional shader-related properties.
        bool isSpecularOn = materialToConvert.IsKeywordEnabled("SPECULAR_ON");
        float oldShadowLum = materialToConvert.GetFloat("_ShadowLum");
        Color oldToonTone = materialToConvert.GetColor("_ToonTone");

        // Store current render queue and lighting settings.
        int oldCustomRenderQueue = materialToConvert.renderQueue;
        bool oldEnableInstancingVariants = materialToConvert.enableInstancing;
        bool oldDoubleSidedGI = materialToConvert.doubleSidedGI;
        MaterialGlobalIlluminationFlags oldLightmapFlags = materialToConvert.globalIlluminationFlags;

        materialToConvert.shader = Shader.Find(newShaderName); // Apply new shader to the material.
        CleanMaterialProperties(materialToConvert); // Clean up any invalid properties from the previous shader.

        // Set basic color and property values for the new shader.
        materialToConvert.SetColor("_Color", new Color(oldColor.r, oldColor.g, oldColor.b, 0));
        materialToConvert.SetColor("_Specular", new Color(oldSpecular.r, oldSpecular.g, oldSpecular.b, 0));
        materialToConvert.SetColor("_Ambient", new Color(oldAmbient.r, oldAmbient.g, oldAmbient.b, 0));

        materialToConvert.SetFloat("_Opaque", oldColor.a);
        materialToConvert.SetFloat("_Shininess", oldShininess);

        // Configure shader-specific settings.
        materialToConvert.SetFloat("_Cull", twoSide ? 0 : 2);
        materialToConvert.SetShaderPassEnabled("SHADOWCASTER", gShad);
        if (sMap == 0)
        {
            materialToConvert.SetFloat("_ReceiveShadows", 1);
            materialToConvert.EnableKeyword("_RECEIVE_SHADOWS_OFF");
        }
        else
        {
            materialToConvert.SetFloat("_ReceiveShadows", 0);
            materialToConvert.DisableKeyword("_RECEIVE_SHADOWS_OFF");
        }
        //materialToConvert.SetFloat("S-SHAD", sShad ? 1 : 0);
        Debug.LogWarning($"S-SHAD = {sShad}"); // Debug log for shadow casting property.

        materialToConvert.SetFloat("_On", outline ? 1 : 0);
        materialToConvert.SetColor("_OutlineColor", oldEdgeColor);
        materialToConvert.SetFloat("_EdgeSize", oldEdgeSize * 10);
        bool transparentOutline = outline && oldEdgeColor.a < 1;

        materialToConvert.SetFloat("_EFFECTS", oldEFFECTS);
        materialToConvert.SetTexture("_MainTex", oldMainTex);
        materialToConvert.SetTexture("_ToonTex", oldToonTex);
        materialToConvert.SetTexture("_SphereCube", oldSphereCube);

        materialToConvert.SetFloat("_SpecularIntensity", isSpecularOn? 1 : 0);
        materialToConvert.SetFloat("_ShadowLum", oldShadowLum);
        materialToConvert.SetColor("_ToonTone", oldToonTone);

        if (transparent || transparentOutline)
        {
            materialToConvert.SetFloat("_Surface", 1);
            materialToConvert.SetOverrideTag("RenderType", "Transparent");
            materialToConvert.EnableKeyword("_SURFACE_TYPE_TRANSPARENT");
            oldCustomRenderQueue = RenderQueueToTransparent(oldCustomRenderQueue);
        }
        else
        {
            materialToConvert.SetFloat("_Surface", 0);
            materialToConvert.SetOverrideTag("RenderType", "Opaque");
            materialToConvert.DisableKeyword("_SURFACE_TYPE_TRANSPARENT");
        }

        // Restore original settings for the material.
        materialToConvert.renderQueue = oldCustomRenderQueue;
        materialToConvert.enableInstancing = oldEnableInstancingVariants;
        materialToConvert.doubleSidedGI = oldDoubleSidedGI;
        materialToConvert.globalIlluminationFlags = oldLightmapFlags;

        EditorUtility.SetDirty(materialToConvert);
        Debug.Log($"Material shader converted: {materialToConvert.name}");
    }

    // Adjusts the render queue value for transparent materials.
    private static int RenderQueueToTransparent(int value)
    {
        if (value >= 2000 && value <= 2499)
        {
            return value + 1000;
        }
        else if (value >= 2500 && value <= 2999)
        {
            return value + 500;
        }
        return value;
    }

    // Cleans up properties that are no longer valid after changing the shader.
    private static void CleanMaterialProperties(Material material)
    {
        Shader shader = material.shader;

        if (shader == null)
        {
            Debug.LogError($"The material '{material.name}' does not have a shader.");
            return;
        }

        var validProperties = new HashSet<string>();

        // Collect valid property names from the new shader.
        for (int i = 0; i < ShaderUtil.GetPropertyCount(shader); i++)
        {
            string propertyName = ShaderUtil.GetPropertyName(shader, i);
            validProperties.Add(propertyName);
        }

        var materialSerializedObject = new SerializedObject(material);
        var savedProperties = materialSerializedObject.FindProperty("m_SavedProperties");

        // Remove properties that are not valid for the new shader.
        RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_TexEnvs"), validProperties);
        RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_Ints"), validProperties);
        RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_Floats"), validProperties);
        RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_Colors"), validProperties);

        materialSerializedObject.ApplyModifiedProperties();
    }

    // Removes properties from the serialized material if they are not present in the new shader.
    private static void RemoveInvalidProperties(SerializedProperty properties, HashSet<string> validProperties)
    {
        for (int i = properties.arraySize - 1; i >= 0; i--)
        {
            var property = properties.GetArrayElementAtIndex(i);
            string propertyName = property.FindPropertyRelative("first").stringValue;

            if (!validProperties.Contains(propertyName))
            {
                properties.DeleteArrayElementAtIndex(i); // Remove invalid property.
            }
        }
    }
}
#endif