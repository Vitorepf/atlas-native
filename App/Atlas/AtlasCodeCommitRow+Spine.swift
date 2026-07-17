import SwiftUI
import AtlasCore

// Spine + a11y — peel de AtlasCodeCommitRow.

extension AtlasCodeCommitRow {
    /// A espinha: linha contínua + o nó. O desvio salta ao olho pela cor.
    var spine: some View {
        let spineTint = color.opacity(0.45)
        return VStack(spacing: 0) {
            Rectangle()
                .fill(isFirst ? Color.clear : spineTint)
                .frame(width: 2, height: 8)
            ZStack {
                if state == .violating {
                    Circle()
                        .strokeBorder(color.opacity(0.5), lineWidth: 1.4)
                        .frame(width: 22, height: 22)
                }
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                    .overlay(Circle().strokeBorder(AtlasTheme.bg, lineWidth: 2))
            }
            .frame(width: 22, height: 22)
            Rectangle()
                .fill(isLast ? Color.clear : spineTint)
                .frame(width: 2)
                .frame(maxHeight: .infinity)
        }
        .frame(width: 22)
        .accessibilityHidden(true)
    }
}
