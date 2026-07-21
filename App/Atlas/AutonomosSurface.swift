import SwiftUI
import AtlasCore

// IDLE-COMPRESS fused AutonomosView · AutonomosSurface.swift

extension AutonomosView {
    /// Face = catálogo local; masthead quieto (sem frota/backlog de sistema).
    var isHeaderHealthy: Bool { true }
}

extension AutonomosView {
    var contentPhaseBusyID: String? {
        switch model.phase {
        case .idle: return "idle"
        case .loading: return "loading"
        default: return nil
        }
    }
}

extension AutonomosView {
    var contentPhaseID: String {
        if let busy = contentPhaseBusyID { return busy }
        switch model.phase {
        case .loaded: return "loaded"
        case .failed: return "failed"
        default: return "idle"
        }
    }
}

extension AutonomosView {
    func spokenScreenBusyLabel() -> String? {
        switch model.phase {
        case .idle, .loading:
            return "Autônomos, abrindo catálogo"
        case .failed:
            return "Autônomos, falha ao abrir catálogo"
        default:
            return nil
        }
    }
}

extension AutonomosView {
    func spokenScreenPhaseLabel() -> String {
        if let busy = spokenScreenBusyLabel() { return busy }
        if isHeaderHealthy {
            return "Autônomos, catálogo quieto"
        }
        return "Autônomos, catálogo carregado"
    }
}

extension AutonomosView {
    func spokenScreenLabel() -> String {
        spokenScreenPhaseLabel()
    }

    static let screenHint = "catálogo local neste iPhone; pergunta e manda só pela pílula"
}

struct AutonomosFleetFailureEmpty: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        AtlasOpsFailureEmpty(
            mode: .load(headline: "Catálogo fora de alcance.", message: message),
            layout: .centered,
            symbol: "exclamationmark.triangle",
            topPadding: 0,
            accessibilityIdentifier: A11yID.autonomosLoadFailure,
            retryAccessibilityIdentifier: A11yID.autonomosRetry,
            retryHint: "tenta reabrir o catálogo Autônomos",
            spokenOverride: "Catálogo Autônomos fora de alcance. \(message)",
            onRetry: onRetry
        )
        .padding(32)
    }
}

extension AutonomosView {
    func autonomosLifecycleChrome<Content: View>(_ content: Content) -> some View {
        autonomosLifecycleScreenA11y(content)
    }
}

extension AutonomosView {
    func autonomosLifecycleScreenA11y<Content: View>(_ content: Content) -> some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            // children:.contain — NÃO colapsar o ecrã num único label; Nightly/
            // Ritmo/lista precisam de identifiers próprios na árvore a11y.
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.autonomosScreen)
            .task { await model.load() }
    }
}

extension AutonomosViewHeader {
    @ViewBuilder
    var titleBadges: some View {
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
}

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
        headerLayout
    }
}

