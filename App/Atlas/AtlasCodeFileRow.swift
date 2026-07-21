import SwiftUI
import AtlasCore

// IDLE-COMPRESS host

// --- AtlasCodeFileRow.swift ---
struct AtlasCodeFileRow: View {
    let file: AtlasCodeFileChange
    var accessibilityIdentifier: String?

    var body: some View {
        lead
            .padding(.vertical, 9)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AtlasCodeFileRowA11y.spokenFile(file))
            .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }
}

