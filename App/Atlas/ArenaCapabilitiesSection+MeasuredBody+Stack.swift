import SwiftUI
import AtlasCore

// Measured stack — peel de ArenaCapabilitiesSection+MeasuredBody.
// Rows → ArenaCapabilitiesSection+MeasuredBody+Stack+Rows.swift
// Chart → ArenaCapabilitiesSection+MeasuredBody+Stack+Chart.swift

extension ArenaCapabilitiesSection {
    @ViewBuilder
    func capabilitiesMeasuredStack(_ capabilities: AtlasArenaCapabilities) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            if capabilities.engine == nil {
                // Perfil agregado (por-motor ainda não publicado): dito, nunca
                // implícito — o operador sabe de quem é a medição.
                Text("todos os motores · perfil agregado")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            capabilitiesMeasuredRowsFrame(capabilities)
            capabilitiesMeasuredChartFrame
        }
    }
}
