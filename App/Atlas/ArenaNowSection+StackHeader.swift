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
            // Só o estado VIVO merece o canto do header; a fila fala na
            // própria linha de disclosure — dizer duas vezes era ruído.
            if runningCount > 0 {
                Text(runningCount == 1 ? "medindo" : "\(runningCount) medindo")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.accent)
                    .monospacedDigit()
                    .accessibilityHidden(true)
            }
        }
    }
}
