import AtlasCore
import SwiftUI

// Cycle 041 fuse → ConversationCockpit+Execution.swift

extension ExecutingStrip {
    @ViewBuilder
    var stripStatus: some View {
        HStack(spacing: 8) {
            stripStatusLeading
            stripStatusTitle
            stripStatusMeta
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(stripAccessibilityLabel)
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusActivityOrIdle: some View {
        if let act = bubble.currentActivity {
            stripStatusActivityRow(act)
        } else {
            stripStatusIdleLine
        }
    }
}

extension ExecutingStrip {
    var stripStatusIdleLine: some View {
        Text("Seguindo a execução")
            .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
            .lineLimit(1)
            .layoutPriority(2)
            .accessibilityHidden(true)
    }
}

extension ExecutingStrip {
    @ViewBuilder
    func stripStatusActivityRow(_ act: AtlasAgentActivity) -> some View {
        HStack(spacing: 5) {
            Image(systemName: activityIcon(act.kind))
                .atlasSans(10, .semibold)
                .foregroundStyle(AtlasTheme.accent.opacity(0.85))
                .accessibilityHidden(true)
            Text(act.title)
                .font(.system(.footnote))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(2)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusLeading: some View {
        if bubble.showsReconnectSurface {
            Image(systemName: bubble.reconnectBannerIcon)
                .atlasSans(10, .semibold)
                .foregroundStyle(AtlasTheme.textSecondary)
                .symbolEffect(.pulse, options: .repeating, isActive: !reduceMotion)
                .accessibilityHidden(true)
        } else {
            BreathingDiamond(size: 8, reduceMotion: reduceMotion)
        }
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusDiffStats: some View {
        if let stats = bubble.diffStats {
            Text("+\(stats.linesAdded) −\(stats.linesRemoved)")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.accent)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusEventTimer: some View {
        TimelineView(.periodic(from: .now, by: 1)) { ctx in
            let secs = bubble.startedAt.map { max(0, Int(ctx.date.timeIntervalSince($0))) } ?? 0
            Text("· \(bubble.activities.count) evento\(bubble.activities.count == 1 ? "" : "s") · \(secs)s")
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusMeta: some View {
        stripStatusEventTimer
        stripStatusDiffStats
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusProgressLine: some View {
        if let p = bubble.executionProgress {
            Text("\(p.current)/\(p.total) · \(p.title)")
                .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(2)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusReconnectLine: some View {
        if bubble.showsReconnectSurface, let line = bubble.reconnectPrimaryLine {
            Text(line)
                .font(.system(.footnote))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(2)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusReconnectOrProgress: some View {
        if bubble.showsReconnectSurface, bubble.reconnectPrimaryLine != nil {
            stripStatusReconnectLine
        } else if bubble.executionProgress != nil {
            stripStatusProgressLine
        }
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusTitle: some View {
        if bubble.showsReconnectSurface || bubble.executionProgress != nil {
            stripStatusReconnectOrProgress
        } else {
            stripStatusActivityOrIdle
        }
    }
}

struct ExecutingStrip: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void
    var onSteer: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 8) {
            stripStatus
            Spacer(minLength: 0)
            stripActionButtons
        }
        .padding(.horizontal, 6)
        .lineLimit(1)
        .accessibilityElement(children: .contain)
    }
}

struct ExecutionBanner: View {
    let text: String
    let icon: String
    let tint: Color
    var reduceMotion = false
    /// Quando o container pai compõe o spoken (reconexão, watchdog), o banner fica só visual.
    var embedInParent = false
    var accessibilityIdentifier: String?

    var body: some View {
        bannerChrome
            .accessibilityElement(children: .ignore)
            .accessibilityHidden(embedInParent)
            .accessibilityLabel(ExecutionBannerA11y.spoken(text: text))
            .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }
}

extension ExecutionBanner {
    func bannerChromeFrame<Content: View>(_ content: Content) -> some View {
        content
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(tint.opacity(0.10)))
            .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).stroke(tint.opacity(0.35), lineWidth: 1))
    }
}

extension ExecutionBanner {
    var bannerContentRow: some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .atlasSans(11, .semibold)
                .symbolEffect(.pulse, options: .repeating, isActive: !reduceMotion)
                .accessibilityHidden(true)
            Text(text)
                .font(AtlasFont.mono(10))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .foregroundStyle(tint)
    }
}

extension ExecutionBanner {
    var bannerChrome: some View {
        bannerChromeFrame(bannerContentRow)
    }
}

// A RIBBON DE EXECUÇÃO — o diferencial vs Cursor. Mostra AO VIVO: quanto tempo,
// a ORQUESTRA (cada agente/provider/modelo + status), o estágio do Atlas Decide,
// e um botão Stop. Cursor mostra 1 agente; o Atlas mostra a máquina inteira.
struct ExecutionRibbon: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void
    var body: some View {
        executionRibbonCard(executionRibbonStack)
    }
}

extension ExecutionRibbon {
    @ViewBuilder
    var decideStrategyLine: some View {
        if let strat = bubble.decideStrategy {
            Text("atlas decide · \(strat)" + (bubble.decideStage.map { " → \($0)" } ?? ""))
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary).padding(.leading, 24)
        }
    }
}

extension ExecutionRibbon {
    @ViewBuilder
    var agentLanes: some View {
        if !bubble.agents.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                agentLanesCaption
                ForEach(bubble.agents) { AgentRow(agent: $0, compactLane: bubble.agents.count >= 2) }
            }.padding(.leading, 24)
        }
    }
}

extension ExecutionRibbon {
    @ViewBuilder
    var agentLanesCaption: some View {
        if bubble.agents.count >= 2 {
            Text("LANES")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }
}

// Cycle 042 — ExecutionRibbon peels fused into cockpit execution

extension ExecutionRibbon {
    @ViewBuilder
    var activitiesTimelineBlock: some View {
        if !bubble.activities.isEmpty {
            LiveTimeline(activities: bubble.activities, reduceMotion: reduceMotion)
        }
    }
}

extension ExecutionRibbon {
    @ViewBuilder
    var reconnectBannerStack: some View {
        ReconnectBanner(bubble: bubble, reduceMotion: reduceMotion)
        SilenceWatchdog(bubble: bubble, reduceMotion: reduceMotion)
    }
}

extension ExecutionRibbon {
    func executionRibbonCard<V: View>(_ content: V) -> some View {
        content
            .padding(.vertical, 10).padding(.horizontal, 14)
            .atlasCard(cornerRadius: AtlasTheme.Radius.control, fillOpacity: 0.5)
    }
}

extension ExecutionRibbon {
    var executionRibbonStack: some View {
        VStack(alignment: .leading, spacing: 8) {
            reconnectBannerStack
            activitiesTimelineBlock
            agentLanes
            decideStrategyLine
        }
    }
}
