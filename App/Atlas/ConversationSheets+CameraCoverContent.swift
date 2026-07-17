import SwiftUI
import AtlasCore

// Camera cover content — peel de ConversationSheets+CameraCoverModifier.
// Capture → ConversationSheets+CameraCoverContent+Capture.swift
// Fail → ConversationSheets+CameraCoverContent+Fail.swift
// A11y → ConversationSheets+CameraCoverA11y.swift

extension ConversationCameraCoverModifier {
    var cameraCoverContent: some View {
        cameraCoverA11y(
            CameraPicker(
                onCapture: { cameraCoverOnCapture(data: $0) },
                onCaptureFailed: cameraCoverOnCaptureFailed,
                onCancel: {}
            )
        )
    }
}
