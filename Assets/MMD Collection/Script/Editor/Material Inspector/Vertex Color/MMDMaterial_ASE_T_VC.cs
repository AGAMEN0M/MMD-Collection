/*
 * ---------------------------------------------------------------------------
 * Description: Custom material inspector for MMD materials built with
 *              Amplify Shader Editor (ASE), including tessellation support
 *              and variant with Vertex Color support.
 *              This inspector provides a structured and simplified UI
 *              focused on MMD-specific workflows, while synchronizing
 *              common rendering rules such as transparency, blending,
 *              alpha clipping, shadow handling, and tessellation controls.
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
    public class MMDMaterial_ASE_T_VC : MMDMaterialCustomInspectorBase
    {
        #region === Inspector UI ===

        /// <summary>
        /// Draws the custom inspector UI for ASE-based MMD materials.
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
                EditorGUILayout.BeginHorizontal();
                FloatToggleProperty(new GUIContent("On", "Enable or disable the outline effect."), properties, "_On");
                GUILayout.Label(GUIContent.none, GUILayout.MinWidth(50f));
                FloatProperty(new GUIContent("Size", "Outline thickness or distance."), properties, "_EdgeSize");
                EditorGUILayout.EndHorizontal();
                ColorProperty(new GUIContent("Color", "Outline color, including transparency."), properties, "_OutlineColor", alpha: true);
            });

            HeaderGroupGUI.DrawGroup(new GUIContent("Texture/Memo", "Controls textures applied to the material and memo notes."), () =>
            {
                FloatDropdownProperty(new GUIContent("Effects", "Special effects using SPH textures:\n- Disabled: No effect.\n- Multi-Sphere: Multiplies a glowing sphere map.\n- Add-Sphere: Creates a glowing sphere map.\n- Sub-Tex: Uses a subtexture on another UV layer for complex effects."), properties, "_EFFECTS", new string[] { "- Disabled", "x Multi-Sphere", "+ Add-Sphere", "Sub-Tex" }, new float[] { 0, 2, 1, 3 });
                GUILayout.Space(10f);
                FloatSliderProperty(new GUIContent("Mask Intensity", "Controls how strongly vertex color masks affect the final texture."), properties, "_MaskIntensity", 0f, 100f);
                TextureProperty(new GUIContent("Texture", "Main texture applied to the material."), properties, "_MainTex");
                TextureProperty(new GUIContent("Texture (R)", "Texture multiplied by the Red vertex color channel."), properties, "_MainTexR");
                TextureProperty(new GUIContent("Texture (G)", "Texture multiplied by the Green vertex color channel."), properties, "_MainTexG");
                TextureProperty(new GUIContent("Texture (B)", "Texture multiplied by the Blue vertex color channel."), properties, "_MainTexB");
                TextureProperty(new GUIContent("Texture (A)", "Texture multiplied by the Alpha vertex color channel."), properties, "_MainTexA");
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

            HeaderGroupGUI.DrawGroup(new GUIContent("Custom Effects Settings", "Controls advanced shading, lighting, and tessellation-related effects."), () =>
            {
                FloatSliderProperty(new GUIContent("Specular Intensity", "Intensity of the specular reflection."), properties, "_SpecularIntensity", 0f, 1f);
                FloatSliderProperty(new GUIContent("SPH Opacity", "Opacity of the SPH reflection map."), properties, "_SPHOpacity", 0f, 1f);
                FloatSliderProperty(new GUIContent("Shadow Luminescence", "Brightness of shadows."), properties, "_ShadowLum", 0f, 10f);
                FloatSliderProperty(new GUIContent("HDR", "HDR lighting intensity."), properties, "_HDR", 1f, 1000f);
                VectorProperty(new GUIContent("Toon Tone", "Toon shading tones applied to the material."), properties, "_ToonTone", 3);
                FloatToggleProperty(new GUIContent("Multiple Lights", "Enable multiple light sources affecting this material."), properties, "_MultipleLights");
                KeywordToggleProperty(new GUIContent("Fog", "Enable fog effect on this material."), properties, "_Fog", "_FOG_ON");
                FloatSliderProperty(new GUIContent("Edge Length", "Controls the tessellation edge length.\nLower values increase tessellation density and surface detail,\nwhile higher values reduce geometry complexity."), properties, "_EdgeLength", 2f, 50f);
                FloatSliderProperty(new GUIContent("Phong Tess Strength", "Controls the strength of Phong tessellation smoothing.\nHigher values create smoother curved surfaces by interpolating normals."), properties, "_PhongTessStrength", 0f, 1f);
                FloatProperty(new GUIContent("Extrusion Amount", "Controls how much the mesh is extruded along its vertex normals.\nUseful for displacement, thickness effects, or stylized deformation."), properties, "_ExtrusionAmount");
            });
        }

        #endregion

        #region === Common Rendering Rules ===

        /// <summary>
        /// Applies shared rendering rules such as transparency,
        /// blending mode behavior, and shadow keyword synchronization.
        /// </summary>
        protected override void ApplyCommonRules()
        {
            var mats = targets.OfType<Material>().ToArray();
            if (mats.Length == 0) return;

            foreach (var mat in mats)
            {
                SetKeyword(mat, "_ALPHATEST_ON", HasFloatPropertyValue(properties, "_AlphaClip", 1));
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