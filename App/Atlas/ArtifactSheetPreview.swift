import AtlasCore
import SwiftUI

// WAVE-112 preview pane peels

extension ArtifactSheet {
    /// WAVE-058: exclusive preview face.
    var previewFace: ArtifactPreviewFace {
        ArtifactPreviewJudgment.face(preview, selectedName: selected?.name)
    }

    @ViewBuilder
    var previewPane: some View {
        VStack(alignment: .leading, spacing: 10) {
            previewPaneStates
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .atlasCard()
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            ArtifactPreviewJudgment.spokenPane(preview, selectedName: selected?.name)
        )
        .accessibilityValue(previewFace.productWord)
    }
}

extension ArtifactSheet {
    @ViewBuilder
    func previewPaneFailure(bytes: Int? = nil, message: String? = nil) -> some View {
        if let bytes {
            previewTooLarge(bytes: bytes)
        } else if let message {
            previewMessageFailure(message)
        }
    }
}

extension ArtifactSheet {
    func load(_ item: AtlasTraceArtifacts.Item) async {
        preview = .loading
        do {
            let content = try await reviews.loadArtifactContent(traceId: traceId, item: item)
            preview = .loaded(item, content)
        } catch let api as AtlasApiError where api.status == 413 {
            preview = .tooLarge(item.byteSize)
        } catch {
            preview = .failed(atlasUserMessage(for: error))
        }
    }
}

extension ArtifactSheet {
    @ViewBuilder
    func previewMessageFailure(_ message: String) -> some View {
        Text(message)
            .font(AtlasFont.serifItalic(14))
            .foregroundStyle(AtlasTheme.domOperacional)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel(
                ArtifactPreviewJudgment.face(
                    .failed(message),
                    selectedName: selected?.name
                ).spokenFace
            )
    }
}

extension ArtifactSheet {
    var previewPaneLoading: some View {
        TraceEvidenceLoading(text: "carregando preview…", reduceMotion: reduceMotion)
            .frame(maxWidth: .infinity, minHeight: 180)
    }
}

extension ArtifactSheet {
    @ViewBuilder
    var previewPaneBusyOrFailed: some View {
        switch preview {
        case .idle, .loading:
            previewPaneLoading
        case .tooLarge(let bytes):
            previewPaneFailure(bytes: bytes)
        case .failed(let message):
            previewPaneFailure(message: message)
        default:
            EmptyView()
        }
    }
}

extension ArtifactSheet {
    @ViewBuilder
    var previewPaneLoaded: some View {
        if case .loaded(let item, let content) = preview {
            ArtifactPreviewContent(item: item, content: content)
        }
    }
}

extension ArtifactSheet {
    @ViewBuilder
    var previewPaneStates: some View {
        switch preview {
        case .idle, .loading, .tooLarge, .failed:
            previewPaneBusyOrFailed
        case .loaded:
            previewPaneLoaded
        }
    }
}

extension ArtifactSheet {
    @ViewBuilder
    func previewTooLarge(bytes: Int) -> some View {
        ArtifactFileFicha(
            name: selected?.name ?? "artefato",
            subtitle: "grande demais para visualizar aqui · \(ArtifactViewer.byteLabel(bytes))"
        )
        .accessibilityLabel(
            ArtifactPreviewJudgment.face(
                .tooLarge(bytes),
                selectedName: selected?.name
            ).spokenFace
        )
    }
}

extension ArtifactSheet {
    var artifacts: AtlasTraceArtifacts? { reviews.artifactsByTrace[traceId] }
    /// WAVE-041: kind-attention rank (image/diff first); selection by id.
    var items: [AtlasTraceArtifacts.Item] {
        guard artifacts?.state == .available else { return [] }
        return ArtifactListJudgment.rankItems(artifacts?.items ?? [])
    }
    var selected: AtlasTraceArtifacts.Item? {
        items.first { $0.id == selectedID } ?? items.first
    }
}

extension ArtifactSheet {
    @ViewBuilder var toast: some View {
        if let t = reviews.toast {
            Text(t)
                .font(AtlasFont.serifItalic(14)).foregroundStyle(AtlasTheme.textPrimary)
                .padding(.horizontal, 16).padding(.vertical, 9)
                .background(Capsule().fill(AtlasTheme.surfaceHi).overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
                .padding(.top, 8)
                .accessibilityLabel(ConversationMessagesJudgment.spokenToast(t))
                .accessibilityAddTraits(.isStaticText)
                .task {
                    try? await Task.sleep(nanoseconds: 1_400_000_000)
                    if reduceMotion { reviews.toast = nil }
                    else { withAnimation(AtlasMotion.editorial) { reviews.toast = nil } }
                }
        }
    }
}

extension ArtifactSheet {
    @ViewBuilder
    var artifactsUnavailable: some View {
        if artifacts?.state == .unavailable {
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
            emptyVisualizable
        }
    }
}
