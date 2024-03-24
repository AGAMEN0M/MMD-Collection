using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

// Utility class for managing CustomMMDData assets within the Unity Editor.
public static class CustomMMDDataUtilityEditor
{
    // Retrieves or creates the CustomMMDData asset.
    public static CustomMMDData GetOrCreateCustomMMDData()
    {
        // Attempt to find an existing CustomMMDData asset.
        CustomMMDData customMMDData = FindCustomMMDData();

        // If not found, create a new one.
        #pragma warning disable IDE0270
        if (customMMDData == null)
        {
            customMMDData = CreateCustomMMDData();
        }
        #pragma warning restore IDE0270

        return customMMDData;
    }

    // Finds an existing CustomMMDData asset in the project.
    private static CustomMMDData FindCustomMMDData()
    {
        string[] guids = AssetDatabase.FindAssets("Custom MMD Data t:CustomMMDData"); // Search for assets with the specified type.

        // If found, load the first asset.
        if (guids.Length > 0)
        {
            string path = AssetDatabase.GUIDToAssetPath(guids[0]);
            return AssetDatabase.LoadAssetAtPath<CustomMMDData>(path);
        }

        return null; // No existing asset found.
    }

    // Creates a new CustomMMDData asset.
    private static CustomMMDData CreateCustomMMDData()
    {
        string folderPath = "Assets/Resources"; // Set folder path.

        // Check if the folder exists; if not, create it.
        if (!Directory.Exists(folderPath))
        {
            Directory.CreateDirectory(folderPath);
        }

        string assetPath = AssetDatabase.GenerateUniqueAssetPath(folderPath + "/Custom MMD Data.asset");
        CustomMMDData customMMDData = ScriptableObject.CreateInstance<CustomMMDData>(); // Create a new instance of CustomMMDData.

        // Create the asset and save it.
        AssetDatabase.CreateAsset(customMMDData, assetPath);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        return customMMDData; // Return the newly created asset.
    }

    // Removes any invalid materials from the CustomMMDData asset.
    public static void RemoveInvalidMaterials(CustomMMDData customMMDMaterialData)
    {
        // Ensure the asset is not null.
        if (customMMDMaterialData == null)
        {
            return; // Exit if the asset is null.
        }

        List<MMDMaterialInfo> validMaterials = new(); // Create a list to store valid materials.

        // Iterate through each material info in the asset.
        foreach (MMDMaterialInfo materialInfo in customMMDMaterialData.materialInfoList)
        {
            // Check if the material reference is not null.
            if (materialInfo.mmdMaterial != null)
            {
                validMaterials.Add(materialInfo); // Add to the valid materials list.
            }
        }

        customMMDMaterialData.materialInfoList = validMaterials; // Replace the material info list with the list of valid materials.
    }
}