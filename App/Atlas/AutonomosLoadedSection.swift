import SwiftUI
import AtlasCore

/// Corpo carregado da área Autônomos — scroll com frota, digest, área e histórico.
/// Stack → AutonomosLoadedSection+Stack.swift
/// Refresh → AutonomosLoadedSection+Refresh.swift
struct AutonomosLoadedSection: View {
    let model: AutonomosModel
    let auditModeEnabled: Bool
    let nightly: NightlyProposalController
    let oldestBacklogCreatedAt: Date?
    @Binding var nightlyStartProposal: NightlyProposalController.ProposalPayload?
    @Binding var control: AtlasAutonomosRunAction?
    @Binding var startRunMode: AtlasAutonomosStartRunMode?
    @Binding var showTransferSheet: Bool
    @Binding var detailSheet: AutonomosDetailSheet?
    @Binding var selfConstructionReceipt: SelfConstructionReceipt?
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        loadedScrollShell
    }
}
