import AtlasCore
import SwiftUI

// IDLE-COMPRESS fused

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
    static func hasDecisionSurface(_ d: AtlasDecisionSummary) -> Bool {
        d.selectedProvider != nil
            || d.selectedModel != nil
            || d.reason != nil
            || d.confidenceScore != nil
            || d.riskLevel != nil
            || d.routeMode != nil
            || d.wasOverridden
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
            Text("Obra concluída")
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
    func spokenCollapsedMetricsParts() -> [String] {
        var parts: [String] = []
        if !bubble.activities.isEmpty { parts.append("\(bubble.activities.count) passos") }
        if let ms = bubble.elapsedMs, ms > 0 { parts.append(humanDuration(ms)) }
        if bubble.decisionSummary.map(Self.hasDecisionSurface) == true { parts.append("decisão do atlas") }
        if bubble.qualitySummary != nil { parts.append("avaliação de qualidade") }
        if !artifactItems.isEmpty { parts.append("\(artifactItems.count) artefatos") }
        return parts
    }
}

extension ExecutionProof {
    var spokenCollapsed: String {
        spokenCollapsed(expanded: false)
    }

    func spokenCollapsed(expanded: Bool) -> String {
        (
            ["prova da execução", expanded ? "expandida" : "recolhida"]
            + spokenCollapsedMetricsParts()
        ).joined(separator: ", ")
    }
}

extension ExecutionProof {
    static func shouldDisplay(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item] = []
    ) -> Bool {
        !bubble.activities.isEmpty
            || bubble.decisionSummary.map(Self.hasDecisionSurface) == true
            || bubble.qualitySummary != nil
            || (!artifactItems.isEmpty && bubble.traceId != nil)
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

struct ExecutionProof: View {
    let bubble: ChatBubble
    var artifactItems: [AtlasTraceArtifacts.Item] = []
    var onOpenArtifacts: (TraceID) -> Void = { _ in }
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var open = false
    @State var replayIndex = 0

    var body: some View {
        proofChrome { proofStack }
    }
}

extension ExecutionProof {
    func activityRowCopy(_ act: AtlasAgentActivity) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(act.title)
                .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
            if let d = act.detail, !d.isEmpty {
                Text(d).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(2).truncationMode(.middle)
            }
        }
    }
}

extension ExecutionProof {
    func activityRowCell(index: Int, act: AtlasAgentActivity) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: activityIcon(act.kind))
                .atlasSans(11).foregroundStyle(AtlasTheme.accent.opacity(0.8))
                .frame(width: 15)
                .accessibilityHidden(true)
            activityRowCopy(act)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "passo \(index + 1) de \(bubble.activities.count), \(activitySpoken(act))"
        )
    }
}

extension ExecutionProof {
    @ViewBuilder
    var activityRows: some View {
        if !bubble.activities.isEmpty {
            ForEach(Array(bubble.activities.enumerated()), id: \.element.id) { index, act in
                activityRowCell(index: index, act: act)
            }
        }
    }
}

extension ExecutionProof {
    @ViewBuilder
    var artifactsBlock: some View {
        if !artifactItems.isEmpty, let traceId = bubble.traceId {
            artifactsButtonA11y(
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onOpenArtifacts(traceId)
                } label: {
                    artifactsButtonLabel(count: artifactItems.count)
                },
                count: artifactItems.count
            )
        }
    }
}

extension ExecutionProof {
    func artifactsButtonA11y<Content: View>(_ content: Content, count: Int) -> some View {
        content
            .buttonStyle(.plain)
            .accessibilityIdentifier(A11yID.artifactsRow)
            .accessibilityLabel("artefatos desta execução, \(count)")
            .accessibilityHint("abre a lista de artefatos deste trace")
    }
}

