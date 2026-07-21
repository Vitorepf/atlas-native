import SwiftUI
import AtlasCore

// Conversation cockpit — AgentRow + ExecutingStrip (WAVE-006 live instrument).
// Peels: ConversationCockpitBanners (banner · reconnect · silence).

extension AgentRow {
    func agentRowChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(.vertical, compactLane ? 3 : 0)
            .padding(.horizontal, compactLane ? 8 : 0)
            .background {
                if compactLane {
                    Capsule().fill(AtlasTheme.bgRecessed)
                }
            }
    }
}

extension AgentRow {
    @ViewBuilder
    var agentModelLabel: some View {
        if let m = agent.model, !m.isEmpty, !m.hasSuffix("_default") {
            Text(m).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary).lineLimit(1)
        }
    }
}

extension AgentRow {
    var turnStatus: AtlasTurnStatus { AtlasTurnStatus(rawValue: agent.status) }

    var statusColor: Color {
        switch turnStatus {
        case .processing: return AtlasTheme.accent
        case .succeeded: return AtlasTheme.domAutonomos
        case .failed, .cancelled: return AtlasTheme.domOperacional
        default: return AtlasTheme.textTertiary
        }
    }

    /// WAVE-027: face/attention vocabulary or silence — no parallel “processando” dialect.
    var statusWord: String? {
        ConversationExecutionPhase.agentStatusWord(rawStatus: agent.status)
    }
}

extension AgentRow {
    var agentRowContent: some View {
        HStack(spacing: 8) {
            Circle().fill(statusColor).frame(width: 6, height: 6)
            // WAVE-049: label via lanes judgment (shared with pack).
            Text(ConversationAgentLanesJudgment.label(for: agent))
                .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.textSecondary)
            agentModelLabel
            Spacer()
            if let statusWord {
                Text(statusWord).font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textTertiary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(ConversationAgentLanesJudgment.label(for: agent)), \(statusWord ?? agent.status)"
        )
    }
}

struct AgentRow: View {
    let agent: ExecAgent
    var compactLane = false
    var body: some View {
        agentRowChrome(agentRowContent)
    }
}

// MARK: - Conversation live instrument (WAVE-006)
// Uma árvore visual: live · progress · reconnect · stop · steer.
// Reconnect banner (cockpit) e silence watchdog continuam secondary surfaces.

