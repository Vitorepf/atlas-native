import SwiftUI
import AtlasCore

// Conteúdo da linha — peel de ThreadRow.
// Trailing → RootChrome+ThreadRow+Trailing.swift

extension ThreadRow {
    var rowContent: some View {
        HStack(spacing: 14) {
            if isRunning {
                BreathingDiamond(size: 9, reduceMotion: reduceMotion).frame(width: 22)
                    .accessibilityHidden(true)
            } else {
                Image(systemName: "bubble.left")
                    .font(.system(size: 17)).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
                    .accessibilityHidden(true)
            }
            Text(thread.title).font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1).truncationMode(.tail)
                .accessibilityHidden(true)
            Spacer(minLength: 8)
            rowTrailing
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
        .overlay(alignment: .leading) {
            if let workspaceTint {
                Rectangle()
                    .fill(workspaceTint.opacity(0.85))
                    .frame(width: 2)
                    .padding(.vertical, 10)
                    .accessibilityHidden(true)
            }
        }
        .contentShape(Rectangle())
    }
}
