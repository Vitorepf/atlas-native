import SwiftUI
import AtlasCore

// Mapping version trailing — peel de ArenaCapabilitiesSection+Header.

extension ArenaCapabilitiesSection {
    // Versão do mapa é proveniência de máquina — vive no spoken de auditoria
    // (A11yLead), não na cara do card.
    @ViewBuilder
    func capabilitiesMapping(_ capabilities: AtlasArenaCapabilities) -> some View {
        EmptyView()
    }
}
