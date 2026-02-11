/*
 * ---------------------------------------------------------------------------
 * Description: Optimized tool to convert MMD4Mecanim materials to URP-compatible shaders.
 *              Supports multiple shader variants (transparent, edge, tessellation, no-shadow) 
 *              and transfers relevant properties to the new shader automatically.
 *              
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

#if UNITY_EDITOR
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEditor;

namespace MMDCollection.Editor
{
    /// <summary>
    /// Tool to convert MMD4Mecanim material shaders to URP-compatible shaders.
    /// </summary>
    public class MaterialShaderConverter : MonoBehaviour
    {
        #region === Shader Model Enum ===

        /// <summary>
        /// Defines the type of shader model used for conversion.
        /// </summary>
        private enum ShaderModel
        {
            Default,                // Standard URP shader without tessellation or special passes.
            Tessellation,           // Shader with tessellation support.
            Empty,                  // Minimal shader, used for dummy materials.
            FourLayers,             // Multi-pass shader with 4 outline layers.
            EightLayers,            // Multi-pass shader with 8 outline layers.
            NoShadow,               // Shader variant that disables shadow casting.
            NoShadowAndTessellation // Shader variant with tessellation but no shadow casting.
        }

        #endregion

        #region === Cached Reflection ===

        private static MethodInfo getShaderGlobalKeywordsMethod; // Reflection method for fetching global shader keywords. Cached for performance.

        #endregion

        #region === Shader Mapping ===

        // Maps original MMD4Mecanim shader names to URP-compatible shader parameters.
        // Each entry contains the new shader path, flags for transparency, outline, double-sided, global shadow, and the shader model type.
        private static readonly Dictionary<string, (string newShader, bool transparent, bool outline, bool twoSide, bool gShad, ShaderModel model)> shaderMap = new()
    {
        { "MMD4Mecanim/MMDLit", ("MMD Collection/URP/MMD (Amplify Shader Editor)", false,false,false,false, ShaderModel.Default) },
        { "MMD4Mecanim/MMDLit-BothFaces", ("MMD Collection/URP/MMD (Amplify Shader Editor)", false,false,true,false, ShaderModel.Default) },
        { "MMD4Mecanim/MMDLit-BothFaces-Edge", ("MMD Collection/URP/MMD (Amplify Shader Editor)", false,true,true,false, ShaderModel.Default) },
        { "MMD4Mecanim/MMDLit-BothFaces-Transparent", ("MMD Collection/URP/MMD (Amplify Shader Editor)", true,false,true,false, ShaderModel.Default) },
        { "MMD4Mecanim/MMDLit-BothFaces-Transparent-Edge", ("MMD Collection/URP/MMD (Amplify Shader Editor)", true,true,true,false, ShaderModel.Default) },
        { "MMD4Mecanim/MMDLit-Dummy", ("MMD Collection/URP/MMD (Amplify Shader Editor)", false,false,false,false, ShaderModel.Empty) },
        { "MMD4Mecanim/MMDLit-Edge", ("MMD Collection/URP/MMD (Amplify Shader Editor)", false,true,false,false, ShaderModel.Default) },
        { "MMD4Mecanim/MMDLit-NEXTEdge-Pass4", ("MMD Collection/URP/MMD - Multiple Outline (Code)", false,false,false,false, ShaderModel.FourLayers) },
        { "MMD4Mecanim/MMDLit-NEXTEdge-Pass8", ("MMD Collection/URP/MMD - Multiple Outline (Code)", false,false,false,false, ShaderModel.EightLayers) },
        { "MMD4Mecanim/MMDLit-NoShadowCasting", ("MMD Collection/URP/MMD (Amplify Shader Editor)", false,false,false,false, ShaderModel.NoShadow) },
        { "MMD4Mecanim/MMDLit-NoShadowCasting-BothFaces", ("MMD Collection/URP/MMD (Amplify Shader Editor)", false,false,true,false, ShaderModel.NoShadow) },
        { "MMD4Mecanim/MMDLit-NoShadowCasting-BothFaces-Edge", ("MMD Collection/URP/MMD (Amplify Shader Editor)", false,true,true,false, ShaderModel.NoShadow) },
        { "MMD4Mecanim/MMDLit-NoShadowCasting-BothFaces-Transparent", ("MMD Collection/URP/MMD (Amplify Shader Editor)", true,false,true,false, ShaderModel.NoShadow) },
        { "MMD4Mecanim/MMDLit-NoShadowCasting-BothFaces-Transparent-Edge", ("MMD Collection/URP/MMD (Amplify Shader Editor)", true,true,true,false, ShaderModel.NoShadow) },
        { "MMD4Mecanim/MMDLit-NoShadowCasting-Edge", ("MMD Collection/URP/MMD (Amplify Shader Editor)", false,true,false,false, ShaderModel.NoShadow) },
        { "MMD4Mecanim/MMDLit-NoShadowCasting-Transparent", ("MMD Collection/URP/MMD (Amplify Shader Editor)", true,false,false,false, ShaderModel.NoShadow) },
        { "MMD4Mecanim/MMDLit-NoShadowCasting-Transparent-Edge", ("MMD Collection/URP/MMD (Amplify Shader Editor)", true,true,false,false, ShaderModel.NoShadow) },
        { "MMD4Mecanim/MMDLit-Tess", ("MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", false,false,false,false, ShaderModel.Tessellation) },
        { "MMD4Mecanim/MMDLit-Tess-BothFaces", ("MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", false,false,true,false, ShaderModel.Tessellation) },
        { "MMD4Mecanim/MMDLit-Tess-BothFaces-Edge", ("MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", false,true,true,false, ShaderModel.Tessellation) },
        { "MMD4Mecanim/MMDLit-Tess-BothFaces-Transparent", ("MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", true,false,true,false, ShaderModel.Tessellation) },
        { "MMD4Mecanim/MMDLit-Tess-BothFaces-Transparent-Edge", ("MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", true,true,true,false, ShaderModel.Tessellation) },
        { "MMD4Mecanim/MMDLit-Tess-Edge", ("MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", false,true,false,false, ShaderModel.Tessellation) },
        { "MMD4Mecanim/MMDLit-Tess-NoShadowCasting", ("MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", false,false,false,false, ShaderModel.NoShadowAndTessellation) },
        { "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-BothFaces", ("MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", false,false,true,false, ShaderModel.NoShadowAndTessellation) },
        { "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-BothFaces-Edge", ("MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", false,true,true,false, ShaderModel.NoShadowAndTessellation) },
        { "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-BothFaces-Transparent", ("MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", true,false,true,false, ShaderModel.NoShadowAndTessellation) },
        { "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-BothFaces-Transparent-Edge", ("MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", true,true,true,false, ShaderModel.NoShadowAndTessellation) },
        { "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-Edge", ("MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", false,true,false,false, ShaderModel.NoShadowAndTessellation) },
        { "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-Transparent", ("MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", true,false,false,false, ShaderModel.NoShadowAndTessellation) },
        { "MMD4Mecanim/MMDLit-Tess-NoShadowCasting-Transparent-Edge", ("MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", true,true,false,false, ShaderModel.NoShadowAndTessellation) },
        { "MMD4Mecanim/MMDLit-Tess-Transparent", ("MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", true,false,false,false, ShaderModel.Tessellation) },
        { "MMD4Mecanim/MMDLit-Tess-Transparent-Edge", ("MMD Collection/URP/MMD - Tessellation (Amplify Shader Editor)", true,true,false,false, ShaderModel.Tessellation) },
        { "MMD4Mecanim/MMDLit-Transparent", ("MMD Collection/URP/MMD (Amplify Shader Editor)", true,false,false,false, ShaderModel.Default) },
        { "MMD4Mecanim/MMDLit-Transparent-Edge", ("MMD Collection/URP/MMD (Amplify Shader Editor)", true,true,false,false, ShaderModel.Default) },
    };

        #endregion

        #region === Menu Method ===

        /// <summary>
        /// Converts selected materials in the project from MMD4Mecanim shaders to URP shaders.
        /// Can be accessed via "Assets/MMD Collection/Convert Material Shader (MMD4Mecanim)".
        /// </summary>
        [MenuItem("Assets/MMD Collection/Convert Material Shader (MMD4Mecanim)", false, 3)]
        public static void ConvertShader()
        {
            // Iterate through all selected objects in the Project window.
            foreach (var obj in Selection.objects)
            {
                if (obj is Material material)
                {
                    // Attempt to find a mapping for this shader.
                    if (shaderMap.TryGetValue(material.shader.name, out var mapping))
                    {
                        ApplyShaderConversion(material, mapping);
                    }
                    else
                    {
                        Debug.LogWarning($"Shader not mapped for conversion: {material.shader.name}", obj);
                    }
                }
            }
        }

        #endregion

        #region === Conversion Core ===

        /// <summary>
        /// Core method to convert a material based on the shader mapping.
        /// Handles undo recording, preserves render settings, and delegates to specific shader application methods.
        /// </summary>
        private static void ApplyShaderConversion(Material material, (string newShader, bool transparent, bool outline, bool twoSide, bool gShad, ShaderModel model) mapping)
        {
            Undo.RecordObject(material, "Convert Material");

            // Preserve rendering-related properties before switching shader.
            bool oldInstancing = material.enableInstancing;
            bool oldDoubleSidedGI = material.doubleSidedGI;
            var oldGIFlags = material.globalIlluminationFlags;

            // Apply the appropriate shader model.
            switch (mapping.model)
            {
                case ShaderModel.Default:
                case ShaderModel.Tessellation:
                case ShaderModel.NoShadow:
                case ShaderModel.NoShadowAndTessellation:
                    ApplyStandard(material, mapping.newShader, mapping.transparent, mapping.outline, mapping.twoSide, mapping.gShad, mapping.model);
                    break;
                case ShaderModel.Empty:
                    ApplyEmpty(material, mapping.newShader);
                    break;
                case ShaderModel.FourLayers:
                case ShaderModel.EightLayers:
                    ApplyMultiplePass(material, mapping.newShader, mapping.model);
                    break;
            }

            // Restore rendering-related properties after shader change.
            material.enableInstancing = oldInstancing;
            material.doubleSidedGI = oldDoubleSidedGI;
            material.globalIlluminationFlags = oldGIFlags;

            // Clean up any shader properties that are no longer valid.
            CleanMaterialProperties(material);
            EditorUtility.SetDirty(material);
            Debug.Log($"Material shader converted: {material.name}", material);
        }

        #endregion

        #region === Helper Methods ===

        /// <summary>
        /// Applies the standard shader model to a material, transferring colors, textures, transparency, and tessellation settings.
        /// </summary>
        private static void ApplyStandard(Material material, string newShaderName, bool transparent, bool outline, bool twoSide, bool gShad, ShaderModel model)
        {
            // Cache all relevant material properties before shader replacement.
            Color oldColor = material.GetColor("_Color");
            Color oldSpecular = material.GetColor("_Specular");
            Color oldAmbient = material.GetColor("_Ambient");
            float oldShininess = material.GetFloat("_Shininess");

            float sMap = material.GetFloat("_NoShadowCasting");
            bool sShad = material.IsKeywordEnabled("SELFSHADOW_ON");

            Color oldEdgeColor = material.GetColor("_EdgeColor");
            float oldEdgeSize = material.GetFloat("_EdgeSize");

            int oldEffects = 0;
            if (material.IsKeywordEnabled("SPHEREMAP_ADD")) oldEffects = 1;
            else if (material.IsKeywordEnabled("SPHEREMAP_MUL")) oldEffects = 2;

            Texture oldMainTex = material.GetTexture("_MainTex");
            Texture oldToonTex = material.GetTexture("_ToonTex");
            Texture oldSphereCube = material.GetTexture("_SphereCube");

            bool isSpecularOn = material.IsKeywordEnabled("SPECULAR_ON");
            float oldShadowLum = material.GetFloat("_ShadowLum");
            Color oldToonTone = material.GetColor("_ToonTone");

            int oldRenderQueue = material.renderQueue;

            float oldTessEdgeLength = 0;
            float oldTessPhongStrength = 0;
            float oldExtrusionAmount = 0;

            // Preserve tessellation properties if applicable.
            if (model == ShaderModel.Tessellation || model == ShaderModel.NoShadowAndTessellation)
            {
                oldTessEdgeLength = material.GetFloat("_TessEdgeLength");
                oldTessPhongStrength = material.GetFloat("_TessPhongStrength");
                oldExtrusionAmount = material.GetFloat("_TessExtrusionAmount");
            }

            material.shader = Shader.Find(newShaderName); // Replace shader.

            // Restore colors with alpha 0 for initial transparency handling.
            material.SetColor("_Color", new Color(oldColor.r, oldColor.g, oldColor.b, 0));
            material.SetColor("_Specular", new Color(oldSpecular.r, oldSpecular.g, oldSpecular.b, 0));
            material.SetColor("_Ambient", new Color(oldAmbient.r, oldAmbient.g, oldAmbient.b, 0));
            material.SetFloat("_Opaque", oldColor.a);
            material.SetFloat("_Shininess", oldShininess);

            // Handle culling, shadow casting, and self-shadowing.
            material.SetFloat("_Cull", twoSide ? 0 : 2);
            material.SetShaderPassEnabled("SHADOWCASTER", gShad);
            material.SetFloat("_ReceiveShadows", sMap == 0 ? 1 : 0);
            material.SetFloat("_SShad", sShad ? 1 : 0);

            // Handle outline properties.
            material.SetFloat("_On", outline ? 1 : 0);
            material.SetColor("_OutlineColor", oldEdgeColor);
            material.SetFloat("_EdgeSize", oldEdgeSize * 10);
            bool transparentOutline = outline && oldEdgeColor.a < 1;

            // Apply effect flags and textures.
            material.SetFloat("_EFFECTS", oldEffects);
            material.SetTexture("_MainTex", oldMainTex);
            material.SetTexture("_ToonTex", oldToonTex);
            material.SetTexture("_SphereCube", oldSphereCube);
            material.SetFloat("_SpecularIntensity", isSpecularOn ? 1 : 0);
            material.SetFloat("_ShadowLum", oldShadowLum);
            material.SetColor("_ToonTone", oldToonTone);

            // Configure transparency if needed.
            if (transparent || transparentOutline)
            {
                material.SetFloat("_Surface", 1);
                material.SetOverrideTag("RenderType", "Transparent");
                oldRenderQueue = RenderQueueToTransparent(oldRenderQueue);
            }
            else
            {
                material.SetFloat("_Surface", 0);
                material.SetOverrideTag("RenderType", "Opaque");
            }

            material.renderQueue = oldRenderQueue;

            // Disable shadow casting for no-shadow variants.
            if (model == ShaderModel.NoShadow || model == ShaderModel.NoShadowAndTessellation)
            {
                material.SetShaderPassEnabled("SHADOWCASTER", false);
                material.SetFloat("_ReceiveShadows", 0);
            }

            // Restore tessellation-specific properties.
            if (model == ShaderModel.Tessellation || model == ShaderModel.NoShadowAndTessellation)
            {
                material.SetFloat("_EdgeLength", oldTessEdgeLength);
                material.SetFloat("_PhongTessStrength", oldTessPhongStrength);
                material.SetFloat("_ExtrusionAmount", oldExtrusionAmount);
            }
        }

        /// <summary>
        /// Applies a minimal shader setup to a material (empty shader).
        /// </summary>
        private static void ApplyEmpty(Material material, string newShaderName)
        {
            int oldRenderQueue = material.renderQueue;
            material.shader = Shader.Find(newShaderName);

            // Set basic properties for dummy shader.
            material.SetFloat("_Opaque", 0);
            material.SetFloat("_Cull", 2);
            material.SetShaderPassEnabled("SHADOWCASTER", false);
            material.SetFloat("_ReceiveShadows", 0);
            material.SetFloat("_SShad", 0);
            material.SetFloat("_Surface", 1);
            material.SetOverrideTag("RenderType", "Transparent");

            material.renderQueue = RenderQueueToTransparent(oldRenderQueue);
        }

        /// <summary>
        /// Applies a multi-pass shader for outline layers.
        /// </summary>
        private static void ApplyMultiplePass(Material material, string newShaderName, ShaderModel layers)
        {
            int oldRenderQueue = material.renderQueue;

            Color oldEdgeColor = material.GetColor("_EdgeColor");
            float oldEdgeSize = material.GetFloat("_EdgeSize");

            material.shader = Shader.Find(newShaderName);

            // Configure number of outline layers.
            material.SetFloat("_OutlineLayers", layers == ShaderModel.EightLayers ? 1 : 0);
            material.SetColor("_OutlineColor", oldEdgeColor);
            material.SetFloat("_OutlineSize", oldEdgeSize * 10);

            material.renderQueue = oldRenderQueue;
        }

        /// <summary>
        /// Converts render queue value to a transparent queue range if required.
        /// </summary>
        private static int RenderQueueToTransparent(int value)
        {
            if (value >= 2000 && value <= 2499) return value + 1000;
            if (value >= 2500 && value <= 2999) return value + 500;
            return value;
        }

        /// <summary>
        /// Cleans material properties that are invalid for the assigned shader.
        /// </summary>
        private static void CleanMaterialProperties(Material material)
        {
            var shader = material.shader;
            if (shader == null)
            {
                Debug.LogError($"The material '{material.name}' does not have a shader.");
                return;
            }

            // Collect all valid property names from the shader.
            var validProperties = new HashSet<string>();
            for (int i = 0; i < shader.GetPropertyCount(); i++) validProperties.Add(shader.GetPropertyName(i));

            // Access serialized material properties.
            var so = new SerializedObject(material);
            var savedProperties = so.FindProperty("m_SavedProperties");

            // Remove invalid texture, float, int, and color properties.
            RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_TexEnvs"), validProperties);
            RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_Ints"), validProperties);
            RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_Floats"), validProperties);
            RemoveInvalidProperties(savedProperties.FindPropertyRelative("m_Colors"), validProperties);

            so.ApplyModifiedProperties();

            CleanInvalidKeywords(material, shader); // Clean invalid shader keywords.
        }

        /// <summary>
        /// Removes invalid properties from a serialized property array based on valid shader property names.
        /// </summary>
        private static void RemoveInvalidProperties(SerializedProperty properties, HashSet<string> validProperties)
        {
            for (int i = properties.arraySize - 1; i >= 0; i--)
            {
                var prop = properties.GetArrayElementAtIndex(i);
                string name = prop.FindPropertyRelative("first").stringValue;
                if (!validProperties.Contains(name)) properties.DeleteArrayElementAtIndex(i);
            }
        }

        /// <summary>
        /// Cleans invalid keywords from a material's shader keywords using ShaderUtil reflection.
        /// </summary>
        private static void CleanInvalidKeywords(Material material, Shader shader)
        {
            if (getShaderGlobalKeywordsMethod == null) getShaderGlobalKeywordsMethod = typeof(ShaderUtil).GetMethod("GetShaderGlobalKeywords", BindingFlags.Static | BindingFlags.NonPublic);

            if (getShaderGlobalKeywordsMethod == null)
            {
                Debug.LogError("ShaderUtil.GetShaderGlobalKeywords not found.");
                return;
            }

            // Compare material keywords with global shader keywords and disable invalid ones.
            string[] materialKeywords = material.shaderKeywords;
            string[] globalKeywords = (string[])getShaderGlobalKeywordsMethod.Invoke(null, new object[] { shader });
            HashSet<string> validKeywords = new(globalKeywords);

            foreach (string kw in materialKeywords) if (!validKeywords.Contains(kw)) material.DisableKeyword(kw);
        }

        #endregion
    }
}
#endif