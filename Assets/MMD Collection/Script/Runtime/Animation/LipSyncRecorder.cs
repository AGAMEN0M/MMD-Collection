/*
 * ---------------------------------------------------------------------------
 * Description:
 * Records real-time lip sync blend shape data from a RealtimeLipSyncAnalyzer
 * component and converts the captured data into a baked AnimationClip.
 * 
 * This system supports:
 * - Pre-roll stabilization before recording starts.
 * - Real-time blend shape sampling.
 * - Automatic AnimationClip generation.
 * - Curve optimization to reduce redundant keyframes.
 * - Editor integration with a custom recording interface.
 * 
 * The generated animation is automatically saved as a .anim file
 * next to the source AudioClip inside the Unity project.
 *
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
 */

using System.Collections.Generic;
using UnityEngine;
using System.IO;

#if UNITY_EDITOR
using UnityEditor;
#endif

namespace MMDCollection
{
    /// <summary>
    /// Records blend shape values from a RealtimeLipSyncAnalyzer and generates
    /// a baked lip sync AnimationClip inside the Unity Editor.
    /// </summary>
    [RequireComponent(typeof(RealtimeLipSyncAnalyzer))]
    [AddComponentMenu("Tools/MMD Collection/Animation/Lip Sync Recorder")]
    public class LipSyncRecorder : MonoBehaviour
    {
        #region === Enums ===

        /// <summary>
        /// Represents the current recording state of the recorder.
        /// </summary>
        public enum RecordingState
        {
            /// <summary>Recorder is inactive.</summary>
            Idle,

            /// <summary>Waiting before recording starts.</summary>
            PreRoll,

            /// <summary>Currently recording blend shape data.</summary>
            Recording,

            /// <summary>Baking and saving the animation clip.</summary>
            Saving
        }

        #endregion

        #region === Serialized Fields ===

        [Header("Avatar Settings")]
        [SerializeField, Tooltip("The avatar GameObject that owns the SkinnedMeshRenderer.")]
        private GameObject targetAvatar;

        [Header("Recording Settings")]
        [SerializeField, Tooltip("Delay in seconds before recording begins.")]
        private float preRollDelay = 10f;

        [SerializeField, Tooltip("Sampling rate used to capture blend shape frames.")]
        private float sampleRate = 30f;

        [SerializeField, Tooltip("Removes redundant keys to optimize the generated animation.")]
        private bool optimize = true;

        #endregion

        #region === Runtime Buffers ===

        /// <summary>
        /// Current recording state.
        /// </summary>
        [HideInInspector]
        public RecordingState state = RecordingState.Idle;

        /// <summary>
        /// Cached reference to the lip sync analyzer.
        /// </summary>
        private RealtimeLipSyncAnalyzer analyzer;

        /// <summary>
        /// General timer used for recording progression.
        /// </summary>
        private float timer;

        /// <summary>
        /// Stores the next sample capture timestamp.
        /// </summary>
        private float nextSampleTime;

        /// <summary>
        /// Keyframe buffer for vowel A.
        /// </summary>
        private readonly List<Keyframe> keyA = new();

        /// <summary>
        /// Keyframe buffer for vowel I.
        /// </summary>
        private readonly List<Keyframe> keyI = new();

        /// <summary>
        /// Keyframe buffer for vowel U.
        /// </summary>
        private readonly List<Keyframe> keyU = new();

        /// <summary>
        /// Keyframe buffer for vowel O.
        /// </summary>
        private readonly List<Keyframe> keyO = new();

        #endregion

        #region === Public Properties ===

        /// <summary>
        /// Avatar root object used to calculate animation paths.
        /// </summary>
        public GameObject TargetAvatar
        {
            get => targetAvatar;
            set => targetAvatar = value;
        }

        /// <summary>
        /// Delay before recording starts.
        /// </summary>
        public float PreRollDelay
        {
            get => preRollDelay;
            set => preRollDelay = value;
        }

