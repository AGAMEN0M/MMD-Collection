/*
 * ---------------------------------------------------------------------------
 * Description:
 * Real-time vowel formant analysis and lip sync system inspired by the
 * LipSynchloid v020 (Miku Miku Moving) algorithm.
 *
 * This component performs:
 * - Real-time FFT spectrum extraction from an AudioSource.
 * - Estimation of vowel formant energy bands (A, I, U, O).
 * - Heuristic-based vowel classification using spectral patterns.
 * - Conversion of detected vowels into MMD-style blend shape weights.
 * - Amplitude-based intensity scaling using sound pressure (dB).
 * - Temporal smoothing using weighted history filters for stability.
 * - Stabilization logic to reduce jitter and micro-fluctuations.
 *
 * Designed for Japanese-style vowel morph target systems commonly used in MMD/VRM:
 * あ (A), い (I), う (U), お (O).
 *
 * The system prioritizes stable real-time animation over linguistic accuracy,
 * making it suitable for stylized avatars, games, and live character rigs.
 *
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
 */

using UnityEngine;
using System;

#if UNITY_EDITOR
using UnityEditor;
#endif

namespace MMDCollection
{
    [AddComponentMenu("Tools/MMD Collection/Animation/Realtime Lip Sync Analyzer")]
    public class RealtimeLipSyncAnalyzer : MonoBehaviour
    {
        #region === Serialized Fields ===

        [Header("References")]
        [SerializeField, Tooltip("Audio source used for real-time voice analysis and FFT spectrum extraction.")]
        private AudioSource audioSource;

        [SerializeField, Tooltip("Skinned mesh renderer containing the facial blend shapes used for lip sync animation.")]
        private SkinnedMeshRenderer skinnedMeshRenderer;

        [Header("Blend Shapes あ (A), い (I), う (U), お (O)")]
        [SerializeField, Tooltip("Blend shape index used for the Japanese vowel あ (A).")]
        private int vowelABlendShapeIndex = 17;

        [SerializeField, Tooltip("Blend shape index used for the Japanese vowel い (I).")]
        private int vowelIBlendShapeIndex = 18;

        [SerializeField, Tooltip("Blend shape index used for the Japanese vowel う (U).")]
        private int vowelUBlendShapeIndex = 19;

        [SerializeField, Tooltip("Blend shape index used for the Japanese vowel お (O).")]
        private int vowelOBlendShapeIndex = 21;

        [Header("LipSynchloid Dynamic Range")]
        [SerializeField, Tooltip("Minimum decibel threshold required before lip sync activation begins.")]
        private float minimumDecibelThreshold = -35.0f;

        [SerializeField, Tooltip("Maximum decibel threshold where morph intensity reaches full strength.")]
        private float maximumDecibelThreshold = -12.0f;

        [Header("Temporal Smoothing")]
        [SerializeField, Range(1, 30), Tooltip("Amount of temporal smoothing samples used by the weighted history filter.")]
        private int smoothingWindowSize = 16;

        [SerializeField, Range(0.01f, 1f), Tooltip("Interpolation speed used when transitioning blend shape values.")]
        private float interpolationSpeed = 0.18f;

        [SerializeField, Range(0.0f, 5.0f), Tooltip("Deadzone threshold used to suppress small blend shape jitter fluctuations.")]
        private float stabilizationDeadzone = 1.5f;

        #endregion

        #region === Runtime Buffers ===

        /// <summary>
        /// Raw waveform audio samples.
        /// </summary>
        private readonly float[] audioSamples = new float[1024];

        /// <summary>
        /// FFT frequency spectrum data.
        /// </summary>
        private readonly float[] frequencySpectrum = new float[512];

        /// <summary>
        /// Current blend shape weights applied to the character.
        /// </summary>
        private readonly float[] currentBlendShapeWeights = new float[4];

        /// <summary>
        /// Temporal smoothing filters for each vowel channel.
        /// </summary>
        private WeightedHistoryFilter[] vowelSmoothingFilters;

