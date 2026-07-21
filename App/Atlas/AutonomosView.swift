import AtlasCore
import SwiftUI

// Cycle 044 fuse → AutonomosView.swift

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

/// Falha de carregamento do catálogo Autônomos.
struct AutonomosFleetFailureEmpty: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundStyle(AtlasTheme.domOperacional.opacity(0.9))
                .accessibilityHidden(true)
            Text("Catálogo fora de alcance.")
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            Text(message)
                .font(.footnote)
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel(message)
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onRetry()
            } label: {
                Text("Tentar de novo")
                    .frame(minWidth: 160, minHeight: 48)
            }
                .buttonStyle(AutonomosPrimaryButtonStyle())
                .accessibilityIdentifier(A11yID.autonomosRetry)
                .accessibilityLabel("tentar de novo")
                .accessibilityHint("tenta reabrir o catálogo Autônomos")
                .accessibilityAddTraits(.isButton)
                .accessibilitySortPriority(8)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 28)
        .frame(maxWidth: 420)
        // Contain: header + retry stay separately focusable for VoiceOver.
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.autonomosLoadFailure)
    }
}

/// Cabeçalho Autônomos — voltar, título, + (lista). Sem refresh mentiroso.
struct AutonomosViewHeader: View {
    enum Trailing {
        case none
        case refresh
        case create
    }

    let auditModeEnabled: Bool
    let canRefresh: Bool
    let isHealthy: Bool
    var title: String = "Autônomos"
    var subtitle: String = ""
    var subtitleLive: Bool = false
    var trailing: Trailing = .refresh
    let reduceMotion: Bool
    let onBack: () -> Void
    let onRefresh: () -> Void
    var onCreate: () -> Void = {}

    var body: some View {
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
        case .none: EmptyView()
        case .create: createButton
        case .refresh: refreshButton
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(AtlasFont.serif(21, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            if !subtitle.isEmpty {
                Text(subtitle.uppercased())
                    .font(AtlasFont.mono(10)).tracking(1.2)
                    .foregroundStyle(subtitleLive ? AtlasTheme.accent : AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }
            if auditModeEnabled {
                Text("MODO AUDITORIA")
                    .font(AtlasFont.mono(9)).tracking(1.0)
                    .foregroundStyle(AtlasTheme.domOperacional)
                    .accessibilityHidden(true)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(spokenTitle())
        .accessibilityIdentifier(A11yID.autonomosHeader)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: isHealthy)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: auditModeEnabled)
    }

    private var backButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onBack()
        } label: {
            Image(systemName: "chevron.left")
                .atlasSans(17, .semibold)
                .foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 44, height: 44)
                .atlasGlassCircle()
                .contentShape(Circle())
        }
        .accessibilityLabel("voltar")
        .accessibilityHint("volta um nível no mapa Autônomos")
        .accessibilityIdentifier(A11yID.autonomosBack)
        .accessibilityAddTraits(.isButton)
    }

    private var createButton: some View {
        Button {
            // Medium: primary create entry from catalog chrome.
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            onCreate()
        } label: {
            Image(systemName: "plus")
                .atlasSans(17, .semibold)
                .foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 44, height: 44)
                .atlasGlassCircle()
                .contentShape(Circle())
        }
        .accessibilityLabel("Novo Autônomo")
        .accessibilityHint("abre o formulário para criar um Autônomo")
        .accessibilityIdentifier(A11yID.autonomosNew)
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(9) // primary catalog create surfaces early in VO
    }

    private var refreshButton: some View {
        Button {
            if canRefresh { AtlasMotion.softImpact(reduceMotion: reduceMotion) }
            onRefresh()
        } label: {
            Image(systemName: "arrow.clockwise")
                .atlasSans(15, .medium)
                .foregroundStyle(canRefresh ? AtlasTheme.textSecondary : AtlasTheme.textTertiary)
                .frame(width: 44, height: 44)
                .atlasGlassCircle()
                .contentShape(Circle())
        }
        .disabled(!canRefresh)
        .opacity(canRefresh ? 1 : 0.45)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: canRefresh)
        .accessibilityLabel(
            canRefresh
                ? "atualizar instância selecionada"
                : "atualizar indisponível, selecione uma instância"
        )
        .accessibilityHint(
            canRefresh ? "recarrega estado da área selecionada" : "nenhuma instância selecionada"
        )
        .accessibilityIdentifier(A11yID.autonomosRefresh)
        .accessibilityAddTraits(.isButton)
    }

    private func spokenTitle() -> String {
        var parts = [title, subtitle]
        if auditModeEnabled { parts.append("modo auditoria") }
        return parts.joined(separator: ", ")
    }
}
