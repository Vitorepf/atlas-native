import SwiftUI
import AtlasCore

// MARK: - Cabeçalho da folha de proveniência (C23)
// Meta → AtlasCodeProvenanceHeader+Meta.swift

extension AtlasCodeProvenanceSheet {
    var header: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 6) {
                Circle()
                    .fill(AtlasCodePalette.color(for: state))
                    .frame(width: 6, height: 6)
                    .accessibilityHidden(true)
                Text(stateLabel)
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1.4)
                    .foregroundStyle(AtlasCodePalette.color(for: state))
                    .accessibilityHidden(true)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenStateKicker())
            .accessibilityIdentifier(A11yID.codeProvenanceState)

            Group {
                if let message = node.message?.nonEmpty {
                    Text(message)
                        .font(AtlasFont.serif(22, .semibold))
                } else {
                    Text(String(node.hash.prefix(8)))
                        .font(AtlasFont.mono(22, .semibold))
                }
            }
            .foregroundStyle(AtlasTheme.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel(spokenHeaderTitle())

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
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isHeader)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
