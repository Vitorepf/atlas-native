import SwiftUI
import Charts
import AtlasCore

// Rows + chart — peel de ArenaCapabilitiesSection.

struct ArenaCapabilityRow: View {
    let capability: AtlasArenaCapability

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline) {
                Text(capability.labelPt)
                    .font(.system(.callout, weight: .medium))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(1)
                Spacer()
                Text("\(ArenaFormat.score(capability.score)) · c/A \(ArenaFormat.score(capability.withAtlas))")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(capability.score == nil ? AtlasTheme.textTertiary : AtlasTheme.textSecondary)
                    .monospacedDigit()
            }
            DualBar(score: capability.score, withAtlas: capability.withAtlas)
            if !contributionLine.isEmpty {
                Text(contributionLine)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(capability.labelPt), score \(ArenaFormat.score(capability.score)), com Atlas \(ArenaFormat.score(capability.withAtlas))")
    }

    private var contributionLine: String {
        var parts: [String] = []
        if let total = capability.casesTotal {
            parts.append("\(total) casos")
        }
        if !capability.suitesContributing.isEmpty {
            parts.append(capability.suitesContributing.joined(separator: ", "))
        }
        return parts.joined(separator: " · ")
    }
}

struct DualBar: View {
    let score: Double?
    let withAtlas: Double?

    var body: some View {
        VStack(spacing: 4) {
            bar(score, color: AtlasTheme.textSecondary)
            bar(withAtlas, color: AtlasTheme.accent)
        }
        .accessibilityHidden(true)
    }

    private func bar(_ value: Double?, color: Color) -> some View {
        GeometryReader { proxy in
            let width = proxy.size.width * min(max(value ?? 0, 0), 1)
            ZStack(alignment: .leading) {
                Capsule().fill(AtlasTheme.surfaceHi.opacity(0.8))
                Capsule()
                    .fill(value == nil ? AtlasTheme.textTertiary.opacity(0.25) : color.opacity(0.85))
                    .frame(width: width)
            }
        }
        .frame(height: 5)
    }
}
