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
    /// Objetivo clampado a 3 linhas; o toque abre o parágrafo inteiro.
    @State var objectiveExpanded = false

    var body: some View {
        areaDetailCardChrome(areaDetailBody)
    }
}
