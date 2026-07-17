import SwiftUI
import AtlasCore

// Empty / unavailable — peel de ArtifactSheet+Content.

extension ArtifactSheet {
    @ViewBuilder
    var emptyOrUnavailable: some View {
        if !loadFinished, artifacts == nil {
            TraceEvidenceLoading(text: "consultando artefatos…", reduceMotion: reduceMotion)
        } else if loadFinished, artifacts == nil {
            TraceEvidenceUnavailable(
                title: "Não foi possível consultar artefatos.",
                subtitle: "feche e tente de novo — o motivo pode estar no aviso superior.",
                identifier: A11yID.artifactsLoadFailure,
                spoken: "não foi possível consultar artefatos"
            )
        } else if artifacts?.state == .unavailable {
            TraceEvidenceUnavailable(
                title: "Sem artefatos nesta execução.",
                subtitle: TraceEvidenceCopy.unavailableReason(artifacts?.reason),
                identifier: A11yID.artifactsUnavailable,
                spoken: TraceEvidenceCopy.unavailableSpoken(
                    prefix: "sem artefatos nesta execução",
                    reason: artifacts?.reason
                )
            )
        } else if items.isEmpty {
            Text("nenhum artefato visualizável")
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier(A11yID.artifactsEmpty)
                .accessibilityLabel("sem artefatos visualizáveis nesta execução")
        }
    }

    var showsEmptyOrUnavailable: Bool {
        (!loadFinished && artifacts == nil)
            || (loadFinished && artifacts == nil)
            || artifacts?.state == .unavailable
            || items.isEmpty
    }
}
