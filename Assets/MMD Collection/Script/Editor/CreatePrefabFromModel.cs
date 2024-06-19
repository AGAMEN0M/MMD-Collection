using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;

public class CreatePrefabFromModel : EditorWindow
{
    // Menu item to trigger prefab creation from selected models.
    [MenuItem("Assets/MMD Collection/Create Prefabs From Selected Model")]
    private static void CreatePrefabsFromModel()
    {
        // Get selected objects in Unity Editor.
        Object[] selectedObjects = Selection.objects;
        List<GameObject> models = new();

        // Iterate through selected objects.
        foreach (Object obj in selectedObjects)
        {
            // Check if selected object is a GameObject and a model prefab.
            if (obj is GameObject selectedObject && PrefabUtility.GetPrefabAssetType(selectedObject) == PrefabAssetType.Model)
            {
                // Get the asset path of the selected model.
                string modelPath = AssetDatabase.GetAssetPath(selectedObject);
                GameObject model = AssetDatabase.LoadAssetAtPath<GameObject>(modelPath);

                // Check if model is successfully loaded.
                if (model != null)
                {
                    models.Add(model); // Add the model to list of models to process.
                }
                else
                {
                    Debug.LogError($"Failed to load model from path: {modelPath}");
                }
            }
        }

        // Process each model found.
        foreach (GameObject model in models)
        {
            ModelConverter(model); // Convert the model into prefabs.
        }

        // If no valid models were found, issue a warning.
        if (models.Count == 0)
        {
            Debug.LogWarning("Select one or more valid 3D model files to create Prefabs.");
        }
    }

    // Converts a GameObject model into prefabs.
    private static void ModelConverter(GameObject model)
    {
        List<GameObject> createdObjects = new();

        // Get all SkinnedMeshRenderer components in the model.
        SkinnedMeshRenderer[] skinnedMeshRenderers = model.GetComponentsInChildren<SkinnedMeshRenderer>();

        // Get all MeshFilter components in the model.
        MeshFilter[] meshFilters = model.GetComponentsInChildren<MeshFilter>();

        // If there are no skinned mesh renderers or mesh filters, issue an error.
        if (skinnedMeshRenderers.Length == 0 && meshFilters.Length == 0)
        {
            Debug.LogError("The selected model does not contain any SkinnedMeshRenderer or MeshFilter components.");
            return;
        }

        // Convert each SkinnedMeshRenderer component into a separate GameObject.
        SkinnedMeshRendererConverter(skinnedMeshRenderers, createdObjects);

        // Convert each MeshFilter component into a separate GameObject.
        MeshFilterConverter(meshFilters, createdObjects);

        // If valid objects were created, create a prefab from them.
        if (createdObjects.Count > 0)
        {
            CreatePrefab(model, createdObjects);
        }
    }

    // Converts an array of SkinnedMeshRenderer components into GameObjects.
    private static void SkinnedMeshRendererConverter(SkinnedMeshRenderer[] skinnedMeshRenderers, List<GameObject> createdObjects)
    {
        foreach (SkinnedMeshRenderer skinnedMeshRenderer in skinnedMeshRenderers)
        {
            // Create a new GameObject with the mesh and materials of the skinned mesh renderer.
            GameObject emptyObject = CreateGameObjectWithMesh(skinnedMeshRenderer.sharedMesh, skinnedMeshRenderer.sharedMaterials);
            createdObjects.Add(emptyObject); // Add the created GameObject to the list.
        }
    }

    // Converts an array of MeshFilter components into GameObjects.
    private static void MeshFilterConverter(MeshFilter[] meshFilters, List<GameObject> createdObjects)
    {
        foreach (MeshFilter meshFilter in meshFilters)
        {
            // Check if the MeshFilter has a MeshRenderer component.
            if (meshFilter.TryGetComponent<MeshRenderer>(out var meshRenderer))
            {
                // Create a new GameObject with the mesh and materials of the mesh filter.
                GameObject emptyObject = CreateGameObjectWithMesh(meshFilter.sharedMesh, meshRenderer.sharedMaterials);
                createdObjects.Add(emptyObject); // Add the created GameObject to the list.
            }
            else
            {
                Debug.LogError("MeshFilter does not have a MeshRenderer.");
            }
        }
    }

    // Creates a new GameObject with a mesh and materials.
    private static GameObject CreateGameObjectWithMesh(Mesh mesh, Material[] materials)
    {
        // Create a new GameObject with the name of the mesh.
        GameObject emptyObject = new(mesh.name);

        // Add MeshFilter and MeshRenderer components to the GameObject.
        MeshFilter meshFilter = emptyObject.AddComponent<MeshFilter>();
        MeshRenderer meshRenderer = emptyObject.AddComponent<MeshRenderer>();

        // Assign the mesh and materials to the MeshFilter and MeshRenderer components.
        meshFilter.sharedMesh = mesh;
        meshRenderer.sharedMaterials = materials;

        return emptyObject; // Return the created GameObject.
    }

    // Creates a prefab from a model and a list of created objects.
    private static void CreatePrefab(GameObject model, List<GameObject> createdObjects)
    {
        // Check if there are any valid objects created.
        if (createdObjects == null || createdObjects.Count == 0)
        {
            Debug.LogError("No valid objects created to make a prefab.");
            return;
        }

        GameObject createObject;
        string modelName = $"{model.name} (Prefab)";

        // If only one object was created, use it as the prefab.
        if (createdObjects.Count == 1)
        {
            createObject = createdObjects[0];
            createObject.name = modelName; // Rename the object.
        }
        else
        {
            // Otherwise, create a new empty GameObject and parent all created objects under it.
            createObject = new GameObject(modelName);
            foreach (GameObject obj in createdObjects)
            {
                obj.transform.SetParent(createObject.transform);
            }
        }

        // Get the directory path of the model.
        string modelParentDirectory = Path.GetDirectoryName(AssetDatabase.GetAssetPath(model));        
        string prefabPath = $"{modelParentDirectory}/{modelName}.prefab"; // Construct the prefab path.

        try
        {
            // Save the created object as a prefab at the specified path.
            GameObject prefab = PrefabUtility.SaveAsPrefabAsset(createObject, prefabPath);

            // Log success message if prefab creation was successful.
            if (prefab != null)
            {
                Debug.Log($"Prefab created and saved at: {prefabPath}");
            }
            else
            {
                Debug.LogError("Failed to create or save the prefab.");
            }
        }
        // Catch any exceptions that occur during prefab saving.
        catch (System.Exception e)
        {
            Debug.LogError($"Error saving prefab: {e.Message}");
        }
        // Ensure the created object is destroyed after saving the prefab.
        finally
        {
            DestroyImmediate(createObject);
        }
    }
}