extension ExecutionProof {
    var artifactsChevron: some View {
        Image(systemName: "chevron.right")
            .atlasSans(10, .semibold)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}

extension ExecutionProof {
    func artifactsButtonLabel(count: Int) -> some View {
        HStack(spacing: 6) {
            artifactsButtonLead(count: count)
            artifactsChevron
        }
        .contentShape(Rectangle())
    }
}

extension ExecutionProof {
    func artifactsButtonLead(count: Int) -> some View {
        HStack(spacing: 6) {
            Text("⎘")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.accent.opacity(0.8))
                .frame(width: 15)
                .accessibilityHidden(true)
            Text("ARTEFATOS (\(count))")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
            Spacer()
        }
    }
}

extension ExecutionProof {
    @ViewBuilder
    var decisionBlock: some View {
        if let d = bubble.decisionSummary, Self.hasDecisionSurface(d) {
            Divider().overlay(AtlasTheme.separatorSoft).accessibilityHidden(true)
            decisionSummaryRow(d)
            decisionReason(d)
        }
    }
}

extension ExecutionProof {
    @ViewBuilder
    func decisionSummaryRow(_ d: AtlasDecisionSummary) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.triangle.branch")
                .atlasSans(11).foregroundStyle(AtlasTheme.accent.opacity(0.8)).frame(width: 15)
                .accessibilityHidden(true)
            Text(decideLine(d))
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(decisionSpoken(d))
    }
}

extension ExecutionProof {
    @ViewBuilder
    var qualityBlock: some View {
        if let q = bubble.qualitySummary {
            HStack(spacing: 6) {
                Image(systemName: "seal")
                    .atlasSans(11).foregroundStyle(qualityColor(q)).frame(width: 15)
                    .accessibilityHidden(true)
                Text(qualityLine(q))
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
            }
            .accessibilityLabel(qualitySpoken(q))
        }
    }

    func qualityColor(_ q: AtlasQualitySummary) -> Color {
        q.status.lowercased().contains("pass") || q.score >= 0.7
            ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional
    }

}

extension ExecutionProof {
    @ViewBuilder
    func decisionReason(_ d: AtlasDecisionSummary) -> some View {
        if let r = d.reason, !r.isEmpty {
            Text("\"\(r)\"")
                .font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textSecondary)
                .padding(.leading, 23)
                .accessibilityLabel("motivo, \(r)")
        }
    }
}

extension ExecutionProof {
    @ViewBuilder
    var expandedProofContent: some View {
        VStack(alignment: .leading, spacing: 7) {
            replayScrubber
            activityRows
            decisionBlock
            qualityBlock
            artifactsBlock
        }
        .padding(.top, 8)
        .padding(.leading, 4)
        .transition(reduceMotion ? .identity : .opacity)
        .onChange(of: bubble.activities.count) {
            replayIndex = min(replayIndex, max(0, timestampedActivities.count - 1))
        }
    }
}

extension ExecutionProof {
    var timestampedActivities: [(activity: AtlasAgentActivity, date: Date)] {
        bubble.activities.compactMap { activity in
            guard let date = AtlasTime.date(activity.occurredAt) else { return nil }
            return (activity, date)
        }
    }
}

extension ExecutionProof {
    var summaryLine: String {
        var parts: [String] = []
        if !bubble.activities.isEmpty { parts.append("\(bubble.activities.count) passos") }
        if let ms = bubble.elapsedMs, ms > 0 { parts.append(humanDuration(ms)) }
        if let q = bubble.qualitySummary { parts.append("quality \(String(format: "%.1f", q.score))") }
        if !artifactItems.isEmpty { parts.append("\(artifactItems.count) artefatos") }
        return parts.joined(separator: " · ")
    }
}

extension ExecutionProof {
    func activitySpoken(_ act: AtlasAgentActivity) -> String {
        var parts = [act.title]
        if let d = act.detail, !d.isEmpty { parts.append(d) }
        return parts.joined(separator: ", ")
    }
}

