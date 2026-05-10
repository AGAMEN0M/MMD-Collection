/*
 * ---------------------------------------------------------------------------
 * Description: The CustomMMDDataUtilityEditor script is a Unity Editor utility class designed to manage CustomMMDData assets. 
 *              It provides functionality to retrieve or create a CustomMMDData asset, ensuring that there is always an 
 *              instance available. The script searches for an existing asset of type CustomMMDData and creates a new one 
 *              if none is found. It also includes a method to remove invalid materials from the CustomMMDData asset by 
 *              filtering out materials that are null, thus maintaining the integrity of the asset.
 *              
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

using UnityEditor;
using UnityEngine;
using System.IO;

namespace MMDCollection.Editor
{
    /// <summary>
    /// Utility class for managing CustomMMDData assets within the Unity Editor.
    /// /// </summary>
    public static class CustomMMDDataUtilityEditor
    {
        #region === Variables ===

        private static CustomMMDData mmdData; // Stores a reference to the CustomMMDData asset to avoid multiple searches and allow reuse.

        #endregion

        #region === Public Methods ===

        /// <summary>
        /// Retrieves the existing CustomMMDData asset or creates a new one if none exists.
        /// </summary>
        /// <returns>A valid instance of CustomMMDData.</returns>
        public static CustomMMDData GetOrCreateCustomMMDData()
        {
            // Check explicitly for null to avoid Unity null-coalescing issues.
            if (mmdData == null)
            {
                mmdData = FindCustomMMDData();

                if (mmdData == null) mmdData = CreateCustomMMDData();
            }

            return mmdData;
        }

        /// <summary>
        /// Removes any entries with null materials from the CustomMMDData's material list.
        /// </summary>
        /// <param name="customMMDMaterialData">The CustomMMDData asset to clean.</param>
        public static void RemoveInvalidMaterials(CustomMMDData customMMDMaterialData)
        {
            if (customMMDMaterialData == null) return;

            // Remove all material entries where mmdMaterial is null.
            customMMDMaterialData.materialInfoList.RemoveAll(materialInfo => materialInfo.mmdMaterial == null);
        }

        #endregion

        #region === Private Methods ===

        // Finds an existing CustomMMDData asset in the project.
        private static CustomMMDData FindCustomMMDData()
        {
            string[] guids = AssetDatabase.FindAssets("Custom MMD Data t:CustomMMDData");

            if (guids.Length > 0)
            {
                string path = AssetDatabase.GUIDToAssetPath(guids[0]);
                return AssetDatabase.LoadAssetAtPath<CustomMMDData>(path);
            }

            return null;
        }

        // Creates a new CustomMMDData asset.
        private static CustomMMDData CreateCustomMMDData()
        {
            const string folderPath = "Assets/Resources";

            if (!Directory.Exists(folderPath)) Directory.CreateDirectory(folderPath);

            string assetPath = AssetDatabase.GenerateUniqueAssetPath(folderPath + "/Custom MMD Data.asset");
            var customMMDData = ScriptableObject.CreateInstance<CustomMMDData>();

            AssetDatabase.CreateAsset(customMMDData, assetPath);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();

            return customMMDData;
        }

        #endregion
    }
}