import SwiftUI
import AtlasCore

// Failed detail — peel de AtlasCodeProvenanceSections+Failed.

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailedDetail(_ message: String) -> some View {
        if let detail = message.nonEmpty {
            Text(detail)
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasCodePalette.alert)
                .accessibilityHidden(true)
        }
    }
}
