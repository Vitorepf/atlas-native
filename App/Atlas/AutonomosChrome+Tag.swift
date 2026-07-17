import SwiftUI

// Tag mono Autônomos — metadado visual; spoken composto vive no container pai.
extension AutonomosChrome {
    @ViewBuilder
    static func tag(_ text: String) -> some View {
        Text(text)
            .font(AtlasFont.mono(9))
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
            .lineLimit(1)
            .accessibilityHidden(true)
    }
}
