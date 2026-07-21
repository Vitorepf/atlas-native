import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: ExecutionProof host+body+chrome fused

// MARK: - Host

// MARK: - Types / Inputs

struct ExecutionProof: View {
    let bubble: ChatBubble
    var artifactItems: [AtlasTraceArtifacts.Item] = []
    var onOpenArtifacts: (TraceID) -> Void = { _ in }
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var open = false
    @State var replayIndex = 0

    // MARK: Body

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
            .accessibilityLabel(ExecutionProofJudgment.spokenArtifactsCTA(count: count))
            .accessibilityHint(ExecutionProofJudgment.artifactsHint)
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

// MARK: - Body

// MARK: - Expanded content

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

// MARK: - Decision / quality sections

extension ExecutionProof {
    @ViewBuilder
    var decisionBlock: some View {
        if let d = bubble.decisionSummary, Self.hasDecisionSurface(d) {
            Divider().overlay(AtlasTheme.separatorSoft).accessibilityHidden(true)
            decisionSummaryRow(d)
            decisionReason(d)
        }
    }

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

    @ViewBuilder
    func decisionReason(_ d: AtlasDecisionSummary) -> some View {
        if let r = d.reason, !r.isEmpty {
            Text("\"\(r)\"")
                .font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textSecondary)
                .padding(.leading, 23)
                .accessibilityLabel(ExecutionProofJudgment.spokenReason(r))
        }
    }

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

// MARK: - Face / summary / spoken bridges

extension ExecutionProof {
    var timestampedActivities: [(activity: AtlasAgentActivity, date: Date)] {
        bubble.activities.compactMap { activity in
            guard let date = AtlasTime.date(activity.occurredAt) else { return nil }
            return (activity, date)
        }
    }

    var proofFace: ExecutionProofFace {
        ExecutionProofJudgment.face(bubble: bubble, artifactItems: rankedArtifactItems)
    }

    /// Kind-attention artifacts (shared with ArtifactJudgment).
    var rankedArtifactItems: [AtlasTraceArtifacts.Item] {
        ExecutionProofJudgment.rankedArtifacts(artifactItems)
    }

    var summaryLine: String {
        ExecutionProofJudgment.summaryLine(
            bubble: bubble,
            artifactItems: rankedArtifactItems,
            humanDuration: humanDuration
        )
    }

    func activitySpoken(_ act: AtlasAgentActivity) -> String {
        ExecutionProofJudgment.activitySpoken(act)
    }

    func qualityLineFlags(_ q: AtlasQualitySummary, base: String) -> String {
        ExecutionProofJudgment.qualityLineFlags(q, base: base)
    }

    func qualityLine(_ q: AtlasQualitySummary) -> String {
        ExecutionProofJudgment.qualityLine(q)
    }

    func qualitySpoken(_ q: AtlasQualitySummary) -> String {
        ExecutionProofJudgment.qualitySpoken(q)
    }
}

// MARK: - Replay scrubber

extension ExecutionProof {
    @ViewBuilder
    var replayScrubber: some View {
        let stamped = timestampedActivities
        if stamped.count >= 2 {
            let index = min(replayIndex, stamped.count - 1)
            let selected = stamped[index]
            replayScrubberChrome(index: index, total: stamped.count, selected: selected)
        } else if !bubble.activities.isEmpty {
            Text(ExecutionProofJudgment.replayUnavailableLabel)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityLabel(ExecutionProofJudgment.replayUnavailableSpoken)
        }
    }

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

    @ViewBuilder
    func replayControls(stampedCount: Int) -> some View {
        if reduceMotion {
            replayStepperControl(stampedCount: stampedCount)
        } else {
            replaySliderControl(stampedCount: stampedCount)
        }
    }

    func replaySliderControl(stampedCount: Int) -> some View {
        Slider(value: Binding(
            get: { Double(replayIndex) },
            set: { replayIndex = min(max(0, Int($0.rounded())), stampedCount - 1) }
        ), in: 0...Double(stampedCount - 1), step: 1)
        .tint(AtlasTheme.accent)
        .accessibilityLabel(ExecutionProofJudgment.replayScrubberLabel)
        .accessibilityValue(
            ExecutionProofJudgment.spokenReplayValue(
                index: replayIndex, total: stampedCount
            )
        )
    }

