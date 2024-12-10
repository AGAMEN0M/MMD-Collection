using System.Collections.Generic;
using UnityEngine.SceneManagement;
using UnityEngine;

[ExecuteInEditMode]
public class GlobalLightManager : MonoBehaviour
{
    [SerializeField][ColorUsage(true, true)] private Color lightColor;
    [SerializeField] private List<Light> allDirectionalLights;

    private bool baked = false;
    private static GlobalLightManager instance;

    [RuntimeInitializeOnLoadMethod]
    private static void InitializeOnLoad()
    {
        if (instance != null) return; // Prevent multiple instances
        GameObject globalLightManager = new("[GlobalLightManager]");
        instance = globalLightManager.AddComponent<GlobalLightManager>();
        DontDestroyOnLoad(globalLightManager);
    }

    private void OnEnable()
    {
        SceneManager.sceneLoaded += OnSceneLoaded; // Add event for scene loading
        OnSceneLoaded(SceneManager.GetActiveScene(), LoadSceneMode.Single); // Call immediately for the current scene
    }

    private void OnDisable()
    {
        SceneManager.sceneLoaded -= OnSceneLoaded; // Remove event when disabled
    }

    private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        GetAllDirectionalLights(); // Update directional lights

        if (AreAllLightsBaked())
        {
            baked = true;
            UpdateLightColor(); // Update light color if baked
        }
        else
        {
            baked = false; // Reset baked status if any light is not baked
        }
    }

    private void GetAllDirectionalLights()
    {
        // Get all lights (including inactive) in the current scene
        var allLights = FindObjectsByType<Light>(FindObjectsSortMode.None);
        allDirectionalLights = new List<Light>(System.Array.FindAll(allLights, light => light.type == LightType.Directional && light.enabled));
    }

    private bool AreAllLightsBaked()
    {
        // Check if all directional lights are baked
        foreach (Light light in allDirectionalLights)
        {
            if (light.lightmapBakeType != LightmapBakeType.Baked)
            {
                return false; // Return false if any light is not baked
            }
        }
        return true; // Return true if all lights are baked
    }

    private void Update()
    {
        if (!baked) UpdateLightColor(); // Update light color if not baked
    }

    private void UpdateLightColor()
    {
        if (allDirectionalLights == null || allDirectionalLights.Count == 0)
        {
            Shader.SetGlobalColor("_GlobalLightColor", Color.black); // Reset global light color if no directional lights
            return;
        }

        lightColor = Color.black; // Reset light color

        // Sum color and intensity of all directional lights
        foreach (Light light in allDirectionalLights)
        {
            lightColor += light.color * light.intensity;
        }

        if (!baked)
        {
            Shader.SetGlobalColor("_GlobalLightColor", lightColor); // Set global color for shaders
        }
        else
        {
            Shader.SetGlobalColor("_GlobalLightColor", lightColor); // Set global color for shaders
        }
    }
}