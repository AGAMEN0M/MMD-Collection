using UnityEngine.SceneManagement;
using UnityEngine.InputSystem;
using UnityEngine;

/// <summary>
/// Automatically creates itself when the game starts and allows cycling
/// through all scenes in the Build Settings by pressing the R key.
/// </summary>
public class SceneCycleTester : MonoBehaviour
{
    /// <summary>
    /// Input action used to detect the scene change key.
    /// </summary>
    private InputAction loadNextSceneAction;

    /// <summary>
    /// Creates the tester automatically before the first scene loads.
    /// </summary>
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
    private static void Initialize()
    {
        var obj = new GameObject(nameof(SceneCycleTester));
        DontDestroyOnLoad(obj);

        obj.AddComponent<SceneCycleTester>();
    }

    /// <summary>
    /// Creates and enables the input action.
    /// </summary>
    private void OnEnable()
    {
        loadNextSceneAction = new InputAction(
            name: "LoadNextScene",
            type: InputActionType.Button,
            binding: "<Keyboard>/r");

        loadNextSceneAction.performed += OnLoadNextScene;
        loadNextSceneAction.Enable();
    }

    /// <summary>
    /// Disables and disposes the input action.
    /// </summary>
    private void OnDisable()
    {
        if (loadNextSceneAction != null)
        {
            loadNextSceneAction.performed -= OnLoadNextScene;
            loadNextSceneAction.Disable();
            loadNextSceneAction.Dispose();
            loadNextSceneAction = null;
        }
    }

    /// <summary>
    /// Called when the input action is performed.
    /// </summary>
    /// <param name="context">Input action callback context.</param>
    private void OnLoadNextScene(InputAction.CallbackContext context) => LoadNextScene();

    /// <summary>
    /// Loads the next scene from the Build Settings.
    /// Wraps back to the first scene after the last one.
    /// </summary>
    private void LoadNextScene()
    {
        int sceneCount = SceneManager.sceneCountInBuildSettings;

        if (sceneCount <= 1)
        {
            Debug.LogWarning("There are not enough scenes in the Build Settings.");
            return;
        }

        int nextScene = SceneManager.GetActiveScene().buildIndex + 1;

        if (nextScene >= sceneCount) nextScene = 0;

        Debug.Log($"Loading scene {nextScene}...");
        SceneManager.LoadScene(nextScene);
    }
}