        #endregion

        #region === Static Vowel Weight Table ===

        /// <summary>
        /// Original LipSynchloid vowel weight matrix.
        /// </summary>
        private static readonly float[][] VowelWeightTable =
        {
            new float[] { 0.6f, 0.0f, 0.0f, 0.0f }, // A
            new float[] { 0.0f, 0.7f, 0.0f, 0.0f }, // I
            new float[] { 0.2f, 0.0f, 0.8f, 0.1f }, // U
            new float[] { 0.3f, 0.4f, 0.1f, 0.0f }, // Transition
            new float[] { 0.2f, 0.0f, 0.0f, 0.5f }, // O
            new float[] { 0.2f, 0.2f, 0.3f, 0.1f }, // Neutral
        };

        #endregion

        #region === Public Properties ===

        /// <summary>
        /// Audio source used for real-time voice analysis and FFT spectrum extraction.
        /// </summary>
        public AudioSource AudioSource
        {
            get => audioSource;
            set => audioSource = value;
        }

        /// <summary>
        /// Skinned mesh renderer containing the facial blend shapes used for lip sync animation.
        /// </summary>
        public SkinnedMeshRenderer SkinnedMeshRenderer
        {
            get => skinnedMeshRenderer;
            set => skinnedMeshRenderer = value;
        }

        /// <summary>
        /// Blend shape index used for the Japanese vowel あ (A).
        /// </summary>
        public int VowelABlendShapeIndex
        {
            get => vowelABlendShapeIndex;
            set => vowelABlendShapeIndex = value;
        }

        /// <summary>
        /// Blend shape index used for the Japanese vowel い (I).
        /// </summary>
        public int VowelIBlendShapeIndex
        {
            get => vowelIBlendShapeIndex;
            set => vowelIBlendShapeIndex = value;
        }

        /// <summary>
        /// Blend shape index used for the Japanese vowel う (U).
        /// </summary>
        public int VowelUBlendShapeIndex
        {
            get => vowelUBlendShapeIndex;
            set => vowelUBlendShapeIndex = value;
        }

        /// <summary>
        /// Blend shape index used for the Japanese vowel お (O).
        /// </summary>
        public int VowelOBlendShapeIndex
        {
            get => vowelOBlendShapeIndex;
            set => vowelOBlendShapeIndex = value;
        }

        /// <summary>
        /// Minimum decibel threshold required before lip sync activation begins.
        /// </summary>
        public float MinimumDecibelThreshold
        {
            get => minimumDecibelThreshold;
            set => minimumDecibelThreshold = value;
        }

        /// <summary>
        /// Maximum decibel threshold where morph intensity reaches full strength.
        /// </summary>
        public float MaximumDecibelThreshold
        {
            get => maximumDecibelThreshold;
            set => maximumDecibelThreshold = value;
        }

        /// <summary>
        /// Amount of temporal smoothing samples used by the weighted history filter.
        /// </summary>
        public int SmoothingWindowSize
        {
            get => smoothingWindowSize;
            set => smoothingWindowSize = value;
        }

        /// <summary>
        /// Interpolation speed used when transitioning blend shape values.
        /// </summary>
        public float InterpolationSpeed
        {
            get => interpolationSpeed;
            set => interpolationSpeed = value;
        }

        /// <summary>
        /// Deadzone threshold used to suppress small blend shape jitter fluctuations.
        /// </summary>
        public float StabilizationDeadzone
        {
            get => stabilizationDeadzone;
            set => stabilizationDeadzone = value;
        }

        #endregion

        #region === Unity Events ===

        /// <summary>
        /// Initializes temporal smoothing filters.
        /// </summary>
        private void Start()
        {
            vowelSmoothingFilters = new WeightedHistoryFilter[4];
            for (int i = 0; i < 4; i++) vowelSmoothingFilters[i] = new WeightedHistoryFilter(smoothingWindowSize);
        }

