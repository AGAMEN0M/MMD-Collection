/*
 * ---------------------------------------------------------------------------
 * Description: This Unity script allows for the efficient rendering of multiple instances of a mesh using GPU instancing. 
 *              It supports drawing meshes either in real-time or only when selected in the editor. The script can reuse 
 *              materials across submeshes or assign unique materials to each submesh. It also includes visual debugging 
 *              in the Scene view through Gizmos, indicating the positions of the mesh instances.
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/
using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("MMD Collection/Draw Mesh Instanced")]
public class DrawMeshInstanced : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] private bool OnDrawSelected = false; // Whether to draw the mesh instances only when selected in the editor.
    [SerializeField] private bool reuseMaterials = true; // Whether to reuse materials for submeshes.
    [Space(10)]
    [SerializeField] private List<DrawMeshInstancedList> drawMeshInstancedLists = new(); // List of mesh instance parameters.

    private void Update()
    {
        DrawMesh(); // Call the method to draw mesh instances.
    }

    // Draw mesh instances.
    private void DrawMesh()
    {
        foreach (var drawList in drawMeshInstancedLists)
        {
            // Check if mesh and materials are valid.
            if (drawList.mesh != null && drawList.materials != null && drawList.materials.Length > 0)
            {
                // Iterate over submeshes.
                for (int i = 0; i < drawList.mesh.subMeshCount; i++)
                {
                    Material materialToUse = drawList.materials[i % drawList.materials.Length]; // Select material for the submesh.

                    // Check if materials should not be reused and if all materials have been used.
                    if (!reuseMaterials && i >= drawList.materials.Length)
                    {
                        break; // Exit the loop.
                    }

                    Matrix4x4[] matrices = new Matrix4x4[] { drawList.transform.localToWorldMatrix }; // Array of transformation matrices.
                    Graphics.DrawMeshInstanced(drawList.mesh, i, materialToUse, matrices); // Draw mesh instances.
                }
            }
        }
    }

    // Draw mesh instances when selected in editor.
    private void OnDrawGizmosSelected()
    {
        if (OnDrawSelected)
        {
            DrawMesh(); // Call the method to draw mesh instances.
        }

        Gizmos.color = Color.green; // Set the Gizmo color to green.        
        Gizmos.DrawSphere(transform.position, 0.15f); // Draw a sphere with a radius of 0.5 units.

        // Ensure the list is not empty.
        if (drawMeshInstancedLists.Count > 0)
        {
            foreach (var drawList in drawMeshInstancedLists)
            {
                // Draw a sphere at the position of each transform in the list.
                if (drawList.transform != null)
                {
                    Gizmos.color = Color.red; // Set the Gizmo color to red.
                    Gizmos.DrawSphere(drawList.transform.position, 0.15f); // Draw a sphere with a radius of 0.5 units.
                }
            }
        }
    }
}

[System.Serializable]
public class DrawMeshInstancedList
{
    public Transform transform; // Transform defining position, rotation, and scale of instances.
    [Space(5)]
    public Mesh mesh; // Mesh to be instanced.
    [Space(5)]
    [Tooltip("Materials must support 'Enable GPU Instancing'")]
    public Material[] materials; // Materials to be applied to instances.
}