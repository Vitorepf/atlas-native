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

    /// C13 + Elite C: merge comprovado = sucesso/silêncio; delivered_total=0
    /// em auto-construção = vazio honesto (nunca “melhorou” sem ledger).
    @ViewBuilder
    var deliveredSection: some View {
        let isSelf = isSelfConstructionArea(area)
        let deliveredTotal = model.delivered?.deliveredTotal ?? 0
        if let delivered = model.delivered, deliveredTotal > 0 {
            deliveredFilled(delivered: delivered, isSelf: isSelf, deliveredTotal: deliveredTotal)
        } else if isSelf {
            deliveredEmptySelf
        }
    }
}
