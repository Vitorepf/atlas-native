import SwiftUI

// Feedback dirigido + helpers — peel de EditorialTurnChrome (régua ≤100).

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

struct FeedbackRow: View {
    let active: String?
    let reduceMotion: Bool
    let onFeedback: (FeedbackKind) -> Void
    var body: some View {
        HStack(spacing: 8) {
            ForEach(FeedbackKind.allCases) { kind in
                let isActive = active == kind.activeAction
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onFeedback(kind)
                } label: {
                    Text(isActive ? "\(kind.label) ✓" : kind.label)
                        .font(AtlasFont.serifItalic(13))
                        .foregroundStyle(isActive ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .overlay(Capsule().stroke(isActive ? AtlasTheme.domAutonomos.opacity(0.5) : AtlasTheme.separator, lineWidth: 1))
                }
                .buttonStyle(PressableScale())
                .accessibilityLabel(EditorialTurnA11y.spokenFeedbackLabel(kind: kind, active: isActive))
                .accessibilityHint(EditorialTurnA11y.spokenFeedbackHint())
                .accessibilityAddTraits(isActive ? .isSelected : [])
                .accessibilityIdentifier(A11yID.editorialTurnFeedback(kind.rawValue))
            }
            Spacer()
        }
        .padding(.top, 2)
    }
}
