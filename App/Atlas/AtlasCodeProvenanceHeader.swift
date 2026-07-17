import SwiftUI
import AtlasCore

// MARK: - Cabeçalho da folha de proveniência (C23)

extension AtlasCodeProvenanceSheet {
    var header: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 6) {
                Circle()
                    .fill(AtlasCodePalette.color(for: state))
                    .frame(width: 6, height: 6)
                Text(stateLabel)
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1.4)
                    .foregroundStyle(AtlasCodePalette.color(for: state))
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(stateLabel.lowercased())
            .accessibilityIdentifier(A11yID.codeProvenanceState)

            Text(node.message ?? "Por que esta linha existe")
                .font(AtlasFont.serif(22, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 3) {
                Text(dateline)
                    .font(AtlasFont.mono(9.5))
                    .foregroundStyle(AtlasTheme.textTertiary)
                // A magnitude do commit vem cedo: uma descrição longa não pode
                // esconder o tamanho do que ele fez. A lista fica no fim.
                if case .loaded(let provenance) = phase, let headline = provenance.diffHeadline {
                    Text(headline)
                        .font(AtlasFont.mono(9.5))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .monospacedDigit()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var stateLabel: String {
        switch state {
        case .onMain: return "NA MAIN"
        // A lei em português e em caixa alta de manchete — nunca o id cru.
        case .violating: return ruleId.map { "FORA DA LINHA · \(AtlasCodeIssue.law($0, trunk: trunk).uppercased())" } ?? "FORA DA LINHA"
        case .healed: return "CURADO"
        case .history: return "HISTÓRIA"
        }
    }

    /// Autor · agente · quando. O agente só aparece quando o ledger respondeu.
    var dateline: String {
        let author = node.authorName.isEmpty ? node.authorEmail : node.authorName
        var parts = [author]
        if case .loaded(let provenance) = phase { parts.append(provenance.agentLabel) }
        parts.append("há \(AtlasCodeRelativeTime.short(from: node.authoredAt))")
        return parts.joined(separator: " · ")
    }

    var hashFooter: some View {
        Text(node.hash)
            .font(AtlasFont.mono(9))
            .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
            .textSelection(.enabled)
            .padding(.top, 2)
            .accessibilityLabel("hash do commit")
    }
}
