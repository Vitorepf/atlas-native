import SwiftUI
import AtlasCore

// Card chrome — peel de AutonomosDigestSection+Card.

extension AutonomosNextDigestSection {
    func digestCardChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.goldBorder, lineWidth: 1))
    }
}
