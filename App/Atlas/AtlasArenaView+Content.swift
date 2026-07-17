import SwiftUI
import AtlasCore

// Conteúdo carregado da Arena — peel de AtlasArenaView (régua ≤110).

extension AtlasArenaView {
    @ViewBuilder
    var content: some View {
        switch model.phase {
        case .idle where model.composite == nil,
             .loading where model.composite == nil:
            loadingCard
        case .failed where model.composite == nil:
            if model.isDomainUnavailable {
                stateCard(ArenaModel.domainUnavailableCopy)
            } else {
                networkFailureCard
            }
        default:
            if let composite = model.composite {
                ArenaNowSection(liveRuns: model.liveRuns, reduceMotion: reduceMotion)
                ArenaIndexSection(
                    composite: composite,
                    reduceMotion: reduceMotion,
                    onEngineTap: { selectedEngine = $0 }
                )
                    .accessibilityIdentifier(A11yID.arenaIndexSection)
                ArenaCapabilitiesSection(capabilities: model.capabilities)
                if let scoreboard = model.scoreboard, !scoreboard.suites.isEmpty {
                    ArenaSuitesSection(
                        scoreboard: scoreboard,
                        onSuiteTap: { selectedSuite = $0 }
                    )
                }
                Button {
                    showingRunSheet = true
                } label: {
                    Label("Rodar medição", systemImage: "play.fill")
                        .font(.system(.body, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(AtlasTheme.goldVeil))
                        .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityIdentifier(A11yID.arenaRunButton)
            } else {
                stateCard(ArenaModel.domainUnavailableCopy)
            }
        }
    }
}
