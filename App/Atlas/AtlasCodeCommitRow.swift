import SwiftUI
import AtlasCore

// MARK: - Linha do commit (mensagem é a manchete)

struct AtlasCodeCommitRow: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let node: AtlasCodeGraphNode
    let state: AtlasCodeNodeState
    let ruleId: String?
    /// A trunk real: a lei na linha fala o nome da linha, nunca "main" no chute.
    let trunk: String?
    let isFirst: Bool
    let isLast: Bool
    /// A pílula respondeu e este commit não está na resposta: ele recua, mas
    /// nunca some — esconder história para responder uma pergunta seria mentir
    /// sobre o repositório.
    var isDimmed: Bool = false
    let onTap: () -> Void
    var onLongPress: (() -> Void)? = nil

    private var color: Color { AtlasCodePalette.color(for: state) }

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                spine
                VStack(alignment: .leading, spacing: 4) {
                    // Manchete: a mensagem do commit. Sem mensagem, o hash é o
                    // último recurso honesto — nunca inventamos um título.
                    Text(node.message ?? String(node.hash.prefix(8)))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(state == .violating ? color : AtlasTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .accessibilityHidden(true)
                    HStack(spacing: 6) {
                        Text(node.authorName.isEmpty ? node.authorEmail : node.authorName)
                            .accessibilityHidden(true)
                        Text("·")
                            .accessibilityHidden(true)
                        Text(AtlasCodeRelativeTime.short(from: node.authoredAt))
                            .accessibilityHidden(true)
                        if let ruleId {
                            Text("·")
                                .accessibilityHidden(true)
                            Text(AtlasCodeIssue.law(ruleId, trunk: trunk))
                                .foregroundStyle(color)
                                .accessibilityHidden(true)
                        }
                    }
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, 7)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(isDimmed ? 0.26 : 1)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.28), value: isDimmed)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            AtlasCodeCommitRowA11y.spokenCommitRow(
                node: node, state: state, trunk: trunk, ruleId: ruleId, isDimmed: isDimmed
            )
        )
        .accessibilityHint(commitAccessibilityHint)
        .accessibilityIdentifier(A11yID.codeCommit(hashPrefix: String(node.hash.prefix(8))))
        .onLongPressGesture(minimumDuration: 0.45) {
            onLongPress?()
        }
    }

    private var commitAccessibilityHint: String {
        guard !isDimmed else { return "" }
        if onLongPress != nil { return "abre proveniência do commit; pressione e segure para opções" }
        return "abre proveniência do commit"
    }
}
