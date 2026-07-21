import SwiftUI
import AtlasCore

// IDLE-COMPRESS fused AutonomosView · AutonomosView.swift

// --- AutonomosView.swift ---
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

// --- AutonomosView+Content+PhaseRouter+Busy.swift ---
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

// --- AutonomosView+Content+PhaseRouter.swift ---
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

// --- AutonomosView+Content.swift ---
extension AutonomosView {
    @ViewBuilder
    var content: some View {
        autonomosPhaseRouter
    }
}

// --- AutonomosView+ContentFailed.swift ---
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

// --- AutonomosView+ContentLoaded.swift ---
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

// --- AutonomosView+ContentShell+Loading.swift ---
extension AutonomosView {
    var loadingContent: some View {
        VStack {
            Spacer()
            TraceEvidenceLoading(text: "abrindo catálogo…", reduceMotion: reduceMotion)
            Spacer()
        }
    }
}

// --- AutonomosView+HeaderStack+ContentAnim.swift ---
extension AutonomosView {
    var autonomosContentAnimated: some View {
        content
            .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: contentPhaseID)
    }
}

// --- AutonomosView+HeaderStack.swift ---
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
        guard let destination, let unit = selectedUnit else { return "" }
        switch destination {
        case .hub:
            return unit.paused ? "Parado" : "Vivo"
        case .evolution:
            return unit.name
        default:
            return ""
        }
    }

    private var headerSubtitleLive: Bool {
        guard let destination, let unit = selectedUnit else { return false }
        switch destination {
        case .hub, .evolution:
            return !unit.paused
        default:
            return false
        }
    }
}

// --- AutonomosViewHeader+A11y.swift ---
extension AutonomosViewHeader {
    func spokenTitle(isHealthy: Bool, auditModeEnabled: Bool) -> String {
        var parts = [title, subtitle]
        if auditModeEnabled { parts.append("modo auditoria") }
        return parts.joined(separator: ", ")
    }

    func spokenBackLabel() -> String { "voltar" }

    func spokenBackHint() -> String { "volta" }
}

// --- AutonomosViewHeader+A11yRefresh.swift ---
extension AutonomosViewHeader {
    func spokenRefreshLabel(canRefresh: Bool) -> String {
        canRefresh
            ? "atualizar instância selecionada"
            : "atualizar indisponível, selecione uma instância"
    }

    func spokenRefreshHint(canRefresh: Bool) -> String {
        canRefresh ? "recarrega estado da área selecionada" : "nenhuma instância selecionada"
    }
}

// --- AutonomosViewHeader+Buttons.swift ---
extension AutonomosViewHeader {
    var backButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onBack()
        } label: {
            Image(systemName: "chevron.left")
                .atlasSans(17, .semibold)
                .foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 40, height: 40)
                .atlasGlassCircle()
        }
        .accessibilityLabel(spokenBackLabel())
        .accessibilityHint(spokenBackHint())
        .accessibilityIdentifier(A11yID.autonomosBack)
    }
}

// --- AutonomosViewHeader+Create.swift ---
extension AutonomosViewHeader {
    var createButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onCreate()
        } label: {
            Image(systemName: "plus")
                .atlasSans(17, .semibold)
                .foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 40, height: 40)
                .atlasGlassCircle()
        }
        .accessibilityLabel("Novo Autônomo")
        .accessibilityHint("Cria um Autônomo com nome e carta")
        .accessibilityIdentifier(A11yID.autonomosNew)
    }
}

// --- AutonomosViewHeader+Layout.swift ---
extension AutonomosViewHeader {
    var headerLayout: some View {
        HStack(spacing: 12) {
            backButton
            titleBlock
            Spacer()
            trailingButton
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, 8)
    }

    @ViewBuilder
    private var trailingButton: some View {
        switch trailing {
        case .none:
            EmptyView()
        case .create:
            createButton
        case .refresh:
            refreshButton
        }
    }
}

// --- AutonomosViewHeader+Refresh.swift ---
extension AutonomosViewHeader {
    var refreshButton: some View {
        Button {
            if canRefresh { AtlasMotion.softImpact(reduceMotion: reduceMotion) }
            onRefresh()
        } label: {
            Image(systemName: "arrow.clockwise")
                .atlasSans(15, .medium)
                .foregroundStyle(canRefresh ? AtlasTheme.textSecondary : AtlasTheme.textTertiary)
                .frame(width: 40, height: 40)
                .atlasGlassCircle()
        }
        .disabled(!canRefresh)
        .opacity(canRefresh ? 1 : 0.45)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: canRefresh)
        .accessibilityLabel(spokenRefreshLabel(canRefresh: canRefresh))
        .accessibilityHint(spokenRefreshHint(canRefresh: canRefresh))
        .accessibilityIdentifier(A11yID.autonomosRefresh)
    }
}

// --- AutonomosViewHeader+Title.swift ---
extension AutonomosViewHeader {
    var titleBlock: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(AtlasFont.serif(21, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            titleBadges
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(spokenTitle(isHealthy: isHealthy, auditModeEnabled: auditModeEnabled))
        .accessibilityIdentifier(A11yID.autonomosHeader)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: isHealthy)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: auditModeEnabled)
    }
}

