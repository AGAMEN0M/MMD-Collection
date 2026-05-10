/*
 * ---------------------------------------------------------------------------
 * Description: Defines a serializable bone configuration and a custom
 *              PropertyDrawer used to render bone-related transform options
 *              in the Unity Inspector. This drawer allows selecting a target
 *              bone Transform and toggling whether its rotation, position,
 *              and visibility should be processed or rendered by systems
 *              that consume this data (e.g., bone visualization or animation tools).
 *              
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

using UnityEditor;
using UnityEngine;
using System;

namespace MMDCollection.BoneRenderer
{
    #region === class Definition ===

    /// <summary>
    /// Represents a single bone transform and its visual and transform settings.
    /// </summary>
    [Serializable]
    public class BonesTransform
    {
        [Tooltip("Reference to the bone Transform that will be controlled or visualized.")]
        public Transform bone;

        [Tooltip("If enabled, the bone rotation will be applied or synchronized.")]
        public bool rotate;

        [Tooltip("If enabled, the bone position will be applied or synchronized.")]
        public bool move;

        [Tooltip("If enabled, the bone will be visible or rendered by the bone system.")]
        public bool visible;
    }

    #endregion

#if UNITY_EDITOR

    #region === Custom Inspector ===

    [CustomPropertyDrawer(typeof(BonesTransform))]
    public class BonesTransformDrawer : PropertyDrawer
    {
        /// <summary>
        /// Renders the custom property GUI in the Inspector.
        /// </summary>
        /// <param name="position">Position rectangle to draw the property.</param>
        /// <param name="property">Serialized property to draw.</param>
        /// <param name="label">Label displayed for the property.</param>
        public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
        {
            EditorGUI.BeginProperty(position, label, property);

            float lineHeight = EditorGUIUtility.singleLineHeight;
            float spacing = EditorGUIUtility.standardVerticalSpacing;

            // Optional top label.
            Rect labelRect = new(position.x, position.y, position.width, lineHeight);
            EditorGUI.LabelField(labelRect, label);

            // Line 1: Bone field.
            Rect boneRect = new(position.x, labelRect.yMax + spacing, position.width, lineHeight);
            EditorGUI.PropertyField(boneRect, property.FindPropertyRelative("bone"), new GUIContent("Bone"));

            // Line 2: Rotate, Move, Visible toggles.
            float toggleWidth = (position.width - 2 * spacing) / 3f;
            Rect toggleRow = new(boneRect.x, boneRect.yMax + spacing, position.width, lineHeight);

            // Save current labelWidth.
            float prevLabelWidth = EditorGUIUtility.labelWidth;

            // Reduce labelWidth for compact alignment.
            EditorGUIUtility.labelWidth = 50f;

            var rotateProp = property.FindPropertyRelative("rotate");
            var moveProp = property.FindPropertyRelative("move");
            var visibleProp = property.FindPropertyRelative("visible");

            Rect rotateRect = new(toggleRow.x, toggleRow.y, toggleWidth, lineHeight);
            Rect moveRect = new(rotateRect.xMax + spacing, toggleRow.y, toggleWidth, lineHeight);
            Rect visibleRect = new(moveRect.xMax + spacing, toggleRow.y, toggleWidth, lineHeight);

            EditorGUI.PropertyField(rotateRect, rotateProp, new GUIContent("Rotate"));
            EditorGUI.PropertyField(moveRect, moveProp, new GUIContent("Move"));
            EditorGUI.PropertyField(visibleRect, visibleProp, new GUIContent("Visible"));

            // Restore original labelWidth.
            EditorGUIUtility.labelWidth = prevLabelWidth;

            EditorGUI.EndProperty();
        }

        /// <summary>
        /// Calculates the total height needed to draw the property.
        /// </summary>
        /// <param name="property">Serialized property being drawn.</param>
        /// <param name="label">GUI label associated with the property.</param>
        /// <returns>The total height in pixels required for the drawer.</returns>
        public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
        {
            float lineHeight = EditorGUIUtility.singleLineHeight;
            float spacing = EditorGUIUtility.standardVerticalSpacing;
            return lineHeight * 3 + spacing * 2;
        }
    }

    #endregion

#endif
}