/*
 * ---------------------------------------------------------------------------
 * Description: This Unity Editor script allows users to create prefabs from selected 3D model assets. 
 *              It extracts all SkinnedMeshRenderer and MeshFilter components from the models and converts them into 
 *              separate GameObjects. These GameObjects are then combined into a prefab, which is saved in the same 
 *              directory as the original model. The script ensures that the generated prefabs retain the original mesh 
 *              and material data.
 *              
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

namespace MMDCollection.Editor
{
    public static class CreatePrefabFromModel
    {
        #region === Menu Methods ===

        /// <summary>
        /// Menu item to trigger prefab creation from selected models.
        /// </summary>
        [MenuItem("Assets/Tools/MMD Collection/Create Prefabs From Selected Model")]
        private static void CreatePrefabsFromModel()
        {
            var selectedObjects = Selection.objects;
            List<GameObject> models = new();

            // Filter only valid model prefabs from selection.
            foreach (var obj in selectedObjects)
            {
                if (obj is GameObject selectedObject && PrefabUtility.GetPrefabAssetType(selectedObject) == PrefabAssetType.Model)
                {
                    string modelPath = AssetDatabase.GetAssetPath(selectedObject);
                    var model = AssetDatabase.LoadAssetAtPath<GameObject>(modelPath);

                    if (model != null) models.Add(model);
                    else Debug.LogError($"Failed to load model from path: {modelPath}", obj);
                }
            }

            if (models.Count == 0)
            {
                Debug.LogWarning("Select one or more valid 3D model files to create Prefabs.");
                return;
            }

            // Convert each valid model into prefab.
            foreach (var model in models) ConvertModelToPrefab(model);
        }

        #endregion

        #region === Conversion Methods ===

        /// <summary>
        /// Converts a GameObject model into prefabs.
        /// </summary>
        /// <param name="model">The source model GameObject that will be converted into one or more prefab objects.</param>
        private static void ConvertModelToPrefab(GameObject model)
        {
            if (model == null) return;

            List<GameObject> createdObjects = new();

            // Convert SkinnedMeshRenderers and MeshFilters into separate GameObjects.
            ConvertComponentsToGameObjects(model.GetComponentsInChildren<SkinnedMeshRenderer>(), createdObjects);
            ConvertComponentsToGameObjects(model.GetComponentsInChildren<MeshFilter>(), createdObjects);

            if (createdObjects.Count > 0) CreatePrefab(model, createdObjects);
            else Debug.LogError("The selected model does not contain any SkinnedMeshRenderer or MeshFilter components.", model);
        }

        /// <summary>
        /// Generic conversion for SkinnedMeshRenderer or MeshFilter components.
        /// </summary>
        /// <param name="components">Array of components that contain mesh and material data to extract.</param>
        /// <param name="createdObjects">List used to store all generated GameObjects created from the extracted mesh data.</param>
        private static void ConvertComponentsToGameObjects<T>(T[] components, List<GameObject> createdObjects)
        {
            foreach (var component in components)
            {
                if (component == null) continue;

                Mesh mesh;
                Material[] materials;

                // Handle SkinnedMeshRenderer
                if (component is SkinnedMeshRenderer smr)
                {
                    mesh = smr.sharedMesh;
                    materials = smr.sharedMaterials;
                }
                // Handle MeshFilter with MeshRenderer
                else if (component is MeshFilter mf && mf.TryGetComponent<MeshRenderer>(out var mr))
                {
                    mesh = mf.sharedMesh;
                    materials = mr.sharedMaterials;
                }
                else
                {
                    Debug.LogError($"Component '{component}' is not a valid mesh renderer or lacks materials.");
                    continue;
                }

                if (mesh != null && materials != null)
                {
                    var obj = CreateGameObjectWithMesh(mesh, materials);
                    createdObjects.Add(obj);
                }
            }
        }

        #endregion

        #region === Utility Methods ===

        /// <summary>
        /// Creates a new GameObject with a mesh and materials.
        /// </summary>
        /// <param name="mesh">The mesh assigned to the generated MeshFilter component.</param>
        /// <param name="materials">The materials assigned to the generated MeshRenderer component.</param>
        /// <returns>The newly created GameObject containing the mesh and renderer components.</returns>
        private static GameObject CreateGameObjectWithMesh(Mesh mesh, Material[] materials)
        {
            GameObject emptyObject = new(mesh.name);

            var meshFilter = emptyObject.AddComponent<MeshFilter>();
            var meshRenderer = emptyObject.AddComponent<MeshRenderer>();

            meshFilter.sharedMesh = mesh;
            meshRenderer.sharedMaterials = materials;

            return emptyObject;
        }

        /// <summary>
        /// Creates a prefab from a model and a list of created objects.
        /// </summary>
        /// <param name="model">The original source model used as the base reference for the prefab name and save location.</param>
        /// <param name="createdObjects">List of generated GameObjects that will be combined and saved as a prefab.</param>
        private static void CreatePrefab(GameObject model, List<GameObject> createdObjects)
        {
            if (createdObjects == null || createdObjects.Count == 0)
            {
                Debug.LogError("No valid objects created to make a prefab.");
                return;
            }

            GameObject prefabRoot;
            string modelName = $"{model.name} (Prefab)";

            // Single object case
            if (createdObjects.Count == 1)
            {
                prefabRoot = createdObjects[0];
                prefabRoot.name = modelName;
            }
            else
            {
                // Multiple objects case
                prefabRoot = new GameObject(modelName);
                foreach (var obj in createdObjects) obj.transform.SetParent(prefabRoot.transform);
            }

            string modelDir = Path.GetDirectoryName(AssetDatabase.GetAssetPath(model));
            string prefabPath = $"{modelDir}/{modelName}.prefab";

            try
            {
                var prefab = PrefabUtility.SaveAsPrefabAsset(prefabRoot, prefabPath);
                if (prefab != null) Debug.Log($"Prefab created and saved at: {prefabPath}");
                else Debug.LogError("Failed to create or save the prefab.");
            }
            catch (System.Exception e)
            {
                Debug.LogError($"Error saving prefab: {e.Message}");
            }
            finally
            {
                Object.DestroyImmediate(prefabRoot);
            }
        }

        #endregion
    }
}