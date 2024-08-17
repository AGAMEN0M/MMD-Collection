/*
 * ---------------------------------------------------------------------------
 * Description: The CustomMMDData script defines a ScriptableObject used to store custom data related to MMD (MikuMikuDance). 
 *              It includes a boolean flag to control the visibility of shader systems and a list of MMDMaterialInfo objects, 
 *              which contain information about various MMD materials. Each MMDMaterialInfo object stores a reference to a 
 *              Unity Material, along with its name in Japanese and English, and a memo for additional notes.
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/
using System.Collections.Generic;
using UnityEngine;

// ScriptableObject to store custom data related to MMD.
public class CustomMMDData : ScriptableObject
{
    [Header("MMD Material Settings")]
    public bool showSystemsDefault; // Boolean flag indicating whether to show more shader systems.
    public List<MMDMaterialInfo> materialInfoList = new(); // List to store information about MMD materials.
}

// Serializable class to hold information about a specific MMD material.
[System.Serializable]
public class MMDMaterialInfo
{
    public Material mmdMaterial; // Reference to the Unity Material.
    public string materialNameJP; // Material name in Japanese.
    public string materialNameEN; // Material name in English.
    public string materialMeno; // Memo for additional notes about the material.
}