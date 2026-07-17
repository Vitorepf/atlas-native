import SwiftUI

// Assinatura sussurrada + feedback dirigido — peel de EditorialTurn.

// A assinatura sussurrada: "— claude-sonnet-4-6, em 6,6 s" — o MODELO exato +
// duração (Cursor esconde o modelo). Fraunces italic, atrasada 220ms.
struct SignatureLine: View {
    let provider: String?
    let model: String?
    let elapsedMs: Int?
    @State private var shown = false
    var body: some View {
        Text(signature)
            .font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.textPrimary.opacity(0.4))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .opacity(shown ? 1 : 0)
            .task {
                try? await Task.sleep(nanoseconds: 220_000_000)
                withAnimation(.easeIn(duration: 0.28)) { shown = true }
            }
    }
    private var signature: String {
        let who = (model?.isEmpty == false && !(model ?? "").hasSuffix("_default")) ? model! : providerWord(provider)
        if let ms = elapsedMs, ms > 0 { return "— \(who), em \(humanDuration(ms))" }
        return "— \(who)"
    }
}

func humanDuration(_ ms: Int) -> String {
    if ms < 1000 { return "um instante" }
    if ms < 60000 { return String(format: "%.1f s", Double(ms) / 1000).replacingOccurrences(of: ".", with: ",") }
    return "\(ms / 60000) min"
}

// Feedback dirigido — treina o roteamento (o que Cursor/Codex não têm).
struct FeedbackRow: View {
    let active: String?
    let onFeedback: (FeedbackKind) -> Void
    var body: some View {
        HStack(spacing: 8) {
            ForEach(FeedbackKind.allCases) { kind in
                let isActive = active == kind.activeAction
                Button { onFeedback(kind) } label: {
                    Text(isActive ? "\(kind.label) ✓" : kind.label)
                        .font(AtlasFont.serifItalic(13))
                        .foregroundStyle(isActive ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .overlay(Capsule().stroke(isActive ? AtlasTheme.domAutonomos.opacity(0.5) : AtlasTheme.separator, lineWidth: 1))
                }
                .buttonStyle(PressableScale())
            }
            Spacer()
        }
        .padding(.top, 2)
    }
}

// claude_cli → "claude", conselho → "conselho", etc.
func providerWord(_ p: String?) -> String {
    guard let p, !p.isEmpty else { return "atlas" }
    let x = p.lowercased()
    for (k, v) in [("claude", "claude"), ("codex", "codex"), ("gemini", "gemini"),
                   ("hermes", "hermes"), ("minimax", "minimax"),
                   ("council", "conselho"), ("conselho", "conselho")] where x.contains(k) {
        return v
    }
    return x
}
