#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;

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
                        //ChangeShader(materialToConvert, "");
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
                        //ChangeShader(materialToConvert, "");
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
    public static void ChangeShader(Material materialToConvert, string newShaderName)
    {
        Undo.RecordObject(materialToConvert, "Convert Material"); // Record the material change for undo purposes.

        // Get the color from the old shader variable.
        Color oldColor = materialToConvert.GetColor("_Color");
        Color oldColor2 = materialToConvert.GetColor("_Specular");
        Color oldColor3 = materialToConvert.GetColor("_Ambient");

        float oldFloat = materialToConvert.GetFloat("_Shininess");

        //float oldFloat2 = materialToConvert.GetFloat("???");
        //float oldFloat3 = materialToConvert.GetFloat("???");
        //float oldFloat4 = materialToConvert.GetFloat("???");
        //float oldFloat5 = materialToConvert.GetFloat("???");

        //float oldFloat6 = materialToConvert.GetFloat("???");
        Color oldColor4 = materialToConvert.GetColor("_EdgeColor");
        float oldFloat7 = materialToConvert.GetFloat("_EdgeSize");

        Texture oldTexture = materialToConvert.GetTexture("_MainTex");
        Texture oldTexture2 = materialToConvert.GetTexture("_ToonTex");
        Texture oldTexture3 = materialToConvert.GetTexture("_SphereCube");
        //float oldFloat7 = materialToConvert.GetFloat("???");

        materialToConvert.shader = Shader.Find(newShaderName); // Set the new shader for the material.

        // Set the variable color in the new shader.
        materialToConvert.SetColor("_Diffuse", oldColor);
        materialToConvert.SetColor("_Specular", oldColor2);
        materialToConvert.SetColor("_Ambient", oldColor3);

        materialToConvert.SetFloat("_Opaque", oldColor.a);
        materialToConvert.SetFloat("_Reflection", oldFloat);

        //materialToConvert.SetFloat("_2_SIDE", oldFloat2);
        //materialToConvert.SetFloat("_G_SHAD", oldFloat3);
        //materialToConvert.SetFloat("_S_MAP", oldFloat4);
        //materialToConvert.SetFloat("_S_SHAD", oldFloat5);

        //materialToConvert.SetFloat("_On", oldFloat6);
        materialToConvert.SetColor("_Color", oldColor4);
        materialToConvert.SetFloat("_Size", oldFloat7);

        materialToConvert.SetTexture("_Texture", oldTexture);
        materialToConvert.SetTexture("_Toon", oldTexture2);
        materialToConvert.SetTexture("_SPH", oldTexture3);
        //materialToConvert.SetKeyword("_EFFECTS", oldFloat7);

        EditorUtility.SetDirty(materialToConvert); // Mark the material as dirty to ensure the change is saved.
        Debug.Log($"Material shader converted: {materialToConvert.name}"); // Log a message indicating the material shader has been converted.
    }
}
#endif