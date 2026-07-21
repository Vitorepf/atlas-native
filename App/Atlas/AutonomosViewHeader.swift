import SwiftUI
import AtlasCore

// WAVE-128 density peel

extension AutonomosViewHeader {
    func spokenTitle(isHealthy: Bool, auditModeEnabled: Bool) -> String {
        var parts = [title, subtitle]
        if auditModeEnabled { parts.append("modo auditoria") }
        return parts.joined(separator: ", ")
    }

    func spokenBackLabel() -> String { WorkspaceScreenJudgment.backLabel }

    func spokenBackHint() -> String { "volta" }
}

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
        .accessibilityLabel(AutonomosListJudgment.createCTA)
        .accessibilityHint("Cria um Autônomo com nome e carta")
        .accessibilityIdentifier(A11yID.autonomosNew)
    }
}

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