        /// <summary>
        /// Recording sampling rate in frames per second.
        /// </summary>
        public float SampleRate
        {
            get => sampleRate;
            set => sampleRate = value;
        }

        #endregion

        #region === Unity Events ===

        /// <summary>
        /// Initializes internal component references.
        /// </summary>
        private void Awake() => analyzer = GetComponent<RealtimeLipSyncAnalyzer>();

        /// <summary>
        /// Handles recording state updates and frame sampling.
        /// </summary>
        private void Update()
        {
            // Stop execution if the recorder is idle or dependencies are missing.
            if (state == RecordingState.Idle || analyzer == null || analyzer.AudioSource == null) return;

            timer += Time.deltaTime; // Advance the internal timer using frame delta time.

            // Handle the pre-roll countdown state.
            if (state == RecordingState.PreRoll)
            {
                // Start playback and recording once the delay has elapsed.
                if (timer >= preRollDelay) StartAudioAndRecording();
                return;
            }

            // Handle active recording logic.
            if (state == RecordingState.Recording)
            {
                // Capture a frame whenever the next sampling time is reached.
                if (timer >= nextSampleTime)
                {
                    CaptureFrame(timer);
                    nextSampleTime += 1f / sampleRate; // Schedule the next sample based on the configured FPS.
                }

                // Stop recording once the audio clip finishes playback.
                if (!analyzer.AudioSource.isPlaying)
                {
                    CaptureFrame(timer); // Capture a final frame to ensure the animation ends correctly.
                    timer = 0f; // Reset timer before baking.
                    state = RecordingState.Saving; // Enter saving state.
                    BakeClip(); // Generate and save the animation clip.
                    state = RecordingState.Idle; // Return to idle state after saving.
                }
            }
        }

        #endregion

        #region === Core Recording Logic ===

        /// <summary>
        /// Starts the lip sync recording process.
        /// </summary>
        public void StartRecording()
        {
            // Prevent recording if required dependencies are missing.
            if (analyzer == null || analyzer.AudioSource == null) return;

            // Ensure audio playback starts from the beginning.
            analyzer.AudioSource.Stop();
            analyzer.AudioSource.time = 0f;
            analyzer.AudioSource.loop = false;

            // Clear previously recorded keyframe data.
            keyA.Clear();
            keyI.Clear();
            keyU.Clear();
            keyO.Clear();

            // Reset timers and state values.
            timer = 0f;
            nextSampleTime = 0f;
            state = RecordingState.PreRoll; // Enter pre-roll mode.
        }

        /// <summary>
        /// Starts audio playback and enters recording mode.
        /// </summary>
        private void StartAudioAndRecording()
        {
            // Restart audio from the beginning.
            analyzer.AudioSource.Stop();
            analyzer.AudioSource.time = 0f;

            analyzer.AudioSource.Play(); // Begin playback.
            timer = 0f; // Reset timer to synchronize animation recording with audio playback.
            state = RecordingState.Recording; // Enter active recording state.
        }

        /// <summary>
        /// Captures the current blend shape values and stores them as keyframes.
        /// </summary>
        /// <param name="time">Current recording time.</param>
        private void CaptureFrame(float time)
        {
            var smr = analyzer.SkinnedMeshRenderer; // Cache the SkinnedMeshRenderer reference.
            if (smr == null) return; // Stop execution if the renderer is missing.

            keyA.Add(new Keyframe(time, smr.GetBlendShapeWeight(analyzer.VowelABlendShapeIndex))); // Record vowel A blend shape value.
            keyI.Add(new Keyframe(time, smr.GetBlendShapeWeight(analyzer.VowelIBlendShapeIndex))); // Record vowel I blend shape value.
            keyU.Add(new Keyframe(time, smr.GetBlendShapeWeight(analyzer.VowelUBlendShapeIndex))); // Record vowel U blend shape value.
            keyO.Add(new Keyframe(time, smr.GetBlendShapeWeight(analyzer.VowelOBlendShapeIndex))); // Record vowel O blend shape value.
        }

