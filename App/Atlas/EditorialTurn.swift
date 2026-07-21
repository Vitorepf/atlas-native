import AtlasCore
import SwiftUI

// IDLE-COMPRESS fused

extension EditorialTurnA11y {
  static func spokenSignature(provider: String?, model: String?, elapsedMs: Int?) -> String {
    guard let who = signatureWho(provider: provider, model: model) else { return "" }
    if let ms = elapsedMs, ms > 0 { return "resposta de \(who), em \(humanDuration(ms))" }
    return "resposta de \(who)"
  }
}

extension EditorialTurnA11y {
  static func spokenUserMessage(_ text: String) -> String {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? "mensagem sua, vazia" : "mensagem sua, \(trimmed)"
  }

  static let spokenFinalAnswerKicker = "resposta final"

  static let copyLongPressHint = "pressionar e segurar copia a resposta"
}

enum EditorialTurnA11y {}

extension EditorialTurnA11y {
  static func spokenFeedbackBase(kind: FeedbackKind) -> String {
    switch kind {
    case .util: return "marcar resposta como útil"
    case .contexto: return "marcar contexto errado"
    case .longo: return "marcar resposta longa demais"
    case .fraco: return "marcar resposta fraca"
    }
  }
}

extension EditorialTurnA11y {
  static func spokenFeedbackLabel(kind: FeedbackKind, active: Bool) -> String {
    let base = spokenFeedbackBase(kind: kind)
    return active ? "\(base), selecionado" : base
  }

  static func spokenFeedbackHint() -> String {
    "envia feedback ao roteamento do Atlas para este turno"
  }
}

extension EditorialTurnA11y {
  static func signatureWho(provider: String?, model: String?) -> String? {
    if let model, !model.isEmpty, !model.hasSuffix("_default") { return model }
    if let provider, !provider.isEmpty {
      let word = providerWord(provider)
      return word.isEmpty ? provider : word
    }
    return nil
  }
}

struct EditorialTurn: View, Equatable {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onFeedback: (FeedbackKind) -> Void
    let onCopy: () -> Void
    var onEditResend: () -> Void = {}
    let onStop: () -> Void
    let onExecutionChoice: (JobID, String) -> Void
    var onRetry: (JobID) -> Void = { _ in }
    var onSteer: (TraceID) -> Void = { _ in }
    var artifactItems: [AtlasTraceArtifacts.Item] = []
    var onOpenArtifacts: (TraceID) -> Void = { _ in }
    @State var placed = false

    var body: some View {
        applyArrival(turnBody)
    }
}

struct FeedbackRow: View {
    let active: String?
    let reduceMotion: Bool
    let onFeedback: (FeedbackKind) -> Void
    var body: some View {
        HStack(spacing: 8) {
            ForEach(FeedbackKind.allCases) { kind in
                feedbackChip(kind)
            }
            Spacer()
        }
        .padding(.top, 2)
    }
}

extension FeedbackRow {
    func feedbackChipA11y<Content: View>(
        _ content: Content,
        kind: FeedbackKind,
        isActive: Bool
    ) -> some View {
        content
            .accessibilityLabel(EditorialTurnA11y.spokenFeedbackLabel(kind: kind, active: isActive))
            .accessibilityHint(EditorialTurnA11y.spokenFeedbackHint())
            .accessibilityAddTraits(isActive ? .isSelected : [])
            .accessibilityIdentifier(A11yID.editorialTurnFeedback(kind.rawValue))
    }
}

extension FeedbackRow {
    func feedbackChipLabel(_ kind: FeedbackKind, isActive: Bool) -> some View {
        Text(isActive ? "\(kind.label) ✓" : kind.label)
            .font(AtlasFont.serifItalic(13))
            .foregroundStyle(isActive ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .overlay(
                Capsule().stroke(
                    isActive ? AtlasTheme.domAutonomos.opacity(0.5) : AtlasTheme.separator,
                    lineWidth: 1
                )
            )
    }
}

extension FeedbackRow {
    func feedbackChip(_ kind: FeedbackKind) -> some View {
        let isActive = active == kind.activeAction
        return feedbackChipA11y(
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onFeedback(kind)
            } label: {
                feedbackChipLabel(kind, isActive: isActive)
            }
            .buttonStyle(PressableScale()),
            kind: kind,
            isActive: isActive
        )
    }
}