        /// <summary>
        /// Performs real-time vowel analysis and applies blend shape animation.
        /// </summary>
        private void LateUpdate()
        {
            if (audioSource == null || !audioSource.isPlaying)
            {
                ResetBlendShapes();
                return;
            }

            // -------------------------------------------------------------------
            // Step 1:
            // Capture waveform samples and calculate RMS loudness.
            // -------------------------------------------------------------------

            audioSource.GetOutputData(audioSamples, 0);
            float rootMeanSquare = CalculateRootMeanSquare(audioSamples);
            float soundPressureDecibels = 20.0f * Mathf.Log10(rootMeanSquare + 1e-5f);

            // -------------------------------------------------------------------
            // Step 2:
            // Extract FFT frequency spectrum.
            // -------------------------------------------------------------------

            audioSource.GetSpectrumData(frequencySpectrum, 0, FFTWindow.BlackmanHarris);

            float totalSpectrumEnergy = 0f;
            for (int i = 0; i < frequencySpectrum.Length; i++) totalSpectrumEnergy += frequencySpectrum[i];

            // Ignore invalid or silent spectrum frames.
            if (totalSpectrumEnergy < 1e-5f)
            {
                ResetBlendShapes();
                return;
            }

            // -------------------------------------------------------------------
            // Step 3:
            // Analyze normalized spectral energy in vowel formant regions.
            // -------------------------------------------------------------------

            float sampleRate = AudioSettings.outputSampleRate;
            float vowelABandEnergy = CalculateNormalizedBandEnergy(0f, 1300f, sampleRate, totalSpectrumEnergy);
            float vowelIBandEnergy = CalculateNormalizedBandEnergy(800f, 1400f, sampleRate, totalSpectrumEnergy);
            float vowelUBandEnergy = CalculateNormalizedBandEnergy(1500f, 2000f, sampleRate, totalSpectrumEnergy);
            float vowelOBandEnergy = CalculateNormalizedBandEnergy(2800f, 3200f, sampleRate, totalSpectrumEnergy);
            float transitionBandEnergy = CalculateNormalizedBandEnergy(1600f, 2600f, sampleRate, totalSpectrumEnergy);

            // -------------------------------------------------------------------
            // Step 4:
            // Generate binary vowel detection flags.
            // -------------------------------------------------------------------

            int vowelDetectionFlags = 0;
            if (vowelABandEnergy >= 20.0f) vowelDetectionFlags += 1;
            if (vowelIBandEnergy >= 13.0f) vowelDetectionFlags += 2;
            if (vowelUBandEnergy >= 9.0f) vowelDetectionFlags += 4;
            if (vowelOBandEnergy >= 6.0f) vowelDetectionFlags += 8;
            if (transitionBandEnergy <= 5.0f) vowelDetectionFlags += 16;

            // -------------------------------------------------------------------
            // Step 5:
            // Classify dominant vowel.
            // -------------------------------------------------------------------

            int detectedVowelIndex = ClassifyVowel(vowelDetectionFlags);

            // -------------------------------------------------------------------
            // Step 6:
            // Retrieve original LipSynchloid morph weights.
            // -------------------------------------------------------------------

            float[] targetMorphWeights = VowelWeightTable[detectedVowelIndex];

            // -------------------------------------------------------------------
            // Step 7:
            // Scale morph intensity using sound pressure.
            // -------------------------------------------------------------------
            float amplitudeScaling = CalculateAmplitudeScaling(soundPressureDecibels, minimumDecibelThreshold, maximumDecibelThreshold);

            // -------------------------------------------------------------------
            // Step 8:
            // Apply smoothing, stabilization and blend shape interpolation.
            // -------------------------------------------------------------------

            ApplyBlendShapeWeights(targetMorphWeights, amplitudeScaling);
        }

        #endregion

        #region === Audio Analysis ===

