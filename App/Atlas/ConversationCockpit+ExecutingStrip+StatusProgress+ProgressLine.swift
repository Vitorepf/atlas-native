import SwiftUI
import AtlasCore

// Execution progress line — peel de ExecutingStrip+StatusProgress.

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusProgressLine: some View {
        if let p = bubble.executionProgress {
            Text("\(p.current)/\(p.total) · \(p.title)")
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(2)
                .accessibilityHidden(true)
        }
    }
}
