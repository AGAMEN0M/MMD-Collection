/*
 * ---------------------------------------------------------------------------
 * Description: This system defines the core data container for the MMD Collection framework,
 *              providing a centralized ScriptableObject used to store material metadata
 *              and global configuration flags for MikuMikuDance (MMD) related rendering systems.
 *
 *              The CustomMMDData asset acts as a lightweight database for mapping Unity Materials
 *              to their corresponding MMD metadata, including localized naming (Japanese/English)
 *              and developer notes for pipeline organization and shader debugging.
 *
 *              Additionally, an editor-only startup utility ensures that exactly one instance
 *              of this data asset exists inside the project structure under the "MMD Collection"
 *              folder hierarchy, automatically generating it inside a Resources directory if missing.
 *
 *              This guarantees predictable access patterns via Resources.Load while avoiding
 *              duplicate asset creation during domain reloads.
 *
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

using System.Collections.Generic;
using UnityEngine;
using System;

#if UNITY_EDITOR
using UnityEditor;
using System.IO;
#endif

namespace MMDCollection
{
    #region === Data Model (Runtime + Editor) ===

    /// <summary>
    /// Central ScriptableObject database for storing MMD-related material metadata
    /// and global configuration flags used across the MMD Collection framework.
    /// </summary>
    public class CustomMMDData : ScriptableObject
    {
        [Header("MMD Material Settings")]
        [Tooltip("Defines whether extended shader system information should be displayed in editor tools.")]
        public bool showSystemsDefault;

        [Space(10)]

        [Tooltip("Database of MMD materials and their associated metadata.")]
        public List<MMDMaterialInfo> materialInfoList = new();
    }

    /// <summary>
    /// Represents a single entry in the MMD material database,
    /// containing localization data and optional developer metadata.
    /// </summary>
    [Serializable]
    public class MMDMaterialInfo
    {
        [Tooltip("Reference to the Unity Material associated with this MMD entry.")]
        public Material mmdMaterial;

        [Tooltip("Material display name in Japanese (used for original MMD compatibility).")]
        public string materialNameJP;

        [Tooltip("Material display name in English (used for editor readability and tooling).")]
        public string materialNameEN;

        [TextArea, Tooltip("Optional developer memo for debugging, shader notes, or pipeline references.")]
        public string materialMeno;
    }

    #endregion

#if UNITY_EDITOR

    #region === Editor Initialization & Asset Bootstrap ===

    /// <summary>
    /// Editor-only bootstrap system responsible for ensuring the existence
    /// of a single CustomMMDData asset inside the project structure.
    ///
    /// This avoids duplicate database assets and guarantees a consistent
    /// entry point for all MMD tooling systems.
    /// </summary>
    [InitializeOnLoad]
    public static class CustomMMDDataStartup
    {
        private const string AssetName = "Custom MMD Data.asset";
        private const string ResourcesFolderName = "Resources";
        private const string FolderName = "MMD Collection";

        /// <summary>
        /// Automatically executed when the Unity Editor reloads assemblies.
        /// Schedules initialization of the MMD data asset.
        /// </summary>
        static CustomMMDDataStartup()
        {
            EditorApplication.delayCall += Initialize;
        }

        /// <summary>
        /// Ensures that the CustomMMDData asset exists exactly once in the project.
        /// If missing, it will be generated inside the MMD Collection/Resources folder.
        /// </summary>
        private static void Initialize()
        {
            // Check if the asset already exists anywhere in the project.
            string[] guids = AssetDatabase.FindAssets("t:CustomMMDData");

            if (guids.Length > 0) return;

            // Resolve base folder location for MMD Collection system.
            string baseFolderPath = FindMMDCollectionFolder();

            if (string.IsNullOrEmpty(baseFolderPath))
            {
                Debug.LogWarning("Folder 'MMD Collection' not found. Using Assets as fallback.");
                baseFolderPath = "Assets";
            }

            // Ensure Resources folder exists inside target directory.
            string resourcesPath = $"{baseFolderPath}/{ResourcesFolderName}";

            if (!AssetDatabase.IsValidFolder(resourcesPath))
                AssetDatabase.CreateFolder(baseFolderPath, ResourcesFolderName);

            // Create and register the ScriptableObject asset.
            var asset = ScriptableObject.CreateInstance<CustomMMDData>();
            string assetPath = $"{resourcesPath}/{AssetName}";

            AssetDatabase.CreateAsset(asset, assetPath);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();

            Debug.Log($"[MMDCollection] CustomMMDData created at: {assetPath}");
        }

        /// <summary>
        /// Searches the Unity project for the root "MMD Collection" folder.
        /// </summary>
        /// <returns>Full project-relative path if found; otherwise null.</returns>
        private static string FindMMDCollectionFolder()
        {
            string[] guids = AssetDatabase.FindAssets($"{FolderName} t:Folder");

            foreach (string guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                if (Path.GetFileName(path) == FolderName) return path;
            }

            return null;
        }
    }

    #endregion

#endif
}