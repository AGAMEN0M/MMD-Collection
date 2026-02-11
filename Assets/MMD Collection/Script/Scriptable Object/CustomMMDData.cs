/*
 * ---------------------------------------------------------------------------
 * Description: The CustomMMDData script defines a ScriptableObject used to store custom data related to MMD (MikuMikuDance). 
 *              It includes a boolean flag to control the visibility of shader systems and a list of MMDMaterialInfo objects, 
 *              which contain information about various MMD materials. Each MMDMaterialInfo object stores a reference to a 
 *              Unity Material, along with its name in Japanese and English, and a memo for additional notes.
 *              
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

using System.Collections.Generic;
using UnityEngine;
using System;

namespace MMDCollection
{
    /// <summary>
    /// ScriptableObject to store custom data related to MMD.
    /// </summary>
    public class CustomMMDData : ScriptableObject
    {
        [Header("MMD Material Settings")]
        [Tooltip("Boolean flag indicating whether to show more shader systems.")]
        public bool showSystemsDefault;

        [Space(10)]

        [Tooltip("List to store information about MMD materials.")]
        public List<MMDMaterialInfo> materialInfoList = new();
    }

    /// <summary>
    /// Serializable class to hold information about a specific MMD material.
    /// </summary>
    [Serializable]
    public class MMDMaterialInfo
    {
        [Tooltip("Reference to the Unity Material.")]
        public Material mmdMaterial;

        [Tooltip("Material name in Japanese.")]
        public string materialNameJP;

        [Tooltip("Material name in English.")]
        public string materialNameEN;

        [TextArea, Tooltip("Memo for additional notes about the material.")]
        public string materialMeno;
    }
}