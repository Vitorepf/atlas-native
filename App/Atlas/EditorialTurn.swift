import SwiftUI
import AtlasCore

// IDLE-COMPRESS fused EditorialTurn · EditorialTurn.swift

// --- EditorialTurn+A11y+Signature.swift ---
extension EditorialTurnA11y {
  static func spokenSignature(provider: String?, model: String?, elapsedMs: Int?) -> String {
    guard let who = signatureWho(provider: provider, model: model) else { return "" }
    if let ms = elapsedMs, ms > 0 { return "resposta de \(who), em \(humanDuration(ms))" }
    return "resposta de \(who)"
  }
}

// --- EditorialTurn+A11y+UserMessage.swift ---
extension EditorialTurnA11y {
  static func spokenUserMessage(_ text: String) -> String {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? "mensagem sua, vazia" : "mensagem sua, \(trimmed)"
  }

  static let spokenFinalAnswerKicker = "resposta final"

  static let copyLongPressHint = "pressionar e segurar copia a resposta"
}

// --- EditorialTurn+A11y.swift ---
enum EditorialTurnA11y {}

// --- EditorialTurn+A11yFeedback+Base.swift ---
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

// --- EditorialTurn+A11yFeedback.swift ---
extension EditorialTurnA11y {
  static func spokenFeedbackLabel(kind: FeedbackKind, active: Bool) -> String {
    let base = spokenFeedbackBase(kind: kind)
    return active ? "\(base), selecionado" : base
  }

  static func spokenFeedbackHint() -> String {
    "envia feedback ao roteamento do Atlas para este turno"
  }
}

// --- EditorialTurn+A11yWho.swift ---
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

// --- EditorialTurn.swift ---
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

// --- EditorialTurnChrome+Feedback.swift ---
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

// --- EditorialTurnChrome+FeedbackChip+A11y.swift ---
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

// --- EditorialTurnChrome+FeedbackChip+Label.swift ---
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

// --- EditorialTurnChrome+FeedbackChip.swift ---
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

// --- EditorialTurnChrome+Helpers.swift ---
func humanDuration(_ ms: Int) -> String {
    if ms < 1000 { return "um instante" }
    if ms < 60000 { return String(format: "%.1f s", Double(ms) / 1000).replacingOccurrences(of: ".", with: ",") }
    return "\(ms / 60000) min"
}

/// claude_cli → "claude", conselho → "conselho", etc. Vazio ≠ fabricar «atlas».
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

// --- EditorialTurnChrome+Signature.swift ---
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

// --- EditorialTurnChrome+SignatureGate.swift ---
extension SignatureLine {
    /// Modelo ou provider reais — nunca fabrica «atlas» quando o contrato não publica quem respondeu.
    static func shouldDisplay(provider: String?, model: String?) -> Bool {
        let hasModel = model.map { !$0.isEmpty && !$0.hasSuffix("_default") } ?? false
        let hasProvider = provider.map { !$0.isEmpty } ?? false
        return hasModel || hasProvider
    }
}

// --- EditorialTurnChrome+SignatureText+Body.swift ---
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

// --- EditorialTurnChrome+SignatureText+Reveal.swift ---
extension SignatureLine {
    func revealSignature() {
        if reduceMotion { shown = true; return }
        Task {
            try? await Task.sleep(nanoseconds: 220_000_000)
            withAnimation(.easeIn(duration: 0.28)) { shown = true }
        }
    }
}

