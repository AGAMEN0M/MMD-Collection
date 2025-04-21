/*
 * ---------------------------------------------------------------------------
 * Description: This Unity script provides free movement control for the camera, allowing it to move and rotate 
 *              freely in all directions. The camera's movement speed, rotation sensitivity, and zoom sensitivity 
 *              can be adjusted. It supports normal and fast movement modes, as well as toggling a "look mode" to 
 *              rotate the camera based on mouse movement. The script is ideal for first-person camera control or for 
 *              navigation in a 3D environment.
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/
using UnityEngine;

[RequireComponent(typeof(Camera))]
[AddComponentMenu("MMD Collection/Free Camera")]
public class FreeCamera : MonoBehaviour
{
    [Header("Camera Settings")]
    [SerializeField] private float movementSpeed = 10f; // Default movement speed.
    [SerializeField] private float fastMovementSpeed = 100f; // Fast movement speed.
    [SerializeField] private float sensitivity = 3f; // Mouse sensitivity for rotation.
    [SerializeField] private float zoomSensitivity = 10f; // Sensitivity for zooming.
    [SerializeField] private float fastZoomSensitivity = 50f; // Fast zooming sensitivity.
    [Header("Key Settings")]
    public KeyCode left = KeyCode.A; // Key to move left.
    public KeyCode right = KeyCode.D; // Key to move right.
    public KeyCode front = KeyCode.W; // Key to move forward.
    public KeyCode back = KeyCode.S; // Key to move backward.
    [Space(10)]
    public KeyCode up = KeyCode.Q; // Key to move up (local).
    public KeyCode down = KeyCode.E; // Key to move down (local).
    [Space(10)]
    public KeyCode upGlobal = KeyCode.R; // Key to move up (global).
    public KeyCode downGlobal = KeyCode.F; // Key to move down (global).
    [Space(10)]
    public KeyCode observe = KeyCode.Mouse1; // Key to enter/exit look mode.
    [Space(10)]
    public KeyCode run = KeyCode.LeftShift; // Key to enable fast movement.
    [Header("Axis Settings")]
    public string zoom = "Mouse ScrollWheel"; // Axis for zooming.
    public string axisX = "Mouse X"; // Axis for horizontal mouse movement.
    public string axisY = "Mouse Y"; // Axis for vertical mouse movement.

    private bool looking = false; // Tracks if the camera is in look mode.

    private void Update()
    {
        // Check if the player is holding down the run key for fast mode.
        var fastMode = Input.GetKey(run);
        var currentMovementSpeed = fastMode ? fastMovementSpeed : movementSpeed;

        // Calculate movement vector based on input keys.
        Vector3 moveDirection = Vector3.zero;
        if (Input.GetKey(left)) moveDirection += -transform.right;
        if (Input.GetKey(right)) moveDirection += transform.right;
        if (Input.GetKey(front)) moveDirection += transform.forward;
        if (Input.GetKey(back)) moveDirection += -transform.forward;
        if (Input.GetKey(up)) moveDirection += transform.up;
        if (Input.GetKey(down)) moveDirection += -transform.up;
        if (Input.GetKey(upGlobal)) moveDirection += Vector3.up;
        if (Input.GetKey(downGlobal)) moveDirection += Vector3.down;

        // Move the camera based on the calculated direction.
        transform.position += currentMovementSpeed * Time.deltaTime * moveDirection;

        // Handle camera rotation based on mouse movement if in look mode.
        if (looking)
        {
            float newRotationX = transform.localEulerAngles.y + Input.GetAxis(axisX) * sensitivity;
            float newRotationY = transform.localEulerAngles.x - Input.GetAxis(axisY) * sensitivity;
            transform.localEulerAngles = new Vector3(newRotationY, newRotationX, 0f);
        }

        // Handle zooming based on mouse scroll wheel input.
        float zoomAxis = Input.GetAxis(zoom);
        if (zoomAxis != 0)
        {
            var currentZoomSensitivity = fastMode ? fastZoomSensitivity : zoomSensitivity;
            transform.position += zoomAxis * currentZoomSensitivity * transform.forward;
        }

        // Toggle look mode on right mouse button press/release.
        if (Input.GetKeyDown(observe))
        {
            StartLooking();
        }
        else if (Input.GetKeyUp(observe))
        {
            StopLooking();
        }
    }

    // Ensure look mode is stopped when the script is disabled.
    private void OnDisable()
    {
        StopLooking();
    }

    /// <summary>
    /// Starts look mode, hiding and locking the cursor to the center of the screen.
    /// </summary>
    public void StartLooking()
    {
        looking = true;
        Cursor.visible = false; // Hide the cursor.
        Cursor.lockState = CursorLockMode.Locked; // Lock the cursor to the center of the screen.
    }

    /// <summary>
    /// Stops look mode, showing and unlocking the cursor from the center of the screen.
    /// </summary>
    public void StopLooking()
    {
        looking = false;
        Cursor.visible = true; // Show the cursor.
        Cursor.lockState = CursorLockMode.None; // Unlock the cursor from the center of the screen.
    }
}