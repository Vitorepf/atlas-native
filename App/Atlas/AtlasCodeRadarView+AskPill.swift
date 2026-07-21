import AtlasCore
import SwiftUI

// Dock da pílula no Radar — peel de AtlasCodeRadarView (WAVE-001).

extension AtlasCodeRadarView {
    var askPillDock: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg.opacity(0.92), AtlasTheme.bg],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 28)
            .allowsHitTesting(false)
            AgenticPill(
                invite: AtlasCodeRadarAskContext.invite,
                accessibilityId: A11yID.radarAskPill,
                accessibilityHintText: "Abre conversa com o contexto do workspace"
            ) {
                askDraft = ""
                showingAsk = true
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.bottom, 10)
        }
        .background(AtlasTheme.bg.opacity(0.01))
    }

    var askConversationSheet: some View {
        ConversationView(
            client: session.client,
            threadId: askThreadId,
            title: "Código · workspace",
            emptyPrompt: AtlasCodeRadarAskContext.emptyPrompt(headline: model.headline),
            emptySuggestions: AtlasCodeRadarAskContext.emptySuggestions,
            taskKind: "code",
            workspace: nil,
            draft: askDraft,
            turnFacts: { [model] _ in
                AtlasCodeRadarAskContext.facts(model: model)
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
