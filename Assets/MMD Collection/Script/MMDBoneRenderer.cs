/*
 * ---------------------------------------------------------------------------
 * Description: Utility component for visualizing bones in the Unity Editor.
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

using System.Collections.Generic;
using UnityEngine;

namespace MMDCollection.BoneRenderer
{
    [ExecuteInEditMode]
    [AddComponentMenu("MMD Collection/Bone Renderer")]
    public class MMDBoneRenderer : MonoBehaviour
    {
#if UNITY_EDITOR
        public bool drawBones = true; // Enables or disables bone drawing in the Scene view.
        [Range(0f, 0.5f)] public float jointSize = 0.015f; // Controls the size of the joint visualization in the Scene view.
        [Space(10)]
        // List of bone groups with associated colors and transform data.
        public List<BoneRendererData> boneRendererList = new()
        {
            new BoneRendererData { boneColor = new Color(0f, 0f, 1f, 0.5f), bonesTransform = new List<BonesTransform>() },
            new BoneRendererData { boneColor = new Color(1f, 0.5f, 0f, 0.5f), bonesTransform = new List<BonesTransform>() }
        };

        /// <summary> Automatically collects all child transforms and populates the bone group list. </summary>
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

        /// <summary> Gets or sets all bone transforms in the renderer list. </summary>
        public Transform[] Transforms
        {
            get
            {
                var result = new List<Transform>();
                foreach (var data in boneRendererList)
                {
                    if (data?.bonesTransform == null) continue;
                    foreach (var boneTransform in data.bonesTransform)
                    {
                        if (boneTransform?.bone != null)
                            result.Add(boneTransform.bone);
                    }
                }
                return result.ToArray();
            }
            set
            {
                boneRendererList = new List<BoneRendererData>();
                if (value != null)
                {
                    var newData = new BoneRendererData
                    {
                        boneColor = new Color(0f, 0f, 1f, 0.5f),
                        bonesTransform = new List<BonesTransform>()
                    };
                    foreach (var t in value)
                    {
                        newData.bonesTransform.Add(new BonesTransform
                        {
                            bone = t,
                            move = false,
                            visible = true
                        });
                    }
                    boneRendererList.Add(newData);
                }
                ExtractBones();
            }
        }

        /// <summary> Structure that holds a pair of bone transforms. </summary>
        public struct TransformPair
        {
            public Transform first;
            public Transform second;
        }

        private TransformPair[] m_Bones;
        private Transform[] m_Tips;

        /// <summary> Array of bone pairs used for drawing bone lines. </summary>
        public TransformPair[] Bones => m_Bones;
        /// <summary> Array of tip bones with no children in the hierarchy. </summary>
        public Transform[] Tips => m_Tips;

        /// <summary> Delegate for add-bone-renderer event. </summary>
        public delegate void OnAddBoneRendererCallback(MMDBoneRenderer boneRenderer);
        /// <summary> Delegate for remove-bone-renderer event. </summary>
        public delegate void OnRemoveBoneRendererCallback(MMDBoneRenderer boneRenderer);

        /// <summary> Static event invoked when a bone renderer is added. </summary>
        public static OnAddBoneRendererCallback onAddBoneRenderer;
        /// <summary> Static event invoked when a bone renderer is removed. </summary>
        public static OnRemoveBoneRendererCallback onRemoveBoneRenderer;

        private void OnEnable()
        {
            ExtractBones();
            onAddBoneRenderer?.Invoke(this);
        }

        private void OnDisable()
        {
            onRemoveBoneRenderer?.Invoke(this);
        }

        /// <summary> Recalculates bones and tips from the current bone list. </summary>
        public void Invalidate()
        {
            ExtractBones();
        }

        /// <summary> Clears all bone references. </summary>
        public void Reset()
        {
            ClearBones();
        }

        /// <summary> Clears the current bone and tip arrays. </summary>
        public void ClearBones()
        {
            m_Bones = null;
            m_Tips = null;
        }

        /// <summary> Extracts and organizes bone and tip data from the renderer list. </summary>
        public void ExtractBones()
        {
            if (boneRendererList == null || boneRendererList.Count == 0)
            {
                ClearBones();
                return;
            }

            var transformsHashSet = new HashSet<Transform>();
            foreach (var group in boneRendererList)
            {
                if (group?.bonesTransform == null) continue;
                foreach (var bone in group.bonesTransform)
                {
                    if (bone != null && bone.bone != null)
                    {
                        transformsHashSet.Add(bone.bone);
                    }
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

                    if (UnityEditor.SceneVisibilityManager.instance.IsHidden(transform.gameObject, false)) continue;

                    var mask = UnityEditor.Tools.visibleLayers;
                    if ((mask & (1 << transform.gameObject.layer)) == 0) continue;

                    bool hasValidChildren = false;

                    if (transform.childCount > 0)
                    {
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

                    if (!hasValidChildren)
                    {
                        tipsList.Add(transform);
                    }
                }
            }

            m_Bones = bonesList.ToArray();
            m_Tips = tipsList.ToArray();
        }
#endif
    }

    /// <summary> Data structure that defines a group of bones and their associated color. </summary>
    [System.Serializable]
    public class BoneRendererData
    {
        public Color boneColor;
        public List<BonesTransform> bonesTransform = new();
    }

    /// <summary> Represents a single bone transform and its visual settings. </summary>
    [System.Serializable]
    public class BonesTransform
    {
        public Transform bone;
        public bool rotate;
        public bool move;
        public bool visible;
    }
}