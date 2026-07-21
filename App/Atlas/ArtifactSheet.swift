import AtlasCore
import SwiftUI

// IDLE-COMPRESS fused

extension ArtifactSheet {
    func spokenArtifactsSheetAvailableLabel(_ artifacts: AtlasTraceArtifacts) -> String {
        // WAVE-041: face-aware spoken (not count-only).
        ArtifactJudgment.spokenSheet(
            artifacts: artifacts,
            deliveryChecks: deliveryChecks
        )
    }
}

extension ArtifactSheet {
    func spokenArtifactsSheetLoadLabel() -> String? {
        if !loadFinished, artifacts == nil {
            return "artefatos da execução, consultando"
        }
        if loadFinished, artifacts == nil {
            return "artefatos da execução, indisponível"
        }
        return nil
    }
}

extension ArtifactSheet {
    func spokenArtifactsSheetLabel() -> String {
        if let load = spokenArtifactsSheetLoadLabel() { return load }
        guard let artifacts else { return "artefatos da execução" }
        return spokenArtifactsSheetAvailableLabel(artifacts)
    }
}

extension ArtifactSheet {
    func artifactSheetA11y<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityIdentifier(A11yID.artifactsSheet)
            .accessibilityLabel(spokenArtifactsSheetLabel())
            .accessibilityHint(ArtifactListJudgment.sheetHint)
    }
}

extension ArtifactSheet {
    func artifactSheetToolbar<Content: View>(_ content: Content) -> some View {
        content
            .navigationTitle("Artefatos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    AtlasCloseToolbarButton(
                        spokenLabel: ArtifactListJudgment.closeLabel,
                        spokenHint: ArtifactListJudgment.closeHint,
                        reduceMotion: reduceMotion
                    ) { dismiss() }
                }
            }
            .overlay(alignment: .top) { toast }
    }
}

extension ArtifactSheet {
    func artifactSheetChrome<Content: View>(_ content: Content) -> some View {
        artifactSheetA11y(artifactSheetToolbar(content))
    }
}

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
                spoken: ArtifactListJudgment.loadFailSpoken
            )
        } else {
            artifactsUnavailable
        }
    }
}

extension ArtifactSheet {
    var showsEmptyOrUnavailable: Bool {
        (!loadFinished && artifacts == nil)
            || (loadFinished && artifacts == nil)
            || artifacts?.state == .unavailable
            || items.isEmpty
    }
}

extension ArtifactSheet {
    @ViewBuilder
    var emptyVisualizable: some View {
        Text(ArtifactListJudgment.emptyVisualizableCopy)
            .font(AtlasFont.serifItalic(15))
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityIdentifier(A11yID.artifactsEmpty)
            .accessibilityLabel(ArtifactListJudgment.spokenEmptyVisualizable())
            .accessibilityValue(ArtifactListFace.silence.productWord)
    }
}

extension ArtifactSheet {
    var artifactNavigationShell: some View {
        NavigationStack {
            artifactSheetChrome(
                ZStack {
                    AtlasTheme.bg.ignoresSafeArea()
                    content
                }
            )
        }
    }
}

struct ArtifactSheet: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID

    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var selectedID: String?
    @State var preview: ArtifactPreviewState = .idle
    @State var loadFinished = false
    @State var mountRevealed = 0

    var body: some View {
        artifactSheetLifecycle(artifactNavigationShell)
    }
}

extension ArtifactSheet {
    @ViewBuilder
    var content: some View {
        if showsEmptyOrUnavailable {
            emptyOrUnavailable
        } else if hasDeliveryProof, !mountComplete {
            artifactMount
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 14)
        } else {
            loadedArtifactsBody
        }
    }
}

extension ArtifactSheet {
    var loadedArtifactsHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ARTEFATOS DO TURNO · \(artifacts?.workspaceLabel ?? "workspace")")
                .font(AtlasFont.mono(10)).tracking(1.0)
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 14)
            ArtifactFaceStrip(
                artifacts: artifacts,
                deliveryChecks: deliveryChecks
            )
        }
    }
}

extension ArtifactSheet {
    var loadedArtifactsScroll: some View {
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

extension ArtifactSheet {
    var loadedArtifactsBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            loadedArtifactsHeader
            loadedArtifactsScroll
        }
    }
}


extension ArtifactSheet {
    func artifactSheetInitialTask() async {
        await reviews.refreshChangeReview(traceId: traceId)
        loadFinished = true
        if hasDeliveryProof { await runMountAnimation() }
        else { mountRevealed = deliveryChecks.count }
    }
}

extension ArtifactSheet {
    func artifactSheetPreviewTask(for item: AtlasTraceArtifacts.Item?) async {
        guard mountComplete, let item else { return }
        await load(item)
    }
}

extension ArtifactSheet {
    func artifactSheetSyncSelection(ids: [String]) {
        if selectedID == nil || selectedID.map({ !ids.contains($0) }) == true {
            selectedID = ids.first
        }
    }
}

extension ArtifactSheet {
    func artifactSheetLifecycle<Content: View>(_ content: Content) -> some View {
        content
            .task { await artifactSheetInitialTask() }
            .onChange(of: items.map(\.id)) { _, ids in artifactSheetSyncSelection(ids: ids) }
            .task(id: selected?.id) { await artifactSheetPreviewTask(for: selected) }
    }
}

extension ArtifactSheet {
    var artifactList: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                artifactListRow(index: index, item: item)
                if index < items.count - 1 {
                    Divider().overlay(AtlasTheme.separatorSoft)
                        .accessibilityHidden(true)
                }
            }
        }
        .padding(.horizontal, 12)
        .atlasCard()
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ArtifactListJudgment.spokenList(itemCount: items.count))
        .accessibilityValue(ArtifactListJudgment.listFace(itemCount: items.count).productWord)
    }
}

extension ArtifactSheet {
    @ViewBuilder
    func artifactListRow(index: Int, item: AtlasTraceArtifacts.Item) -> some View {
        let selected = item.id == selected?.id
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            selectedID = item.id
        } label: {
            artifactListRowLabel(item: item)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(A11yID.artifactsItem(index))
        .accessibilityLabel(ArtifactListJudgment.spokenRow(item: item, selected: selected))
        .accessibilityAddTraits(selected ? .isSelected : [])
        .accessibilityHint(ArtifactListJudgment.rowHint(selected: selected))
    }
}

extension ArtifactSheet {
    @ViewBuilder
    func artifactListRowLeading(item: AtlasTraceArtifacts.Item) -> some View {
        Text("▸")
            .font(AtlasFont.mono(11))
            .foregroundStyle(item.id == selected?.id ? AtlasTheme.accent : AtlasTheme.textTertiary)
            .accessibilityHidden(true)
        Text(item.name)
            .atlasSans(15, .medium)
            .foregroundStyle(AtlasTheme.textPrimary)
            .lineLimit(1)
            .accessibilityHidden(true)
    }
}

extension ArtifactSheet {
    func artifactListRowLabel(item: AtlasTraceArtifacts.Item) -> some View {
        HStack(spacing: 10) {
            artifactListRowLeading(item: item)
            Spacer()
            artifactListRowMeta(item: item)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

extension ArtifactSheet {
    func artifactListRowMeta(item: AtlasTraceArtifacts.Item) -> some View {
        Text("\(ArtifactViewer.byteLabel(item.byteSize))  \(ArtifactViewer.kindLabel(item.kind))")
            .font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}


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