extension ExecutionProof {
    func qualityLineFlags(_ q: AtlasQualitySummary, base: String) -> String {
        var out = base
        if q.flagCount > 0 { out += " · \(q.flagCount) alertas" }
        if q.actionCount > 0 { out += " · \(q.actionCount) ações" }
        return out
    }
}

extension ExecutionProof {
    func qualityLine(_ q: AtlasQualitySummary) -> String {
        let base = "quality \(String(format: "%.1f", q.score)) · \(q.status)"
        return qualityLineFlags(q, base: base)
    }
}

extension ExecutionProof {
    func qualitySpoken(_ q: AtlasQualitySummary) -> String {
        var parts = ["qualidade \(String(format: "%.1f", q.score)), status \(q.status)"]
        if q.flagCount > 0 { parts.append("\(q.flagCount) alertas") }
        if q.actionCount > 0 { parts.append("\(q.actionCount) ações de correção") }
        return parts.joined(separator: ", ")
    }
}

extension ExecutionProof {
    @ViewBuilder
    var replayScrubber: some View {
        let stamped = timestampedActivities
        if stamped.count >= 2 {
            let index = min(replayIndex, stamped.count - 1)
            let selected = stamped[index]
            replayScrubberChrome(index: index, total: stamped.count, selected: selected)
        } else if !bubble.activities.isEmpty {
            Text("REPLAY indisponível · eventos sem timestamps")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityLabel("replay indisponível porque os eventos não têm timestamps")
        }
    }
}

extension ExecutionProof {
    func replayScrubberChrome(
        index: Int,
        total: Int,
        selected: (activity: AtlasAgentActivity, date: Date)
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            replayScrubberHeader(index: index, total: total, selected: selected)
            replayControls(stampedCount: total)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.bgRecessed))
        .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
        .accessibilityIdentifier(A11yID.executionReplayScrubber)
    }
}

extension ExecutionProof {
    func replaySliderControl(stampedCount: Int) -> some View {
        Slider(value: Binding(
            get: { Double(replayIndex) },
            set: { replayIndex = min(max(0, Int($0.rounded())), stampedCount - 1) }
        ), in: 0...Double(stampedCount - 1), step: 1)
        .tint(AtlasTheme.accent)
        .accessibilityLabel("scrubber de replay da execução")
        .accessibilityValue("passo \(min(replayIndex, stampedCount - 1) + 1) de \(stampedCount)")
    }
}

extension ExecutionProof {
    func replayStepperControl(stampedCount: Int) -> some View {
        Stepper("passo \(min(replayIndex, stampedCount - 1) + 1)", value: Binding(
            get: { replayIndex },
            set: { replayIndex = min(max(0, $0), stampedCount - 1) }
        ), in: 0...(stampedCount - 1))
        .labelsHidden()
        .accessibilityLabel("replay da execução, passo \(min(replayIndex, stampedCount - 1) + 1) de \(stampedCount)")
    }
}

extension ExecutionProof {
    @ViewBuilder
    func replayControls(stampedCount: Int) -> some View {
        if reduceMotion {
            replayStepperControl(stampedCount: stampedCount)
        } else {
            replaySliderControl(stampedCount: stampedCount)
        }
    }
}

extension ExecutionProof {
    func replayScrubberHeader(
        index: Int,
        total: Int,
        selected: (activity: AtlasAgentActivity, date: Date)
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            replayScrubberTitle(index: index, total: total)
            replayScrubberMeta(selected: selected)
        }
    }
}

extension ExecutionProof {
    func replayScrubberMeta(selected: (activity: AtlasAgentActivity, date: Date)) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(selected.activity.title)
                .font(.system(.caption, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(2)
                .accessibilityHidden(true)
            Text(selected.activity.occurredAt ?? "")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionProof {
    func replayScrubberTitle(index: Int, total: Int) -> some View {
        HStack {
            Text("REPLAY")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
            Spacer()
            Text("\(index + 1)/\(total)")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
        }
    }
}
