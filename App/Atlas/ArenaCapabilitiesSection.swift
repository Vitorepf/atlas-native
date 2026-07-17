import SwiftUI
import AtlasCore

/// Capacidades medidas — sem dados reais = silêncio total (lei V1, paridade AGORA/SUITES).
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
        }
    }
}
