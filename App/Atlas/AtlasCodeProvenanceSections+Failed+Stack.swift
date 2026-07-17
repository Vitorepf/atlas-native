import SwiftUI
import AtlasCore

// Failed stack — peel de AtlasCodeProvenanceSections+Failed.

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailedStack(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            provenanceFailedTitle
            provenanceFailedDetail(message)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenFailed(message))
    }
}
