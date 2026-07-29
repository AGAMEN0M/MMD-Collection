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

using UnityEngine.InputSystem.Controls;
using UnityEngine.InputSystem;
using UnityEngine;

namespace MMDCollection
{
    [RequireComponent(typeof(Camera))]
    [AddComponentMenu("Tools/MMD Collection/Camera/Free Fly Camera")]
    public class FreeFlyCamera : MonoBehaviour
    {
        #region === Camera Settings ===

        [Header("Camera Settings")]
        [SerializeField, Tooltip("Movement speed applied when the run key is not held.")]
        private float movementSpeed = 10f;

        [SerializeField, Tooltip("Movement speed applied while holding the run key.")]
        private float fastMovementSpeed = 100f;

        [SerializeField, Tooltip("Mouse sensitivity used to rotate the camera in look mode.")]
        private float sensitivity = 15f;

        [SerializeField, Tooltip("Zoom speed applied when scrolling the mouse wheel normally.")]
        private float zoomSensitivity = 100f;

        [SerializeField, Tooltip("Zoom speed applied when scrolling while holding the run key.")]
        private float fastZoomSensitivity = 500f;

        #endregion

        #region === Key Settings ===

        [Header("Key Settings")]
        [SerializeField, Tooltip("Key used to move the camera left, relative to its local orientation.")]
        private Key left = Key.A;

        [SerializeField, Tooltip("Key used to move the camera right, relative to its local orientation.")]
        private Key right = Key.D;

        [SerializeField, Tooltip("Key used to move the camera forward, relative to its local orientation.")]
        private Key front = Key.W;

        [SerializeField, Tooltip("Key used to move the camera backward, relative to its local orientation.")]
        private Key back = Key.S;

        [Space(10)]

        [SerializeField, Tooltip("Key used to move the camera upward in local space.")]
        private Key up = Key.Q;

        [SerializeField, Tooltip("Key used to move the camera downward in local space.")]
        private Key down = Key.E;

        [Space(10)]

        [SerializeField, Tooltip("Key used to move the camera upward in world space.")]
        private Key upGlobal = Key.R;

        [SerializeField, Tooltip("Key used to move the camera downward in world space.")]
        private Key downGlobal = Key.F;

        [Space(10)]

        [SerializeField, Tooltip("Mouse button used to enable look mode and rotate the camera with the mouse.")]
        private int observeButton = 1; // 0 = left, 1 = right, 2 = middle (Mouse.current.*Button)

        [Space(10)]

        [SerializeField, Tooltip("Key used to enable fast movement and fast zoom modes.")]
        private Key run = Key.LeftShift;

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
        public Key Left
        {
            get => left;
            set => left = value;
        }

        /// <summary>
        /// Gets or sets the key used to move the camera right.
        /// </summary>
        public Key Right
        {
            get => right;
            set => right = value;
        }

        /// <summary>
        /// Gets or sets the key used to move the camera forward.
        /// </summary>
        public Key Front
        {
            get => front;
            set => front = value;
        }

        /// <summary>
        /// Gets or sets the key used to move the camera backward.
        /// </summary>
        public Key Back
        {
            get => back;
            set => back = value;
        }

        /// <summary>
        /// Gets or sets the key used to move the camera upward in local space.
        /// </summary>
        public Key Up
        {
            get => up;
            set => up = value;
        }

        /// <summary>
        /// Gets or sets the key used to move the camera downward in local space.
        /// </summary>
        public Key Down
        {
            get => down;
            set => down = value;
        }

        /// <summary>
        /// Gets or sets the key used to move the camera upward in world space.
        /// </summary>
        public Key UpGlobal
        {
            get => upGlobal;
            set => upGlobal = value;
        }

        /// <summary>
        /// Gets or sets the key used to move the camera downward in world space.
        /// </summary>
        public Key DownGlobal
        {
            get => downGlobal;
            set => downGlobal = value;
        }

