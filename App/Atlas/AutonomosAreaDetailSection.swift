import SwiftUI
import AtlasCore

/// Shell chrome — peel de AutonomosAreaDetailSection.
/// Stack body → AutonomosAreaDetailSection+Body.swift

struct AutonomosAreaDetailSection: View {
    let area: AtlasAutonomosArea
    let model: AutonomosModel
    @Binding var control: AtlasAutonomosRunAction?
    @Binding var startRunMode: AtlasAutonomosStartRunMode?
    @Binding var showTransferSheet: Bool
    let onOpenDetail: (AutonomosDetailSheet) -> Void
    let onSelfConstructionReceipt: (SelfConstructionReceipt) -> Void

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        areaDetailBody
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 18).fill(AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(AtlasTheme.separator, lineWidth: 1))
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.autonomosAreaDetailSection)
    }
}
