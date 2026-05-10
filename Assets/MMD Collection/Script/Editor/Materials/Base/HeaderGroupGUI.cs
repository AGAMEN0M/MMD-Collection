/*
 * ---------------------------------------------------------------------------
 * Description: Provides a lightweight and optimized collapsible header group
 *              for custom inspectors and editor windows with persistent state.
 * 
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using System;

namespace MMDCollection.Editor
{
    /// <summary>
    /// Provides a lightweight and optimized collapsible group drawer
    /// intended exclusively for custom inspectors and editor windows.
    /// </summary>
    public static class HeaderGroupGUI
    {
        #region === State Cache ===

        /// <summary>
        /// Stores foldout states per group key to avoid repeated EditorPrefs access.
        /// </summary>
        private static readonly Dictionary<string, bool> foldoutStates = new();

        #endregion

        #region === Public API ===

        /// <summary>
        /// Draws a collapsible inspector group with persistent open/closed state.
        /// </summary>
        /// <param name="groupName">Displayed name of the group header.</param>
        /// <param name="drawContent">Callback responsible for drawing the group contents.</param>
        public static void DrawGroup(GUIContent groupName, Action drawContent)
        {
            // Retrieve the saved foldout state for this group.
            bool isOpen = GetGroupState(groupName.text);

            // Cache commonly used values to avoid repeated property access.
            float lineHeight = EditorGUIUtility.singleLineHeight;
            float fullWidth = EditorGUIUtility.currentViewWidth;

            // Reserve a single rect for the header.
            Rect headerRect = GUILayoutUtility.GetRect(0f, lineHeight + 2f, GUILayout.ExpandWidth(true));

            // Ensure the rect spans the entire inspector width.
            headerRect.x = 0f;
            headerRect.width = fullWidth;

            // Draw a solid black 1px top border.
            EditorGUI.DrawRect(new Rect(headerRect.x, headerRect.y, headerRect.width, 1f), new Color(0f, 0f, 0f, 0.3f));

            // Draw the group background with subtle transparency.
            EditorGUI.DrawRect(headerRect, new Color(0f, 0f, 0f, 0.1f));

            // Adjust rect for foldout control padding.
            headerRect.x += 28f;
            headerRect.width -= 28f;

            // Create a cached foldout style with bold text.
            GUIStyle foldoutStyle = EditorStyles.foldout;
            foldoutStyle.fontStyle = FontStyle.Bold;

            GUIContent label = new($" {groupName.text}", groupName.tooltip);

            // Draw foldout and detect state change.
            bool newState = EditorGUI.Foldout(headerRect, isOpen, label, true, foldoutStyle);

            // Persist foldout state only if it changed.
            if (newState != isOpen)
            {
                isOpen = newState;
                SaveGroupState(groupName.text, newState);
            }

            // Draw group contents if expanded.
            if (isOpen)
            {
                EditorGUI.indentLevel++;
                drawContent?.Invoke();
                EditorGUI.indentLevel--;
                GUILayout.Space(2f);
            }
        }

        #endregion
        
        #region === Internal Helpers ===
        
        /// <summary>
        /// Retrieves the stored foldout state for a group.
        /// </summary>
        private static bool GetGroupState(string groupName)
        {
            if (!foldoutStates.TryGetValue(groupName, out bool state))
            {
                state = EditorPrefs.GetBool(GetPrefsKey(groupName), true);
                foldoutStates[groupName] = state;
            }

            return state;
        }

        /// <summary>
        /// Saves the foldout state both in memory and EditorPrefs.
        /// </summary>
        private static void SaveGroupState(string groupName, bool state)
        {
            foldoutStates[groupName] = state;
            EditorPrefs.SetBool(GetPrefsKey(groupName), state);
        }

        /// <summary>
        /// Generates a unique EditorPrefs key for the group.
        /// </summary>
        private static string GetPrefsKey(string groupName) => $"HeaderGroupGUI_Foldout_{groupName}";

        #endregion
    }
}