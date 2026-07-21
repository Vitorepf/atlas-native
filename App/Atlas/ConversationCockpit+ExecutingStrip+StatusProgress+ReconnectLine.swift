import SwiftUI
import AtlasCore

// Reconnect primary line — peel de ExecutingStrip+StatusProgress.

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusReconnectLine: some View {
        if bubble.showsReconnectSurface, let line = bubble.reconnectPrimaryLine {
            Text(line)
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(2)
                .accessibilityHidden(true)
        }
    }
}