        /// <summary>
        /// Gets or sets the mouse button used to toggle look mode (0 = left, 1 = right, 2 = middle).
        /// </summary>
        public int ObserveButton
        {
            get => observeButton;
            set => observeButton = value;
        }

        /// <summary>
        /// Gets or sets the key used to enable fast movement and zoom.
        /// </summary>
        public Key Run
        {
            get => run;
            set => run = value;
        }

        #endregion

        #region === Unity Callbacks ===

        private void Update()
        {
            if (Keyboard.current == null) return;

            var fastMode = IsKeyPressed(run);

            HandleMovement(fastMode);
            HandleLook();
            HandleZoom(fastMode);
            HandleObserveToggle();
        }

        // Ensure cursor state is restored when the component is disabled.
        private void OnDisable() => StopLooking();

        #endregion

        #region === Input Handling (FN_ methods) ===

        /// <summary>
        /// Reads the movement keys and applies translation to the camera.
        /// </summary>
        private void HandleMovement(bool fastMode)
        {
            var currentMovementSpeed = fastMode ? fastMovementSpeed : movementSpeed;

            var moveDirection = Vector3.zero;

            if (IsKeyPressed(left)) moveDirection += -transform.right;
            if (IsKeyPressed(right)) moveDirection += transform.right;
            if (IsKeyPressed(front)) moveDirection += transform.forward;
            if (IsKeyPressed(back)) moveDirection += -transform.forward;
            if (IsKeyPressed(up)) moveDirection += transform.up;
            if (IsKeyPressed(down)) moveDirection += -transform.up;
            if (IsKeyPressed(upGlobal)) moveDirection += Vector3.up;
            if (IsKeyPressed(downGlobal)) moveDirection += Vector3.down;

            transform.position += currentMovementSpeed * Time.deltaTime * moveDirection;
        }

        /// <summary>
        /// Rotates the camera based on mouse delta while look mode is active.
        /// </summary>
        private void HandleLook()
        {
            if (!looking || Mouse.current == null)
            {
                return;
            }

            var mouseDelta = Mouse.current.delta.ReadValue();

            float newRotationX = transform.localEulerAngles.y + mouseDelta.x * sensitivity * Time.deltaTime;
            float newRotationY = transform.localEulerAngles.x - mouseDelta.y * sensitivity * Time.deltaTime;

            transform.localEulerAngles = new Vector3(newRotationY, newRotationX, 0f);
        }

        /// <summary>
        /// Reads the mouse scroll wheel and moves the camera forward/backward.
        /// </summary>
        private void HandleZoom(bool fastMode)
        {
            if (Mouse.current == null)
            {
                return;
            }

            float zoomAxis = Mouse.current.scroll.ReadValue().y;
            if (zoomAxis != 0f)
            {
                var currentZoomSensitivity = fastMode ? fastZoomSensitivity : zoomSensitivity;
                transform.position += zoomAxis * currentZoomSensitivity * Time.deltaTime * transform.forward;
            }
        }

        /// <summary>
        /// Detects press/release of the configured mouse button to toggle look mode.
        /// </summary>
        private void HandleObserveToggle()
        {
            if (Mouse.current == null)
            {
                return;
            }

            var button = GetObserveButtonControl();
            if (button == null)
            {
                return;
            }

            if (button.wasPressedThisFrame)
            {
                StartLooking();
            }
            else if (button.wasReleasedThisFrame)
            {
                StopLooking();
            }
        }

        /// <summary>
        /// Resolves the ButtonControl matching the configured observe mouse button index.
        /// </summary>
        private ButtonControl GetObserveButtonControl()
        {
            return observeButton switch
            {
                0 => Mouse.current.leftButton,
                1 => Mouse.current.rightButton,
                2 => Mouse.current.middleButton,
                _ => Mouse.current.rightButton,
            };
        }

        /// <summary>
        /// Helper to check whether a given Key is currently held down.
        /// </summary>
        private static bool IsKeyPressed(Key key)
        {
            return Keyboard.current != null && Keyboard.current[key].isPressed;
        }

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