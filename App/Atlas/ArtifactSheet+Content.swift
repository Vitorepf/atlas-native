import SwiftUI
import AtlasCore

// Estados vazios + shell de conteúdo — peel de ArtifactSheet+Content.

extension ArtifactSheet {
    @ViewBuilder
    var content: some View {
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
        } else if hasDeliveryProof, !mountComplete {
            artifactMount
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 14)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("ARTEFATOS DO TURNO · \(artifacts?.workspaceLabel ?? "workspace")")
                    .font(AtlasFont.mono(10)).tracking(1.0)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.top, 14)
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        artifactList
                        previewPane
                    }
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}
