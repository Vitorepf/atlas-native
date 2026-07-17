import SwiftUI
import AtlasCore

// Entregas comprovadas — peel de AutonomosAreaDetailSection.
// Empty → AutonomosAreaDeliveredSection+Empty.swift
// Filled → AutonomosAreaDeliveredSection+Filled.swift

struct AutonomosAreaDeliveredSection: View {
    let area: AtlasAutonomosArea
    let model: AutonomosModel
    let onSelfConstructionReceipt: (SelfConstructionReceipt) -> Void

    @Environment(\.openURL) var openURL
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        deliveredSection
    }
}
