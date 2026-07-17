import SwiftUI
import AtlasCore

// Estados vazio/erro/carregando — peel de AtlasArenaView (régua ~160).
// Failure/exception → AtlasArenaView+Failure.swift

extension AtlasArenaView {
    var loadingCard: some View {
        TraceEvidenceLoading(text: "carregando índice medido…", reduceMotion: reduceMotion)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .atlasCard()
    }

    func stateCard(_ message: String) -> some View {
        Text(message)
            .font(.system(.subheadline))
            .foregroundStyle(AtlasTheme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .atlasCard()
            .accessibilityLabel(message)
    }

    var domainUnavailableCard: some View {
        Text(ArenaModel.domainUnavailableCopy)
            .font(.system(.subheadline))
            .foregroundStyle(AtlasTheme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .atlasCard()
            .accessibilityElement(children: .combine)
            .accessibilityLabel(domainUnavailableSpoken)
            .accessibilityHint(domainUnavailableHint)
    }
}
