import SwiftUI
import Charts
import AtlasCore

// DualBar track — peel de ArenaCapabilitiesSection+DualBar.

extension DualBar {
    func bar(_ value: Double?, color: Color) -> some View {
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