        /// <summary>
        /// Generates and saves the final lip sync AnimationClip.
        /// </summary>
        private void BakeClip()
        {
#if UNITY_EDITOR

            // Prevent baking if required references are missing.
            if (targetAvatar == null || analyzer.SkinnedMeshRenderer == null) return;

            // Calculate the relative transform path from the avatar root to the renderer.
            string relativePath = AnimationUtility.CalculateTransformPath(analyzer.SkinnedMeshRenderer.transform, targetAvatar.transform);

            // Create a new animation clip using the configured sample rate.
            AnimationClip clip = new()
            {
                frameRate = sampleRate
            };

            // Build animation curves from the recorded keyframe buffers.
            AnimationCurve[] curves =
            {
                new(keyA.ToArray()),
                new(keyI.ToArray()),
                new(keyU.ToArray()),
                new(keyO.ToArray())
            };

            // Apply curve optimization if enabled.
            if (optimize)
            {
                for (int i = 0; i < curves.Length; i++) curves[i] = OptimizeCurve(curves[i]);
            }

            // Cache all target blend shape indexes.
            int[] blendShapeIndexes =
            {
                analyzer.VowelABlendShapeIndex,
                analyzer.VowelIBlendShapeIndex,
                analyzer.VowelUBlendShapeIndex,
                analyzer.VowelOBlendShapeIndex
            };

            // Bind each generated curve to its respective blend shape.
            for (int i = 0; i < 4; i++)
            {
                // Retrieve the blend shape name from the mesh.
                string blendShapeName = analyzer.SkinnedMeshRenderer.sharedMesh.GetBlendShapeName(blendShapeIndexes[i]);

                // Assign the animation curve to the blend shape property.
                clip.SetCurve(relativePath,typeof(SkinnedMeshRenderer), $"blendShape.{blendShapeName}", curves[i]);
            }

            var audioClip = analyzer.AudioSource.clip; // Cache the source audio clip reference.

            // Build the output animation path.
            string path = Path.Combine(Path.GetDirectoryName(AssetDatabase.GetAssetPath(audioClip)), $"{audioClip.name}_LipSync.anim");
            path = path.Replace("\\", "/"); // Normalize path separators for Unity compatibility.

            // Delete the previous animation file if it already exists.
            if (File.Exists(path)) AssetDatabase.DeleteAsset(path);

            // Create and save the new animation asset.
            AssetDatabase.CreateAsset(clip, path);
            AssetDatabase.SaveAssets();

            Debug.Log($"[{nameof(LipSyncRecorder)}] Sucesso! Animação salva em: {path}", clip);

            EditorApplication.isPlaying = false; // Automatically stop play mode after baking finishes.

        #else

            Debug.LogError($"[{nameof(LipSyncRecorder)}] Saving .anim files is only supported within the Unity Editor.");

        #endif
        }

