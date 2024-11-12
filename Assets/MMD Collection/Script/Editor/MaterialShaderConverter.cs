/*
 * ---------------------------------------------------------------------------
 * Description: [Add a short description of the script here.]
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/
#if UNITY_EDITOR
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEditor;
using UnityEngine.UI;

public class MaterialShaderConverter : MonoBehaviour
{
    // Menu item to convert the shaders of selected materials in the Unity Editor.
    [MenuItem("Assets/MMD Collection/Convert Material Shader (MMD4Mecanim)")]
    public static void ConvertShader()
    {
        // Iterate through each selected object in the Unity Editor selection.
        foreach (Object selectedObject in Selection.objects)
        {
            // Check if the selected object is a Material before proceeding.
            if (selectedObject is Material)
            {
                Material materialToConvert = selectedObject as Material;

                // Handle conversion based on the shader name assigned to the material.
                switch (materialToConvert.shader.name)
                {
                    // Replace specific MMD shaders with their URP counterparts.
                    case "MMD4Mecanim/MMDLit":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", false, false, false, false, ShaderModel.MMD4);
                        break;
                    case "MMD4Mecanim/MMDLit-BothFaces":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", false, false, true, false, ShaderModel.MMD4);
                        break;
                    case "MMD4Mecanim/MMDLit-BothFaces-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", false, true, true, false, ShaderModel.MMD4);
                        break;
                    case "MMD4Mecanim/MMDLit-BothFaces-Transparent":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", true, false, true, false, ShaderModel.MMD4);
                        break;
                    case "MMD4Mecanim/MMDLit-BothFaces-Transparent-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", true, true, true, false, ShaderModel.MMD4);
                        break;
                    case "MMD4Mecanim/MMDLit-Dummy":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", false, false, false, false, ShaderModel.MMD4_Empty);
                        break;
                    case "MMD4Mecanim/MMDLit-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", false, true, false, false, ShaderModel.MMD4);
                        break;
                    case "MMD4Mecanim/MMDLit-NEXTEdge-Pass4":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD - Multiple Outline (Amplify Shader Editor)", false, false, false, false, ShaderModel.MMD4_Pass4);
                        break;
                    case "MMD4Mecanim/MMDLit-NEXTEdge-Pass8":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD - Multiple Outline (Amplify Shader Editor)", false, false, false, false, ShaderModel.MMD4_Pass8);
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting":
                        // Não recebe sombra e não emite
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-BothFaces":
                        // Não recebe sombra e não emite (Duas fazes)
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-BothFaces-Edge":
                        // Não recebe sombra e não emite (Duas fazes e outline)
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-BothFaces-Transparent":
                        // Não recebe sombra e não emite (Duas fazes) [Trasparente]
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-BothFaces-Transparent-Edge":
                        // Não recebe sombra e não emite (Duas fazes e outline) [Trasparente]
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-Edge":
                        // Não recebe sombra e não emite (outline)
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-Transparent":
                        // Não recebe sombra e não emite [Trasparente]
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-Transparent-Edge":
                        // Não recebe sombra e não emite (outline) [Trasparente]
                        break;
                    case "MMD4Mecanim/MMDLit-Tess":
                        // tecelagem
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-BothFaces":
                        // tecelagem
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-BothFaces-Edge":
                        // tecelagem
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-BothFaces-Transparent":
                        // tecelagem
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-BothFaces-Transparent-Edge":
                        // tecelagem
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-Edge":
                        // tecelagem
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting":
                        // tecelagem
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-BothFaces":
                        // tecelagem
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-BothFaces-Edge":
                        // tecelagem
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-BothFaces-Transparent":
                        // tecelagem
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-BothFaces-Transparent-Edge":
                        // tecelagem
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-Edge":
                        // tecelagem
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-Transparent":
                        // tecelagem
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-Transparent-Edge":
                        // tecelagem
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-Transparent":
                        // tecelagem
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-Transparent-Edge":
                        // tecelagem
                        break;
                    case "MMD4Mecanim/MMDLit-Transparent":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", true, false, false, false, ShaderModel.MMD4);
                        break;
                    case "MMD4Mecanim/MMDLit-Transparent-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", true, true, false, false, ShaderModel.MMD4);
                        break;
                    default:
                        Debug.LogWarning($"Unable to convert shader: {materialToConvert.shader.name}");
                        break;
                }
            }
        }
    }

    private enum ShaderModel
    {
        MMD4,
        MMD4_Empty,
        MMD4_Pass4,
        MMD4_Pass8,
        MMD4_Tessellation
    }

    // Method to change the shader of a material and transfer its properties to the new shader.
    private static void ChangeShader(Material materialToConvert, string newShaderName, bool transparent, bool outline, bool twoSide, bool gShad, ShaderModel model)
    {
        // Record the material's state to enable undo functionality in the editor.
        Undo.RecordObject(materialToConvert, "Convert Material");

        // Store current render queue and lighting settings.
        bool oldEnableInstancingVariants = materialToConvert.enableInstancing;
        bool oldDoubleSidedGI = materialToConvert.doubleSidedGI;
        MaterialGlobalIlluminationFlags oldLightmapFlags = materialToConvert.globalIlluminationFlags;

        switch (model)
        {
            case ShaderModel.MMD4:
                ApplyMMD4(materialToConvert, newShaderName, transparent, outline, twoSide, gShad, false);
                break;
            case ShaderModel.MMD4_Empty:
                ApplyMMD4Empty(materialToConvert, newShaderName);
                break;
            case ShaderModel.MMD4_Pass4:
                ApplyMMD4MultiplePass(materialToConvert, newShaderName, ShaderModel.MMD4_Pass4);
                break;
            case ShaderModel.MMD4_Pass8:
                ApplyMMD4MultiplePass(materialToConvert, newShaderName, ShaderModel.MMD4_Pass8);
                break;
            case ShaderModel.MMD4_Tessellation:
                ApplyMMD4(materialToConvert, newShaderName, transparent, outline, twoSide, gShad, true);
                break;
            default:
                Debug.LogWarning($"Shader model {model} não suportado.");
                break;
        }

        
        // Restore original rendering settings for the material.
        materialToConvert.enableInstancing = oldEnableInstancingVariants;
        materialToConvert.doubleSidedGI = oldDoubleSidedGI;
        materialToConvert.globalIlluminationFlags = oldLightmapFlags;

        CleanMaterialProperties(materialToConvert);

        // Mark the material as dirty to update the editor.
        EditorUtility.SetDirty(materialToConvert);
        Debug.Log($"Material shader converted: {materialToConvert.name}");
    }

    private static void ApplyMMD4(Material materialToConvert, string newShaderName, bool transparent, bool outline, bool twoSide, bool gShad, bool Tessellation)
    {
        // Retrieve and store current material properties.
        Color oldColor = materialToConvert.GetColor("_Color");
        Color oldSpecular = materialToConvert.GetColor("_Specular");
        Color oldAmbient = materialToConvert.GetColor("_Ambient");

        float oldShininess = materialToConvert.GetFloat("_Shininess");

        float sMap = materialToConvert.GetFloat("_NoShadowCasting");
        bool sShad = materialToConvert.IsKeywordEnabled("SELFSHADOW_ON");

        Color oldEdgeColor = materialToConvert.GetColor("_EdgeColor");
        float oldEdgeSize = materialToConvert.GetFloat("_EdgeSize");

        // Determine any special effects active on the material.
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

        // Apply the new shader and clean up any obsolete properties.
        materialToConvert.shader = Shader.Find(newShaderName);

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

        materialToConvert.SetFloat("_SShad", sShad ? 1 : 0);

        materialToConvert.SetFloat("_On", outline ? 1 : 0);
        materialToConvert.SetColor("_OutlineColor", oldEdgeColor);
        materialToConvert.SetFloat("_EdgeSize", oldEdgeSize * 10);
        bool transparentOutline = outline && oldEdgeColor.a < 1;

        materialToConvert.SetFloat("_EFFECTS", oldEFFECTS);
        materialToConvert.SetTexture("_MainTex", oldMainTex);
        materialToConvert.SetTexture("_ToonTex", oldToonTex);
        materialToConvert.SetTexture("_SphereCube", oldSphereCube);

        materialToConvert.SetFloat("_SpecularIntensity", isSpecularOn ? 1 : 0);
        materialToConvert.SetFloat("_ShadowLum", oldShadowLum);
        materialToConvert.SetColor("_ToonTone", oldToonTone);

        // Handle transparency-related properties.
        if (transparent || transparentOutline)
        {
            materialToConvert.SetFloat("_Surface", 1);
            materialToConvert.SetOverrideTag("RenderType", "Transparent");
            oldCustomRenderQueue = RenderQueueToTransparent(oldCustomRenderQueue);
        }
        else
        {
            materialToConvert.SetFloat("_Surface", 0);
            materialToConvert.SetOverrideTag("RenderType", "Opaque");
        }

        materialToConvert.renderQueue = oldCustomRenderQueue;
    }

    private static void ApplyMMD4Empty(Material materialToConvert, string newShaderName)
    {
        int oldCustomRenderQueue = materialToConvert.renderQueue;

        materialToConvert.shader = Shader.Find(newShaderName);

        materialToConvert.SetFloat("_Opaque", 0);

        materialToConvert.SetFloat("_Cull", 2);
        materialToConvert.SetShaderPassEnabled("SHADOWCASTER", false);
        materialToConvert.SetFloat("_ReceiveShadows", 0);
        materialToConvert.DisableKeyword("_RECEIVE_SHADOWS_OFF");

        materialToConvert.SetFloat("_SShad", 0);

        materialToConvert.SetFloat("_Surface", 1);
        materialToConvert.SetOverrideTag("RenderType", "Transparent");
        oldCustomRenderQueue = RenderQueueToTransparent(oldCustomRenderQueue);

        materialToConvert.renderQueue = oldCustomRenderQueue;
    }

    private static void ApplyMMD4MultiplePass(Material materialToConvert, string newShaderName, ShaderModel layers)
    {
        int oldCustomRenderQueue = materialToConvert.renderQueue;

        Color oldEdgeColor = materialToConvert.GetColor("_EdgeColor");
        float oldEdgeSize = materialToConvert.GetFloat("_EdgeSize");
        bool transparentOutline = oldEdgeColor.a < 1;

        materialToConvert.shader = Shader.Find(newShaderName);

        materialToConvert.SetFloat("_OutlineLayers", (layers == ShaderModel.MMD4_Pass8) ? 1 : 0);
        materialToConvert.SetColor("_OutlineColor", oldEdgeColor);
        materialToConvert.SetFloat("_EdgeSize", oldEdgeSize * 10);

        materialToConvert.SetFloat("_ReceiveShadows", 0);
        materialToConvert.DisableKeyword("_RECEIVE_SHADOWS_OFF");

        if (transparentOutline)
        {
            materialToConvert.SetFloat("_Surface", 1);
            materialToConvert.SetOverrideTag("RenderType", "Transparent");
            oldCustomRenderQueue = RenderQueueToTransparent(oldCustomRenderQueue);
        }
        else
        {
            materialToConvert.SetFloat("_Surface", 0);
            materialToConvert.SetOverrideTag("RenderType", "Opaque");
        }

        materialToConvert.renderQueue = oldCustomRenderQueue;
    }

    // Adjusts the render queue for transparent materials based on the current queue value.
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

    // Cleans up properties in the material that are invalid for the new shader.
    private static void CleanMaterialProperties(Material material)
    {
        Shader shader = material.shader;

        if (shader == null)
        {
            Debug.LogError($"The material '{material.name}' does not have a shader.");
            return;
        }

        var validProperties = new HashSet<string>();

        // Collect valid properties from the new shader.
        for (int i = 0; i < ShaderUtil.GetPropertyCount(shader); i++)
        {
            string propertyName = ShaderUtil.GetPropertyName(shader, i);
            validProperties.Add(propertyName);
        }

        var materialSerializedObject = new SerializedObject(material);
        var savedProperties = materialSerializedObject.FindProperty("m_SavedProperties");

        // Remove any properties that are no longer valid for the new shader.
        RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_TexEnvs"), validProperties);
        RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_Ints"), validProperties);
        RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_Floats"), validProperties);
        RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_Colors"), validProperties);

        materialSerializedObject.ApplyModifiedProperties();

        // Clean invalid keywords.
        CleanInvalidKeywords(material, shader);
    }

    // Removes properties that are not valid for the current shader.
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
            /*
            // Log removed keywords if any were found.
            if (removedKeywords.Count > 0)
            {
                Debug.Log($"Removed invalid keywords from material '{material.name}': {string.Join(", ", removedKeywords)}");
            }
            */
        }
        else
        {
            // Log an error if the ShaderUtil method cannot be found.
            Debug.LogError("Failed to retrieve global shader keywords. ShaderUtil method not found.");
        }
    }
}
#endif