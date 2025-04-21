/*
 * ---------------------------------------------------------------------------
 * Description: Custom Inspector for the MMDBoneRenderer component to handle
 *              live updates and undo operations for bone extraction.
 * Author: Lucas Gomes Cecchini
 * Pseudonym: AGAMENOM
 * ---------------------------------------------------------------------------
*/

using UnityEngine;
using UnityEditor;

namespace MMDCollection.BoneRenderer
{
    [CustomEditor(typeof(MMDBoneRenderer))]
    [CanEditMultipleObjects]
    public class MMDBoneRendererInspector : Editor
    {
        // Overrides the default Inspector GUI to support live updates and correctly handle Undo/Redo operations.
        public override void OnInspectorGUI()
        {
            serializedObject.Update(); // Update the serialized representation of the target object.

            // Detect changes in the Inspector.
            EditorGUI.BeginChangeCheck();
            DrawDefaultInspector();
            bool boneRendererDirty = EditorGUI.EndChangeCheck();

            // Also mark as dirty if the user performs an Undo or Redo.
            boneRendererDirty |= Event.current.type == EventType.ValidateCommand && Event.current.commandName == "UndoRedoPerformed";

            serializedObject.ApplyModifiedProperties(); // Apply modified properties to the serialized object.

            // If anything changed, update the bone renderer's internal data.
            if (boneRendererDirty)
            {
                foreach (var t in targets)
                {
                    var boneRenderer = t as MMDBoneRenderer;
                    boneRenderer.ExtractBones();
                }
            }
        }
    }
}