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

// MARK: - Face strip

// MARK: - Artifact face strip (WAVE-041)

/// Thin exclusive evidence face for Artefatos sheet.
struct ArtifactFaceStrip: View {
    let artifacts: AtlasTraceArtifacts?
    let deliveryChecks: [ArtifactDeliveryCheck]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var face: ArtifactEvidenceFace {
        ArtifactJudgment.face(artifacts: artifacts, deliveryChecks: deliveryChecks)
    }

    var body: some View {
        switch face {
        case .absent:
            EmptyView()
        case .unavailable, .empty, .ready, .deliveryPressure:
            stripChrome
        }
    }

    private var stripChrome: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Circle()
                .fill(dotColor)
                .frame(width: 7, height: 7)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(face.kicker)
                    .font(AtlasFont.mono(9))
                    .tracking(0.7)
                    .foregroundStyle(titleColor)
                Text(ArtifactJudgment.summaryLine(
                    artifacts: artifacts,
                    deliveryChecks: deliveryChecks
                ))
                .font(AtlasFont.serif(12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(face.spokenFace)
        .accessibilityIdentifier(A11yID.artifactsFace)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: face.productWord)
    }

    private var dotColor: Color {
        switch face {
        case .deliveryPressure: return AtlasTheme.domOperacional
        case .ready: return AtlasTheme.domAutonomos
        case .empty, .unavailable: return AtlasTheme.textTertiary
        case .absent: return AtlasTheme.textTertiary
        }
    }

    private var titleColor: Color {
        switch face {
        case .deliveryPressure: return AtlasTheme.domOperacional
        case .ready: return AtlasTheme.domAutonomos
        case .empty, .unavailable, .absent: return AtlasTheme.textTertiary
        }
    }
}

// MARK: - ArtifactSheetDelivery

extension ArtifactDeliveryCheck {
    var isPassing: Bool {
        let s = status.lowercased()
        return s == "pass" || s == "passed"
    }

    var spoken: String { "\(label), status \(status)" }
}

struct ArtifactDeliveryCheck: Identifiable, Equatable {
    let id: String
    let label: String
    let status: String
}

enum ArtifactDeliveryProof {
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

extension ArtifactSheet {
    @ViewBuilder
    var artifactMount: some View {
        artifactMountStack
    }
}

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

extension ArtifactSheet {
    var mountHeader: some View {
        mountHeaderCounter
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(mountSpoken)
    }
}

extension ArtifactSheet {
    var changeReview: AtlasTraceChangeReview? { reviews.changeReviewsByTrace[traceId] }
    /// WAVE-041: fail-first delivery proof order.
    var deliveryChecks: [ArtifactDeliveryCheck] {
        ArtifactJudgment.rankDeliveryChecks(
            ArtifactDeliveryProof.checks(from: changeReview)
        )
    }
    var hasDeliveryProof: Bool { !deliveryChecks.isEmpty }
    var mountComplete: Bool { !hasDeliveryProof || mountRevealed >= deliveryChecks.count }
}

extension ArtifactSheet {
    var mountSpoken: String {
        let n = min(mountRevealed, deliveryChecks.count)
        let tail = mountComplete ? "entrega liberada" : "montando provas"
        return "montagem da entrega, prova \(n) de \(deliveryChecks.count), \(tail)"
    }
}

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

// MARK: - ArtifactSheetPreview

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