        /// <summary>
        /// Optimizes an animation curve by removing redundant keyframes
        /// while preserving important shape transitions.
        /// </summary>
        /// <param name="curve">Curve to optimize.</param>
        /// <returns>Optimized animation curve.</returns>
        private AnimationCurve OptimizeCurve(AnimationCurve curve)
        {
            // Prevent processing invalid or extremely small curves.
            if (curve == null || curve.length < 3) return curve;

            float threshold = 0.5f; // Threshold used to detect negligible changes.

            // Clamp and preserve the first keyframe.
            var firstKey = curve.keys[0];
            firstKey.value = Mathf.Clamp(firstKey.value, 0f, 100f);

            // Pre-filtered key collection.
            List<Keyframe> preFilteredKeys = new() { firstKey };

            // Analyze intermediate keys.
            for (int i = 1; i < curve.length - 1; i++)
            {
                // Clamp neighboring values.
                float prevValue = Mathf.Clamp(curve.keys[i - 1].value, 0f, 100f);
                float currentValue = Mathf.Clamp(curve.keys[i].value, 0f, 100f);
                float nextValue = Mathf.Clamp(curve.keys[i + 1].value, 0f, 100f);

                // Detect flat regions with insignificant changes.
                bool isWithinThreshold = Mathf.Abs(currentValue - prevValue) < threshold && Mathf.Abs(nextValue - currentValue) < threshold;

                // Detect important peaks or valleys.
                bool isPeakOrValley = (currentValue > prevValue && currentValue > nextValue) || (currentValue < prevValue && currentValue < nextValue);

                // Detect exact zero values.
                bool isExactZero = Mathf.Approximately(currentValue, 0f);

                // Keep keys that contain meaningful shape information.
                if (!isWithinThreshold || isPeakOrValley || isExactZero)
                {
                    var clampedKey = curve.keys[i];
                    clampedKey.value = currentValue;
                    preFilteredKeys.Add(clampedKey);
                }
            }

            // Clamp and preserve the last keyframe.
            var lastKey = curve.keys[curve.length - 1];
            lastKey.value = Mathf.Clamp(lastKey.value, 0f, 100f);

            preFilteredKeys.Add(lastKey);

            // Skip advanced optimization if too few keys remain.
            if (preFilteredKeys.Count < 3) return new AnimationCurve(preFilteredKeys.ToArray());

            float epsilon = 0.5f; // Epsilon value used by the Ramer-Douglas-Peucker simplification.

            // Tracks which keys should be preserved.
            var keepFlags = new bool[preFilteredKeys.Count];

            // Always preserve first and last keys.
            keepFlags[0] = true;
            keepFlags[preFilteredKeys.Count - 1] = true;

            // Preserve neighboring keys around exact zero values.
            for (int i = 1; i < preFilteredKeys.Count - 1; i++)
            {
                if (Mathf.Approximately(preFilteredKeys[i].value, 0f))
                {
                    keepFlags[i - 1] = true;
                    keepFlags[i] = true;
                    keepFlags[i + 1] = true;
                }
            }

            // Stack used for iterative RDP segmentation.
            Stack<KeyValuePair<int, int>> segments = new();

            // Push the initial segment.
            segments.Push(new KeyValuePair<int, int>(0, preFilteredKeys.Count - 1));

            // Process all curve segments.
            while (segments.Count > 0)
            {
                var segment = segments.Pop(); // Retrieve the current segment.

                int startIndex = segment.Key;
                int endIndex = segment.Value;

                // Skip invalid segments.
                if (endIndex <= startIndex + 1) continue;

                // Track the furthest point from the segment line.
                float maxDistance = 0f;
                int maxIndex = startIndex;

                var startKey = preFilteredKeys[startIndex];
                var endKey = preFilteredKeys[endIndex];

                // Measure the perpendicular distance of each point.
                for (int i = startIndex + 1; i < endIndex; i++)
                {
                    var currentKey = preFilteredKeys[i];
                    float distance = GetPerpendicularDistance(currentKey, startKey, endKey, sampleRate);

                    // Preserve the point with the greatest deviation.
                    if (distance > maxDistance)
                    {
                        maxDistance = distance;
                        maxIndex = i;
                    }
                }

                // Preserve keys above the simplification threshold.
                if (maxDistance > epsilon)
                {
                    keepFlags[maxIndex] = true;

                    // Split the segment into two new segments.
                    segments.Push(new KeyValuePair<int, int>(startIndex, maxIndex));
                    segments.Push(new KeyValuePair<int, int>(maxIndex, endIndex));
                }
            }
            
            List<Keyframe> rdpKeys = new(); // Collect all preserved keys.

            for (int i = 0; i < preFilteredKeys.Count; i++)
            {
                if (keepFlags[i]) rdpKeys.Add(preFilteredKeys[i]);
            }

            // Preserve and clamp the first optimized key.
            var finalFirstKey = rdpKeys[0];
            finalFirstKey.value = Mathf.Clamp(finalFirstKey.value, 0f, 100f);

            List<Keyframe> optimizedKeys = new() { finalFirstKey };

            // Remove remaining redundant flat keys.
            for (int i = 1; i < rdpKeys.Count; i++)
            {
                if (i < rdpKeys.Count - 1)
                {
                    float prevVal = Mathf.Clamp(rdpKeys[i - 1].value, 0f, 100f);
                    float currVal = Mathf.Clamp(rdpKeys[i].value, 0f, 100f);
                    float nextVal = Mathf.Clamp(rdpKeys[i + 1].value, 0f, 100f);

                    // Skip perfectly flat middle keys.
                    if (Mathf.Approximately(prevVal, currVal) && Mathf.Approximately(currVal, nextVal)) continue;
                }

                // Clamp and preserve valid keys.
                var validKey = rdpKeys[i];
                validKey.value = Mathf.Clamp(validKey.value, 0f, 100f);

                optimizedKeys.Add(validKey);
            }

            AnimationCurve optimizedCurve = new(optimizedKeys.ToArray()); // Create the final optimized curve.

            #if UNITY_EDITOR
            // Apply smooth automatic tangents to all keys.
            for (int i = 0; i < optimizedCurve.length; i++)
            {
                AnimationUtility.SetKeyLeftTangentMode(optimizedCurve, i, AnimationUtility.TangentMode.ClampedAuto);
                AnimationUtility.SetKeyRightTangentMode(optimizedCurve, i, AnimationUtility.TangentMode.ClampedAuto);
            }
            #endif

            return optimizedCurve;
        }

