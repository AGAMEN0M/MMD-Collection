/*
 * ---------------------------------------------------------------------------
 * Description: Editor-only utility responsible for rendering and interacting
 *              with MMD bone structures in the Unity Scene view.
 *              Uses GPU instancing for efficient visualization and supports
 *              selection, highlighting, and transform tools.
 * 
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
        #region === Nested Types ===

        /// <summary>
        /// Internal utility class responsible for batching bone rendering
        /// using GPU instancing.
        /// </summary>
        private class BatchRenderer
        {
            /// <summary>
            /// Maximum number of instances per DrawMeshInstanced call.
            /// </summary>
            const int kMaxDrawMeshInstanceCount = 1023;

            /// <summary>
            /// Defines available sub-mesh types.
            /// </summary>
            public enum SubMeshType
            {
                BoneFaces,
                BoneWire,
                Count
            }

            /// <summary>
            /// Shared mesh used for rendering.
            /// </summary>
            public Mesh mesh;

            /// <summary>
            /// Material used for rendering the mesh.
            /// </summary>
            public Material material;

            // Lists to store data for each render instance.
            private readonly List<Matrix4x4> m_Matrices = new();
            private readonly List<Vector4> m_Colors = new();
            private readonly List<Vector4> m_Highlights = new();

            /// <summary>
            /// Adds a new instance to be rendered.
            /// </summary>
            public void AddInstance(Matrix4x4 matrix, Color color, Color highlight)
            {
                m_Matrices.Add(matrix);
                m_Colors.Add(color);
                m_Highlights.Add(highlight);
            }

            /// <summary>
            /// Clears all stored instance data.
            /// </summary>
            public void Clear()
            {
                m_Matrices.Clear();
                m_Colors.Clear();
                m_Highlights.Clear();
            }

            /// <summary>
            /// Calculates the required number of render chunks.
            /// </summary>
            private static int RenderChunkCount(int totalCount) => Mathf.CeilToInt((totalCount / (float)kMaxDrawMeshInstanceCount));

            /// <summary>
            /// Extracts a chunk of data from a list for instanced rendering.
            /// </summary>
            private static T[] GetRenderChunk<T>(List<T> array, int chunkIndex)
            {
                int rangeCount = (chunkIndex < (RenderChunkCount(array.Count) - 1)) ? kMaxDrawMeshInstanceCount : array.Count - (chunkIndex * kMaxDrawMeshInstanceCount);
                return array.GetRange(chunkIndex * kMaxDrawMeshInstanceCount, rangeCount).ToArray();
            }

            /// <summary>
            /// Renders all queued instances using instanced draw calls.
            /// </summary>
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

        #endregion
        
        #region === Static State ===

        // List of all registered bone renderers.
        private static readonly List<MMDBoneRenderer> s_BoneRendererComponents = new();

        // Lazy initialized batch renderer for pyramid mesh.
        private static BatchRenderer s_PyramidMeshRenderer;

        // Lazy loaded shared material for bone rendering.
        private static Material s_Material;

        // Cached visible layers.
        private static int s_VisibleLayersCache = 0;

        // Hash for GUI control IDs.
        private static readonly int s_ButtonHash = "BoneHandle".GetHashCode();

        #endregion

        #region === Constants ===

        private const float k_Epsilon = 1e-5f;
        private const float k_BoneBaseSize = 2f;
        private const float k_BoneTipSize = 0.5f;

        #endregion

        #region === Static Constructor ===

        /// <summary>
        /// Registers editor callbacks and scene hooks.
        /// </summary>
        static MMDBoneRendererUtils()
        {
            MMDBoneRenderer.onAddBoneRenderer += OnAddBoneRenderer;
            MMDBoneRenderer.onRemoveBoneRenderer += OnRemoveBoneRenderer;

            SceneVisibilityManager.visibilityChanged += OnVisibilityChanged;
            EditorApplication.hierarchyChanged += OnHierarchyChanged;
            SceneView.duringSceneGui += DrawSkeletons;

            s_VisibleLayersCache = Tools.visibleLayers;
        }

        #endregion

        #region === Lazy Resources ===

        /// <summary>
        /// Gets or creates the shared bone rendering material.
        /// </summary>
        private static Material Material
        {
            get
            {
                if (!s_Material)
                {
                    var shader = (Shader)EditorGUIUtility.LoadRequired("BoneHandles.shader");
                    s_Material = new Material(shader)
                    {
                        hideFlags = HideFlags.DontSaveInEditor,
                        enableInstancing = true
                    };
                }

                return s_Material;
            }
        }

        /// <summary>
        /// Gets or creates the pyramid mesh batch renderer.
        /// </summary>
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

        #endregion

        #region === Bone Rendering Core ===

        /// <summary>
        /// Computes the transformation matrix used to render a bone mesh.
        /// </summary>
        /// <param name="start">World-space position of the bone root.</param>
        /// <param name="end">World-space position of the bone tip or child transform.</param>
        /// <param name="length">Distance between the start and end positions of the bone.</param>
        /// <param name="size">Global scale factor applied to the bone thickness.</param>
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

        #endregion

        #region === Scene GUI Rendering ===

        /// <summary>
        /// Draws all registered skeletons in the Scene view.
        /// </summary>
        /// <param name="sceneview">Current SceneView instance responsible for rendering editor gizmos and handles.</param>
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

                if (boneRenderer == null || boneRenderer.BoneRendererList == null || boneRenderer.BoneRendererList.Count == 0) continue;

                // Skip bone renderers not in the current prefab stage.
                var prefabStage = PrefabStageUtility.GetCurrentPrefabStage();
                if (prefabStage != null)
                {
                    var stageHandle = prefabStage.stageHandle;
                    if (stageHandle.IsValid() && !stageHandle.Contains(boneRenderer.gameObject)) continue;
                }

                if (boneRenderer.DrawBones)
                {
                    // Loop through all BoneRendererData groups.
                    foreach (var boneRendererData in boneRenderer.BoneRendererList)
                    {
                        if (boneRendererData == null || boneRendererData.bonesTransform == null || boneRenderer.Bones == null) continue;

                        var color = boneRendererData.boneColor;
                        var size = 0.025f;

                        // Collect visible bones from BoneRendererData.
                        var visibleBones = new HashSet<Transform>();
                        foreach (var boneData in boneRendererData.bonesTransform)
                        {
                            if (boneData != null && boneData.bone != null && boneData.visible) visibleBones.Add(boneData.bone);
                        }

                        // Render bone lines.
                        for (var j = 0; j < boneRenderer.Bones.Length; j++)
                        {
                            var bone = boneRenderer.Bones[j];
                            if (bone.first == null || bone.second == null) continue;
                            if (!visibleBones.Contains(bone.first)) continue;
                            if (!AreBonesInSameGroup(boneRenderer.BoneRendererList, bone.first, bone.second)) continue;

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
                            var handleSize = boneRenderer.JointSize;

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

        #endregion

        #region === Utilities ===

        /// <summary>
        /// Checks if two transforms belong to the same bone group.
        /// </summary>
        /// <param name="boneRendererList">List of bone renderer groups used to determine group membership.</param>
        /// <param name="bone1">First bone transform to compare.</param>
        /// <param name="bone2">Second bone transform to compare.</param>
        /// <returns>
        /// True if both transforms are found within the same bone group; otherwise, false.
        /// </returns>
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

        #endregion

        #region === Registration & Callbacks ===

        /// <summary>
        /// Adds a MMDBoneRenderer to the list of renderable components.
        /// </summary>
        /// <param name="obj">Instance of the MMDBoneRenderer component to be registered for Scene view rendering.</param>
        public static void OnAddBoneRenderer(MMDBoneRenderer obj) => s_BoneRendererComponents.Add(obj);

        /// <summary>
        /// Removes a MMDBoneRenderer from the list of renderable components.
        /// </summary>
        /// <param name="obj">Instance of the MMDBoneRenderer component to be unregistered from Scene view rendering.</param>
        public static void OnRemoveBoneRenderer(MMDBoneRenderer obj) => s_BoneRendererComponents.Remove(obj);

        /// <summary>
        /// Called when visibility changes in the scene (e.g., layer change).
        /// </summary>
        public static void OnVisibilityChanged()
        {
            foreach (var boneRenderer in s_BoneRendererComponents) boneRenderer.Invalidate();
            SceneView.RepaintAll();
        }

        /// <summary>
        /// Called when hierarchy changes in the scene.
        /// </summary>
        public static void OnHierarchyChanged()
        {
            foreach (var boneRenderer in s_BoneRendererComponents) boneRenderer.Invalidate();
            SceneView.RepaintAll();
        }

        #endregion

        #region === Private Methods / Rendering ===

        /// <summary>
        /// Handles the rendering and interaction logic for a single bone or bone tip.
        /// </summary>
        /// <param name="transform">The transform representing the bone root.</param>
        /// <param name="childTransform">Optional child transform representing the bone direction.</param>
        /// <param name="color">Base visualization color of the bone.</param>
        /// <param name="size">Scale factor applied to the bone size.</param>
        private static void DoBoneRender(Transform transform, Transform childTransform, Color color, float size)
        {
            // Defines the start and end positions of the bone.
            Vector3 start = transform.position;
            Vector3 end = childTransform != null ? childTransform.position : start;

            GameObject boneGO = transform.gameObject; // Cached reference to the bone GameObject.

            // Calculates bone length and determines if this is a tip bone.
            float length = (end - start).magnitude;
            bool tipBone = (length < k_Epsilon);

            // Generates a unique control ID for SceneView interaction.
            int id = GUIUtility.GetControlID(s_ButtonHash, FocusType.Passive);
            Event evt = Event.current;

            switch (evt.GetTypeForControl(id))
            {
                case EventType.Layout:
                    {
                        // Registers the selectable area for this bone.
                        HandleUtility.AddControl(id, tipBone ? HandleUtility.DistanceToCircle(start, k_BoneTipSize * size * 0.5f) : HandleUtility.DistanceToLine(start, end));
                        break;
                    }
                case EventType.MouseMove:
                    {
                        // Triggers repaint when hovering this bone.
                        if (id == HandleUtility.nearestControl) HandleUtility.Repaint();
                        break;
                    }
                case EventType.MouseDown:
                    {
                        // Ignores interaction when Alt is pressed (camera controls).
                        if (evt.alt) break;

                        // Handles bone selection on left mouse click.
                        if (HandleUtility.nearestControl == id && evt.button == 0)
                        {
                            if (!SceneVisibilityManager.instance.IsPickingDisabled(boneGO, false))
                            {
                                GUIUtility.hotControl = id;
                                Selection.activeObject = boneGO;
                                evt.Use();

                                // Determines the correct editor tool based on bone settings.
                                for (var i = 0; i < s_BoneRendererComponents.Count; i++)
                                {
                                    var boneRenderer = s_BoneRendererComponents[i];
                                    if (boneRenderer == null || boneRenderer.BoneRendererList == null) continue;

                                    foreach (var boneRendererData in boneRenderer.BoneRendererList)
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
                        // Starts drag-and-drop operation for the bone transform.
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
                        // Releases the control when the mouse button is released.
                        if (GUIUtility.hotControl == id && (evt.button == 0 || evt.button == 2))
                        {
                            GUIUtility.hotControl = 0;
                            evt.Use();
                        }
                        break;
                    }
                case EventType.Repaint:
                    {
                        // Determines highlight color based on hover and selection state.
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

                        // Queues the bone mesh instance for rendering.
                        PyramidMeshRenderer.AddInstance(ComputeBoneMatrix(start, end, length, size), color, highlight);
                    }
                    break;
            }
        }

        #endregion
    }
}