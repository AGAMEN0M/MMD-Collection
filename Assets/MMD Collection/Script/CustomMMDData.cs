using System.Collections.Generic;
using UnityEngine;

// ScriptableObject to store custom data related to MMD.
public class CustomMMDData : ScriptableObject
{
    [Header("MMD Material Settings")]
    public bool showMoreSystems; // Boolean flag indicating whether to show more shader systems.
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
    public bool useSlider; // Boolean flag indicating whether to use a slider for this material.
}