        /// <summary>
        /// Calculates the perpendicular distance between a point and a line segment.
        /// </summary>
        /// <param name="p">Point being measured.</param>
        /// <param name="start">Line segment start point.</param>
        /// <param name="end">Line segment end point.</param>
        /// <param name="fps">Frame rate scaling factor.</param>
        /// <returns>Perpendicular distance to the line segment.</returns>
        private float GetPerpendicularDistance(Keyframe p, Keyframe start, Keyframe end, float fps)
        {
            // Convert time values into frame space.
            float pTime = p.time * fps;
            float startTime = start.time * fps;
            float endTime = end.time * fps;

            // Calculate squared line length.
            float lineLengthSq = (endTime - startTime) * (endTime - startTime) + (end.value - start.value) * (end.value - start.value);

            // Handle degenerate line segments.
            if (Mathf.Approximately(lineLengthSq, 0f))
            {
                return Mathf.Sqrt((pTime - startTime) * (pTime - startTime) + (p.value - start.value) * (p.value - start.value));
            }

            // Project the point onto the line segment.
            float t = ((pTime - startTime) * (endTime - startTime) + (p.value - start.value) * (end.value - start.value)) / lineLengthSq;
            t = Mathf.Clamp01(t); // Clamp the projection inside the segment range.

            // Calculate projected coordinates.
            float projTime = startTime + t * (endTime - startTime);
            float projValue = start.value + t * (end.value - start.value);

            // Return the Euclidean distance to the projected point.
            return Mathf.Sqrt((pTime - projTime) * (pTime - projTime) + (p.value - projValue) * (p.value - projValue));
        }

        #endregion

        #region === Progress API ===

        /// <summary>
        /// Returns the current recording progress normalized between 0 and 1.
        /// </summary>
        /// <returns>Normalized progress value.</returns>
        public float GetProgress()
        {
            switch (state)
            {
                case RecordingState.PreRoll:
                    if (preRollDelay <= 0f) return 1f; // Return full progress when pre-roll is disabled.
                    return Mathf.Clamp01(timer / preRollDelay); // Return normalized pre-roll progress.

                case RecordingState.Recording:
                    if (analyzer == null || analyzer.AudioSource == null || analyzer.AudioSource.clip == null) return 0f; // Prevent invalid progress calculations.
                    return Mathf.Clamp01(analyzer.AudioSource.time / analyzer.AudioSource.clip.length); // Return normalized audio playback progress.

                case RecordingState.Saving:
                    return 1f; // Saving always represents completed progress.

                default:
                    return 0f; // Idle state has no active progress.
            }
        }

