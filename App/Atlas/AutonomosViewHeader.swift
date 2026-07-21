import SwiftUI

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
                .frame(width: 40, height: 40)
                .atlasGlassCircle()
        }
        .accessibilityLabel("voltar")
        .accessibilityHint("volta")
        .accessibilityIdentifier(A11yID.autonomosBack)
    }

    private var createButton: some View {
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

    private var refreshButton: some View {
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
        .accessibilityLabel(
            canRefresh
                ? "atualizar instância selecionada"
                : "atualizar indisponível, selecione uma instância"
        )
        .accessibilityHint(
            canRefresh ? "recarrega estado da área selecionada" : "nenhuma instância selecionada"
        )
        .accessibilityIdentifier(A11yID.autonomosRefresh)
    }

    private func spokenTitle() -> String {
        var parts = [title, subtitle]
        if auditModeEnabled { parts.append("modo auditoria") }
        return parts.joined(separator: ", ")
    }
}
