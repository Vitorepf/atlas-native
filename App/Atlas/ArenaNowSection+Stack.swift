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
                nowLiveActivityNote
            }
        }
        .padding(16)
        .atlasCard()
    }

    /// Zero runs — ausência dita, nunca inventada (goal: sempre ver a contagem).
    var nowEmptyQuietRow: some View {
        Text("Nenhuma medição em andamento — toque em Rodar medição para iniciar.")
            .font(.system(.caption))
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}
