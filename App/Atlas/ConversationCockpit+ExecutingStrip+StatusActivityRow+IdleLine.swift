import SwiftUI
import AtlasCore

// Idle line — peel de ExecutingStrip+StatusActivityRow.

extension ExecutingStrip {
    var stripStatusIdleLine: some View {
        Text("Seguindo a execução")
            .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
            .lineLimit(1)
            .layoutPriority(2)
            .accessibilityHidden(true)
    }
}
