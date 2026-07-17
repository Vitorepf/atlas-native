import SwiftUI
import AtlasCore

// Dateline + magnitude — peel de AtlasCodeProvenanceHeader.

extension AtlasCodeProvenanceSheet {
    var headerDatelineBlock: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(dateline)
                .font(AtlasFont.mono(9.5))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityLabel(spokenDateline())
            // A magnitude do commit vem cedo: uma descrição longa não pode
            // esconder o tamanho do que ele fez. A lista fica no fim.
            if case .loaded(let provenance) = phase, let headline = provenance.diffHeadline {
                Text(headline)
                    .font(AtlasFont.mono(9.5))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
                    .accessibilityLabel("magnitude, \(headline)")
            }
        }
    }
}
