/*
 * ---------------------------------------------------------------------------
 * Description: Utility class for rendering MMD bone structures in Unity Editor.
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

using UnityEditor.SceneManagement;
using System.Collections.Generic;
using UnityEngine.Rendering;
using UnityEngine;
using UnityEditor;
using System.Linq;

namespace MMDCollection.BoneRenderer
{
    [InitializeOnLoad]
    public static class MMDBoneRendererUtils
    {
        /// <summary> Internal utility class for batching bone rendering with instanced meshes. </summary>
        private class BatchRenderer
        {
            const int kMaxDrawMeshInstanceCount = 1023;

            public enum SubMeshType { BoneFaces, BoneWire, Count }

            public Mesh mesh;
            public Material material;

            // Lists to store data for each render instance.
        #pragma warning disable IDE0044
            private List<Matrix4x4> m_Matrices = new();
            private List<Vector4> m_Colors = new();
            private List<Vector4> m_Highlights = new();
        #pragma warning restore IDE0044

            /// <summary> Adds a new render instance with matrix, color, and highlight. </summary>
            public void AddInstance(Matrix4x4 matrix, Color color, Color highlight)
            {
                m_Matrices.Add(matrix);
                m_Colors.Add(color);
                m_Highlights.Add(highlight);
            }

            /// <summary> Clears all stored instances. </summary>
            public void Clear()
            {
                m_Matrices.Clear();
                m_Colors.Clear();
                m_Highlights.Clear();
            }

            private static int RenderChunkCount(int totalCount)
            {
                return Mathf.CeilToInt((totalCount / (float)kMaxDrawMeshInstanceCount));
            }

            private static T[] GetRenderChunk<T>(List<T> array, int chunkIndex)
            {
                int rangeCount = (chunkIndex < (RenderChunkCount(array.Count) - 1)) ?
                    kMaxDrawMeshInstanceCount : array.Count - (chunkIndex * kMaxDrawMeshInstanceCount);

                return array.GetRange(chunkIndex * kMaxDrawMeshInstanceCount, rangeCount).ToArray();
            }

            /// <summary> Renders all added mesh instances using batching and GPU instancing. </summary>
            public void Render()
            {
                if (m_Matrices.Count == 0 || m_Colors.Count == 0 || m_Highlights.Count == 0) return;

                int count = System.Math.Min(m_Matrices.Count, System.Math.Min(m_Colors.Count, m_Highlights.Count));

                Material mat = material;
                mat.SetPass(0);

                MaterialPropertyBlock propertyBlock = new();
                CommandBuffer cb = new();
                int chunkCount = RenderChunkCount(count);
                for (int i = 0; i < chunkCount; ++i)
                {
                    cb.Clear();
                    Matrix4x4[] matrices = GetRenderChunk(m_Matrices, i);
                    propertyBlock.SetVectorArray("_Color", GetRenderChunk(m_Colors, i));

                    material.DisableKeyword("WIRE_ON");
                    cb.DrawMeshInstanced(mesh, (int)SubMeshType.BoneFaces, material, 0, matrices, matrices.Length, propertyBlock);
                    Graphics.ExecuteCommandBuffer(cb);

                    cb.Clear();
                    propertyBlock.SetVectorArray("_Color", GetRenderChunk(m_Highlights, i));

                    material.EnableKeyword("WIRE_ON");
                    cb.DrawMeshInstanced(mesh, (int)SubMeshType.BoneWire, material, 0, matrices, matrices.Length, propertyBlock);
                    Graphics.ExecuteCommandBuffer(cb);
                }
            }
        }

        // List of all registered bone renderers.
    #pragma warning disable IDE0044
        private static List<MMDBoneRenderer> s_BoneRendererComponents = new();
    #pragma warning restore IDE0044

        // Lazy initialized batch renderer for pyramid mesh.
        private static BatchRenderer s_PyramidMeshRenderer;

        // Lazy loaded shared material for bone rendering.
        private static Material s_Material;

        private const float k_Epsilon = 1e-5f;
        private const float k_BoneBaseSize = 2f;
        private const float k_BoneTipSize = 0.5f;

        // Hash for GUI control IDs.
    #pragma warning disable IDE0044
        private static int s_ButtonHash = "BoneHandle".GetHashCode();
    #pragma warning restore IDE0044

        // Cached visible layers.
        private static int s_VisibleLayersCache = 0;

        // Static constructor hooks scene events.
        static MMDBoneRendererUtils()
        {
            MMDBoneRenderer.onAddBoneRenderer += OnAddBoneRenderer;
            MMDBoneRenderer.onRemoveBoneRenderer += OnRemoveBoneRenderer;
            SceneVisibilityManager.visibilityChanged += OnVisibilityChanged;
            EditorApplication.hierarchyChanged += OnHierarchyChanged;
            SceneView.duringSceneGui += DrawSkeletons;

            s_VisibleLayersCache = Tools.visibleLayers;
        }

        /// <summary> Gets or creates the material used for rendering bones. </summary>
        private static Material Material
        {
            get
            {
                if (!s_Material)
                {
                    Shader shader = (Shader)EditorGUIUtility.LoadRequired("BoneHandles.shader");
                    s_Material = new Material(shader)
                    {
                        hideFlags = HideFlags.DontSaveInEditor,
                        enableInstancing = true
                    };
                }

                return s_Material;
            }
        }

        /// <summary> Gets or creates the batch renderer for pyramid mesh. </summary>
        private static BatchRenderer PyramidMeshRenderer
        {
            get
            {
                if (s_PyramidMeshRenderer == null)
                {
                    var mesh = new Mesh
                    {
                        name = "BoneRendererPyramidMesh",
                        subMeshCount = (int)BatchRenderer.SubMeshType.Count,
                        hideFlags = HideFlags.DontSave
                    };

                    // Pyramid vertices.
                    Vector3[] vertices = new Vector3[]
                    {
                        new(0f, 1f, 0f),  // Top of the pyramid (0).
                        new(-1f, -1f, -1f), // Base - bottom left corner (1).
                        new(1f, -1f, -1f),  // Base - bottom right corner (2).
                        new(1f, -1f, 1f),   // Base - top right corner (3).
                        new(-1f, -1f, 1f)   // Base - top left corner (4).
                    };
                    mesh.vertices = vertices;

                    // Triangles for solid faces.
                    int[] boneFaceIndices = new int[]
                    {
                        0, 1, 2, // Front face.
                        0, 2, 3, // Right face.
                        0, 3, 4, // Back face.
                        0, 4, 1, // Left face.
                        1, 4, 3, // Base (half 1).
                        1, 3, 2  // Base (half 2).
                    };
                    mesh.SetIndices(boneFaceIndices, MeshTopology.Triangles, (int)BatchRenderer.SubMeshType.BoneFaces);

                    // Lines for wireframe view.
                    int[] boneWireIndices = new int[]
                    {
                        0, 1, 0, 2, 0, 3, 0, 4, 1, 2, 2, 3, 3, 4, 4, 1
                    };
                    mesh.SetIndices(boneWireIndices, MeshTopology.Lines, (int)BatchRenderer.SubMeshType.BoneWire);

                    s_PyramidMeshRenderer = new BatchRenderer()
                    {
                        mesh = mesh,
                        material = Material
                    };
                }

                return s_PyramidMeshRenderer;
            }
        }

        //Computes a transformation matrix for rendering a bone between two points.
        private static Matrix4x4 ComputeBoneMatrix(Vector3 start, Vector3 end, float length, float size)
        {
            // Bone direction (local Y axis of the pyramid).
            Vector3 direction = (end - start).normalized;

            // Tangent perpendicular to the direction of the bone.
            Vector3 tangent = Vector3.Cross(Vector3.up, direction);

            // Correct if it is almost parallel to the up.
            if (tangent.sqrMagnitude < 0.001f)
            {
                tangent = Vector3.Cross(Vector3.right, direction);
            }

            tangent.Normalize();

            // Bitangent orthogonal to the direction and the tangent (local X-axis).
            Vector3 bitangent = Vector3.Cross(direction, tangent);

            // Adjusted scales and position.
            float height = length * 0.5f;
            float baseScale = length * k_BoneBaseSize * size;
            Vector3 pivot = start + direction * height; // Move the mesh up

            return new Matrix4x4(
                new Vector4(bitangent.x * baseScale, bitangent.y * baseScale, bitangent.z * baseScale, 0f), // X axis.
                new Vector4(direction.x * height, direction.y * height, direction.z * height, 0f), // Y axis (height/2).
                new Vector4(tangent.x * baseScale, tangent.y * baseScale, tangent.z * baseScale, 0f), // Z axis.
                new Vector4(pivot.x, pivot.y, pivot.z, 1f)); // Position moved up.
        }

        // Draws all skeletons in the current SceneView based on registered MMDBoneRenderer components.
        private static void DrawSkeletons(SceneView sceneview)
        {
            // Check if the visible layers changed.
            if (Tools.visibleLayers != s_VisibleLayersCache)
            {
                OnVisibilityChanged();
                s_VisibleLayersCache = Tools.visibleLayers;
            }

            var gizmoColor = Gizmos.color;

            PyramidMeshRenderer.Clear(); // Clear previous bone instances.

            // Iterate through all bone renderer components.
            for (var i = 0; i < s_BoneRendererComponents.Count; i++)
            {
                var boneRenderer = s_BoneRendererComponents[i];

                if (boneRenderer == null || boneRenderer.boneRendererList == null || boneRenderer.boneRendererList.Count == 0) continue;

                // Skip bone renderers not in the current prefab stage.
                PrefabStage prefabStage = PrefabStageUtility.GetCurrentPrefabStage();
                if (prefabStage != null)
                {
                    StageHandle stageHandle = prefabStage.stageHandle;
                    if (stageHandle.IsValid() && !stageHandle.Contains(boneRenderer.gameObject)) continue;
                }

                if (boneRenderer.drawBones)
                {
                    // Loop through all BoneRendererData groups.
                    foreach (var boneRendererData in boneRenderer.boneRendererList)
                    {
                        if (boneRendererData == null || boneRendererData.bonesTransform == null || boneRenderer.Bones == null) continue;

                        var color = boneRendererData.boneColor;
                        var size = 0.025f;

                        // Collect visible bones from BoneRendererData.
                        var visibleBones = new HashSet<Transform>();
                        foreach (var boneData in boneRendererData.bonesTransform)
                        {
                            if (boneData != null && boneData.bone != null && boneData.visible)
                            {
                                visibleBones.Add(boneData.bone);
                            }
                        }

                        // Render bone lines.
                        for (var j = 0; j < boneRenderer.Bones.Length; j++)
                        {
                            var bone = boneRenderer.Bones[j];
                            if (bone.first == null || bone.second == null) continue;
                            if (!visibleBones.Contains(bone.first)) continue;
                            if (!AreBonesInSameGroup(boneRenderer.boneRendererList, bone.first, bone.second)) continue;

                            DoBoneRender(bone.first, bone.second, color, size);
                        }

                        // Render bone tips.
                        for (var k = 0; k < boneRenderer.Tips.Length; k++)
                        {
                            var tip = boneRenderer.Tips[k];
                            if (tip == null || !visibleBones.Contains(tip)) continue;

                            DoBoneRender(tip, null, color, size);
                        }

                        // Draw interactive handles for each visible bone.
                        foreach (var boneData in boneRendererData.bonesTransform)
                        {
                            if (boneData == null || boneData.bone == null || !boneData.visible) continue;

                            var transform = boneData.bone;
                            var position = transform.position;
                            var handleSize = boneRenderer.jointSize;

                            var isSelected = Selection.transforms.Contains(transform);
                            Handles.color = isSelected ? Color.yellow : color;

                            if (boneData.move)
                            {
                                Handles.CubeHandleCap(0, position, Quaternion.identity, handleSize, EventType.Repaint);
                            }
                            else
                            {
                                Handles.SphereHandleCap(0, position, Quaternion.identity, handleSize, EventType.Repaint);
                            }
                        }
                    }
                }
            }

            PyramidMeshRenderer.Render(); // Render all queued bone visuals.

            Gizmos.color = gizmoColor; // Restore original gizmo color.
        }

        /// <summary> Checks if two bones are part of the same BoneRendererData group. </summary>
        public static bool AreBonesInSameGroup(List<BoneRendererData> boneRendererList, Transform bone1, Transform bone2)
        {
            if (bone1 == null || bone2 == null) return false;

            foreach (var group in boneRendererList)
            {
                bool foundT1 = false;
                bool foundT2 = false;

                foreach (var bone in group.bonesTransform)
                {
                    if (bone.bone == bone1) foundT1 = true;
                    if (bone.bone == bone2) foundT2 = true;
                    if (foundT1 && foundT2) return true;
                }
            }

            return false;
        }

        // Handles the rendering of a single bone or bone tip with user interaction.
        private static void DoBoneRender(Transform transform, Transform childTransform, Color color, float size)
        {
            Vector3 start = transform.position;
            Vector3 end = childTransform != null ? childTransform.position : start;

            GameObject boneGO = transform.gameObject;

            float length = (end - start).magnitude;
            bool tipBone = (length < k_Epsilon);

            int id = GUIUtility.GetControlID(s_ButtonHash, FocusType.Passive);
            Event evt = Event.current;

            switch (evt.GetTypeForControl(id))
            {
                case EventType.Layout:
                    {
                        HandleUtility.AddControl(id, tipBone ? HandleUtility.DistanceToCircle(start, k_BoneTipSize * size * 0.5f) : HandleUtility.DistanceToLine(start, end));
                        break;
                    }
                case EventType.MouseMove:
                    {
                        if (id == HandleUtility.nearestControl)
                        {
                            HandleUtility.Repaint();
                        }
                        break;
                    }
                case EventType.MouseDown:
                    {
                        if (evt.alt) break;

                        if (HandleUtility.nearestControl == id && evt.button == 0)
                        {
                            if (!SceneVisibilityManager.instance.IsPickingDisabled(boneGO, false))
                            {
                                GUIUtility.hotControl = id;
                                Selection.activeObject = boneGO;
                                evt.Use();

                                // Determine interaction tool for this bone.
                                for (var i = 0; i < s_BoneRendererComponents.Count; i++)
                                {
                                    var boneRenderer = s_BoneRendererComponents[i];
                                    if (boneRenderer == null || boneRenderer.boneRendererList == null) continue;

                                    foreach (var boneRendererData in boneRenderer.boneRendererList)
                                    {
                                        if (boneRendererData == null || boneRendererData.bonesTransform == null) continue;

                                        // Checks if the current transform is in the bonesTransform list.
                                        foreach (var boneData in boneRendererData.bonesTransform)
                                        {
                                            if (boneData != null && boneData.bone == transform)
                                            {
                                                // Sets the correct tool based on boneData properties.
                                                if (boneData.rotate && boneData.move)
                                                {
                                                    Tools.current = Tool.Transform; // Transformation tool.
                                                }
                                                else if (boneData.rotate)
                                                {
                                                    Tools.current = Tool.Rotate; // Rotation tool.
                                                }
                                                else if (boneData.move)
                                                {
                                                    Tools.current = Tool.Move; // Movement tool.
                                                }

                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        break;
                    }
                case EventType.MouseDrag:
                    {
                        if (!evt.alt && GUIUtility.hotControl == id)
                        {
                            if (!SceneVisibilityManager.instance.IsPickingDisabled(boneGO, false))
                            {
                                DragAndDrop.PrepareStartDrag();
                                DragAndDrop.objectReferences = new Object[] { transform };
                                DragAndDrop.StartDrag(ObjectNames.GetDragAndDropTitle(transform));

                                GUIUtility.hotControl = 0;

                                evt.Use();
                            }
                        }
                        break;
                    }
                case EventType.MouseUp:
                    {
                        if (GUIUtility.hotControl == id && (evt.button == 0 || evt.button == 2))
                        {
                            GUIUtility.hotControl = 0;
                            evt.Use();
                        }
                        break;
                    }
                case EventType.Repaint:
                    {
                        Color highlight = color;

                        bool hoveringBone = GUIUtility.hotControl == 0 && HandleUtility.nearestControl == id;
                        hoveringBone = hoveringBone && !SceneVisibilityManager.instance.IsPickingDisabled(transform.gameObject, false);

                        if (hoveringBone)
                        {
                            highlight = Handles.preselectionColor;
                        }
                        else if (Selection.Contains(boneGO) || Selection.activeObject == boneGO)
                        {
                            highlight = Handles.selectedColor;
                        }

                        PyramidMeshRenderer.AddInstance(ComputeBoneMatrix(start, end, length, size), color, highlight);
                    }
                    break;
            }
        }

        /// <summary> Adds a MMDBoneRenderer to the list of renderable components. </summary>
        public static void OnAddBoneRenderer(MMDBoneRenderer obj)
        {
            s_BoneRendererComponents.Add(obj);
        }

        /// <summary> Removes a MMDBoneRenderer from the list of renderable components. </summary>
        public static void OnRemoveBoneRenderer(MMDBoneRenderer obj)
        {
            s_BoneRendererComponents.Remove(obj);
        }

        /// <summary> Called when visibility changes in the scene (e.g., layer change). </summary>
        public static void OnVisibilityChanged()
        {
            foreach(var boneRenderer in s_BoneRendererComponents)
            {
                boneRenderer.Invalidate();
            }

            SceneView.RepaintAll();
        }

        /// <summary> Called when hierarchy changes in the scene. </summary>
        public static void OnHierarchyChanged()
        {
            foreach(var boneRenderer in s_BoneRendererComponents)
            {
                boneRenderer.Invalidate();
            }

            SceneView.RepaintAll();
        }
    }
}