        /// <summary>
        /// Calculates RMS amplitude from waveform samples.
        /// </summary>
        /// <param name="samples">Waveform sample buffer.</param>
        /// <returns>Root mean square amplitude.</returns>
        private float CalculateRootMeanSquare(float[] samples)
        {
            float squaredAmplitudeSum = 0f;
            for (int i = 0; i < samples.Length; i++) squaredAmplitudeSum += samples[i] * samples[i];
            return Mathf.Sqrt(squaredAmplitudeSum / samples.Length);
        }

        /// <summary>
        /// Calculates normalized spectral energy inside a frequency band.
        /// </summary>
        /// <param name="minimumFrequency">Lower frequency bound in Hz.</param>
        /// <param name="maximumFrequency">Upper frequency bound in Hz.</param>
        /// <param name="sampleRate">Current output sample rate.</param>
        /// <param name="totalSpectrumEnergy">Total spectrum energy.</param>
        /// <returns>Normalized energy percentage.</returns>
        private float CalculateNormalizedBandEnergy(float minimumFrequency, float maximumFrequency, float sampleRate, float totalSpectrumEnergy)
        {
            float spectrumBinSize = sampleRate / 2f / frequencySpectrum.Length;
            int minimumSpectrumIndex = Mathf.Clamp(Mathf.FloorToInt(minimumFrequency / spectrumBinSize), 0, frequencySpectrum.Length - 1);
            int maximumSpectrumIndex = Mathf.Clamp(Mathf.CeilToInt(maximumFrequency / spectrumBinSize), minimumSpectrumIndex, frequencySpectrum.Length - 1);

            float bandEnergySum = 0f;
            for (int i = minimumSpectrumIndex; i <= maximumSpectrumIndex; i++) bandEnergySum += frequencySpectrum[i];

            return (bandEnergySum / totalSpectrumEnergy) * 100f;
        }

        #endregion

        #region === Vowel Classification ===

        /// <summary>
        /// Classifies the dominant vowel using LipSynchloid heuristic rules.
        /// </summary>
        /// <param name="detectionFlags">Binary vowel detection flags.</param>
        /// <returns>Detected vowel index.</returns>
        private int ClassifyVowel(int detectionFlags)
        {
            if ((detectionFlags & 7) == 7) return 0;
            if ((detectionFlags & 3) == 3) return 4;
            if ((detectionFlags & 17) == 17) return 3;
            if ((detectionFlags & 9) == 9) return 1;
            return (detectionFlags & 1) == 1 ? 2 : 5;
        }

        #endregion

        #region === Morph Processing ===

        /// <summary>
        /// Converts sound pressure into normalized morph scaling.
        /// </summary>
        /// <param name="decibelValue">Current sound pressure in dB.</param>
        /// <param name="minimumDecibel">Minimum active threshold.</param>
        /// <param name="maximumDecibel">Maximum active threshold.</param>
        /// <returns>Normalized amplitude scaling.</returns>
        private float CalculateAmplitudeScaling(float decibelValue, float minimumDecibel, float maximumDecibel)
        {
            if (decibelValue < minimumDecibel) return 0f;
            if (decibelValue > maximumDecibel) return 1f;
            return -1.0f / (minimumDecibel - maximumDecibel) * decibelValue + 1.0f / (minimumDecibel - maximumDecibel) * minimumDecibel;
        }

