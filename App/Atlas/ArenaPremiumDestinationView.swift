import SwiftUI
import AtlasCore

struct ArenaPremiumDestinationView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(AtlasSession.self) private var session
    let target: ArenaPremiumDestination
    @Bindable var model: ArenaModel
    let onStop: (AtlasArenaLiveRun) -> Void
    let onSuite: (AtlasArenaSuite) -> Void
    @State private var showingAsk = false
    @State private var askThreadId: ThreadID?
    @State private var askDraft = ""

    var body: some View {
        ScrollView {
            destinationContent
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 18)
                .padding(.bottom, 108)
        }
        .scrollIndicators(.hidden)
        .background(AtlasTheme.bg.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg.opacity(0.92), AtlasTheme.bg],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 28)
                .allowsHitTesting(false)
                ArenaPremiumAskPill(
                    invite: ArenaPremiumAskContext.invite(tab: .now, destination: target)
                ) {
                    askDraft = ""
                    showingAsk = true
                }
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.bottom, 10)
            }
        }
        .sheet(isPresented: $showingAsk) {
            ConversationView(
                client: session.client,
                threadId: askThreadId,
                title: "Arena · \(title)",
                emptyPrompt: ArenaPremiumAskContext.invite(tab: .now, destination: target),
                emptySuggestions: ArenaPremiumAskContext.emptySuggestions(tab: .now),
                taskKind: "arena",
                workspace: nil,
                draft: askDraft,
                turnFacts: { [model] _ in
                    ArenaPremiumAskContext.facts(model: model, tab: .now)
                },
                onThread: { askThreadId = $0 },
                hidesNavigationBack: true
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .presentationBackground(AtlasTheme.bg)
            .presentationCornerRadius(28)
        }
    }

    @ViewBuilder
    private var destinationContent: some View {
        switch target {
        case .execution:
            ArenaPremiumExecutionView(model: model, onStop: onStop)
        case .plan:
            ArenaPremiumPlanView(model: model)
        case .queue:
            ArenaPremiumQueueView(model: model)
        case .alerts:
            ArenaPremiumAlertsView(model: model, onSuite: onSuite)
        case .results:
            ArenaPremiumResultsView(
                model: model,
                reduceMotion: reduceMotion,
                onSuite: onSuite
            )
        }
    }

    private var title: String {
        switch target {
        case .execution: "Execução"
        case .plan: "Plano"
        case .queue: "Fila"
        case .alerts: "Alertas"
        case .results: "Motor"
        }
    }
}