func humanDuration(_ ms: Int) -> String {
    if ms < 1000 { return "um instante" }
    if ms < 60000 { return String(format: "%.1f s", Double(ms) / 1000).replacingOccurrences(of: ".", with: ",") }
    return "\(ms / 60000) min"
}

func providerWord(_ p: String?) -> String {
    guard let p, !p.isEmpty else { return "" }
    let x = p.lowercased()
    for (k, v) in [("claude", "claude"), ("codex", "codex"), ("gemini", "gemini"),
                   ("hermes", "hermes"), ("minimax", "minimax"),
                   ("council", "conselho"), ("conselho", "conselho")] where x.contains(k) {
        return v
    }
    return x
}

struct SignatureLine: View {
    let provider: String?
    let model: String?
    let elapsedMs: Int?
    let reduceMotion: Bool
    @State var shown = false

    var body: some View {
        Text(signature)
            .font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.textPrimary.opacity(0.4))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .opacity(shown ? 1 : 0)
            .accessibilityLabel(EditorialTurnA11y.spokenSignature(provider: provider, model: model, elapsedMs: elapsedMs))
            .accessibilityIdentifier(A11yID.editorialTurnSignature)
            .onAppear { revealSignature() }
    }
}

extension SignatureLine {
    static func shouldDisplay(provider: String?, model: String?) -> Bool {
        let hasModel = model.map { !$0.isEmpty && !$0.hasSuffix("_default") } ?? false
        let hasProvider = provider.map { !$0.isEmpty } ?? false
        return hasModel || hasProvider
    }
}

extension SignatureLine {
    var signature: String {
        let who = signatureWho
        if let ms = elapsedMs, ms > 0 { return "— \(who), em \(humanDuration(ms))" }
        return "— \(who)"
    }

    var signatureWho: String {
        if let model, !model.isEmpty, !model.hasSuffix("_default") { return model }
        let word = providerWord(provider)
        return word.isEmpty ? "provedor não publicado" : word
    }
}

extension SignatureLine {
    func revealSignature() {
        if reduceMotion { shown = true; return }
        Task {
            try? await Task.sleep(nanoseconds: 220_000_000)
            withAnimation(.easeIn(duration: 0.28)) { shown = true }
        }
    }
}

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

extension EditorialTurn {
    @ViewBuilder
    var assistantExecutionBlock: some View {
        if let state = bubble.executionPresentationState {
            assistantExecutionCard(state)
        }
    }
}

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

extension EditorialTurn {
    var assistantSteerHandler: (() -> Void)? {
        let steerTrace = bubble.executionPresence?.isOngoing == true ? bubble.traceId : nil
        return steerTrace.map { trace in { onSteer(trace) } }
    }
}

extension EditorialTurn {
    @ViewBuilder
    var assistantPlanCard: some View {
        PlanCard(bubble: bubble)
    }
}

extension EditorialTurn {
    @ViewBuilder
    var assistantExecutionRibbon: some View {
        // WAVE-027: presence-ongoing keeps ribbon; not streaming-only (sink ≡ strip).
        // WAVE-012 dual-surface reconnect silence remains inside ExecutionRibbon.
        if bubble.hasLiveExecutionSurface,
           ConversationExecutionPhase.isPresenceOngoing(bubble) {
            ExecutionRibbon(bubble: bubble, reduceMotion: reduceMotion, onStop: onStop)
        }
    }
}

extension EditorialTurn {
    @ViewBuilder
    var turnBodyAssistantBranch: some View {
        assistantTurn
    }
}

extension EditorialTurn {
    @ViewBuilder
    var turnBodyUserBranch: some View {
        userTurn
    }
}

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

extension EditorialTurn {
    @ViewBuilder
    var assistantClosingTail: some View {
        if !bubble.text.isEmpty {
            AtlasMarkdownView(text: bubble.text, streaming: bubble.streaming)
        }
        assistantClosingMeta
    }
}

extension EditorialTurn {
    nonisolated static func == (lhs: EditorialTurn, rhs: EditorialTurn) -> Bool {
        lhs.bubble == rhs.bubble && lhs.reduceMotion == rhs.reduceMotion && lhs.artifactItems == rhs.artifactItems
    }
}

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

extension EditorialTurn {
    var userEditResendLabel: some View {
        HStack(spacing: 5) {
            Image(systemName: "arrow.turn.down.right")
                .atlasSans(10, .semibold)
                .accessibilityHidden(true)
            Text("editar e reenviar")
                .atlasSans(11, .medium)
        }
        .foregroundStyle(AtlasTheme.textSecondary)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
    }
}

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
