import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: ArtifactSheet + viewer/preview peels fused

// MARK: - ArtifactSheet

// MARK: - Host

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

// MARK: - Sections

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

// MARK: - ArtifactSheetChrome

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
// MARK: - ArtifactViewer

enum ArtifactViewer {}
// MARK: - ArtifactPreviewState

enum ArtifactPreviewState {
    case idle
    case loading
    case loaded(AtlasTraceArtifacts.Item, AtlasArtifactContent)
    case tooLarge(Int)
    case failed(String)
}
// MARK: - ArtifactFileFicha

extension ArtifactFileFicha {
    func fichaA11yBind<Content: View>(_ content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(ArtifactPreviewJudgment.spokenFicha(name: name, subtitle: subtitle))
    }
}

extension ArtifactFileFicha {
    var fichaNameStack: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(name)
                .font(AtlasFont.serif(17, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(subtitle)
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}

struct ArtifactFileFicha: View {
    let name: String
    let subtitle: String

    var body: some View {
        fichaA11yBind(fichaNameStack)
    }
}
// MARK: - ArtifactPreviewZoom

struct ZoomableArtifactImage: View {
    let image: UIImage
    let name: String
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var scale: CGFloat = 1
    @State var lastScale: CGFloat = 1
    @State var offset: CGSize = .zero
    @State var lastOffset: CGSize = .zero

    var body: some View {
        applyZoomAccessibility(zoomImageCore)
    }
}

extension ZoomableArtifactImage {
    func applyZoomAccessibility<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityLabel(ArtifactPreviewJudgment.spokenZoomImage(name: name, scale: scale))
            .accessibilityHint(ArtifactPreviewJudgment.zoomHint)
            .accessibilityIdentifier(A11yID.artifactsZoomImage)
            .accessibilityZoomAction { action in
                switch action.direction {
                case .zoomIn:
                    setScale(scale + 0.5)
                case .zoomOut:
                    setScale(scale - 0.5)
                @unknown default:
                    break
                }
            }
            .accessibilityAction(named: ArtifactPreviewJudgment.zoomResetAction) { resetZoom() }
    }
}

extension ZoomableArtifactImage {
    func clamped(_ value: CGFloat) -> CGFloat {
        min(4, max(1, value))
    }
}

extension ZoomableArtifactImage {
    var zoomImageCore: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .scaleEffect(scale)
            .offset(offset)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
            .contentShape(Rectangle())
            .gesture(zoomGesture.simultaneously(with: dragGesture))
            .onTapGesture(count: 2) { resetZoom() }
            .animation(reduceMotion ? nil : .easeOut(duration: AtlasMotion.instinct), value: scale)
            .animation(reduceMotion ? nil : .easeOut(duration: AtlasMotion.instinct), value: offset)
    }
}

extension ZoomableArtifactImage {
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale > 1 else { return }
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }
}

extension ZoomableArtifactImage {
    var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = clamped(lastScale * value)
            }
            .onEnded { _ in
                lastScale = scale
                if scale <= 1 { resetOffset() }
            }
    }
}

extension ZoomableArtifactImage {
    func resetOffset() {
        offset = .zero
        lastOffset = .zero
    }
}

extension ZoomableArtifactImage {
    func resetZoom() {
        scale = 1
        lastScale = 1
        resetOffset()
    }
}

extension ZoomableArtifactImage {
    func setScale(_ value: CGFloat) {
        scale = clamped(value)
        lastScale = scale
        if scale <= 1 { resetOffset() }
    }
}
