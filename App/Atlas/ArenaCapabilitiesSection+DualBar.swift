import SwiftUI
import Charts
import AtlasCore

// DualBar — peel de ArenaCapabilitiesSection+Rows.

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
