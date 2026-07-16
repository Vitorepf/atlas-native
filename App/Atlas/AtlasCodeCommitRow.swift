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
    }

    /// A espinha: linha contínua + o nó. O desvio salta ao olho pela cor.
    private var spine: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(isFirst ? Color.clear : AtlasTheme.accent.opacity(0.55))
                .frame(width: 2, height: 8)
            ZStack {
                if state == .violating {
                    Circle()
                        .strokeBorder(AtlasCodePalette.alert.opacity(0.5), lineWidth: 1.4)
                        .frame(width: 22, height: 22)
                }
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                    .overlay(Circle().strokeBorder(AtlasTheme.bg, lineWidth: 2))
            }
            .frame(width: 22, height: 22)
            Rectangle()
                .fill(isLast ? Color.clear : AtlasTheme.accent.opacity(0.55))
                .frame(width: 2)
                .frame(maxHeight: .infinity)
        }
        .frame(width: 22)
        .accessibilityHidden(true)
    }

    private var accessibilityText: String {
        let title = node.message ?? String(node.hash.prefix(8))
        let author = node.authorName.isEmpty ? node.authorEmail : node.authorName
        switch state {
        case .violating: return "\(title), por \(author), fora da main\(ruleId.map { ", regra \($0)" } ?? "")"
        case .healed: return "\(title), por \(author), curado"
        case .onMain: return "\(title), por \(author), na main"
        case .history: return "\(title), por \(author)"
        }
    }
}
