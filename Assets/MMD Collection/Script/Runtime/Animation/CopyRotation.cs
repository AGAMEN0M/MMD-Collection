/*
 * ---------------------------------------------------------------------------
 * Description: This Unity component copies the world rotation from a source bone list
 *              to a target bone list during LateUpdate. It is intended for animation
 *              synchronization scenarios, such as retargeting or runtime bone mirroring.
 *
 *              This version focuses exclusively on rotation copying, without clamping,
 *              limits, or interpolation. The process can be enabled or disabled at runtime.
 *
 * Author: Lucas Gomes Cecchini.
 * Pseudonym: AGAMENOM.
 * ---------------------------------------------------------------------------
*/

using UnityEngine;

namespace MMDCollection
{
    [AddComponentMenu("MMD Collection/Animation/Copy Rotation")]
    public class CopyRotation : MonoBehaviour
    {
        #region === Inspector Fields ===

        [Header("Settings")]
        [SerializeField, Tooltip("Enables or disables the bone rotation copy process.")]
        private bool isCopyEnabled = true;

        [Header("Copy and Paste Rotations")]
        [SerializeField, Tooltip("Source bones from which rotations will be copied.")]
        private Transform[] copyBones;

        [Space(10f)]

        [SerializeField, Tooltip("Target bones that will receive the copied rotations.")]
        private Transform[] pasteBones;

        #endregion

        #region === Public Properties ===

        /// <summary>
        /// Gets or sets whether the rotation copy process is enabled.
        /// </summary>
        public bool IsCopyEnabled
        {
            get => isCopyEnabled;
            set => isCopyEnabled = value;
        }

        /// <summary>
        /// Gets or sets the source bones used for copying rotations.
        /// </summary>
        public Transform[] CopyBones
        {
            get => copyBones;
            set => copyBones = value;
        }

        /// <summary>
        /// Gets or sets the target bones that receive copied rotations.
        /// </summary>
        public Transform[] PasteBones
        {
            get => pasteBones;
            set => pasteBones = value;
        }

        #endregion

        #region === Unity Callbacks ===

        /// <summary>
        /// Copies bone rotations from the source list to the target list.
        /// Executed during LateUpdate to ensure animation consistency.
        /// </summary>
        private void LateUpdate()
        {
            // Stops execution if the copy process is disabled.
            if (!isCopyEnabled) return;

            // Validates that both bone arrays exist.
            if (copyBones == null || pasteBones == null)
            {
                Debug.LogWarning("Copy or paste bone array is null.", this);
                return;
            }

            // Ensures both arrays have the same length to avoid index errors.
            if (copyBones.Length != pasteBones.Length)
            {
                Debug.LogError("CopyBones and PasteBones must have the same length.", this);
                return;
            }

            // Iterates through each bone pair and applies rotation copying.
            for (int i = 0; i < copyBones.Length; i++)
            {
                // Skips invalid references to avoid runtime exceptions.
                if (copyBones[i] == null || pasteBones[i] == null)
                {
                    Debug.LogWarning("Copy or paste transform is null!", this);
                    continue;
                }

                // Copies the world rotation from source to target bone.
                pasteBones[i].rotation = copyBones[i].rotation;
            }
        }

        #endregion
    }
}