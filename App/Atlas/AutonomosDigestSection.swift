import SwiftUI
import AtlasCore

// MARK: - Próximo / último resumo (M09)
// Card → AutonomosDigestSection+Card.swift
// Body → AutonomosDigestSection+Body.swift

struct AutonomosNextDigestSection: View {
    let digest: AtlasAutonomosDigestResponse
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        digestBody
    }
}
