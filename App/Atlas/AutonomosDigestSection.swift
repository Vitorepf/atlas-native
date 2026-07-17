import SwiftUI
import AtlasCore

// MARK: - Próximo / último resumo (M09)
// Card → AutonomosDigestSection+Card.swift

struct AutonomosNextDigestSection: View {
    let digest: AtlasAutonomosDigestResponse
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        if shouldShowDigest(digest) {
            digestCard
        } else {
            AutonomosDigestEmptyState()
        }
    }
}
