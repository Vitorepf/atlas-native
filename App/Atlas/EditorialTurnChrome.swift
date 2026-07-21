import SwiftUI
import AtlasCore

// EditorialTurn peels — FeedbackRow · SignatureLine · format helpers

// MARK: - Feedback

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

// MARK: - Shared format helpers (multi-call-site · WAVE-069 peels)

func humanDuration(_ ms: Int) -> String {
    EditorialTurnJudgment.humanDuration(ms)
}

func providerWord(_ p: String?) -> String {
    guard let p, !p.isEmpty else { return "" }
    return EditorialTurnJudgment.providerWord(p)
}

// MARK: - Signature (WAVE-069)

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
            .accessibilityValue(
                EditorialTurnJudgment.face(provider: provider, model: model).productWord
            )
            .accessibilityIdentifier(A11yID.editorialTurnSignature)
            .onAppear { revealSignature() }
    }
}

extension SignatureLine {
    static func shouldDisplay(provider: String?, model: String?) -> Bool {
        EditorialTurnJudgment.face(provider: provider, model: model) != .absent
    }
}

extension SignatureLine {
    var signature: String {
        let who = signatureWho
        if let ms = elapsedMs, ms > 0 {
            return "— \(who), em \(EditorialTurnJudgment.humanDuration(ms))"
        }
        return "— \(who)"
    }

    var signatureWho: String {
        EditorialTurnJudgment.signatureWho(provider: provider, model: model)
            ?? "provedor não publicado"
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

