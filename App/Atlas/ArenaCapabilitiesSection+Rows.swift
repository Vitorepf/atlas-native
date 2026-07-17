import SwiftUI
import Charts
import AtlasCore

// Rows — peel de ArenaCapabilitiesSection.
// DualBar → +DualBar · Contribution → +Contribution.swift
// Header → ArenaCapabilitiesSection+RowHeader.swift · Line view → +RowContributionView.swift

struct ArenaCapabilityRow: View {
    let capability: AtlasArenaCapability

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            capabilityHeader
            DualBar(score: capability.score, withAtlas: capability.withAtlas)
            contributionLineView
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArenaCapabilitiesSectionA11y.spokenCapability(capability))
        .accessibilityIdentifier(A11yID.arenaCapabilityRow(capability.capability))
    }
}
