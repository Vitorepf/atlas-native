import SwiftUI
import AtlasCore

// WAVE-013 fused ArtifactSheet+Content.swift

// --- ArtifactSheet+Content.swift ---
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

// --- ArtifactSheet+ContentLoaded+Header.swift ---
extension ArtifactSheet {
    var loadedArtifactsHeader: some View {
        Text("ARTEFATOS DO TURNO · \(artifacts?.workspaceLabel ?? "workspace")")
            .font(AtlasFont.mono(10)).tracking(1.0)
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 14)
    }
}

// --- ArtifactSheet+ContentLoaded+Scroll.swift ---
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

// --- ArtifactSheet+ContentLoaded.swift ---
extension ArtifactSheet {
    var loadedArtifactsBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            loadedArtifactsHeader
            loadedArtifactsScroll
        }
    }
}

// --- ArtifactSheet+DeliveryCheck.swift ---
extension ArtifactDeliveryCheck {
    var isPassing: Bool {
        let s = status.lowercased()
        return s == "pass" || s == "passed"
    }

    var spoken: String { "\(label), status \(status)" }
}

// --- ArtifactSheet+DeliveryProof.swift ---
struct ArtifactDeliveryCheck: Identifiable, Equatable {
    let id: String
    let label: String
    let status: String
}

enum ArtifactDeliveryProof {
    /// Controles + testRuns publicados na revisão trace-scoped — vazio = silêncio na montagem.
    static func checks(from review: AtlasTraceChangeReview?) -> [ArtifactDeliveryCheck] {
        guard review?.state == .available, let review else { return [] }
        let controls = review.controls.map {
            ArtifactDeliveryCheck(id: "control-\($0.id)", label: $0.slug, status: $0.status)
        }
        let tests = review.testRuns.map {
            ArtifactDeliveryCheck(id: "test-\($0.id)", label: $0.command ?? "teste", status: $0.status)
        }
        return controls + tests
    }
}

// --- ArtifactSheet+Lifecycle+InitialTask.swift ---
extension ArtifactSheet {
    func artifactSheetInitialTask() async {
        await reviews.refreshChangeReview(traceId: traceId)
        loadFinished = true
        if hasDeliveryProof { await runMountAnimation() }
        else { mountRevealed = deliveryChecks.count }
    }
}

// --- ArtifactSheet+Lifecycle+PreviewTask.swift ---
extension ArtifactSheet {
    func artifactSheetPreviewTask(for item: AtlasTraceArtifacts.Item?) async {
        guard mountComplete, let item else { return }
        await load(item)
    }
}

// --- ArtifactSheet+Lifecycle+SelectionSync.swift ---
extension ArtifactSheet {
    func artifactSheetSyncSelection(ids: [String]) {
        if selectedID == nil || selectedID.map({ !ids.contains($0) }) == true {
            selectedID = ids.first
        }
    }
}

// --- ArtifactSheet+Lifecycle.swift ---
extension ArtifactSheet {
    func artifactSheetLifecycle<Content: View>(_ content: Content) -> some View {
        content
            .task { await artifactSheetInitialTask() }
            .onChange(of: items.map(\.id)) { _, ids in artifactSheetSyncSelection(ids: ids) }
            .task(id: selected?.id) { await artifactSheetPreviewTask(for: selected) }
    }
}

// --- ArtifactSheet+List.swift ---
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
        .accessibilityLabel("lista de artefatos, \(items.count) itens")
    }
}

// --- ArtifactSheet+ListRow.swift ---
extension ArtifactSheet {
    @ViewBuilder
    func artifactListRow(index: Int, item: AtlasTraceArtifacts.Item) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            selectedID = item.id
        } label: {
            artifactListRowLabel(item: item)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(A11yID.artifactsItem(index))
        .accessibilityLabel("\(item.name), \(ArtifactViewer.byteLabel(item.byteSize)), \(ArtifactViewer.kindLabel(item.kind))")
        .accessibilityAddTraits(item.id == selected?.id ? .isSelected : [])
        .accessibilityHint(item.id == selected?.id ? "selecionado no preview" : "abre o preview deste artefato")
    }
}