        #endregion
    }

#if UNITY_EDITOR

    #region === Custom Editor ===

    /// <summary>
    /// Custom inspector used to control and monitor the LipSyncRecorder.
    /// </summary>
    [CanEditMultipleObjects]
    [CustomEditor(typeof(LipSyncRecorder))]
    public class LipSyncRecorderEditor : Editor
    {
        /// <summary>
        /// Draws the custom inspector GUI.
        /// </summary>
        public override void OnInspectorGUI()
        {
            var recorder = (LipSyncRecorder)target; // Cache the target recorder reference.

            // Display an editor-only warning message.
            GUI.color = Color.yellow;
            EditorGUILayout.HelpBox("This script is for editor use only.", MessageType.Warning);
            GUI.color = Color.white;

            // Disable the record button while recording is active.
            GUI.enabled = recorder.state == LipSyncRecorder.RecordingState.Idle;

            // Change button label depending on play mode state.
            var buttonLabel = EditorApplication.isPlaying ? "Start Recording" : "Play";
            var tooltip = EditorApplication.isPlaying ? "Starts the lip sync recording process." : "Enters Play Mode so recording can begin.";

            // Draw the main recording button.
            if (GUILayout.Button(new GUIContent(buttonLabel, tooltip), GUILayout.Height(30)))
            {
                if (EditorApplication.isPlaying) recorder.StartRecording(); // Start recording if already in play mode.
                else EditorApplication.isPlaying = true; // Otherwise enter play mode first.
            }

            GUI.enabled = true;

            GUILayout.Space(10);

            float progress = recorder.GetProgress(); // Retrieve normalized recording progress.

            // Default progress bar values.
            Color progressColor = Color.gray;
            string label = "Idle";

            // Update visual state depending on the recorder state.
            switch (recorder.state)
            {
                // Display stabilization progress.
                case LipSyncRecorder.RecordingState.PreRoll:
                    progressColor = Color.red;
                    label = $"Stabilizing {Mathf.RoundToInt(progress * 100f)}%";
                    break;

                // Display active recording progress.
                case LipSyncRecorder.RecordingState.Recording:
                    progressColor = Color.cyan;
                    label = $"Recording {Mathf.RoundToInt(progress * 100f)}%";
                    break;

                // Display saving state.
                case LipSyncRecorder.RecordingState.Saving:
                    progressColor = Color.green;
                    label = "Saving...";
                    progress = 1f;
                    break;
            }

            EditorGUILayout.LabelField("Recording Progress");

            Rect rect = GUILayoutUtility.GetRect(18, 18, "TextField"); // Reserve space for the progress bar.
            EditorGUI.DrawRect(rect, new Color(0.15f, 0.15f, 0.15f)); // Draw the progress bar background.

            // Calculate the filled region size.
            Rect fill = rect;
            fill.width *= progress;

            EditorGUI.DrawRect(fill, progressColor); // Draw the filled progress area.

            // Create centered label style for the progress text.
            GUIStyle progressLabelStyle = new(EditorStyles.boldLabel)
            {
                alignment = TextAnchor.MiddleCenter
            };

            // Calculate color brightness to improve text readability.
            float brightness = (progressColor.r * 0.299f) + (progressColor.g * 0.587f) + (progressColor.b * 0.114f);

            // Automatically switch text color depending on background brightness.
            progressLabelStyle.normal.textColor = brightness > 0.5f ? Color.black : Color.white;

            // Draw progress label on top of the progress bar.
            EditorGUI.LabelField(rect, label, progressLabelStyle);

            GUILayout.Space(10);

            DrawDefaultInspector(); // Draw the default serialized fields.

            // Continuously repaint the inspector while in play mode to keep the progress bar updated in real time.
            if (EditorApplication.isPlaying) Repaint();
        }
    }

    #endregion

#endif
}