        /// <summary>
        /// Applies smoothed blend shape weights to the character mesh.
        /// </summary>
        /// <param name="targetMorphWeights">Target vowel morph weights.</param>
        /// <param name="amplitudeScaling">Volume scaling factor.</param>
        private void ApplyBlendShapeWeights(float[] targetMorphWeights, float amplitudeScaling)
        {
            if (skinnedMeshRenderer == null) return;

            bool isSilent = amplitudeScaling <= 0f;

            for (int i = 0; i < 4; i++)
            {
                float targetBlendShapeWeight = 0f;

                // Process active voice frames.
                if (!isSilent)
                {
                    float rawMorphWeight = targetMorphWeights[i] * amplitudeScaling;
                    float smoothedMorphWeight = (float)vowelSmoothingFilters[i].Evaluate(rawMorphWeight);
                    targetBlendShapeWeight = Mathf.Clamp(smoothedMorphWeight * 100f, 0f, 100f);
                }
                else
                {
                    // Feed zeros into the filter to gradually clear history.
                    vowelSmoothingFilters[i].Evaluate(0.0);
                }

                // Apply deadzone stabilization.
                if (Mathf.Abs(targetBlendShapeWeight - currentBlendShapeWeights[i]) > stabilizationDeadzone)
                {
                    currentBlendShapeWeights[i] = Mathf.Lerp(currentBlendShapeWeights[i], targetBlendShapeWeight, interpolationSpeed);
                }
                else
                {
                    // Accelerate decay during silence.
                    float decaySpeed = isSilent ? 0.3f : interpolationSpeed;
                    currentBlendShapeWeights[i] = Mathf.Lerp(currentBlendShapeWeights[i], targetBlendShapeWeight, decaySpeed);
                }
            }

            // Apply final blend shape weights.
            skinnedMeshRenderer.SetBlendShapeWeight(vowelABlendShapeIndex, currentBlendShapeWeights[0]);
            skinnedMeshRenderer.SetBlendShapeWeight(vowelIBlendShapeIndex, currentBlendShapeWeights[1]);
            skinnedMeshRenderer.SetBlendShapeWeight(vowelUBlendShapeIndex, currentBlendShapeWeights[2]);
            skinnedMeshRenderer.SetBlendShapeWeight(vowelOBlendShapeIndex, currentBlendShapeWeights[3]);
        }

        /// <summary>
        /// Gradually resets all blend shape weights to neutral.
        /// </summary>
        private void ResetBlendShapes()
        {
            if (skinnedMeshRenderer == null) return;

            for (int i = 0; i < 4; i++)
            {
                float filteredWeight = (float)vowelSmoothingFilters[i].Evaluate(0f);
                currentBlendShapeWeights[i] = Mathf.Lerp(currentBlendShapeWeights[i], filteredWeight * 100f, 0.2f);
            }

            skinnedMeshRenderer.SetBlendShapeWeight(vowelABlendShapeIndex, currentBlendShapeWeights[0]);
            skinnedMeshRenderer.SetBlendShapeWeight(vowelIBlendShapeIndex, currentBlendShapeWeights[1]);
            skinnedMeshRenderer.SetBlendShapeWeight(vowelUBlendShapeIndex, currentBlendShapeWeights[2]);
            skinnedMeshRenderer.SetBlendShapeWeight(vowelOBlendShapeIndex, currentBlendShapeWeights[3]);
        }

        #endregion

        #region === Internal Filter ===

        /// <summary>
        /// Weighted temporal smoothing filter based on exponential decay history.
        /// </summary>
        private class WeightedHistoryFilter
        {
            #region === Fields ===

            /// <summary>
            /// Number of history samples used by the filter.
            /// </summary>
            private readonly int historySize;

            /// <summary>
            /// Internal historical sample buffer.
            /// </summary>
            private readonly double[] historyBuffer;

            #endregion

            #region === Constructor ===

            /// <summary>
            /// Creates a new weighted history filter.
            /// </summary>
            /// <param name="historySize">Number of smoothing samples.</param>
            public WeightedHistoryFilter(int historySize)
            {
                this.historySize = Mathf.Clamp(historySize, 1, 30);
                historyBuffer = new double[this.historySize];
            }

            #endregion

            #region === Public Methods ===