    func replayStepperControl(stampedCount: Int) -> some View {
        Stepper("passo \(min(replayIndex, stampedCount - 1) + 1)", value: Binding(
            get: { replayIndex },
            set: { replayIndex = min(max(0, $0), stampedCount - 1) }
        ), in: 0...(stampedCount - 1))
        .labelsHidden()
        .accessibilityLabel(
            ExecutionProofJudgment.spokenReplayStep(
                index: replayIndex, total: stampedCount
            )
        )
    }
}

// MARK: - Chrome

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

// MARK: - Ribbon

struct ExecutionRibbon: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void

    private var face: ConversationExecutionFace {
        ConversationExecutionPhase.face(for: bubble)
    }

    var body: some View {
        executionRibbonStack
            .padding(.vertical, 10).padding(.horizontal, 14)
            .atlasCard(cornerRadius: AtlasTheme.Radius.control, fillOpacity: 0.5)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(ConversationExecutionPhase.spokenFace(face))
    }

    var executionRibbonStack: some View {
        VStack(alignment: .leading, spacing: 8) {
            reconnectBannerStack
            if face != .finished && face != .quiet {
                activitiesTimelineBlock
                agentLanes
                decideStrategyLine
            }
        }
    }

    @ViewBuilder
    var reconnectBannerStack: some View {
        // WAVE-012 + WAVE-022: dual-surface primary is strip; ribbon silence when streaming.
        if ConversationExecutionPhase.ribbonShowsReconnectBanner(bubble) {
            ReconnectBanner(bubble: bubble, reduceMotion: reduceMotion)
        }
        if ConversationExecutionPhase.ribbonShowsSilenceWatchdog(bubble) {
            SilenceWatchdog(bubble: bubble, reduceMotion: reduceMotion)
        }
    }

    @ViewBuilder
    var activitiesTimelineBlock: some View {
        if !bubble.activities.isEmpty {
            LiveTimeline(activities: bubble.activities, reduceMotion: reduceMotion)
        }
    }

    @ViewBuilder
    var agentLanes: some View {
        // WAVE-049: attention-ranked lanes (failed/awaiting first).
        let ranked = ConversationAgentLanesJudgment.rank(bubble.agents)
        let lanesFace = ConversationAgentLanesJudgment.face(from: bubble.agents)
        if !ranked.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                if let kicker = lanesFace.kicker {
                    Text(kicker)
                        .font(AtlasFont.mono(10))
                        .tracking(1.1)
                        .foregroundStyle(
                            lanesFace.productWord == "attention"
                                ? AtlasTheme.domOperacional
                                : AtlasTheme.textTertiary
                        )
                        .accessibilityLabel(lanesFace.spokenFace)
                        .accessibilityIdentifier(A11yID.executionAgentLanes)
                }
                ForEach(ranked) { AgentRow(agent: $0, compactLane: ranked.count >= 2) }
            }.padding(.leading, 24)
        }
    }

    @ViewBuilder
    var decideStrategyLine: some View {
        if let strat = bubble.decideStrategy {
            Text("atlas decide · \(strat)" + (bubble.decideStage.map { " → \($0)" } ?? ""))
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary).padding(.leading, 24)
        }
    }
}

// MARK: - ExecutionProofJudgment

// MARK: - Types

/// Exclusive finished-turn proof face (WAVE-042).
enum ExecutionProofFace: Equatable {
    case empty
    case steps(Int)
    case decision
    case quality(score: Double, status: String)
    case evidence(Int)
    /// Multiple organs present — lead by strongest signal.
    case compound(lead: String, parts: [String])

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .steps: return "steps"
        case .decision: return "decision"
        case .quality: return "quality"
        case .evidence: return "evidence"
        case .compound: return "compound"
        }
    }

    /// Collapsed header kicker — never always "Obra concluída".
    var kicker: String {
        switch self {
        case .empty: return "Prova"
        case .steps: return "Obra com passos"
        case .decision: return "Decisão do atlas"
        case .quality: return "Qualidade da obra"
        case .evidence: return "Evidência publicada"
        case .compound(let lead, _): return lead
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "sem prova publicada"
        case .steps(let n):
            return n == 1 ? "prova com 1 passo" : "prova com \(n) passos"
        case .decision:
            return "prova com decisão do atlas"
        case .quality(let score, let status):
            return "prova de qualidade \(String(format: "%.1f", score)), status \(status)"
        case .evidence(let n):
            return n == 1 ? "prova com 1 artefato" : "prova com \(n) artefatos"
        case .compound(_, let parts):
            return "prova composta, " + parts.joined(separator: ", ")
        }
    }
}

