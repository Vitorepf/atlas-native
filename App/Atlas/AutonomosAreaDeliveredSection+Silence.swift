import SwiftUI
import AtlasCore

// Delivered self silence line — peel de AutonomosAreaDeliveredSection+Filled.

extension AutonomosAreaDeliveredSection {
    @ViewBuilder
    var deliveredSelfSilence: some View {
        Text("silêncio · você não foi necessário — só veto com recibo")
            .font(AtlasFont.serifItalic(13))
            .foregroundStyle(AtlasTheme.textTertiary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityHidden(true)
    }
}
