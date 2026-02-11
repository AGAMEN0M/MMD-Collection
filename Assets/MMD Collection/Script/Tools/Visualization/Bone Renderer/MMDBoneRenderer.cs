/*
 * ---------------------------------------------------------------------------
 * Description: Editor-only utility component responsible for visualizing
 *              bone hierarchies directly in the Unity Scene view.
 *              This component extracts bone relationships and draws
 *              visual connections and joints for debugging and inspection.
 * 
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

using System.Collections.Generic;
using UnityEngine;
using System;

namespace MMDCollection.BoneRenderer
{
    #region === Data Structures ===

    /// <summary>
    /// Serializable data container that defines a group of bones
    /// and the color used to visualize them in the Scene view.
    /// </summary>
    [Serializable]
    public class BoneRendererData
    {
        [Tooltip("Color used to draw this bone group in the Scene view.")]
        public Color boneColor;

        [Tooltip("List of bone transform data associated with this group.")]
        public List<BonesTransform> bonesTransform = new();
    }

    #endregion

    [ExecuteInEditMode]
    [AddComponentMenu("MMD Collection/Tools/Visualization/Bone Renderer")]
    public class MMDBoneRenderer : MonoBehaviour
    {
    #if UNITY_EDITOR

        #region === Internal Structures ===

        /// <summary>
        /// Represents a pair of transforms used to draw a bone connection line.
        /// </summary>
        public struct TransformPair
        {
            [Tooltip("Parent transform of the bone.")]
            public Transform first;

            [Tooltip("Child transform of the bone.")]
            public Transform second;
        }

        #endregion

        #region === Serialized Fields ===

        [Header("Visualization Settings")]
        [SerializeField, Tooltip("Enables or disables bone visualization in the Scene view.")]
        private bool drawBones = true;

        [SerializeField, Range(0f, 0.5f), Tooltip("Controls the visual size of joint points in the Scene view.")]
        private float jointSize = 0.015f;

        [Space(10)]

        [Header("Bone Groups")]
        [SerializeField, Tooltip("Collection of bone groups, each with its own color and bone data.")]
        private List<BoneRendererData> boneRendererList = new()
        {
            new BoneRendererData
            {
                boneColor = new Color(0f, 0f, 1f, 0.5f),
                bonesTransform = new List<BonesTransform>()
            },
            new BoneRendererData
            {
                boneColor = new Color(1f, 0.5f, 0f, 0.5f),
                bonesTransform = new List<BonesTransform>()
            }
        };

        #endregion

        #region === Cached Runtime Data ===

        /// <summary>
        /// Cached array of bone transform pairs used for line rendering.
        /// </summary>
        private TransformPair[] m_Bones;

        /// <summary>
        /// Cached array of bone tips that have no valid children.
        /// </summary>
        private Transform[] m_Tips;

        #endregion

        #region === Public Properties ===

        /// <summary>
        /// Gets or sets whether bones should be drawn in the Scene view.
        /// </summary>
        public bool DrawBones
        {
            get => drawBones;
            set => drawBones = value;
        }

        /// <summary>
        /// Gets or sets the size of the joint visualization.
        /// </summary>
        public float JointSize
        {
            get => jointSize;
            set => jointSize = value;
        }

        /// <summary>
        /// Gets or sets the list of bone renderer groups.
        /// </summary>
        public List<BoneRendererData> BoneRendererList
        {
            get => boneRendererList;
            set => boneRendererList = value;
        }

        /// <summary>
        /// Gets the extracted bone transform pairs.
        /// </summary>
        public TransformPair[] Bones => m_Bones;

        /// <summary>
        /// Gets the extracted tip transforms.
        /// </summary>
        public Transform[] Tips => m_Tips;

        #endregion

        #region === Events ===

        /// <summary>
        /// Callback invoked when a bone renderer component is enabled.
        /// </summary>
        public delegate void OnAddBoneRendererCallback(MMDBoneRenderer boneRenderer);

        /// <summary>
        /// Callback invoked when a bone renderer component is disabled.
        /// </summary>
        public delegate void OnRemoveBoneRendererCallback(MMDBoneRenderer boneRenderer);

        /// <summary>
        /// Static event fired when a bone renderer is added.
        /// </summary>
        public static OnAddBoneRendererCallback onAddBoneRenderer;

        /// <summary>
        /// Static event fired when a bone renderer is removed.
        /// </summary>
        public static OnRemoveBoneRendererCallback onRemoveBoneRenderer;

        #endregion

        #region === Unity Lifecycle ===

        /// <summary>
        /// Called when the component becomes enabled.
        /// Rebuilds bone data and notifies listeners.
        /// </summary>
        private void OnEnable()
        {
            ExtractBones();
            onAddBoneRenderer?.Invoke(this);
        }

        /// <summary>
        /// Called when the component becomes disabled.
        /// Notifies listeners of removal.
        /// </summary>
        private void OnDisable() => onRemoveBoneRenderer?.Invoke(this);

        #endregion

        #region === Public API ===

        /// <summary>
        /// Forces a recalculation of bone and tip data.
        /// </summary>
        public void Invalidate() => ExtractBones();

        /// <summary>
        /// Clears all extracted bone data.
        /// </summary>
        public void Reset() => ClearBones();

        /// <summary>
        /// Adds a new bone group to the renderer.
        /// </summary>
        /// <param name="color">Visualization color of the group.</param>
        /// <param name="bones">Bone list assigned to the group.</param>
        public void AddBoneGroup(Color color, List<BonesTransform> bones)
        {
            // Ensures the main list exists before adding a new group.
            boneRendererList ??= new List<BoneRendererData>();

            // Creates a new bone group data container.
            var newGroup = new BoneRendererData
            {
                boneColor = color,

                // If the provided list is null, an empty list is created to avoid null references.
                bonesTransform = bones ?? new List<BonesTransform>()
            };

            // Adds the new group to the renderer list.
            boneRendererList.Add(newGroup);

            // Rebuilds internal bone and tip caches to reflect the new data.
            Invalidate();
        }

        /// <summary>
        /// Adds a bone to an existing group.
        /// </summary>
        /// <param name="group">Index of the target group.</param>
        /// <param name="bone">Bone transform data to add.</param>
        public void AddBone(int group, BonesTransform bone)
        {
            // Validates the renderer list before accessing it.
            if (boneRendererList == null) return;

            // Ensures the group index is within valid bounds.
            if (group < 0 || group >= boneRendererList.Count) return;

            // Ignores null bone data to prevent invalid entries.
            if (bone == null || bone.bone == null) return;

            var targetGroup = boneRendererList[group];

            // Ensures the bone list exists for the selected group.
            targetGroup.bonesTransform ??= new List<BonesTransform>();

            // Prevents duplicate bone entries in the same group.
            foreach (var existingBone in targetGroup.bonesTransform)
            {
                if (existingBone != null && existingBone.bone == bone.bone) return;
            }

            // Adds the bone to the selected group.
            targetGroup.bonesTransform.Add(bone);

            // Rebuilds internal bone and tip caches to include the new bone.
            Invalidate();
        }

        #endregion

        #region === Bone Extraction ===

        /// <summary>
        /// Clears cached bone and tip arrays.
        /// </summary>
        public void ClearBones()
        {
            m_Bones = null;
            m_Tips = null;
        }

        /// <summary>
        /// Extracts bone relationships and tip data from the current renderer list.
        /// </summary>
        public void ExtractBones()
        {
            if (boneRendererList == null || boneRendererList.Count == 0)
            {
                ClearBones();
                return;
            }

            // Collects all valid bone transforms into a hash set for fast lookup.
            var transformsHashSet = new HashSet<Transform>();
            foreach (var group in boneRendererList)
            {
                if (group?.bonesTransform == null) continue;
                foreach (var bone in group.bonesTransform)
                {
                    if (bone != null && bone.bone != null) transformsHashSet.Add(bone.bone);
                }
            }

            var bonesList = new List<TransformPair>();
            var tipsList = new List<Transform>();

            foreach (var group in boneRendererList)
            {
                if (group?.bonesTransform == null) continue;
                foreach (var boneData in group.bonesTransform)
                {
                    var transform = boneData?.bone;
                    if (transform == null) continue;

                    // Skips hidden objects in the Scene visibility manager.
                    if (UnityEditor.SceneVisibilityManager.instance.IsHidden(transform.gameObject, false)) continue;

                    // Skips objects outside the visible layer mask.
                    var mask = UnityEditor.Tools.visibleLayers;
                    if ((mask & (1 << transform.gameObject.layer)) == 0) continue;

                    bool hasValidChildren = false;

                    if (transform.childCount > 0)
                    {
                        // Iterates through children and checks for valid bone connections.
                        for (var k = 0; k < transform.childCount; ++k)
                        {
                            var childTransform = transform.GetChild(k);

                            if (transformsHashSet.Contains(childTransform))
                            {
                                bonesList.Add(new TransformPair() { first = transform, second = childTransform });
                                hasValidChildren = true;
                            }
                        }
                    }

                    // If no valid children were found, the bone is considered a tip.
                    if (!hasValidChildren) tipsList.Add(transform);
                }
            }

            m_Bones = bonesList.ToArray();
            m_Tips = tipsList.ToArray();
        }

        #endregion

        #region === Editor Utilities ===

        /// <summary>
        /// Automatically replaces all bone groups by collecting all child transforms.
        /// This method is intended for quick setup and debugging only.
        /// </summary>
        [ContextMenu("Alto Get Bones")]
        public void AltoGetBones()
        {
            bool confirm = UnityEditor.EditorUtility.DisplayDialog(
                "Confirm Operation",
                "Do you want to replace all groups and automatically collect all child objects?\nThe auto function is not the appropriate way to use this tool.",
                "Yes", "Cancel");

            if (!confirm) return;

            var children = GetComponentsInChildren<Transform>(includeInactive: true);
            var boneList = new List<BonesTransform>();

            foreach (var child in children)
            {
                if (child == transform) continue;
                boneList.Add(new BonesTransform
                {
                    bone = child,
                    move = false,
                    rotate = false,
                    visible = true
                });
            }

            boneRendererList = new List<BoneRendererData>
            {
                new() { boneColor = new Color(0f, 0f, 1f, 0.5f), bonesTransform = boneList }
            };

            ExtractBones();
        }

        #endregion

    #endif
    }
}