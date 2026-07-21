import SwiftUI
import AtlasCore

// IDLE-COMPRESS fused EditorialTurn · EditorialTurn+Body.swift

// --- EditorialTurn+Arrival.swift ---
extension EditorialTurn {
    func applyArrival<Content: View>(_ content: Content) -> some View {
        content
            .opacity(placed ? 1 : 0)
            .offset(y: placed ? 0 : 12)
            .onAppear {
                if reduceMotion { placed = true }
                else { withAnimation(AtlasMotion.arrival) { placed = true } }
            }
    }
}

// --- EditorialTurn+Assistant.swift ---
extension EditorialTurn {
    @ViewBuilder
    var assistantTurn: some View {
        VStack(alignment: .leading, spacing: 12) {
            assistantPlanCard
            assistantExecutionRibbon
            assistantExecutionBlock
            assistantClosing
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: 0.38) { onCopy() }
        .accessibilityHint(EditorialTurnA11y.copyLongPressHint)
    }
}

// --- EditorialTurn+AssistantExecution.swift ---
extension EditorialTurn {
    @ViewBuilder
    var assistantExecutionBlock: some View {
        if let state = bubble.executionPresentationState {
            assistantExecutionCard(state)
        }
    }
}

// --- EditorialTurn+AssistantExecutionCard.swift ---
extension EditorialTurn {
    @ViewBuilder
    func assistantExecutionCard(_ state: AtlasExecutionPresentationState) -> some View {
        if ExecutionStateCard.shouldDisplay(state: state) {
            ExecutionStateCard(
                state: state,
                jobId: bubble.executionChoiceJobId,
                onChoose: onExecutionChoice,
                retryableJobId: bubble.retryableJobId,
                onRetry: onRetry,
                onSteer: assistantSteerHandler
            )
        }
    }
}

// --- EditorialTurn+AssistantExecutionSteer.swift ---
extension EditorialTurn {
    var assistantSteerHandler: (() -> Void)? {
        let steerTrace = bubble.executionPresence?.isOngoing == true ? bubble.traceId : nil
        return steerTrace.map { trace in { onSteer(trace) } }
    }
}

// --- EditorialTurn+AssistantPlan.swift ---
extension EditorialTurn {
    @ViewBuilder
    var assistantPlanCard: some View {
        PlanCard(bubble: bubble)
    }
}

// --- EditorialTurn+AssistantRibbon.swift ---
extension EditorialTurn {
    @ViewBuilder
    var assistantExecutionRibbon: some View {
        if bubble.streaming, bubble.hasLiveExecutionSurface {
            ExecutionRibbon(bubble: bubble, reduceMotion: reduceMotion, onStop: onStop)
        }
    }
}

// --- EditorialTurn+Body+AssistantBranch.swift ---
extension EditorialTurn {
    @ViewBuilder
    var turnBodyAssistantBranch: some View {
        assistantTurn
    }
}

// --- EditorialTurn+Body+UserBranch.swift ---
extension EditorialTurn {
    @ViewBuilder
    var turnBodyUserBranch: some View {
        userTurn
    }
}

// --- EditorialTurn+Body.swift ---
extension EditorialTurn {
    var turnBody: some View {
        Group {
            if bubble.role == "user" {
                turnBodyUserBranch
            } else {
                turnBodyAssistantBranch
            }
        }
    }
}

// --- EditorialTurn+Closing.swift ---
extension EditorialTurn {
    @ViewBuilder
    var assistantClosing: some View {
        if !bubble.streaming,
           ExecutionProof.shouldDisplay(bubble: bubble, artifactItems: artifactItems) {
            ExecutionProof(bubble: bubble, artifactItems: artifactItems, onOpenArtifacts: onOpenArtifacts)
            Text("RESPOSTA FINAL")
                .font(.system(.caption2, weight: .semibold)).tracking(1.6)
                .foregroundStyle(AtlasTheme.accent.opacity(0.85))
                .accessibilityLabel(EditorialTurnA11y.spokenFinalAnswerKicker)
                .accessibilityAddTraits(.isHeader)
        }
        assistantClosingTail
    }
}

// --- EditorialTurn+ClosingMeta.swift ---
extension EditorialTurn {
    @ViewBuilder
    var assistantClosingMeta: some View {
        if !bubble.streaming {
            if SignatureLine.shouldDisplay(provider: bubble.provider, model: bubble.model) {
                SignatureLine(
                    provider: bubble.provider, model: bubble.model,
                    elapsedMs: bubble.elapsedMs, reduceMotion: reduceMotion)
            }
            FeedbackRow(active: bubble.feedbackAction, reduceMotion: reduceMotion, onFeedback: onFeedback)
        }
    }
}

// --- EditorialTurn+ClosingTail.swift ---
extension EditorialTurn {
    @ViewBuilder
    var assistantClosingTail: some View {
        if !bubble.text.isEmpty {
            AtlasMarkdownView(text: bubble.text, streaming: bubble.streaming)
        }
        assistantClosingMeta
    }
}

// --- EditorialTurn+Equatable.swift ---
extension EditorialTurn {
    // F2.10: igualdade só no que a tela mostra — closures recriadas pelo pai
    // não invalidam o subtree (pare com `.equatable()` no call site).
    nonisolated static func == (lhs: EditorialTurn, rhs: EditorialTurn) -> Bool {
        lhs.bubble == rhs.bubble && lhs.reduceMotion == rhs.reduceMotion && lhs.artifactItems == rhs.artifactItems
    }
}

// --- EditorialTurn+User.swift ---
extension EditorialTurn {
    @ViewBuilder
    var userTurn: some View {
        VStack(alignment: .leading, spacing: 8) {
            userQuote
            userEditResendButton
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// --- EditorialTurn+UserEdit.swift ---
extension EditorialTurn {
    var userEditResendButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onEditResend()
        } label: {
            userEditResendLabel
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel("editar esta mensagem e reenviar como novo turno")
        .accessibilityHint("abre o compositor com este texto para um novo envio")
    }
}

// --- EditorialTurn+UserEditLabel.swift ---
extension EditorialTurn {
    var userEditResendLabel: some View {
        HStack(spacing: 5) {
            Image(systemName: "arrow.turn.down.right")
                .atlasSans(10, .semibold)
                .accessibilityHidden(true)
            // Ação fala em sans (mono é hash/recibo/meta — canon §C);
            // secondary dá affordance de ação sem gritar.
            Text("editar e reenviar")
                .atlasSans(11, .medium)
        }
        .foregroundStyle(AtlasTheme.textSecondary)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
    }
}

// --- EditorialTurn+UserQuote.swift ---
extension EditorialTurn {
    var userQuote: some View {
        Text("\"\(bubble.text)\"")
            .font(AtlasFont.serifItalic(18)).lineSpacing(8).foregroundStyle(AtlasTheme.textPrimary)
            .padding(.leading, 16)
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 1).fill(AtlasTheme.accent).frame(width: 2)
                    .accessibilityHidden(true)
            }
            .accessibilityLabel(EditorialTurnA11y.spokenUserMessage(bubble.text))
    }
}

