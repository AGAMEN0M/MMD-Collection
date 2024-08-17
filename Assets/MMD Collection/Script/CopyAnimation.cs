/*
 * ---------------------------------------------------------------------------
 * Description: This Unity script copies the rotation of bones from one set of transforms (copyBone) to another 
 *              set (pasteBone) in real-time, typically used for animation purposes. It includes an option to limit 
 *              the rotation values to a specified maximum and allows toggling updates through the update property. 
 *              The script ensures that the rotation data is copied correctly and clamped within set boundaries if required.
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/
using UnityEngine;

[AddComponentMenu("MMD Collection/Copy Animation")]
public class CopyAnimation : MonoBehaviour
{
    [Header("Settings")]
    public bool update = true;  // Toggle for updating rotations.
    [Header("Copy and Paste Rotations")]
    [SerializeField] private Transform[] copyBone;  // Source bones for copying rotations.
    [Space(10)]
    [SerializeField] private Transform[] pasteBone; // Target bones for pasting rotations.
    [Header("Rotation Limit Settings")]
    [SerializeField] private bool useMaxRotation = false; // Toggle for using max rotation limits.
    [SerializeField] private Vector3 maxRotation = new(10f, 10f, 10f); // Max rotation limits.

    private void LateUpdate()
    {
        // Exit if update is not enabled.
        if (!update) return;

        // Check if the copy and paste arrays are of the same length.
        if (copyBone.Length != pasteBone.Length)
        {
            Debug.LogError("Copy and paste arrays must be of the same length!");
            return;
        }

        // Loop through each bone pair.
        for (int i = 0; i < copyBone.Length; i++)
        {
            if (copyBone[i] != null && pasteBone[i] != null)
            {
                // Copy rotation directly or use clamped rotation.
                pasteBone[i].rotation = useMaxRotation ? ClampRotation(copyBone[i].rotation) : copyBone[i].rotation;
            }
            else
            {
                Debug.LogWarning("Copy or paste transform is null!");
            }
        }
    }

    // Clamps the rotation based on the maxRotation limits.
    private Quaternion ClampRotation(Quaternion rotation)
    {
        Vector3 eulerRotation = rotation.eulerAngles;

        // Clamp each axis if the corresponding max rotation is non-zero.
        if (maxRotation.x != 0f)
        {
            eulerRotation.x = Mathf.Clamp(AdjustRotation(eulerRotation.x), -maxRotation.x, maxRotation.x);
        }
        if (maxRotation.y != 0f)
        {
            eulerRotation.y = Mathf.Clamp(AdjustRotation(eulerRotation.y), -maxRotation.y, maxRotation.y);
        }
        if (maxRotation.z != 0f)
        {
            eulerRotation.z = Mathf.Clamp(AdjustRotation(eulerRotation.z), -maxRotation.z, maxRotation.z);
        }

        return Quaternion.Euler(eulerRotation);
    }

    // Adjusts rotation angle to handle wrapping around 360 degrees.
    private float AdjustRotation(float angle)
    {
        if (angle > 180f)
        {
            angle -= 360f;
        }
        return angle;
    }
}