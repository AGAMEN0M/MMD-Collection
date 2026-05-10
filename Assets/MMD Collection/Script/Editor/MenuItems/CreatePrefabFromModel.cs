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

        // Menu item to trigger prefab creation from selected models.
        [MenuItem("Assets/MMD Collection/Create Prefabs From Selected Model", false, 4)]
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

                    if (model != null)
                    {
                        models.Add(model);
                    }
                    else
                    {
                        Debug.LogError($"Failed to load model from path: {modelPath}", obj);
                    }
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

        // Converts a GameObject model into prefabs.
        private static void ConvertModelToPrefab(GameObject model)
        {
            if (model == null) return;

            List<GameObject> createdObjects = new();

            // Convert SkinnedMeshRenderers and MeshFilters into separate GameObjects.
            ConvertComponentsToGameObjects(model.GetComponentsInChildren<SkinnedMeshRenderer>(), createdObjects);
            ConvertComponentsToGameObjects(model.GetComponentsInChildren<MeshFilter>(), createdObjects);

            if (createdObjects.Count > 0)
            {
                CreatePrefab(model, createdObjects);
            }
            else
            {
                Debug.LogError("The selected model does not contain any SkinnedMeshRenderer or MeshFilter components.", model);
            }
        }

        // Generic conversion for SkinnedMeshRenderer or MeshFilter components.
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

        // Creates a new GameObject with a mesh and materials.
        private static GameObject CreateGameObjectWithMesh(Mesh mesh, Material[] materials)
        {
            GameObject emptyObject = new(mesh.name);

            var meshFilter = emptyObject.AddComponent<MeshFilter>();
            var meshRenderer = emptyObject.AddComponent<MeshRenderer>();

            meshFilter.sharedMesh = mesh;
            meshRenderer.sharedMaterials = materials;

            return emptyObject;
        }

        // Creates a prefab from a model and a list of created objects.
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
                if (prefab != null)
                {
                    Debug.Log($"Prefab created and saved at: {prefabPath}");
                }
                else
                {
                    Debug.LogError("Failed to create or save the prefab.");
                }
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