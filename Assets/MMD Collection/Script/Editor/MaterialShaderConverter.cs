/*
 * ---------------------------------------------------------------------------
 * Description: This script automates the conversion of material shaders in Unity's URP (Universal Render Pipeline) 
 *              specifically for MMD (MikuMikuDance) shaders, allowing seamless transition and adaptation of shaders 
 *              for URP compatibility.
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/
#if UNITY_EDITOR
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEditor;

public class MaterialShaderConverter : MonoBehaviour
{
    // Enum defining different shader models used in the conversion process.
    private enum ShaderModel
    {
        Default,                  // Standard shader with no special modifications.
        Tessellation,             // Shader with tessellation for finer surface details.
        Empty,                    // Minimal shader without extra visual effects.
        FourLayers,               // Shader supporting up to four outline layers.
        EightLayers,              // Shader supporting up to eight outline layers.
        NoShadow,                 // Shader with shadow casting disabled.
        NoShadowAndTessellation   // Shader with both no shadow casting and tessellation.
    }

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
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", false, false, false, false, ShaderModel.Default);
                        break;
                    case "MMD4Mecanim/MMDLit-BothFaces":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", false, false, true, false, ShaderModel.Default);
                        break;
                    case "MMD4Mecanim/MMDLit-BothFaces-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", false, true, true, false, ShaderModel.Default);
                        break;
                    case "MMD4Mecanim/MMDLit-BothFaces-Transparent":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", true, false, true, false, ShaderModel.Default);
                        break;
                    case "MMD4Mecanim/MMDLit-BothFaces-Transparent-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", true, true, true, false, ShaderModel.Default);
                        break;
                    case "MMD4Mecanim/MMDLit-Dummy":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", false, false, false, false, ShaderModel.Empty);
                        break;
                    case "MMD4Mecanim/MMDLit-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", false, true, false, false, ShaderModel.Default);
                        break;
                    case "MMD4Mecanim/MMDLit-NEXTEdge-Pass4":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD - Multiple Outline (Code)", false, false, false, false, ShaderModel.FourLayers);
                        break;
                    case "MMD4Mecanim/MMDLit-NEXTEdge-Pass8":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD - Multiple Outline (Code)", false, false, false, false, ShaderModel.EightLayers);
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", false, false, false, false, ShaderModel.NoShadow);
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-BothFaces":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", false, false, true, false, ShaderModel.NoShadow);
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-BothFaces-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", false, true, true, false, ShaderModel.NoShadow);
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-BothFaces-Transparent":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", true, false, true, false, ShaderModel.NoShadow);
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-BothFaces-Transparent-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", true, true, true, false, ShaderModel.NoShadow);
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", false, true, false, false, ShaderModel.NoShadow);
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-Transparent":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", true, false, false, false, ShaderModel.NoShadow);
                        break;
                    case "MMD4Mecanim/MMDLit-NoShadowCasting-Transparent-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", true, true, false, false, ShaderModel.NoShadow);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", false, false, false, false, ShaderModel.Tessellation);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-BothFaces":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", false, false, true, false, ShaderModel.Tessellation);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-BothFaces-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", false, true, true, false, ShaderModel.Tessellation);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-BothFaces-Transparent":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", true, false, true, false, ShaderModel.Tessellation);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-BothFaces-Transparent-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", true, true, true, false, ShaderModel.Tessellation);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", false, true, false, false, ShaderModel.Tessellation);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", false, false, false, false, ShaderModel.NoShadowAndTessellation);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-BothFaces":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", false, false, true, false, ShaderModel.NoShadowAndTessellation);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-BothFaces-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", false, true, true, false, ShaderModel.NoShadowAndTessellation);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-BothFaces-Transparent":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", true, false, true, false, ShaderModel.NoShadowAndTessellation);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-BothFaces-Transparent-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", true, true, true, false, ShaderModel.NoShadowAndTessellation);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", false, true, false, false, ShaderModel.NoShadowAndTessellation);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-Transparent":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", true, false, false, false, ShaderModel.NoShadowAndTessellation);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-Transparent-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", true, true, false, false, ShaderModel.NoShadowAndTessellation);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-Transparent":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", true, false, false, false, ShaderModel.Tessellation);
                        break;
                    case "MMD4Mecanim/MMDLit-Tess-Transparent-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", true, true, false, false, ShaderModel.Tessellation);
                        break;
                    case "MMD4Mecanim/MMDLit-Transparent":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", true, false, false, false, ShaderModel.Default);
                        break;
                    case "MMD4Mecanim/MMDLit-Transparent-Edge":
                        ChangeShader(materialToConvert, "MMD Collection/URP/MMD (Amplify Shader Editor)", true, true, false, false, ShaderModel.Default);
                        break;
                    default:
                        Debug.LogWarning($"Unable to convert shader: {materialToConvert.shader.name}");
                        break;
                }
            }
        }
    }

    // Method to change the shader of a material and transfer its properties to the new shader.
    private static void ChangeShader(Material materialToConvert, string newShaderName, bool transparent, bool outline, bool twoSide, bool gShad, ShaderModel model)
    {
        Undo.RecordObject(materialToConvert, "Convert Material");  // Record material for undo functionality.

        // Store current render queue and lighting settings.
        bool oldEnableInstancingVariants = materialToConvert.enableInstancing;
        bool oldDoubleSidedGI = materialToConvert.doubleSidedGI;
        MaterialGlobalIlluminationFlags oldLightmapFlags = materialToConvert.globalIlluminationFlags;

        switch (model)
        {
            case ShaderModel.Default:
                ApplyStandard(materialToConvert, newShaderName, transparent, outline, twoSide, gShad, ShaderModel.Default);
                break;
            case ShaderModel.Tessellation:
                ApplyStandard(materialToConvert, newShaderName, transparent, outline, twoSide, gShad, ShaderModel.Tessellation);
                break;
            case ShaderModel.Empty:
                ApplyEmpty(materialToConvert, newShaderName);
                break;
            case ShaderModel.FourLayers:
                ApplyMultiplePass(materialToConvert, newShaderName, ShaderModel.FourLayers);
                break;
            case ShaderModel.EightLayers:
                ApplyMultiplePass(materialToConvert, newShaderName, ShaderModel.EightLayers);
                break;
            case ShaderModel.NoShadow:
                ApplyStandard(materialToConvert, newShaderName, transparent, outline, twoSide, gShad, ShaderModel.NoShadow);
                break;
            case ShaderModel.NoShadowAndTessellation:
                ApplyStandard(materialToConvert, newShaderName, transparent, outline, twoSide, gShad, ShaderModel.NoShadowAndTessellation);
                break;
            default:
                Debug.LogWarning($"Shader model {model} não suportado.");
                break;
        }

        // Restore original rendering settings for the material.
        materialToConvert.enableInstancing = oldEnableInstancingVariants;
        materialToConvert.doubleSidedGI = oldDoubleSidedGI;
        materialToConvert.globalIlluminationFlags = oldLightmapFlags;

        CleanMaterialProperties(materialToConvert); // Clean properties irrelevant to the new shader.

        EditorUtility.SetDirty(materialToConvert); // Mark as dirty to update in the editor.
        Debug.Log($"Material shader converted: {materialToConvert.name}"); // Confirm shader conversion.
    }

    // Method to apply the standard shader model settings to a material.
    private static void ApplyStandard(Material materialToConvert, string newShaderName, bool transparent, bool outline, bool twoSide, bool gShad, ShaderModel model)
    {
        // Retrieve and store key color properties from the current material.
        Color oldColor = materialToConvert.GetColor("_Color");
        Color oldSpecular = materialToConvert.GetColor("_Specular");
        Color oldAmbient = materialToConvert.GetColor("_Ambient");

        float oldShininess = materialToConvert.GetFloat("_Shininess"); // Retrieve shininess level.

        // Check shadow casting and self-shadowing settings.
        float sMap = materialToConvert.GetFloat("_NoShadowCasting");
        bool sShad = materialToConvert.IsKeywordEnabled("SELFSHADOW_ON");

        // Retrieve edge color and edge size for outline effects.
        Color oldEdgeColor = materialToConvert.GetColor("_EdgeColor");
        float oldEdgeSize = materialToConvert.GetFloat("_EdgeSize");

        // Determine if any specific sphere map effects are active.
        int oldEFFECTS = 0;
        if (materialToConvert.IsKeywordEnabled("SPHEREMAP_ADD"))
        {
            oldEFFECTS = 1; // Additive sphere map effect.
        }
        else if (materialToConvert.IsKeywordEnabled("SPHEREMAP_MUL"))
        {
            oldEFFECTS = 2; // Multiplicative sphere map effect.
        }

        // Retrieve primary texture and other shader-related textures.
        Texture oldMainTex = materialToConvert.GetTexture("_MainTex");
        Texture oldToonTex = materialToConvert.GetTexture("_ToonTex");
        Texture oldSphereCube = materialToConvert.GetTexture("_SphereCube");

        // Retrieve additional shader-related properties.
        bool isSpecularOn = materialToConvert.IsKeywordEnabled("SPECULAR_ON");
        float oldShadowLum = materialToConvert.GetFloat("_ShadowLum");
        Color oldToonTone = materialToConvert.GetColor("_ToonTone");

        // Store current render queue and lighting settings.
        int oldCustomRenderQueue = materialToConvert.renderQueue;

        // Initialize tessellation properties if the model includes tessellation.
        float oldTessEdgeLength = 0;
        float oldTessPhongStrength = 0;
        float oldExtrusionAmount = 0;

        if (model == ShaderModel.Tessellation || model == ShaderModel.NoShadowAndTessellation)
        {
            oldTessEdgeLength = materialToConvert.GetFloat("_TessEdgeLength");
            oldTessPhongStrength = materialToConvert.GetFloat("_TessPhongStrength");
            oldExtrusionAmount = materialToConvert.GetFloat("_TessExtrusionAmount");
        }

        materialToConvert.shader = Shader.Find(newShaderName); // Apply the new shader to the material.

        // Set basic colors and transparency values.
        materialToConvert.SetColor("_Color", new Color(oldColor.r, oldColor.g, oldColor.b, 0));
        materialToConvert.SetColor("_Specular", new Color(oldSpecular.r, oldSpecular.g, oldSpecular.b, 0));
        materialToConvert.SetColor("_Ambient", new Color(oldAmbient.r, oldAmbient.g, oldAmbient.b, 0));

        materialToConvert.SetFloat("_Opaque", oldColor.a);
        materialToConvert.SetFloat("_Shininess", oldShininess);

        // Configure culling and shadow casting settings.
        materialToConvert.SetFloat("_Cull", twoSide ? 0 : 2); // 0: two-sided, 2: single-sided.
        materialToConvert.SetShaderPassEnabled("SHADOWCASTER", gShad); // Enable/disable shadow casting.
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

        materialToConvert.SetFloat("_SShad", sShad ? 1 : 0); // Set self-shadow flag.

        // Configure outline settings if enabled.
        materialToConvert.SetFloat("_On", outline ? 1 : 0);
        materialToConvert.SetColor("_OutlineColor", oldEdgeColor);
        materialToConvert.SetFloat("_EdgeSize", oldEdgeSize * 10); // Scale up edge size.
        bool transparentOutline = outline && oldEdgeColor.a < 1;

        // Apply special effect and texture properties.
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
            materialToConvert.SetFloat("_Surface", 1); // Enable transparent mode.
            materialToConvert.SetOverrideTag("RenderType", "Transparent");
            oldCustomRenderQueue = RenderQueueToTransparent(oldCustomRenderQueue); // Adjust render queue.
        }
        else
        {
            materialToConvert.SetFloat("_Surface", 0); // Opaque mode.
            materialToConvert.SetOverrideTag("RenderType", "Opaque");
        }

        materialToConvert.renderQueue = oldCustomRenderQueue; // Restore the original render queue.

        // Disable shadow casting for no-shadow models.
        if (model == ShaderModel.NoShadow || model == ShaderModel.NoShadowAndTessellation)
        {
            materialToConvert.SetShaderPassEnabled("SHADOWCASTER", false);
            materialToConvert.SetFloat("_ReceiveShadows", 0);
            materialToConvert.DisableKeyword("_RECEIVE_SHADOWS_OFF");
        }

        // Apply tessellation-specific settings if relevant to the model.
        if (model == ShaderModel.Tessellation || model == ShaderModel.NoShadowAndTessellation)
        {
            materialToConvert.SetFloat("_EdgeLength", oldTessEdgeLength);
            materialToConvert.SetFloat("_PhongTessStrength", oldTessPhongStrength);
            materialToConvert.SetFloat("_ExtrusionAmount", oldExtrusionAmount);
        }
    }

    // Applies a minimal shader setup to a material by clearing extraneous properties.
    private static void ApplyEmpty(Material materialToConvert, string newShaderName)
    {
        int oldCustomRenderQueue = materialToConvert.renderQueue;

        materialToConvert.shader = Shader.Find(newShaderName); // Apply the new shader to the material.

        // Set basic rendering settings for an empty shader configuration.
        materialToConvert.SetFloat("_Opaque", 0); // Set material as fully transparent.
        materialToConvert.SetFloat("_Cull", 2);   // Enable backface culling.

        // Disable shadow casting and receiving.
        materialToConvert.SetShaderPassEnabled("SHADOWCASTER", false);
        materialToConvert.SetFloat("_ReceiveShadows", 0);
        materialToConvert.DisableKeyword("_RECEIVE_SHADOWS_OFF");
        materialToConvert.SetFloat("_SShad", 0);

        // Adjust render queue for transparency if necessary.
        materialToConvert.SetFloat("_Surface", 1);
        materialToConvert.SetOverrideTag("RenderType", "Transparent");
        oldCustomRenderQueue = RenderQueueToTransparent(oldCustomRenderQueue);

        materialToConvert.renderQueue = oldCustomRenderQueue;
    }

    // Configures a material with multi-pass shader settings, allowing for layered effects.
    private static void ApplyMultiplePass(Material materialToConvert, string newShaderName, ShaderModel layers)
    {
        int oldCustomRenderQueue = materialToConvert.renderQueue;

        // Retrieve current outline color and edge size to retain in the new shader.
        Color oldEdgeColor = materialToConvert.GetColor("_EdgeColor");
        float oldEdgeSize = materialToConvert.GetFloat("_EdgeSize");

        materialToConvert.shader = Shader.Find(newShaderName); // Apply the new shader to the material.

        // Set outline layer count based on the ShaderModel parameter.
        materialToConvert.SetFloat("_OutlineLayers", (layers == ShaderModel.EightLayers) ? 1 : 0);

        // Set outline properties for the new shader.
        materialToConvert.SetColor("_OutlineColor", oldEdgeColor);
        materialToConvert.SetFloat("_OutlineSize", oldEdgeSize * 10);

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
            validProperties.Add(propertyName); // Add to valid properties list.
        }

        var materialSerializedObject = new SerializedObject(material);
        var savedProperties = materialSerializedObject.FindProperty("m_SavedProperties");

        // Remove any properties that are no longer valid for the new shader.
        RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_TexEnvs"), validProperties);
        RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_Ints"), validProperties);
        RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_Floats"), validProperties);
        RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_Colors"), validProperties);

        materialSerializedObject.ApplyModifiedProperties(); // Apply property modifications.
        CleanInvalidKeywords(material, shader); // Clean invalid keywords from material.
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

    // Removes invalid keywords from a material's shader keyword list to ensure compatibility with the new shader.
    private static void CleanInvalidKeywords(Material material, Shader shader)
    {
        // Use reflection to access internal 'GetShaderGlobalKeywords' method.
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
                    removedKeywords.Add(keyword); // Track removed keywords.
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