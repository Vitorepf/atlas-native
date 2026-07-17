import SwiftUI
import AtlasCore

// Campo de texto do composer — peel de ComposerToolbar.
// Attach → ComposerToolbar+FieldAttach.swift
// Placeholder → ComposerToolbar+Field+Placeholder.swift
// TextField → ComposerToolbar+Field+TextFieldInput.swift

extension ComposerToolbar {
    var composerTextField: some View {
        ZStack(alignment: .topLeading) {
            composerFieldPlaceholder
            composerTextFieldInput
        }
    }
}
