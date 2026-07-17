import SwiftUI
import Charts
import AtlasCore

// Rows — peel de ArenaCapabilitiesSection.
// DualBar → +DualBar · Contribution → +Contribution.swift
// Header → ArenaCapabilitiesSection+RowHeader.swift

struct ArenaCapabilityRow: View {
    let capability: AtlasArenaCapability

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            capabilityHeader
            DualBar(score: capability.score, withAtlas: capability.withAtlas)
            if !contributionLine.isEmpty {
                Text(contributionLine)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArenaCapabilitiesSectionA11y.spokenCapability(capability))
        .accessibilityIdentifier(A11yID.arenaCapabilityRow(capability.capability))
    }
}
