import SwiftUI
import AtlasCore

// AGORA header — peel de ArenaNowSection+Stack.

extension ArenaNowSection {
    var nowSectionHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("AGORA")
                .font(.system(.caption, weight: .semibold))
                .tracking(1.4)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Text(nowCountCaption)
                .font(AtlasFont.mono(11))
                .foregroundStyle(runningCount > 0 ? AtlasTheme.accent : AtlasTheme.textTertiary)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
    }

    /// "2 rodando · 3 na fila" / "1 na fila" / "nada rodando".
    var nowCountCaption: String {
        var parts: [String] = []
        if runningCount > 0 { parts.append("\(runningCount) rodando") }
        if queuedCount > 0 { parts.append("\(queuedCount) na fila") }
        return parts.isEmpty ? "nada rodando" : parts.joined(separator: " · ")
    }
}
