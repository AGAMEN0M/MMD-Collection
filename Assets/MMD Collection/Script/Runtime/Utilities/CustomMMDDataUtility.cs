/*
 * ---------------------------------------------------------------------------
 * Description: This utility provides centralized access and maintenance operations for the
 *              CustomMMDData database used throughout the MMD Collection framework.
 *
 *              The system is responsible for safely loading and caching the global
 *              CustomMMDData asset from Unity's Resources system, ensuring efficient reuse
 *              without repeated asset lookups during editor or runtime operations.
 *
 *              Additionally, the utility includes validation and cleanup helpers designed
 *              to maintain database integrity by removing invalid or missing material
 *              references from the material metadata collection.
 *
 *              This class acts as the primary access layer for all systems that require
 *              interaction with MMD material metadata and configuration settings.
 *              
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

using UnityEngine;

namespace MMDCollection
{
    /// <summary>
    /// Central utility responsible for loading, caching, and maintaining
    /// the CustomMMDData database used by the MMD Collection framework.
    /// </summary>
    public static class CustomMMDDataUtility
    {
        #region === Cached Data ===

        /// <summary>
        /// Cached reference to the loaded CustomMMDData asset.
        /// Prevents repeated Resources.Load operations.
        /// </summary>
        private static CustomMMDData cachedData;

        #endregion

        #region === Public API ===

        /// <summary>
        /// Retrieves the global CustomMMDData asset from the Resources folder.
        /// Uses an internal cache to avoid repeated loading operations.
        /// </summary>
        /// <returns>Valid CustomMMDData instance if found; otherwise null.</returns>
        public static CustomMMDData GetCustomMMDData()
        {
            // Return cached asset if already loaded.
            if (cachedData != null) return cachedData;

            // Attempt to load the database asset from Resources.
            var languageData = Resources.Load<CustomMMDData>("Custom MMD Data");

            // Validate load result.
            if (languageData == null)
            {
                Debug.LogError("Failed to load 'Custom MMD Data' from Resources. Ensure the asset exists and is located inside a Resources folder.");
                return null;
            }

            // Cache the loaded asset for future access.
            cachedData = languageData;
            return languageData;
        }

        /// <summary>
        /// Removes invalid material entries from the CustomMMDData database.
        /// Any entry with a missing material reference will be removed.
        /// </summary>
        /// <param name="customMMDData">Target database asset to validate and clean.</param>
        public static void RemoveInvalidMaterials(CustomMMDData customMMDMaterialData)
        {
            // Validate input reference.
            if (customMMDMaterialData == null) return;

            // Remove entries with missing material references.
            customMMDMaterialData.materialInfoList.RemoveAll(materialInfo => materialInfo.mmdMaterial == null);
        }

        #endregion
    }
}