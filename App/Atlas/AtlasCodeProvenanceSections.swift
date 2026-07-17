import SwiftUI
import AtlasCore

// MARK: - Seções da folha de proveniência (C23)
// Extraídas sem mudança de comportamento — a folha só compõe.

struct AtlasCodeProvenanceWhyTarget: Identifiable {
    let path: String
    var id: String { path }
}

extension AtlasCodeProvenanceSheet {
    /// A lei que sustenta a acusação — e o documento que a prova.
    @ViewBuilder
    var lawCitation: some View {
        if state == .violating, let ruleId {
            VStack(alignment: .leading, spacing: 3) {
                Text(AtlasCodeIssue.law(ruleId, trunk: trunk))
                    .font(AtlasFont.serif(14, .semibold))
                    .foregroundStyle(AtlasCodePalette.alert)
                if let ruleCanon {
                    Text(ruleCanon)
                        .font(AtlasFont.mono(8.5))
                        .foregroundStyle(AtlasTheme.textTertiary.opacity(0.85))
                        .lineLimit(1)
                        .truncationMode(.head)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(AtlasCodePalette.alert.opacity(0.08))
            )
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier(A11yID.codeProvenanceLaw)
        }
    }

    /// A porta para o agente, com o commit já no assunto.
    var askButton: some View {
        Button(action: onAsk) {
            HStack(spacing: 8) {
                Text("✦")
                    .font(AtlasFont.serif(12))
                    .foregroundStyle(AtlasTheme.accent)
                Text("perguntar sobre este commit")
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textSecondary)
                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .atlasCard(cornerRadius: 12)
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(A11yID.codeProvenanceAsk)
        .accessibilityLabel("Perguntar ao Atlas sobre este commit")
    }
}