struct ExecutingStrip: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void
    var onSteer: (() -> Void)? = nil
    /// WAVE-031: same path as StateCard — resolveExecutionChoice(jobId, optionId).
    var onChoose: ((JobID, String) -> Void)? = nil

    /// WAVE-023: strip branches on exclusive face (not bool soup alone).
    private var face: ConversationExecutionFace {
        ConversationExecutionPhase.face(for: bubble)
    }

    private var decisionRequired: Bool {
        ConversationDecisionJudgment.isDecisionRequired(bubble)
    }

    private var choiceActions: [AtlasExecutionPresentationState.Action] {
        ConversationDecisionJudgment.choiceActions(for: bubble)
    }

    var body: some View {
        HStack(spacing: 8) {
            stripStatus
            Spacer(minLength: 0)
            if ConversationExecutionPhase.stripShowsLiveChrome(bubble) || decisionRequired {
                stripActionButtons
            }
        }
        .padding(.horizontal, 6)
        .lineLimit(1)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.executionLiveStrip)
    }

    // MARK: Status

    @ViewBuilder
    var stripStatus: some View {
        HStack(spacing: 8) {
            stripStatusLeading
            stripStatusTitle
            if face != .finished && face != .quiet {
                stripStatusMeta
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(stripAccessibilityLabel)
    }

    @ViewBuilder
    var stripStatusLeading: some View {
        // Face reconnect (includes dual-surface primary ownership for WAVE-012).
        if face == .reconnect {
            Image(systemName: bubble.reconnectBannerIcon)
                .atlasSans(10, .semibold)
                .foregroundStyle(AtlasTheme.textSecondary)
                .symbolEffect(.pulse, options: .repeating, isActive: !reduceMotion)
                .accessibilityHidden(true)
        } else if face == .paused {
            Text("‖")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        } else if face == .finished {
            Image(systemName: "checkmark")
                .atlasSans(10, .bold)
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
        } else {
            BreathingDiamond(size: 8, reduceMotion: reduceMotion)
        }
    }

    @ViewBuilder
    var stripStatusTitle: some View {
        // WAVE-027/031: primary kicker = face/decision spoken; detail secondary.
        HStack(spacing: 6) {
            Text(ConversationExecutionPhase.primarySpoken(for: bubble))
                .font(AtlasFont.mono(11, .semibold))
                .foregroundStyle(
                    decisionRequired
                        ? AtlasTheme.accent
                        : (face == .quiet || face == .finished
                            ? AtlasTheme.textTertiary
                            : AtlasTheme.textSecondary)
                )
                .lineLimit(1)
                .layoutPriority(3)
                .accessibilityHidden(true)
            stripStatusDetail
        }
    }

    @ViewBuilder
    var stripStatusDetail: some View {
        switch face {
        case .reconnect:
            if bubble.showsReconnectSurface, let line = bubble.reconnectPrimaryLine {
                Text(line)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(2)
                    .accessibilityHidden(true)
            }
        case .multiAgent, .running:
            // WAVE-040: shared plan progress grammar with PlanCard.
            if bubble.executionPlan != nil || bubble.executionProgress != nil {
                Text(PlanJudgment.summaryLine(bubble: bubble))
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(2)
                    .accessibilityHidden(true)
            } else if let act = bubble.currentActivity {
                Text(act.title)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(2)
                    .accessibilityHidden(true)
            }
        case .finished, .paused, .quiet:
            EmptyView()
        }
    }

    @ViewBuilder
    var stripStatusMeta: some View {
        TimelineView(.periodic(from: .now, by: 1)) { ctx in
            let secs = bubble.startedAt.map { max(0, Int(ctx.date.timeIntervalSince($0))) } ?? 0
            Text("· \(bubble.activities.count) evento\(bubble.activities.count == 1 ? "" : "s") · \(secs)s")
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .lineLimit(1)
                .accessibilityHidden(true)
        }
        if let stats = bubble.diffStats {
            Text("+\(stats.linesAdded) −\(stats.linesRemoved)")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.accent)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }

    // MARK: Actions

    @ViewBuilder
    var stripActionButtons: some View {
        // WAVE-031: elevate choice when published; stop/steer secondary.
        if decisionRequired, let jobId = bubble.executionChoiceJobId, let onChoose {
            if choiceActions.count == 1, let only = choiceActions.first {
                Button {
                    onChoose(jobId, only.id)
                } label: {
                    Text(ConversationDecisionJudgment.stripChooseLabel(
                        actionCount: 1,
                        firstTitle: only.title
                    ))
                    .font(.system(.footnote, weight: .semibold))
                    .foregroundStyle(AtlasTheme.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                }
                .buttonStyle(PressableScale())
                .accessibilityIdentifier(A11yID.executionActionChoice(only.id))
                .accessibilityLabel(only.title)
                .accessibilityHint(ConversationLiveStripJudgment.spokenChooseConfirmHint())
            } else {
                Menu {
                    ForEach(choiceActions) { action in
                        Button(action.title) {
                            onChoose(jobId, action.id)
                        }
                    }
                } label: {
                    Text(ConversationDecisionJudgment.stripChooseLabel(
                        actionCount: choiceActions.count,
                        firstTitle: choiceActions.first?.title
                    ))
                    .font(.system(.footnote, weight: .semibold))
                    .foregroundStyle(AtlasTheme.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                }
                .accessibilityLabel(ConversationDecisionJudgment.spokenLead)
                .accessibilityHint(ConversationLiveStripJudgment.spokenChooseMenuHint())
            }
        }
        if ConversationLiveStripJudgment.showsSteerCTA(
            decisionRequired: decisionRequired,
            hasSteerHandler: onSteer != nil
        ), let onSteer {
            Button(action: onSteer) {
                Text(ConversationLiveStripJudgment.steerButtonTitle)
                    .font(.system(.footnote, weight: .medium))
                    .foregroundStyle(AtlasTheme.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel(ConversationLiveStripJudgment.spokenSteer())
            .accessibilityHint(ConversationLiveStripJudgment.spokenSteerHint())
        }
        Button(action: onStop) {
            Text(ConversationLiveStripJudgment.stopButtonTitle)
                .font(.system(.footnote, weight: .medium))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(ConversationLiveStripJudgment.spokenStop())
        .accessibilityHint(ConversationLiveStripJudgment.spokenStopHint())
    }

    // MARK: A11y (phase-aligned compound label · WAVE-093)

    var stripAccessibilityLabel: String {
        ConversationLiveStripJudgment.spokenStrip(
            bubble: bubble,
            decisionRequired: decisionRequired,
            choiceActionCount: choiceActions.count,
            face: face,
            reconnectSpoken: face == .reconnect ? bubble.reconnectSpokenLabel : nil
        )
    }
}

