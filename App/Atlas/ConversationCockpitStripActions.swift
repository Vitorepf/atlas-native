import SwiftUI
import AtlasCore

// WAVE-156 density peel — ExecutingStrip actions + a11y

extension ExecutingStrip {
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
