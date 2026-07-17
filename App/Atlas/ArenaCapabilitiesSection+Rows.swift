import SwiftUI
import Charts
import AtlasCore

// Rows — peel de ArenaCapabilitiesSection.
// DualBar → ArenaCapabilitiesSection+DualBar.swift

struct ArenaCapabilityRow: View {
    let capability: AtlasArenaCapability

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline) {
                Text(capability.labelPt)
                    .font(.system(.callout, weight: .medium))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(1)
                    .accessibilityHidden(true)
                Spacer()
                Text("\(ArenaFormat.score(capability.score)) · c/A \(ArenaFormat.score(capability.withAtlas))")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(capability.score == nil ? AtlasTheme.textTertiary : AtlasTheme.textSecondary)
                    .monospacedDigit()
                    .accessibilityHidden(true)
            }
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

    var contributionLine: String {
        var parts: [String] = []
        if let cases = ArenaCapabilitiesSectionA11y.casesCaption(for: capability) {
            parts.append(cases)
        }
        if !capability.suitesContributing.isEmpty {
            parts.append(capability.suitesContributing.joined(separator: ", "))
        }
        return parts.joined(separator: " · ")
    }
}