// --- ArtifactSheet+ListRowLabel+Leading.swift ---
extension ArtifactSheet {
    @ViewBuilder
    func artifactListRowLeading(item: AtlasTraceArtifacts.Item) -> some View {
        Text("▸")
            .font(AtlasFont.mono(11))
            .foregroundStyle(item.id == selected?.id ? AtlasTheme.accent : AtlasTheme.textTertiary)
            .accessibilityHidden(true)
        // Linha de lista fala em sans (canon §C: serif é masthead/título).
        Text(item.name)
            .atlasSans(15, .medium)
            .foregroundStyle(AtlasTheme.textPrimary)
            .lineLimit(1)
            .accessibilityHidden(true)
    }
}

// --- ArtifactSheet+ListRowLabel.swift ---
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

// --- ArtifactSheet+ListRowMeta.swift ---
extension ArtifactSheet {
    func artifactListRowMeta(item: AtlasTraceArtifacts.Item) -> some View {
        Text("\(ArtifactViewer.byteLabel(item.byteSize))  \(ArtifactViewer.kindLabel(item.kind))")
            .font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}

// --- ArtifactSheet+Mount.swift ---
extension ArtifactSheet {
    @ViewBuilder
    var artifactMount: some View {
        artifactMountStack
    }
}

// --- ArtifactSheet+MountAnimation.swift ---
extension ArtifactSheet {
    func runMountAnimation() async {
        guard hasDeliveryProof else {
            mountRevealed = deliveryChecks.count
            return
        }
        if reduceMotion {
            mountRevealed = deliveryChecks.count
            return
        }
        mountRevealed = 0
        for step in 1...deliveryChecks.count {
            try? await Task.sleep(nanoseconds: 280_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(AtlasMotion.editorial) { mountRevealed = step }
        }
    }
}

// --- ArtifactSheet+MountCheckRow+Texts.swift ---
extension ArtifactSheet {
    @ViewBuilder
    func mountCheckRowTexts(check: ArtifactDeliveryCheck) -> some View {
        Text(check.label)
            .font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textPrimary)
            .lineLimit(1)
            .accessibilityHidden(true)
        Spacer(minLength: 0)
        Text(check.status)
            .font(AtlasFont.mono(10))
            .foregroundStyle(check.isPassing ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
            .accessibilityHidden(true)
    }
}

// --- ArtifactSheet+MountCheckRow.swift ---
extension ArtifactSheet {
    func mountCheckRow(index: Int, check: ArtifactDeliveryCheck) -> some View {
        HStack(spacing: 8) {
            mountCheckRowTexts(check: check)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(check.spoken)
        .accessibilityIdentifier(A11yID.artifactsMountCheck(index))
        .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
    }
}

// --- ArtifactSheet+MountChecks.swift ---
extension ArtifactSheet {
    @ViewBuilder
    var mountChecks: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(deliveryChecks.enumerated()), id: \.element.id) { index, check in
                if index < mountRevealed {
                    mountCheckRow(index: index, check: check)
                }
            }
        }
    }
}

// --- ArtifactSheet+MountCounter+ProgressText.swift ---
extension ArtifactSheet {
    var mountCounterText: some View {
        HStack(spacing: 8) {
            Text("MONTAGEM")
                .font(AtlasFont.mono(10)).tracking(1.0)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text("·")
                .font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text("\(min(mountRevealed, deliveryChecks.count))/\(deliveryChecks.count)")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.accent)
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
        }
    }
}

// --- ArtifactSheet+MountCounter.swift ---
extension ArtifactSheet {
    var mountHeaderCounter: some View {
        HStack(spacing: 8) {
            mountCounterText
            if !mountComplete {
                BreathingDiamond(size: 8, reduceMotion: reduceMotion)
                    .accessibilityHidden(true)
            }
            Spacer(minLength: 0)
        }
    }
}

// --- ArtifactSheet+MountHeader.swift ---
extension ArtifactSheet {
    var mountHeader: some View {
        mountHeaderCounter
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(mountSpoken)
    }
}

// --- ArtifactSheet+MountPredicates.swift ---
extension ArtifactSheet {
    var changeReview: AtlasTraceChangeReview? { reviews.changeReviewsByTrace[traceId] }
    var deliveryChecks: [ArtifactDeliveryCheck] { ArtifactDeliveryProof.checks(from: changeReview) }
    var hasDeliveryProof: Bool { !deliveryChecks.isEmpty }
    var mountComplete: Bool { !hasDeliveryProof || mountRevealed >= deliveryChecks.count }
}

