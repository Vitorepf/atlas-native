import SwiftUI
import AtlasCore

/// Capacidades medidas — sem dados reais = silêncio total (lei V1, paridade AGORA/SUITES).
/// Header → ArenaCapabilitiesSection+Header.swift
struct ArenaCapabilitiesSection: View {
    let capabilities: AtlasArenaCapabilities?
    let reduceMotion: Bool

    var measuredCapabilities: [AtlasArenaCapability] {
        capabilities?.capabilities ?? []
    }

    var body: some View {
        if !measuredCapabilities.isEmpty, let capabilities {
            VStack(alignment: .leading, spacing: 14) {
                capabilitiesHeader(capabilities)

                ForEach(measuredCapabilities) { capability in
                    ArenaCapabilityRow(capability: capability)
                        .transition(reduceMotion ? .identity : .opacity)
                }
                ArenaCapabilitiesChart(capabilities: measuredCapabilities)
                    .frame(height: 190)
            }
            .padding(16)
            .atlasCard()
            .accessibilityElement(children: .contain)
            .accessibilityLabel(ArenaCapabilitiesSectionA11y.spokenSection(capabilities))
            .accessibilityIdentifier(A11yID.arenaCapabilitiesSection)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: measuredCapabilities.map(\.id))
        }
    }
}
