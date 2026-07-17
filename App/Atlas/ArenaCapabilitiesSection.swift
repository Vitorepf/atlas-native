import SwiftUI
import AtlasCore

struct ArenaCapabilitiesSection: View {
    let capabilities: AtlasArenaCapabilities?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("CAPACIDADES")
                        .font(.system(.caption, weight: .semibold))
                        .tracking(1.4)
                        .foregroundStyle(AtlasTheme.textTertiary)
                    Text(capabilities?.engine ?? "motor não selecionado")
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
                Spacer()
                Text(capabilities?.mappingVersion ?? "não medido")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(capabilities == nil ? AtlasTheme.textTertiary : AtlasTheme.textSecondary)
            }

            if let capabilities, !capabilities.capabilities.isEmpty {
                ForEach(capabilities.capabilities) { capability in
                    ArenaCapabilityRow(capability: capability)
                }
                ArenaCapabilitiesChart(capabilities: capabilities.capabilities)
                    .frame(height: 190)
            } else {
                Text("não medido")
                    .font(AtlasFont.mono(13))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                    .accessibilityLabel("capacidades não medidas")
            }
        }
        .padding(16)
        .atlasCard()
    }
}