            /// <summary>
            /// Evaluates a new sample using exponential weighted history.
            /// </summary>
            /// <param name="inputValue">Current input value.</param>
            /// <returns>Smoothed output value.</returns>
            public double Evaluate(double inputValue)
            {
                historyBuffer[0] = inputValue;
                double weightedSum = 0.0;

                // Apply exponentially decreasing weights.
                for (int i = 0; i < historySize; ++i) weightedSum += historyBuffer[i] / Math.Pow(2.0, i);

                // Normalize final output.
                double normalizedOutput = weightedSum / (Math.Pow(2.0, historySize) - 1.0) * Math.Pow(2.0, historySize - 1);

                // Shift history buffer.
                for (int i = historySize - 1; i > 0; --i) historyBuffer[i] = historyBuffer[i - 1];

                return normalizedOutput;
            }

            #endregion
        }

        #endregion
    }

#if UNITY_EDITOR

    #region === Custom Editor ===

    /// <summary>
    /// Custom Unity Editor inspector for RealtimeLipSyncAnalyzer.
    /// Provides real-time visualization and automation tools for lip sync debugging.
    /// </summary>
    [CanEditMultipleObjects]
    [CustomEditor(typeof(RealtimeLipSyncAnalyzer))]
    public class RealtimeLipSyncAnalyzerEditor : Editor
    {
        #region === Debug Graph ===

        /// <summary>
        /// Number of samples stored in the debug graph history buffer.
        /// </summary>
        private const int GraphSize = 64;

        /// <summary>
        /// Historical values for vowel A blend shape weight.
        /// </summary>
        private readonly float[] vowelAHistory = new float[GraphSize];

        /// <summary>
        /// Historical values for vowel I blend shape weight.
        /// </summary>
        private readonly float[] vowelIHistory = new float[GraphSize];

        /// <summary>
        /// Historical values for vowel U blend shape weight.
        /// </summary>
        private readonly float[] vowelUHistory = new float[GraphSize];

        /// <summary>
        /// Historical values for vowel O blend shape weight.
        /// </summary>
        private readonly float[] vowelOHistory = new float[GraphSize];

        /// <summary>
        /// Current write index used for circular buffer graph storage.
        /// </summary>
        private int graphIndex;

        #endregion

        #region === Unity Events ===

        /// <summary>
        /// Renders the custom inspector UI and updates debug visualization.
        /// </summary>
        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            // Cast target to analyzer instance for runtime inspection.
            var analyzer = target as RealtimeLipSyncAnalyzer;

            // Draw vowel legend for debugging clarity.
            EditorGUILayout.LabelField("🔴 A | 🔵 I | 🟢 U | 🟡 O", new GUIStyle(EditorStyles.label) { alignment = TextAnchor.MiddleCenter });
            DrawDebugGraph(analyzer); // Render real-time debug graph.

            EditorGUILayout.Space(10);

            // Button used to automatically map blend shapes based on naming conventions.
            if (GUILayout.Button(new GUIContent("Auto Detect MMD Vowel Blend Shapes", "Automatically searches and assigns vowel blend shape indices (A, I, U, O)."), GUILayout.Height(30)))
            {
                AutoDetectBlendShapes();
            }

            EditorGUILayout.Space(10);

            DrawDefaultInspector(); // Draw default inspector fields below custom tools.

            serializedObject.ApplyModifiedProperties();

            // Force continuous repaint for real-time graph updates.
            if (EditorApplication.isPlaying) Repaint();
        }

        #endregion

        #region === Blend Shape Detection ===

