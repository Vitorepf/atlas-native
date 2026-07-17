import SwiftUI
import AtlasCore

// Failed body — peel de AtlasCodeProvenanceSections+Failed+Stack.

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailedBody(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            provenanceFailedTitle
            provenanceFailedDetail(message)
        }
    }
}
