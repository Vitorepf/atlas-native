import SwiftUI
import AtlasCore

// Dateline block — RECONSTRUÍDO pós-merge (o peel criou `dateline`/título mas
// o bloco composto sumiu). Fiel ao original pré-merge: dateline em mono +
// a magnitude do commit cedo (diffHeadline), nunca escondida pela descrição.

extension AtlasCodeProvenanceSheet {
    var headerDatelineBlock: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(dateline)
                .font(AtlasFont.mono(9.5))
                .foregroundStyle(AtlasTheme.textTertiary)
            if case .loaded(let provenance) = phase, let headline = provenance.diffHeadline {
                Text(headline)
                    .font(AtlasFont.mono(9.5))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
            }
        }
    }
}
