import AtlasCore
import SwiftUI

// WAVE-113 chrome/gates peel

// MARK: - Chrome / gates

extension ExecutionProof {
    func proofChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.vertical, 8).padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.surface.opacity(0.35))
                    .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
            )
    }
}

extension ExecutionProof {
    /// WAVE-042: gate owned by Judgment.
    static func hasDecisionSurface(_ d: AtlasDecisionSummary) -> Bool {
        ExecutionProofJudgment.hasDecisionSurface(d)
    }
}

extension ExecutionProof {
    var collapsedHeader: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            withAnimation(reduceMotion ? nil : AtlasMotion.editorial) { open.toggle() }
        } label: {
            collapsedHeaderLabel
        }
        .buttonStyle(.plain)
        .accessibilityLabel(spokenCollapsed(expanded: open))
        .accessibilityHint(open ? "toque para fechar a prova" : "toque para expandir a prova")
        .accessibilityIdentifier(A11yID.executionProof)
    }
}

extension ExecutionProof {
    var collapsedHeaderLabel: some View {
        HStack(spacing: 10) {
            Circle().fill(AtlasTheme.accent).frame(width: 10, height: 10)
                .accessibilityHidden(true)
            collapsedHeaderSummary
            Spacer(minLength: 0)
            Text(open ? "Fechar" : "Abrir")
                .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
        .contentShape(Rectangle())
    }
}

extension ExecutionProof {
    @ViewBuilder
    var collapsedHeaderSummary: some View {
        VStack(alignment: .leading, spacing: 1) {
            // WAVE-042: exclusive face kicker (not always "Obra concluída").
            Text(proofFace.kicker)
                .font(.system(.subheadline, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            if !summaryLine.isEmpty {
                Text(summaryLine)
                    .font(.system(.caption)).foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .accessibilityHidden(true)
            }
        }
    }
}

extension ExecutionProof {
    func decideLine(_ d: AtlasDecisionSummary) -> String {
        var out = "atlas decide"
        if let m = d.routeMode { out += " · \(m)" }
        if let p = d.selectedProvider { out += " · \(p)" }
        if let c = d.confidenceScore { out += " · conf \(String(format: "%.2f", c))" }
        if d.wasOverridden { out += " · override" }
        return out
    }
}

extension ExecutionProof {
    func decisionSpokenRoute(_ d: AtlasDecisionSummary) -> [String] {
        var parts = ["decisão do atlas"]
        if let m = d.routeMode { parts.append("modo \(m)") }
        if let p = d.selectedProvider { parts.append("provedor \(p)") }
        return parts
    }
}

extension ExecutionProof {
    func decisionSpoken(_ d: AtlasDecisionSummary) -> String {
        var parts = decisionSpokenRoute(d)
        if let c = d.confidenceScore { parts.append("confiança \(String(format: "%.2f", c))") }
        if d.wasOverridden { parts.append("substituída manualmente") }
        if let r = d.reason, !r.isEmpty { parts.append("motivo \(r)") }
        return parts.joined(separator: ", ")
    }
}

extension ExecutionProof {
    var spokenCollapsed: String {
        spokenCollapsed(expanded: false)
    }

    func spokenCollapsed(expanded: Bool) -> String {
        ExecutionProofJudgment.spokenCollapsed(
            bubble: bubble,
            artifactItems: rankedArtifactItems,
            expanded: expanded,
            humanDuration: humanDuration
        )
    }
}

extension ExecutionProof {
    static func shouldDisplay(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item] = []
    ) -> Bool {
        ExecutionProofJudgment.shouldDisplay(
            bubble: bubble,
            artifactItems: artifactItems
        )
    }
}

extension ExecutionProof {
    var proofStack: some View {
        VStack(alignment: .leading, spacing: 0) {
            collapsedHeader
            if open {
                expandedProofContent
            }
        }
    }
}

