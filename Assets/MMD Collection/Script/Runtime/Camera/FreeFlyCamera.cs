/*
 * ---------------------------------------------------------------------------
 * Description: This Unity component implements a free-fly camera system designed for editor
 *              tools, scene exploration, debugging, and first-person style navigation.
 * 
 *              The camera can move freely in all directions using configurable keyboard
 *              controls, rotate based on mouse movement while in "look mode", and zoom
 *              forward or backward using the mouse scroll wheel.
 * 
 *              It supports both normal and fast movement/zoom speeds, allowing precise
 *              control or rapid traversal of large scenes. All controls, sensitivities,
 *              and input axes are fully customizable via the Inspector.
 * 
 *              Ideal use cases include scene navigation, cinematic tools, inspection
 *              cameras, and debug utilities.
 * 
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

using UnityEngine;

namespace MMDCollection
{
    [RequireComponent(typeof(Camera))]
    [AddComponentMenu("MMD Collection/Camera/Free Fly Camera")]
    public class FreeFlyCamera : MonoBehaviour
    {
        #region === Camera Settings ===

        [Header("Camera Settings")]
        [SerializeField, Tooltip("Movement speed applied when the run key is not held.")]
        private float movementSpeed = 10f;

        [SerializeField, Tooltip("Movement speed applied while holding the run key.")]
        private float fastMovementSpeed = 100f;

        [SerializeField, Tooltip("Mouse sensitivity used to rotate the camera in look mode.")]
        private float sensitivity = 3f;

        [SerializeField, Tooltip("Zoom speed applied when scrolling the mouse wheel normally.")]
        private float zoomSensitivity = 10f;

        [SerializeField, Tooltip("Zoom speed applied when scrolling while holding the run key.")]
        private float fastZoomSensitivity = 50f;

        #endregion

        #region === Key Settings ===

        [Header("Key Settings")]
        [SerializeField, Tooltip("Key used to move the camera left, relative to its local orientation.")]
        private KeyCode left = KeyCode.A;

        [SerializeField, Tooltip("Key used to move the camera right, relative to its local orientation.")]
        private KeyCode right = KeyCode.D;

        [SerializeField, Tooltip("Key used to move the camera forward, relative to its local orientation.")]
        private KeyCode front = KeyCode.W;

        [SerializeField, Tooltip("Key used to move the camera backward, relative to its local orientation.")]
        private KeyCode back = KeyCode.S;

        [Space(10)]

        [SerializeField, Tooltip("Key used to move the camera upward in local space.")]
        private KeyCode up = KeyCode.Q;

        [SerializeField, Tooltip("Key used to move the camera downward in local space.")]
        private KeyCode down = KeyCode.E;

        [Space(10)]

        [SerializeField, Tooltip("Key used to move the camera upward in world space.")]
        private KeyCode upGlobal = KeyCode.R;

        [SerializeField, Tooltip("Key used to move the camera downward in world space.")]
        private KeyCode downGlobal = KeyCode.F;

        [Space(10)]

        [SerializeField, Tooltip("Key used to enable look mode and rotate the camera with the mouse.")]
        private KeyCode observe = KeyCode.Mouse1;

        [Space(10)]

        [SerializeField, Tooltip("Key used to enable fast movement and fast zoom modes.")]
        private KeyCode run = KeyCode.LeftShift;

        #endregion

        #region === Axis Settings ===

        [Header("Axis Settings")]
        [SerializeField, Tooltip("Input axis name used for zooming the camera forward or backward.")]
        private string zoom = "Mouse ScrollWheel";

        [SerializeField, Tooltip("Input axis name used for horizontal mouse movement.")]
        private string axisX = "Mouse X";

        [SerializeField, Tooltip("Input axis name used for vertical mouse movement.")]
        private string axisY = "Mouse Y";

        #endregion

        #region === Runtime State ===

        private bool looking = false; // Indicates whether the camera is currently in look mode.

        #endregion

        #region === Public Properties ===

        /// <summary>
        /// Gets or sets the normal movement speed of the camera.
        /// </summary>
        public float MovementSpeed
        {
            get => movementSpeed;
            set => movementSpeed = value;
        }

        /// <summary>
        /// Gets or sets the fast movement speed used while holding the run key.
        /// </summary>
        public float FastMovementSpeed
        {
            get => fastMovementSpeed;
            set => fastMovementSpeed = value;
        }

        /// <summary>
        /// Gets or sets the mouse sensitivity used for camera rotation.
        /// </summary>
        public float Sensitivity
        {
            get => sensitivity;
            set => sensitivity = value;
        }

        /// <summary>
        /// Gets or sets the normal zoom sensitivity.
        /// </summary>
        public float ZoomSensitivity
        {
            get => zoomSensitivity;
            set => zoomSensitivity = value;
        }

        /// <summary>
        /// Gets or sets the fast zoom sensitivity used while holding the run key.
        /// </summary>
        public float FastZoomSensitivity
        {
            get => fastZoomSensitivity;
            set => fastZoomSensitivity = value;
        }

        /// <summary>
        /// Gets or sets the key used to move the camera left.
        /// </summary>
        public KeyCode Left
        {
            get => left;
            set => left = value;
        }

        /// <summary>
        /// Gets or sets the key used to move the camera right.
        /// </summary>
        public KeyCode Right
        {
            get => right;
            set => right = value;
        }

        /// <summary>
        /// Gets or sets the key used to move the camera forward.
        /// </summary>
        public KeyCode Front
        {
            get => front;
            set => front = value;
        }

        /// <summary>
        /// Gets or sets the key used to move the camera backward.
        /// </summary>
        public KeyCode Back
        {
            get => back;
            set => back = value;
        }

        /// <summary>
        /// Gets or sets the key used to move the camera upward in local space.
        /// </summary>
        public KeyCode Up
        {
            get => up;
            set => up = value;
        }

        /// <summary>
        /// Gets or sets the key used to move the camera downward in local space.
        /// </summary>
        public KeyCode Down
        {
            get => down;
            set => down = value;
        }

        /// <summary>
        /// Gets or sets the key used to move the camera upward in world space.
        /// </summary>
        public KeyCode UpGlobal
        {
            get => upGlobal;
            set => upGlobal = value;
        }

        /// <summary>
        /// Gets or sets the key used to move the camera downward in world space.
        /// </summary>
        public KeyCode DownGlobal
        {
            get => downGlobal;
            set => downGlobal = value;
        }

        /// <summary>
        /// Gets or sets the key used to toggle look mode.
        /// </summary>
        public KeyCode Observe
        {
            get => observe;
            set => observe = value;
        }

        /// <summary>
        /// Gets or sets the key used to enable fast movement and zoom.
        /// </summary>
        public KeyCode Run
        {
            get => run;
            set => run = value;
        }

        /// <summary>
        /// Gets or sets the input axis name used for zooming.
        /// </summary>
        public string Zoom
        {
            get => zoom;
            set => zoom = value;
        }

        /// <summary>
        /// Gets or sets the input axis name used for horizontal mouse movement.
        /// </summary>
        public string AxisX
        {
            get => axisX;
            set => axisX = value;
        }

        /// <summary>
        /// Gets or sets the input axis name used for vertical mouse movement.
        /// </summary>
        public string AxisY
        {
            get => axisY;
            set => axisY = value;
        }

        #endregion

        #region === Unity Callbacks ===

        private void Update()
        {
            // Determine whether fast mode is active.
            var fastMode = Input.GetKey(run);
            var currentMovementSpeed = fastMode ? fastMovementSpeed : movementSpeed;

            // Build the movement direction vector based on pressed keys.
            var moveDirection = Vector3.zero;

            if (Input.GetKey(left)) moveDirection += -transform.right;
            if (Input.GetKey(right)) moveDirection += transform.right;
            if (Input.GetKey(front)) moveDirection += transform.forward;
            if (Input.GetKey(back)) moveDirection += -transform.forward;
            if (Input.GetKey(up)) moveDirection += transform.up;
            if (Input.GetKey(down)) moveDirection += -transform.up;
            if (Input.GetKey(upGlobal)) moveDirection += Vector3.up;
            if (Input.GetKey(downGlobal)) moveDirection += Vector3.down;

            // Apply movement to the camera position.
            transform.position += currentMovementSpeed * Time.deltaTime * moveDirection;

            // Rotate the camera when look mode is active.
            if (looking)
            {
                float newRotationX = transform.localEulerAngles.y + Input.GetAxis(axisX) * sensitivity;
                float newRotationY = transform.localEulerAngles.x - Input.GetAxis(axisY) * sensitivity;

                transform.localEulerAngles = new Vector3(newRotationY, newRotationX, 0f);
            }

            // Handle zoom input.
            float zoomAxis = Input.GetAxis(zoom);
            if (zoomAxis != 0f)
            {
                var currentZoomSensitivity = fastMode ? fastZoomSensitivity : zoomSensitivity;
                transform.position += zoomAxis * currentZoomSensitivity * transform.forward;
            }

            // Handle look mode activation and deactivation.
            if (Input.GetKeyDown(observe))
            {
                StartLooking();
            }
            else if (Input.GetKeyUp(observe))
            {
                StopLooking();
            }
        }

        // Ensure cursor state is restored when the component is disabled.
        private void OnDisable() => StopLooking();

        #endregion

        #region === Look Mode Control ===

        /// <summary>
        /// Enables look mode, locking and hiding the cursor to allow free camera rotation.
        /// </summary>
        public void StartLooking()
        {
            looking = true;
            Cursor.visible = false;
            Cursor.lockState = CursorLockMode.Locked;
        }

        /// <summary>
        /// Disables look mode, restoring the cursor visibility and unlock state.
        /// </summary>
        public void StopLooking()
        {
            looking = false;
            Cursor.visible = true;
            Cursor.lockState = CursorLockMode.None;
        }

        #endregion
    }
}