import SwiftUI
import AtlasCore

/// Capacidades — o hero da Arena (goal do operador 2026-07-17): desempenho
/// por habilidade, sem e com Atlas. Sem medição = ausência DITA, nunca
/// silêncio — o operador precisa saber que a dimensão existe e está vazia.
/// Header → ArenaCapabilitiesSection+Header.swift
/// Body → ArenaCapabilitiesSection+MeasuredBody.swift
struct ArenaCapabilitiesSection: View {
    let capabilities: AtlasArenaCapabilities?
    let reduceMotion: Bool

    var measuredCapabilities: [AtlasArenaCapability] {
        capabilities?.capabilities ?? []
    }

    var body: some View {
        if !measuredCapabilities.isEmpty, let capabilities {
            capabilitiesMeasuredBody(capabilities)
        } else {
            capabilitiesUnmeasuredCard
        }
    }

    /// Ausência dita: a taxonomia vem do servidor; aqui só o estado.
    var capabilitiesUnmeasuredCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CAPACIDADES")
                .font(.system(.caption, weight: .semibold))
                .tracking(1.4)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityAddTraits(.isHeader)
            Text("Nenhuma capacidade medida ainda — rode uma medição para mapear as habilidades dos motores.")
                .font(.system(.caption))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .atlasCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("capacidades, nenhuma medida ainda")
        .accessibilityIdentifier(A11yID.arenaCapabilitiesSection)
    }
}
