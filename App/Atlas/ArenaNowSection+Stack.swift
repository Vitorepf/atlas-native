import SwiftUI
import AtlasCore

// Stack AGORA — peel de ArenaNowSection+Body.
// Header → ArenaNowSection+StackHeader.swift

extension ArenaNowSection {
    var nowSectionStack: some View {
        VStack(alignment: .leading, spacing: 12) {
            nowSectionHeader
            if runs.isEmpty {
                nowEmptyQuietRow
            } else {
                nowRunRows
                nowQueueLine
            }
        }
        .padding(16)
        .atlasCard()
    }

    /// Fila em UMA linha quieta; os nomes só ocupam a tela quando pedidos.
    @ViewBuilder
    var nowQueueLine: some View {
        if !queuedSuiteNames.isEmpty {
            AutonomosDigestToggleLine(
                title: "na fila",
                detail: queuedSuiteNames.count == 1 ? "1 suíte" : "\(queuedSuiteNames.count) suítes",
                expanded: $queueExpanded,
                a11yID: A11yID.arenaNowQueueToggle
            )
            if queueExpanded {
                Text(queuedSuiteNames.joined(separator: " · "))
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .accessibilityLabel("na fila: \(queuedSuiteNames.joined(separator: ", "))")
            }
        }
    }

    /// Zero runs — ausência dita, nunca inventada (goal: sempre ver a contagem).
    var nowEmptyQuietRow: some View {
        Text("Nada medindo agora.")
            .font(.system(.caption))
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}