        /// <summary>
        /// Automatically detects vowel-related blend shapes in the assigned mesh.
        /// Supports Japanese MMD-style naming conventions.
        /// </summary>
        private void AutoDetectBlendShapes()
        {
            foreach (var targetObject in targets)
            {
                var analyzer = targetObject as RealtimeLipSyncAnalyzer;
                if (analyzer == null) continue;

                // Ensure valid mesh reference before processing.
                var smr = analyzer.SkinnedMeshRenderer;
                if (smr == null || smr.sharedMesh == null)
                {
                    Debug.LogWarning($"Missing SkinnedMeshRenderer or mesh on {analyzer.name}", analyzer);
                    continue;
                }

                Undo.RecordObject(analyzer, "Auto Detect BlendShapes");

                // Attempt to find vowel-related blend shapes using flexible name matching.
                analyzer.VowelABlendShapeIndex = FindBlendShapeIndex(smr.sharedMesh, "a", "あ");
                analyzer.VowelIBlendShapeIndex = FindBlendShapeIndex(smr.sharedMesh, "i", "い");
                analyzer.VowelUBlendShapeIndex = FindBlendShapeIndex(smr.sharedMesh, "u", "う");
                analyzer.VowelOBlendShapeIndex = FindBlendShapeIndex(smr.sharedMesh, "o", "お");

                EditorUtility.SetDirty(analyzer);
            }
        }

        /// <summary>
        /// Searches for a blend shape index using exact and token-based matching rules.
        /// </summary>
        /// <param name="mesh">Target mesh containing blend shapes.</param>
        /// <param name="keywords">Keywords used for matching vowel names.</param>
        /// <returns>Blend shape index if found; otherwise -1.</returns>
        private int FindBlendShapeIndex(Mesh mesh, params string[] keywords)
        {
            if (mesh == null) return -1;

            string[] normalizedKeywords = new string[keywords.Length];

            // Normalize keywords for safe comparison.
            for (int i = 0; i < keywords.Length; i++) normalizedKeywords[i] = NormalizeBlendShapeName(keywords[i]);

            // PASS 1: Exact match search.
            for (int blendShapeIndex = 0; blendShapeIndex < mesh.blendShapeCount; blendShapeIndex++)
            {
                string normalizedBlendShapeName = NormalizeBlendShapeName(mesh.GetBlendShapeName(blendShapeIndex));

                for (int keywordIndex = 0; keywordIndex < normalizedKeywords.Length; keywordIndex++)
                {
                    if (normalizedBlendShapeName == normalizedKeywords[keywordIndex]) return blendShapeIndex;
                }
            }

            // PASS 2: Token-based flexible match (MMD/VRM naming compatibility).
            for (int blendShapeIndex = 0; blendShapeIndex < mesh.blendShapeCount; blendShapeIndex++)
            {
                string normalizedBlendShapeName = NormalizeBlendShapeName(mesh.GetBlendShapeName(blendShapeIndex));

                for (int keywordIndex = 0; keywordIndex < normalizedKeywords.Length; keywordIndex++)
                {
                    string keyword = normalizedKeywords[keywordIndex];

                    if (normalizedBlendShapeName.StartsWith(keyword + ".") || normalizedBlendShapeName.EndsWith("." + keyword) || normalizedBlendShapeName.StartsWith(keyword + "_") || normalizedBlendShapeName.EndsWith("_" + keyword) || normalizedBlendShapeName.StartsWith(keyword + "-") || normalizedBlendShapeName.EndsWith("-" + keyword) || normalizedBlendShapeName.Contains("." + keyword + ".") || normalizedBlendShapeName.Contains("_" + keyword + "_") || normalizedBlendShapeName.Contains("-" + keyword + "-"))
                    {
                        return blendShapeIndex;
                    }
                }
            }

            return -1;
        }

        /// <summary>
        /// Normalizes blend shape names for consistent comparison.
        /// Removes spaces and forces lowercase.
        /// </summary>
        /// <param name="value">Original blend shape name.</param>
        /// <returns>Normalized string.</returns>
        private string NormalizeBlendShapeName(string value)
        {
            if (string.IsNullOrWhiteSpace(value)) return string.Empty;
            return value.Trim().ToLowerInvariant().Replace(" ", string.Empty).Replace("　", string.Empty);
        }

        #endregion

        #region === Debug Graph ===

