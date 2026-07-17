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
                        .foregroundStyle(state == .violating ? AtlasCodePalette.alert : AtlasTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    HStack(spacing: 6) {
                        Text(node.authorName.isEmpty ? node.authorEmail : node.authorName)
                        Text("·")
                        Text(AtlasCodeRelativeTime.short(from: node.authoredAt))
                        if let ruleId {
                            Text("·")
                            // A lei em português. `worktree_allowlist` é nome de
                            // máquina e não sobe à tela em que o operador decide
                            // se apaga trabalho — o tradutor já existia, e só o
                            // grafo continuava falando snake_case.
                            Text(AtlasCodeIssue.law(ruleId, trunk: trunk))
                                .foregroundStyle(AtlasCodePalette.alert)
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
        // O leitor de tela precisa do mesmo sinal que o olho recebe.
        .accessibilityHint(isDimmed ? "fora da resposta" : "")
        .accessibilityIdentifier(A11yID.codeCommit(hashPrefix: String(node.hash.prefix(8))))
        .onLongPressGesture(minimumDuration: 0.45) {
            onLongPress?()
        }
    }
}
