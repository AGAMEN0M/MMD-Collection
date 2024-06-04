using System.Collections.Generic;
using UnityEngine;

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