        /// <summary>
        /// Renders the real-time vowel debug graph in the inspector.
        /// </summary>
        /// <param name="analyzer">The RealtimeLipSyncAnalyzer instance used to fetch runtime blend shape data for visualization.</param>
        private void DrawDebugGraph(RealtimeLipSyncAnalyzer analyzer)
        {
            Rect graphRect = GUILayoutUtility.GetRect(10, 90, GUILayout.ExpandWidth(true));

            EditorGUI.DrawRect(graphRect, new Color(0.12f, 0.12f, 0.12f)); // Background.

            // Border lines for visual structure.
            Handles.color = new Color(0.3f, 0.3f, 0.3f);

            Handles.DrawLine(new Vector3(graphRect.x, graphRect.y), new Vector3(graphRect.xMax, graphRect.y));
            Handles.DrawLine(new Vector3(graphRect.x, graphRect.yMax), new Vector3(graphRect.xMax, graphRect.yMax));
            Handles.DrawLine(new Vector3(graphRect.x, graphRect.y), new Vector3(graphRect.x, graphRect.yMax));
            Handles.DrawLine(new Vector3(graphRect.xMax, graphRect.y), new Vector3(graphRect.xMax, graphRect.yMax));

            // Mid reference line for neutral baseline.
            float midY = graphRect.y + graphRect.height * 0.5f;
            Handles.color = new Color(0.2f, 0.2f, 0.2f);

            Handles.DrawLine(new Vector3(graphRect.x, midY), new Vector3(graphRect.xMax, midY));

            // Capture runtime data only when analyzer exists.
            if (analyzer != null) CaptureBlendShapeHistory(analyzer);

            // Draw vowel curves.
            DrawGraphLine(graphRect, vowelAHistory, Color.red);
            DrawGraphLine(graphRect, vowelIHistory, Color.cyan);
            DrawGraphLine(graphRect, vowelUHistory, Color.green);
            DrawGraphLine(graphRect, vowelOHistory, Color.yellow);
        }

        /// <summary>
        /// Captures current blend shape values into circular history buffers.
        /// </summary>
        /// <param name="analyzer">The RealtimeLipSyncAnalyzer instance providing SkinnedMeshRenderer and blend shape indices.</param>
        private void CaptureBlendShapeHistory(RealtimeLipSyncAnalyzer analyzer)
        {
            if (analyzer.SkinnedMeshRenderer == null) return;

            var smr = analyzer.SkinnedMeshRenderer;

            vowelAHistory[graphIndex] = smr.GetBlendShapeWeight(analyzer.VowelABlendShapeIndex) / 100f;
            vowelIHistory[graphIndex] = smr.GetBlendShapeWeight(analyzer.VowelIBlendShapeIndex) / 100f;
            vowelUHistory[graphIndex] = smr.GetBlendShapeWeight(analyzer.VowelUBlendShapeIndex) / 100f;
            vowelOHistory[graphIndex] = smr.GetBlendShapeWeight(analyzer.VowelOBlendShapeIndex) / 100f;

            graphIndex = (graphIndex + 1) % GraphSize;
        }

        /// <summary>
        /// Draws a single colored line graph representing a vowel channel.
        /// </summary>
        /// <param name="rect">The rectangle area where the graph is rendered in the inspector.</param>
        /// <param name="data">Circular buffer containing normalized blend shape values over time.</param>
        /// <param name="color">Color used to render the specific vowel curve.</param>
        private void DrawGraphLine(Rect rect, float[] data, Color color)
        {
            Handles.color = color;

            for (int i = 1; i < GraphSize; i++)
            {
                int prev = (graphIndex + i - 1) % GraphSize;
                int curr = (graphIndex + i) % GraphSize;

                float x1 = rect.x + ((i - 1) / (float)(GraphSize - 1)) * rect.width;
                float x2 = rect.x + (i / (float)(GraphSize - 1)) * rect.width;

                float y1 = rect.yMax - (data[prev] * rect.height);
                float y2 = rect.yMax - (data[curr] * rect.height);

                Handles.DrawLine(new Vector3(x1, y1), new Vector3(x2, y2));
            }
        }

        #endregion
    }

    #endregion

#endif
}