import SwiftUI
import AtlasCore

/// Capacidades medidas — sem dados reais = silêncio total (lei V1, paridade AGORA/SUITES).
struct ArenaCapabilitiesSection: View {
    let capabilities: AtlasArenaCapabilities?
    let reduceMotion: Bool

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
                            .accessibilityAddTraits(.isHeader)
                        if let engine = capabilities.engine?.nonEmpty {
                            Text(engine)
                                .font(AtlasFont.mono(11))
                                .foregroundStyle(AtlasTheme.textTertiary)
                                .accessibilityHidden(true)
                        }
                    }
                    Spacer()
                    if let mapping = capabilities.mappingVersion.nonEmpty {
                        Text(mapping)
                            .font(AtlasFont.mono(10))
                            .foregroundStyle(AtlasTheme.textSecondary)
                            .accessibilityHidden(true)
                    }
                }

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