// --- ArtifactSheet+MountSpoken.swift ---
extension ArtifactSheet {
    var mountSpoken: String {
        let n = min(mountRevealed, deliveryChecks.count)
        let tail = mountComplete ? "entrega liberada" : "montando provas"
        return "montagem da entrega, prova \(n) de \(deliveryChecks.count), \(tail)"
    }
}

// --- ArtifactSheet+MountStack.swift ---
extension ArtifactSheet {
    var artifactMountStack: some View {
        VStack(alignment: .leading, spacing: 10) {
            mountHeader
            mountChecks
        }
        .padding(14)
        .atlasCard()
        .accessibilityIdentifier(A11yID.artifactsMount)
    }
}

// --- ArtifactSheet+Preview.swift ---
extension ArtifactSheet {
    @ViewBuilder
    var previewPane: some View {
        VStack(alignment: .leading, spacing: 10) {
            previewPaneStates
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .atlasCard()
    }
}

// --- ArtifactSheet+PreviewFailure.swift ---
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

// --- ArtifactSheet+PreviewLoad.swift ---
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

// --- ArtifactSheet+PreviewMessage.swift ---
extension ArtifactSheet {
    @ViewBuilder
    func previewMessageFailure(_ message: String) -> some View {
        Text(message)
            .font(AtlasFont.serifItalic(14))
            .foregroundStyle(AtlasTheme.domOperacional)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel("preview falhou, \(message)")
    }
}

// --- ArtifactSheet+PreviewStates+Busy+Loading.swift ---
extension ArtifactSheet {
    var previewPaneLoading: some View {
        TraceEvidenceLoading(text: "carregando preview…", reduceMotion: reduceMotion)
            .frame(maxWidth: .infinity, minHeight: 180)
    }
}

// --- ArtifactSheet+PreviewStates+Busy.swift ---
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

// --- ArtifactSheet+PreviewStates+Loaded.swift ---
extension ArtifactSheet {
    @ViewBuilder
    var previewPaneLoaded: some View {
        if case .loaded(let item, let content) = preview {
            ArtifactPreviewContent(item: item, content: content)
        }
    }
}

// --- ArtifactSheet+PreviewStates.swift ---
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

// --- ArtifactSheet+PreviewTooLarge.swift ---
extension ArtifactSheet {
    @ViewBuilder
    func previewTooLarge(bytes: Int) -> some View {
        ArtifactFileFicha(
            name: selected?.name ?? "artefato",
            subtitle: "grande demais para visualizar aqui · \(ArtifactViewer.byteLabel(bytes))"
        )
        .accessibilityLabel(
            ArtifactViewerA11y.spokenTooLarge(
                name: selected?.name ?? "artefato",
                bytes: bytes
            )
        )
    }
}

// --- ArtifactSheet+Selection.swift ---
extension ArtifactSheet {
    var artifacts: AtlasTraceArtifacts? { reviews.artifactsByTrace[traceId] }
    var items: [AtlasTraceArtifacts.Item] {
        guard artifacts?.state == .available else { return [] }
        return artifacts?.items ?? []
    }
    var selected: AtlasTraceArtifacts.Item? {
        items.first { $0.id == selectedID } ?? items.first
    }
}

// --- ArtifactSheet+Toast.swift ---
extension ArtifactSheet {
    @ViewBuilder var toast: some View {
        if let t = reviews.toast {
            Text(t)
                .font(AtlasFont.serifItalic(14)).foregroundStyle(AtlasTheme.textPrimary)
                .padding(.horizontal, 16).padding(.vertical, 9)
                .background(Capsule().fill(AtlasTheme.surfaceHi).overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
                .padding(.top, 8)
                .accessibilityLabel(ConversationViewA11y.spokenToast(t))
                .accessibilityAddTraits(.isStaticText)
                .task {
                    try? await Task.sleep(nanoseconds: 1_400_000_000)
                    if reduceMotion { reviews.toast = nil }
                    else { withAnimation(AtlasMotion.editorial) { reviews.toast = nil } }
                }
        }
    }
}

// --- ArtifactSheet+Unavailable.swift ---
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

