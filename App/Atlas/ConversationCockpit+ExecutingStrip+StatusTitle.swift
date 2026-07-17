import SwiftUI
import AtlasCore

// Strip status title — peel de ConversationCockpit+ExecutingStrip+StatusLines.
// Activity → ConversationCockpit+ExecutingStrip+StatusActivity.swift

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusTitle: some View {
        if bubble.showsReconnectSurface, let line = bubble.reconnectPrimaryLine {
            Text(line)
                .font(.system(.footnote))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(2)
                .accessibilityHidden(true)
        } else if let p = bubble.executionProgress {
            Text("\(p.current)/\(p.total) · \(p.title)")
                .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(2)
                .accessibilityHidden(true)
        } else {
            stripStatusActivityOrIdle
        }
    }
}
