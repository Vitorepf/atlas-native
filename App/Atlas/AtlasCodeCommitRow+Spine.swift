import SwiftUI
import AtlasCore

// Spine + a11y — peel de AtlasCodeCommitRow.

extension AtlasCodeCommitRow {
    /// A espinha: linha contínua + o nó. O desvio salta ao olho pela cor.
    var spine: some View {
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

    var accessibilityText: String {
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
