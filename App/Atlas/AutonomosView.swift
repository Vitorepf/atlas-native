import SwiftUI
import AtlasCore

/// Face Autônomos v9 — catálogo → hub → evolução · pílula no MapShell.
struct AutonomosView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var destination: AutonomosDestination?
    @State var selectedUnitID: String?
    @State var showNewSheet = false

    var model: AutonomosModel { session.autonomos }

    /// Face = catálogo local; masthead quieto.
    private var isHeaderHealthy: Bool { true }

    private var contentPhaseID: String {
        switch model.phase {
        case .idle: "idle"
        case .loading: "loading"
        case .loaded: "loaded"
        case .failed: "failed"
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
        guard let destination, let unit = selectedUnit else { return "" }
        switch destination {
        case .hub: return unit.paused ? "Parado" : "Vivo"
        case .evolution: return unit.name
        default: return ""
        }
    }

    private var headerSubtitleLive: Bool {
        guard let destination, let unit = selectedUnit else { return false }
        switch destination {
        case .hub, .evolution: return !unit.paused
        default: return false
        }
    }

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
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
                    onCreate: { showNewSheet = true }
                )
                phaseContent
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
                    .animation(reduceMotion ? nil : AtlasMotion.editorial, value: contentPhaseID)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.autonomosScreen)
        .task { await model.load() }
    }

    @ViewBuilder
    private var phaseContent: some View {
        switch model.phase {
        case .idle, .loading:
            VStack {
                Spacer()
                TraceEvidenceLoading(text: "abrindo catálogo…", reduceMotion: reduceMotion)
                Spacer()
            }
        case .failed(let message):
            VStack {
                Spacer()
                AutonomosFleetFailureEmpty(message: message) {
                    Task { await model.load() }
                }
                Spacer()
            }
        case .loaded:
            AutonomosMapShell(
                model: model,
                destination: $destination,
                selectedUnitID: $selectedUnitID,
                showNewSheet: $showNewSheet
            )
        }
    }
}
