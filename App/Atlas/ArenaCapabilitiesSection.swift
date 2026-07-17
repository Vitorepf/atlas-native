import SwiftUI
import AtlasCore

/// Capacidades medidas — sem dados reais = silêncio total (lei V1, paridade AGORA/SUITES).
struct ArenaCapabilitiesSection: View {
    let capabilities: AtlasArenaCapabilities?

    private var measuredCapabilities: [AtlasArenaCapability] {
        capabilities?.capabilities ?? []
    }

    var body: some View {
        if !measuredCapabilities.isEmpty, let capabilities {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("CAPACIDADES")
                            .font(.system(.caption, weight: .semibold))
                            .tracking(1.4)
                            .foregroundStyle(AtlasTheme.textTertiary)
                        if let engine = capabilities.engine?.nonEmpty {
                            Text(engine)
                                .font(AtlasFont.mono(11))
                                .foregroundStyle(AtlasTheme.textTertiary)
                        }
                    }
                    Spacer()
                    Text(capabilities.mappingVersion)
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }

                ForEach(measuredCapabilities) { capability in
                    ArenaCapabilityRow(capability: capability)
                }
                ArenaCapabilitiesChart(capabilities: measuredCapabilities)
                    .frame(height: 190)
            }
            .padding(16)
            .atlasCard()
            .accessibilityIdentifier(A11yID.arenaCapabilitiesSection)
        }
    }
}
