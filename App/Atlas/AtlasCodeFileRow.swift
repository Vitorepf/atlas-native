import SwiftUI
import AtlasCore

// IDLE-COMPRESS host

struct AtlasCodeFileRow: View {
    let file: AtlasCodeFileChange
    var accessibilityIdentifier: String?

    var body: some View {
        lead
            .padding(.vertical, 9)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AtlasCodeProvenanceJudgment.spokenFile(file))
            .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }
}

