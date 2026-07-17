import SwiftUI
import AtlasCore

// Delivered filled stack — peel de AutonomosAreaDeliveredSection.
// Silence → AutonomosAreaDeliveredSection+Silence.swift
// Caption → AutonomosAreaDeliveredSection+Filled+Caption.swift
// CycleList → AutonomosAreaDeliveredSection+Filled+CycleList.swift

extension AutonomosAreaDeliveredSection {
    @ViewBuilder
    func deliveredFilled(delivered: AtlasAutonomosDeliveredResponse, isSelf: Bool, deliveredTotal: Int) -> some View {
        let visible = min(delivered.delivered.count, AutonomosAreaDeliveredA11y.visibleCap)
        VStack(alignment: .leading, spacing: 6) {
            deliveredFilledCaption(isSelf: isSelf, deliveredTotal: deliveredTotal, visible: visible)
            if isSelf { deliveredSelfSilence }
            deliveredFilledCycleList(delivered: delivered, visible: visible, isSelf: isSelf)
        }
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: deliveredTotal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(AutonomosAreaDeliveredA11y.spokenSection(isSelf: isSelf, total: deliveredTotal, visible: visible))
        .accessibilityIdentifier(isSelf ? A11yID.autonomosAreaDeliveredSelf : A11yID.autonomosAreaDeliveredSection)
    }
}