// MARK: - Judgment

/// Pure execution proof grammar — face · gates · summary · pack · spoken.
enum ExecutionProofJudgment {

    static func hasDecisionSurface(_ d: AtlasDecisionSummary) -> Bool {
        d.selectedProvider != nil
            || d.selectedModel != nil
            || d.reason != nil
            || d.confidenceScore != nil
            || d.riskLevel != nil
            || d.routeMode != nil
            || d.wasOverridden
    }

    static func shouldDisplay(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item] = []
    ) -> Bool {
        !bubble.activities.isEmpty
            || bubble.decisionSummary.map(hasDecisionSurface) == true
            || bubble.qualitySummary != nil
            || (!artifactItems.isEmpty && bubble.traceId != nil)
    }

    static func face(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item] = []
    ) -> ExecutionProofFace {
        guard shouldDisplay(bubble: bubble, artifactItems: artifactItems) else {
            return .empty
        }

        var parts: [String] = []
        var lead = "Prova da obra"

        let steps = bubble.activities.count
        if steps > 0 {
            parts.append(steps == 1 ? "1 passo" : "\(steps) passos")
            lead = "Obra com passos"
        }
        if let d = bubble.decisionSummary, hasDecisionSurface(d) {
            parts.append("decisão")
            lead = "Decisão do atlas"
        }
        if let q = bubble.qualitySummary {
            parts.append("quality \(String(format: "%.1f", q.score))")
            lead = "Qualidade da obra"
        }
        if !artifactItems.isEmpty {
            parts.append(artifactItems.count == 1 ? "1 artefato" : "\(artifactItems.count) artefatos")
            if steps == 0, bubble.decisionSummary.map(hasDecisionSurface) != true,
               bubble.qualitySummary == nil {
                lead = "Evidência publicada"
            }
        }

        if parts.count >= 2 {
            return .compound(lead: lead, parts: parts)
        }
        if steps > 0 { return .steps(steps) }
        if let d = bubble.decisionSummary, hasDecisionSurface(d) { return .decision }
        if let q = bubble.qualitySummary {
            return .quality(score: q.score, status: q.status)
        }
        if !artifactItems.isEmpty { return .evidence(artifactItems.count) }
        return .empty
    }

    static func summaryLine(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item] = [],
        humanDuration: (Int) -> String
    ) -> String {
        var parts: [String] = []
        if !bubble.activities.isEmpty {
            parts.append("\(bubble.activities.count) passos")
        }
        if let ms = bubble.elapsedMs, ms > 0 {
            parts.append(humanDuration(ms))
        }
        if let q = bubble.qualitySummary {
            parts.append("quality \(String(format: "%.1f", q.score))")
        }
        if !artifactItems.isEmpty {
            parts.append("\(artifactItems.count) artefatos")
        }
        if let d = bubble.decisionSummary, hasDecisionSurface(d) {
            if let mode = d.routeMode { parts.append(mode) }
            else { parts.append("decisão") }
        }
        return parts.joined(separator: " · ")
    }

    static func rankedArtifacts(
        _ items: [AtlasTraceArtifacts.Item]
    ) -> [AtlasTraceArtifacts.Item] {
        ArtifactJudgment.rankItems(items)
    }

    static func spokenCollapsed(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item],
        expanded: Bool,
        humanDuration: (Int) -> String
    ) -> String {
        let face = face(bubble: bubble, artifactItems: artifactItems)
        var parts = [
            "prova da execução",
            expanded ? "expandida" : "recolhida",
            face.spokenFace
        ]
        if let ms = bubble.elapsedMs, ms > 0 {
            parts.append(humanDuration(ms))
        }
        return parts.joined(separator: ", ")
    }

    static func packFacts(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item] = []
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(bubble: bubble, artifactItems: artifactItems)
        facts.append("proof_face: \(face.productWord)")
        if !shouldDisplay(bubble: bubble, artifactItems: artifactItems) {
            absences.append("nenhuma prova publicada neste turno")
            return (facts, absences)
        }
        if !bubble.activities.isEmpty {
            facts.append("steps: \(bubble.activities.count)")
        } else {
            absences.append("sem passos de atividade")
        }
        if let d = bubble.decisionSummary, hasDecisionSurface(d) {
            if let p = d.selectedProvider { facts.append("decision_provider: \(p)") }
            if let m = d.routeMode { facts.append("decision_mode: \(m)") }
            if let c = d.confidenceScore {
                facts.append("decision_confidence: \(String(format: "%.2f", c))")
            }
        } else {
            absences.append("sem decisão de atlas publicada")
        }
        if let q = bubble.qualitySummary {
            let quality = qualityPackFacts(q)
            facts.append(contentsOf: quality.facts)
            absences.append(contentsOf: quality.absences)
        } else {
            absences.append("sem quality summary")
        }
        if artifactItems.isEmpty {
            absences.append("sem artefatos na prova")
        } else {
            facts.append("artifacts: \(artifactItems.count)")
            for item in rankedArtifacts(artifactItems).prefix(4) {
                facts.append("artifact: \(item.kind.rawValue) · \(item.name)")
            }
        }
        return (facts, absences)
    }


    // MARK: - Chrome spoken
    // MARK: - WAVE-082 quality · activity · replay absence

    static func qualityLineFlags(_ q: AtlasQualitySummary, base: String) -> String {
        var out = base
        if q.flagCount > 0 { out += " · \(q.flagCount) alertas" }
        if q.actionCount > 0 { out += " · \(q.actionCount) ações" }
        return out
    }

    static func qualityLine(_ q: AtlasQualitySummary) -> String {
        let base = "quality \(String(format: "%.1f", q.score)) · \(q.status)"
        return qualityLineFlags(q, base: base)
    }

    static func qualitySpoken(_ q: AtlasQualitySummary) -> String {
        var parts = ["qualidade \(String(format: "%.1f", q.score)), status \(q.status)"]
        if q.flagCount > 0 { parts.append("\(q.flagCount) alertas") }
        if q.actionCount > 0 { parts.append("\(q.actionCount) ações de correção") }
        return parts.joined(separator: ", ")
    }

    static func activitySpoken(_ act: AtlasAgentActivity) -> String {
        var parts = [act.title]
        if let d = act.detail, !d.isEmpty { parts.append(d) }
        return parts.joined(separator: ", ")
    }

    static let replayUnavailableLabel =
        "REPLAY indisponível · eventos sem timestamps"
    static let replayUnavailableSpoken =
        "replay indisponível porque os eventos não têm timestamps"

    // MARK: Chrome spoken (WAVE residual · proof card)

    static let artifactsHint = "abre a lista de artefatos deste trace"
    static let replayScrubberLabel = "scrubber de replay da execução"

    static func spokenArtifactsCTA(count: Int) -> String {
        let noun = count == 1 ? "artefato" : "artefatos"
        return "artefatos desta execução, \(count) \(noun)"
    }

    static func spokenReason(_ reason: String) -> String {
        "motivo, \(reason)"
    }

    static func spokenReplayStep(index: Int, total: Int) -> String {
        let step = min(max(0, index), max(0, total - 1)) + 1
        return "replay da execução, passo \(step) de \(total)"
    }

    static func spokenReplayValue(index: Int, total: Int) -> String {
        let step = min(max(0, index), max(0, total - 1)) + 1
        return "passo \(step) de \(total)"
    }

    static func qualityPackFacts(
        _ q: AtlasQualitySummary
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        let absences: [String] = []
        facts.append("quality_score: \(String(format: "%.2f", q.score))")
        facts.append("quality_status: \(q.status)")
        if q.flagCount > 0 { facts.append("quality_flags: \(q.flagCount)") }
        if q.actionCount > 0 { facts.append("quality_actions: \(q.actionCount)") }
        return (facts, absences)
    }

}
