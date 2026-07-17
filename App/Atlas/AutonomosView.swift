import SwiftUI
import AtlasCore

/// Autônomos — área própria 24/7 (canon da obra), independente de conversa.
/// Cada valor desta tela vem do loop real: área, lock, ciclos, backlog, frota
/// global, saúde da fila e recibos governados. Nada é inferido; ausência de
/// dado é ausência na tela (C13: estado só aparece com a prova correspondente).
/// Content → AutonomosView+Content.swift · Lifecycle → AutonomosView+Lifecycle.swift
struct AutonomosView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var control: AtlasAutonomosRunAction?
    @State var startRunMode: AtlasAutonomosStartRunMode?
    @State var showTransferSheet = false
    @State var detailSheet: AutonomosDetailSheet?
    @State var nightly = NightlyProposalController.shared
    @State var nightlyStartProposal: NightlyProposalController.ProposalPayload?
    @State var selfConstructionReceipt: SelfConstructionReceipt?
    @State var rhythmSampleDays: Int?

    var model: AutonomosModel { session.autonomos }

    var body: some View {
        autonomosLifecycleChrome(
            ZStack {
                AtlasTheme.bg.ignoresSafeArea()
                VStack(spacing: 0) {
                    AutonomosViewHeader(
                        auditModeEnabled: session.auditModeEnabled,
                        canRefresh: model.selectedArea != nil,
                        isHealthy: isHeaderHealthy,
                        reduceMotion: reduceMotion,
                        onBack: { dismiss() },
                        onRefresh: { Task { await model.refreshSelected() } }
                    )
                    content
                        .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
                        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: contentPhaseID)
                }
            }
        )
    }
}
