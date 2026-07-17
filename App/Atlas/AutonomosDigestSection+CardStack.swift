import SwiftUI
import AtlasCore

// Digest card stack — peel de AutonomosDigestSection+Card.
// WindowCaption → AutonomosDigestSection+CardStack+WindowCaption.swift
// LastBody → AutonomosDigestSection+CardStack+LastBody.swift

extension AutonomosNextDigestSection {
    @ViewBuilder
    func digestCardStack(last: Bool, window: String?) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            AutonomosChrome.sectionCaption(sectionTitle)
            digestCardWindowCaption(last: last, window: window)
            digestScheduleCopy(last: last)
            digestCardLastBody(last: last)
        }
    }
}
