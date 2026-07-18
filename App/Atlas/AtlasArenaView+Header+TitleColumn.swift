import SwiftUI
import AtlasCore

// Title column — peel de AtlasArenaView+Header.

extension AtlasArenaView {
    var headerTitleColumn: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("ARENA")
                .font(.system(.caption, weight: .semibold))
                .tracking(1.5)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text("Medição dos motores")
                .font(AtlasFont.serif(28, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            // "medido há Xmin" REMOVIDO do visual (veto do operador: relógio
            // de máquina não é experiência) — a idade do snapshot fica na voz.
        }
    }
}
