import SwiftUI
import AtlasCore

// Dateline / state / hash — peel de AtlasCodeProvenanceHeader.

extension AtlasCodeProvenanceSheet {
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
        if case .loaded(let provenance) = phase, !provenance.agent.isEmpty {
            parts.append(provenance.agentLabel)
        }
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
