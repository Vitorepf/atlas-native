import AtlasCore
import SwiftUI

// Cycle 044 fuse → AtlasCodeProvenanceHeader.swift

// MARK: - Cabeçalho da folha de proveniência (C23)

extension AtlasCodeProvenanceSheet {
    var header: some View {
        VStack(alignment: .leading, spacing: 9) {
            headerStateKicker
            headerTitle
            headerDatelineBlock
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isHeader)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

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

extension AtlasCodeProvenanceSheet {
    var hashFooter: some View {
        Text(node.hash)
            .font(AtlasFont.mono(9))
            .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
            .textSelection(.enabled)
            .padding(.top, 2)
            .accessibilityLabel("hash do commit")
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    var headerTitle: some View {
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
    }
}
