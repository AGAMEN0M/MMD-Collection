/*
 * ---------------------------------------------------------------------------
 * Description: Custom material inspector for the MMD Shader Graph material
 *              variant with Normal and Height Map support.
 *              This inspector organizes the UI into logical sections and
 *              applies common rendering rules such as transparency, blending,
 *              alpha clipping, and shadow keyword synchronization.
 * 
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

using MMDCollection.Editor;
using System.Linq;
using UnityEditor;
using UnityEngine;

using static MMDCollection.Editor.MaterialUtility;

namespace MMDCollection.ShaderMMD
{
    public class MMDMaterial_SG_NHM : MMDMaterialCustomInspectorBase
    {
        #region === Inspector UI ===

        /// <summary>
        /// Draws the custom inspector user interface.
        /// Organizes material properties into logical and user-friendly sections.
        /// </summary>
        protected override void DrawUI()
        {
            HeaderGroupGUI.DrawGroup(new GUIContent("Material Color", "Controls the base colors and reflective properties of the material."), () =>
            {
                ColorProperty(new GUIContent("Diffuse", "Base color of the material."), properties, "_Color");
                ColorProperty(new GUIContent("Specular", "Color of light reflection or glow on the material."), properties, "_Specular");
                ColorProperty(new GUIContent("Ambient", "Ambient color affecting how the material interacts with lighting."), properties, "_Ambient");
                GUILayout.Space(10f);
                FloatSliderProperty(new GUIContent("Opaque", "Alpha value of the material, controls transparency."), properties, "_Opaque", 0f, 1f);
                FloatProperty(new GUIContent("Reflection", "Reflection intensity of the material."), properties, "_Shininess");
            });

            HeaderGroupGUI.DrawGroup(new GUIContent("Rendering", "Controls how the material is rendered, including shadows and double-sided geometry."), () =>
            {
                EditorGUILayout.BeginHorizontal();
                DoubleToggleProperty(properties);
                GUILayout.Label(GUIContent.none, GUILayout.MinWidth(50f));
                PassToggleProperty(new GUIContent("G-SHAD", "When enabled, this GameObject will cast shadows onto any geometry that can receive them."), properties, "SHADOWCASTER");
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.BeginHorizontal();
                KeywordToggleProperty(new GUIContent("S-MAP", "When enabled, other GameObjects can cast shadows onto this GameObject."), properties, "_ReceiveShadows", "_RECEIVE_SHADOWS_OFF", invertKeyword: true);
                GUILayout.Label(GUIContent.none, GUILayout.MinWidth(50f));
                FloatToggleProperty(new GUIContent("S-SHAD", "Receives shading only from itself."), properties, "_SShad");
                EditorGUILayout.EndHorizontal();
            });

            HeaderGroupGUI.DrawGroup(new GUIContent("Edge (Outline)", "Controls the outline effect around the material's mesh."), () =>
            {
                EditorGUI.BeginDisabledGroup(true);
                EditorGUILayout.BeginHorizontal();
                FloatToggleProperty(new GUIContent("On", "Enable or disable the outline effect."), properties, "_On");
                GUILayout.Label(GUIContent.none, GUILayout.MinWidth(50f));
                FloatProperty(new GUIContent("Size", "Outline thickness or distance."), properties, "_EdgeSize");
                EditorGUILayout.EndHorizontal();
                ColorProperty(new GUIContent("Color", "Outline color, including transparency."), properties, "_OutlineColor", alpha: true);
                EditorGUI.EndDisabledGroup();
            });

            HeaderGroupGUI.DrawGroup(new GUIContent("Texture/Memo", "Controls textures applied to the material and memo notes."), () =>
            {
                FloatDropdownProperty(new GUIContent("Effects", "Special effects using SPH textures:\n- Disabled: No effect.\n- Multi-Sphere: Multiplies a glowing sphere map.\n- Add-Sphere: Creates a glowing sphere map.\n- Sub-Tex: Uses a subtexture on another UV layer for complex effects."), properties, "_EFFECTS", new string[] { "- Disabled", "x Multi-Sphere", "+ Add-Sphere", "Sub-Tex" }, new float[] { 0, 2, 1, 3 });
                GUILayout.Space(10f);
                TextureProperty(new GUIContent("Texture", "Main texture applied to the material."), properties, "_MainTex");
                TextureProperty(new GUIContent("Toon", "Toon texture for shading and highlights."), properties, "_ToonTex");

                if (HasFloatPropertyValue(properties, "_EFFECTS", 3))
                {
                    GUILayout.Space(10f);
                    FloatDropdownProperty(new GUIContent("UV Layer", "Select which UV layer the subtexture is applied to."), properties, "_UVLayer", new string[] { "Layer 1", "Layer 2", "Layer 3", "Layer 4" }, new float[] { 0, 1, 2, 3 });
                    TextureProperty(new GUIContent("SPH", "Subtexture used for artificial reflection."), properties, "_SubTex", showScaleOffset: true);
                }
                else
                {
                    TextureProperty(new GUIContent("SPH", "Sphere or cube map used for artificial reflection."), properties, "_SphereCube", cubemap: true);
                }

                GUILayout.Space(10f);
                DrawMemoData();
            });

            HeaderGroupGUI.DrawGroup(new GUIContent("Custom Effects Settings", "Controls advanced shading, reflection, and lighting effects."), () =>
            {
                FloatSliderProperty(new GUIContent("Specular Intensity", "Intensity of the specular reflection."), properties, "_SpecularIntensity", 0f, 1f);
                FloatSliderProperty(new GUIContent("SPH Opacity", "Opacity of the SPH reflection map."), properties, "_SPHOpacity", 0f, 1f);
                FloatSliderProperty(new GUIContent("Shadow Luminescence", "Brightness of shadows."), properties, "_ShadowLum", 0f, 10f);
                FloatSliderProperty(new GUIContent("HDR", "HDR lighting intensity."), properties, "_HDR", 1f, 1000f);
                VectorProperty(new GUIContent("Toon Tone", "Toon shading tones applied to the material."), properties, "_ToonTone", 3);
                FloatToggleProperty(new GUIContent("Multiple Lights", "Enable multiple light sources affecting this material."), properties, "_MultipleLights");
                FloatToggleProperty(new GUIContent("Fog", "Enable fog effect on this material."), properties, "_Fog");
            });

            HeaderGroupGUI.DrawGroup(new GUIContent("Simulator Normal Map Settings", "Controls simulated normal mapping used to enhance surface lighting details without modifying geometry."), () =>
            {
                FloatToggleProperty(new GUIContent("Normal Map", "Enables or disables the use of a simulated normal map for this material."), properties, "_SimulatorNormalMap");
                FloatProperty(new GUIContent("Normal Scale", "Controls the intensity of the normal map effect."), properties, "_BumpScale");
                TextureProperty(new GUIContent("Normal Map", "Normal map texture used to simulate surface detail and lighting variation."), properties, "_NormalMap");
            });

            HeaderGroupGUI.DrawGroup(new GUIContent("Simulator Height Map Settings", "Controls simulated height mapping to create a parallax depth illusion on the surface."), () =>
            {
                FloatToggleProperty(new GUIContent("Height Map", "Enables or disables the use of a simulated height (parallax) map."), properties, "_SimulatorHeightMap");
                FloatSliderProperty(new GUIContent("Parallax", "Controls the perceived depth strength of the height map effect."), properties, "_Parallax", 0.005f, 0.08f);
                TextureProperty(new GUIContent("Height Map", "Height map texture used to simulate surface depth through parallax mapping."), properties, "_ParallaxMap");
            });
        }

        #endregion

        #region === Common Rendering Rules ===

        /// <summary>
        /// Applies shared rendering rules across all selected materials.
        /// Synchronizes material properties with shader keywords.
        /// </summary>
        protected override void ApplyCommonRules()
        {
            // Shader keywords related to shadow reception.
            const string KEYWORD_RECEIVE_SHADOWS_DISABLED = "_RECEIVE_SHADOWS_OFF";
            const string KEYWORD_MAIN_LIGHT_SHADOWS_CASCADE = "_MAIN_LIGHT_SHADOWS_CASCADE";
            const string KEYWORD_ADDITIONAL_LIGHT_SHADOWS = "_ADDITIONAL_LIGHT_SHADOWS";

            // Shader keyword used for alpha modulation in multiply blending.
            const string KEYWORD_ALPHA_MODULATE = "_ALPHAMODULATE_ON";

            // Collect all selected materials.
            var mats = targets.OfType<Material>().ToArray();
            if (mats.Length == 0) return;

            // Transparency and blending-related properties.
            var alphaClip = MaterialEditor.GetMaterialProperty(mats, "_AlphaClip");
            var surface = MaterialEditor.GetMaterialProperty(mats, "_Surface");
            var blend = MaterialEditor.GetMaterialProperty(mats, "_Blend");

            // Shadow-related properties.
            var receiveShadows = MaterialEditor.GetMaterialProperty(mats, "_ReceiveShadows");
            var receiveShadowsOff = MaterialEditor.GetMaterialProperty(mats, KEYWORD_RECEIVE_SHADOWS_DISABLED);
            var mainLightCascade = MaterialEditor.GetMaterialProperty(mats, KEYWORD_MAIN_LIGHT_SHADOWS_CASCADE);
            var additionalLightShadow = MaterialEditor.GetMaterialProperty(mats, KEYWORD_ADDITIONAL_LIGHT_SHADOWS);

            bool surfaceTransparent = surface != null && surface.floatValue == 1f;
            int blendMode = blend != null ? Mathf.RoundToInt(blend.floatValue) : 0;

            foreach (var mat in mats)
            {
                // Enable or disable alpha testing.
                if (alphaClip != null) SetKeyword(mat, "_ALPHATEST_ON", alphaClip.floatValue == 1f);

                // Toggle transparent surface keyword.
                SetKeyword(mat, "_SURFACE_TYPE_TRANSPARENT", surfaceTransparent);

                // Control alpha modulation based on blend mode.
                switch (blendMode)
                {
                    case 1: // Premultiply.
                    case 2: // Additive.
                        mat.DisableKeyword(KEYWORD_ALPHA_MODULATE);
                        break;

                    case 3: // Multiply.
                        SetKeyword(mat, KEYWORD_ALPHA_MODULATE, surfaceTransparent);
                        break;

                    default: // Alpha.
                        mat.DisableKeyword(KEYWORD_ALPHA_MODULATE);
                        break;
                }

                // Determine whether the material should receive shadows.
                bool shadowsOn = receiveShadows != null && receiveShadows.floatValue == 1f;

                // Synchronize float properties.
                if (receiveShadowsOff != null) receiveShadowsOff.floatValue = shadowsOn ? 0f : 1f;
                if (mainLightCascade != null) mainLightCascade.floatValue = shadowsOn ? 1f : 0f;
                if (additionalLightShadow != null) additionalLightShadow.floatValue = shadowsOn ? 1f : 0f;

                // Synchronize shader keywords.
                SetKeyword(mat, KEYWORD_RECEIVE_SHADOWS_DISABLED, !shadowsOn);
                SetKeyword(mat, KEYWORD_MAIN_LIGHT_SHADOWS_CASCADE, shadowsOn);
                SetKeyword(mat, KEYWORD_ADDITIONAL_LIGHT_SHADOWS, shadowsOn);

                EditorUtility.SetDirty(mat); // Mark material as dirty so Unity saves the changes.
            }
        }

        #endregion

        #region === Utilities ===

        /// <summary>
        /// Enables or disables a shader keyword on a material.
        /// </summary>
        private static void SetKeyword(Material mat, string keyword, bool enabled)
        {
            if (enabled) mat.EnableKeyword(keyword);
            else mat.DisableKeyword(keyword);
        }

        #endregion

        #region === Shader-Specific Rules ===

        /// <summary>
        /// Applies shader-specific rules.
        /// Currently unused for this shader.
        /// </summary>
        protected override void ApplyShaderSpecificRules()
        {

        }

        #endregion
    }
}