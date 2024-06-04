using UnityEngine;

[RequireComponent(typeof(Camera))] // Ensure the GameObject has a Camera component.
public class FreeCam : MonoBehaviour
{
    [Header("Camera Settings")]
    [SerializeField] private float movementSpeed = 10f; // Speed of camera movement.
    [SerializeField] private float fastMovementSpeed = 100f; // Speed of camera movement when holding "fast" key.
    [Space(5)]
    [SerializeField] private float sensitivity = 3f; // Sensitivity of camera rotation.
    [Space(5)]
    [SerializeField] private float zoomSensitivity = 10f; // Sensitivity of camera zoom.
    [SerializeField] private float fastZoomSensitivity = 50f; // Sensitivity of camera zoom when holding "fast" key.
    [Space(20)]
    [Header("Key Settings")]
    [SerializeField] private KeyCode leftKey = KeyCode.A; // Key to move camera left.
    [SerializeField] private KeyCode rightKey = KeyCode.D; // Key to move camera right.
    [SerializeField] private KeyCode forwardKey = KeyCode.W; // Key to move camera forward.
    [SerializeField] private KeyCode backwardKey = KeyCode.S; // Key to move camera backward.
    [Space(5)]
    [SerializeField] private KeyCode upKey = KeyCode.Q; // Key to move camera up.
    [SerializeField] private KeyCode downKey = KeyCode.E; // Key to move camera down.
    [Space(5)]
    [SerializeField] private KeyCode globalUpKey = KeyCode.R; // Key to move camera globally up.
    [SerializeField] private KeyCode globalDownKey = KeyCode.F; // Key to move camera globally down.
    [Space(5)]
    [SerializeField] private KeyCode fastKey = KeyCode.LeftShift; // Key to activate fast movement.
    [Space(5)]
    [SerializeField] private KeyCode lookKey = KeyCode.Mouse1; // Key to toggle look mode (free mouse).

    private Camera cam; // Reference to the Camera component.
    private bool looking = false; // Flag to determine if the camera is in "look" mode.

    private void OnEnable()
    {
        cam = GetComponent<Camera>(); // Get the Camera component when the script is enabled.
    }

    private void Update()
    {
        // Check for toggling of "look" mode.
        if (Input.GetKeyDown(lookKey))
        {
            StartLooking(); // Start looking mode.
        }
        else if (Input.GetKeyUp(lookKey))
        {
            StopLooking(); // Stop looking mode.
        }

        // Check if the camera is in "look" mode.
        if (looking)
        {
            // Determine the movement speed based on whether the "fast" key is pressed.
            var fastMode = Input.GetKey(fastKey);
            var movementSpeed = fastMode ? fastMovementSpeed : this.movementSpeed;

            // Handle camera movement based on input keys.
            if (Input.GetKey(leftKey))
            {
                cam.transform.position = cam.transform.position + (movementSpeed * Time.deltaTime * -cam.transform.right);
            }

            if (Input.GetKey(rightKey))
            {
                cam.transform.position = cam.transform.position + (movementSpeed * Time.deltaTime * cam.transform.right);
            }

            if (Input.GetKey(forwardKey))
            {
                cam.transform.position = cam.transform.position + (movementSpeed * Time.deltaTime * cam.transform.forward);
            }

            if (Input.GetKey(backwardKey))
            {
                cam.transform.position = cam.transform.position + (movementSpeed * Time.deltaTime * -cam.transform.forward);
            }

            if (Input.GetKey(upKey))
            {
                cam.transform.position = cam.transform.position + (movementSpeed * Time.deltaTime * cam.transform.up);
            }

            if (Input.GetKey(downKey))
            {
                cam.transform.position = cam.transform.position + (movementSpeed * Time.deltaTime * -cam.transform.up);
            }

            if (Input.GetKey(globalUpKey))
            {
                cam.transform.position = cam.transform.position + (movementSpeed * Time.deltaTime * Vector3.up);
            }

            if (Input.GetKey(globalDownKey))
            {
                cam.transform.position = cam.transform.position + (movementSpeed * Time.deltaTime * -Vector3.up);
            }

            // Handle camera rotation based on mouse movement.
            float newRotationX = cam.transform.localEulerAngles.y + Input.GetAxis("Mouse X") * sensitivity;
            float newRotationY = cam.transform.localEulerAngles.x - Input.GetAxis("Mouse Y") * sensitivity;
            cam.transform.localEulerAngles = new Vector3(newRotationY, newRotationX, 0f);

            // Handle camera zoom based on mouse scroll wheel input.
            float axis = Input.GetAxis("Mouse ScrollWheel");
            if (axis != 0)
            {
                var zoomSensitivity = fastMode ? fastZoomSensitivity : this.zoomSensitivity;
                cam.transform.position = cam.transform.position + axis * zoomSensitivity * cam.transform.forward;
            }
        }
    }

    private void OnDisable()
    {
        StopLooking(); // Ensure the camera exits "look" mode when disabled.
    }

    // Method to start "look" mode.
    public void StartLooking()
    {
        looking = true;
        Cursor.visible = false; // Hide the cursor.
        Cursor.lockState = CursorLockMode.Locked; // Lock the cursor.
    }

    // Method to stop "look" mode.
    public void StopLooking()
    {
        looking = false;
        Cursor.visible = true; // Show the cursor.
        Cursor.lockState = CursorLockMode.None; // Unlock the cursor.
    }
}