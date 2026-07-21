import AtlasCore
import SwiftUI

// Cycle 041 fuse → AtlasCodeProvenanceHeader+Dateline.swift

extension AtlasCodeProvenanceSheet {
    var stateLabelHealthy: String? {
        switch state {
        case .onMain: return "NA MAIN"
        case .healed: return "CURADO"
        default: return nil
        }
    }
}

extension AtlasCodeProvenanceSheet {
    var stateLabelViolating: String {
        ruleId.map { "FORA DA LINHA · \(AtlasCodeIssue.law($0, trunk: trunk).uppercased())" } ?? "FORA DA LINHA"
    }
}

extension AtlasCodeProvenanceSheet {
    var stateLabel: String {
        if let healthy = stateLabelHealthy { return healthy }
        switch state {
        case .violating: return stateLabelViolating
        case .history: return "HISTÓRIA"
        default: return "HISTÓRIA"
        }
    }
}

extension AtlasCodeProvenanceSheet {
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
}

extension AtlasCodeProvenanceSheet {
    var headerStateKickerGlyph: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(AtlasCodePalette.color(for: state))
                .frame(width: 6, height: 6)
                .accessibilityHidden(true)
            Text(stateLabel)
                .atlasSans(9, .bold)
                .tracking(1.4)
                .foregroundStyle(AtlasCodePalette.color(for: state))
                .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    var headerStateKicker: some View {
        headerStateKickerGlyph
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenStateKicker())
            .accessibilityIdentifier(A11yID.codeProvenanceState)
    }
}
