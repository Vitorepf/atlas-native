import SwiftUI
import AtlasCore

// Signal chrome — peel de AutonomosOperationDigestSection+Body.

extension AutonomosOperationDigestSection {
    func digestSignalChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: 14)
                .stroke(incidentPresent ? AtlasTheme.domOperacional.opacity(0.4) : AtlasTheme.goldBorder, lineWidth: 1))
    }
}
