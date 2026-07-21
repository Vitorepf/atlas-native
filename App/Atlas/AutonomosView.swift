import SwiftUI
import AtlasCore

// IDLE-COMPRESS fused AutonomosView · AutonomosView.swift

// MARK: - Host

struct AutonomosView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var destination: AutonomosDestination?
    @State var selectedUnitID: String?
    @State var showNewSheet = false

    var model: AutonomosModel { session.autonomos }

    var body: some View {
        autonomosLifecycleChrome(
            ZStack {
                AtlasTheme.bg.ignoresSafeArea()
                autonomosHeaderStack
            }
        )
    }
}

extension AutonomosView {
    @ViewBuilder
    var autonomosBusyPhaseRouter: some View {
        switch model.phase {
        case .idle, .loading:
            loadingContent
        case .failed(let message):
            failedContent(message: message)
        default:
            EmptyView()
        }
    }
}

// MARK: - Sections

extension AutonomosView {
    @ViewBuilder
    var autonomosPhaseRouter: some View {
        switch model.phase {
        case .idle, .loading, .failed:
            autonomosBusyPhaseRouter
        case .loaded:
            loadedContent
        }
    }
}

extension AutonomosView {
    @ViewBuilder
    var content: some View {
        autonomosPhaseRouter
    }
}

extension AutonomosView {
    func failedContent(message: String) -> some View {
        VStack {
            Spacer()
            AutonomosFleetFailureEmpty(message: message) {
                Task { await model.load() }
            }
            Spacer()
        }
    }
}

extension AutonomosView {
    var loadedContent: some View {
        AutonomosMapShell(
            model: model,
            destination: $destination,
            selectedUnitID: $selectedUnitID,
            showNewSheet: $showNewSheet
        )
    }
}

extension AutonomosView {
    var loadingContent: some View {
        VStack {
            Spacer()
            TraceEvidenceLoading(text: "abrindo catálogo…", reduceMotion: reduceMotion)
            Spacer()
        }
    }
}

extension AutonomosView {
    var autonomosContentAnimated: some View {
        content
            .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: contentPhaseID)
    }
}

extension AutonomosView {
    var autonomosHeaderStack: some View {
        VStack(spacing: 0) {
            AutonomosViewHeader(
                auditModeEnabled: session.auditModeEnabled,
                canRefresh: false,
                isHealthy: isHeaderHealthy,
                title: headerTitle,
                subtitle: headerSubtitle,
                subtitleLive: headerSubtitleLive,
                trailing: destination == nil ? .create : .none,
                reduceMotion: reduceMotion,
                onBack: {
                    if let destination {
                        self.destination = destination.backTarget
                        if self.destination == nil {
                            selectedUnitID = nil
                        }
                    } else {
                        dismiss()
                    }
                },
                onRefresh: {},
                onCreate: {
                    showNewSheet = true
                }
            )
            autonomosContentAnimated
        }
    }

    private var selectedUnit: AutonomosUnit? {
        guard let selectedUnitID else { return nil }
        return model.operatorUnit(id: selectedUnitID)
    }

    private var headerTitle: String {
        guard let destination else { return "Autônomos" }
        if case .hub = destination {
            return selectedUnit?.name ?? "Autônomo"
        }
        return destination.navTitle
    }

    private var headerSubtitle: String {
        guard let destination else { return "" }
        switch destination {
        case .hub:
            // WAVE-030: loop face when area bound; else catalog pause honesty.
            if model.selectedArea != nil {
                return AutonomosRunControlJudgment.face(
                    areaSelected: true,
                    canControl: model.canControlSelectedArea,
                    live: model.live
                ).productWord
            }
            guard let unit = selectedUnit else { return "" }
            return unit.paused ? "Parado" : "Vivo"
        case .evolution:
            return selectedUnit?.name ?? ""
        case .decisions, .decisionInbox, .decisionOrder:
            let face = AutonomosDecisionJudgment.face(
                backlog: model.backlog,
                areaSelected: model.selectedArea != nil,
                error: model.controlError
            )
            return face.productWord
        default:
            return ""
        }
    }

    private var headerSubtitleLive: Bool {
        guard let destination else { return false }
        switch destination {
        case .hub, .evolution:
            return selectedUnit.map { !$0.paused } ?? false
        case .decisions, .decisionInbox, .decisionOrder:
            if case .items = AutonomosDecisionJudgment.face(
                backlog: model.backlog,
                areaSelected: model.selectedArea != nil,
                error: model.controlError
            ) { return true }
            return false
        default:
            return false
        }
    }
}

