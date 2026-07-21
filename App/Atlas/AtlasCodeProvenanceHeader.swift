import SwiftUI
import AtlasCore

// WAVE-009 fused Provenance header
// Single-feature peel fusion for Code depth instrument.

// --- fused from AtlasCodeProvenanceHeader+Dateline+StateLabel+Healthy.swift ---
extension AtlasCodeProvenanceSheet {
    var stateLabelHealthy: String? {
        switch state {
        case .onMain: return "NA MAIN"
        case .healed: return "CURADO"
        default: return nil
        }
    }
}

// --- fused from AtlasCodeProvenanceHeader+Dateline+StateLabel+Violating.swift ---
extension AtlasCodeProvenanceSheet {
    var stateLabelViolating: String {
        ruleId.map { "FORA DA LINHA · \(AtlasCodeIssue.law($0, trunk: trunk).uppercased())" } ?? "FORA DA LINHA"
    }
}

// --- fused from AtlasCodeProvenanceHeader+Dateline+StateLabel.swift ---
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

// --- fused from AtlasCodeProvenanceHeader+Dateline.swift ---
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

// --- fused from AtlasCodeProvenanceHeader+DatelineBlock.swift ---
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

// --- fused from AtlasCodeProvenanceHeader+Meta.swift ---
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

// --- fused from AtlasCodeProvenanceHeader+StateKicker+Glyph.swift ---
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

// --- fused from AtlasCodeProvenanceHeader+StateKicker.swift ---
extension AtlasCodeProvenanceSheet {
    var headerStateKicker: some View {
        headerStateKickerGlyph
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenStateKicker())
            .accessibilityIdentifier(A11yID.codeProvenanceState)
    }
}

// --- fused from AtlasCodeProvenanceHeader+Title.swift ---
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

// --- fused from AtlasCodeProvenanceHeader.swift ---
// MARK: - Cabeçalho da folha de proveniência (C23)
// Meta → AtlasCodeProvenanceHeader+Meta.swift · Dateline → +Dateline.swift
// Title → AtlasCodeProvenanceHeader+Title.swift
// State → AtlasCodeProvenanceHeader+StateKicker.swift

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


