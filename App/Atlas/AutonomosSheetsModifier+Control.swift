import SwiftUI
import AtlasCore

// Control / start-run sheets — peel de AutonomosSheetsModifier.
// Start → AutonomosSheetsModifier+ControlStart.swift
// Only → AutonomosSheetsModifier+ControlOnly.swift

extension AutonomosSheetsModifier {
    @ViewBuilder
    func controlSheets<Content: View>(on content: Content) -> some View {
        startRunSheet(on: controlSheetOnly(on: content))
    }
}
