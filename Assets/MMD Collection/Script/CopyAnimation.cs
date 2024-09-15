/*
 * ---------------------------------------------------------------------------
 * Description: This Unity script copies the rotation of bones from one set of transforms (copyBone) to another 
 *              set (pasteBone) in real-time, typically used for animation purposes. This version focuses solely 
 *              on copying rotations without any clamping or limiting options. It allows toggling the update process 
 *              using the 'update' property and ensures the correct matching of bone arrays between the source and target.
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/
using UnityEngine;

[AddComponentMenu("MMD Collection/Copy Animation")]
public class CopyAnimation : MonoBehaviour
{
    [Header("Settings")]
    public bool update = true;  // Toggle for enabling or disabling the update of bone rotations.
    [Header("Copy and Paste Rotations")]
    [SerializeField] private Transform[] copyBone;  // Source bones from which rotations will be copied.
    [Space(10)]
    [SerializeField] private Transform[] pasteBone; // Target bones where the copied rotations will be applied.

    private void LateUpdate()
    {
        if (!update) return; // Exits the function if updates are disabled.

        // Validates that both copy and paste arrays have the same length.
        if (copyBone.Length != pasteBone.Length)
        {
            Debug.LogError("Copy and paste arrays must be of the same length!", this);
            return;
        }

        // Iterates through the bones to copy and apply rotations.
        for (int i = 0; i < copyBone.Length; i++)
        {
            if (copyBone[i] != null && pasteBone[i] != null)
            {
                // Directly copies the rotation from the source bone to the target bone.
                pasteBone[i].rotation = copyBone[i].rotation;
            }
            else
            {
                Debug.LogWarning("Copy or paste transform is null!", this);
            }
        }
    }
}