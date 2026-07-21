import AtlasCore
import Foundation
import SwiftUI
import UIKit

// Cycle 044 fuse → ArtifactSheet.swift

enum ArtifactPreviewState {
    case idle
    case loading
    case loaded(AtlasTraceArtifacts.Item, AtlasArtifactContent)
    case tooLarge(Int)
    case failed(String)
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

extension ArtifactSheet {
    func artifactSheetA11y<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityIdentifier(A11yID.artifactsSheet)
            // Contain without fused sheet label so list/preview stay focusable.
            .accessibilityElement(children: .contain)
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
                        spokenLabel: "fechar artefatos",
                        spokenHint: "volta para a conversa",
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
    var artifacts: AtlasTraceArtifacts? { reviews.artifactsByTrace[traceId] }
    var items: [AtlasTraceArtifacts.Item] {
        guard artifacts?.state == .available else { return [] }
        return artifacts?.items ?? []
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
        Text("ARTEFATOS DO TURNO · \(artifacts?.workspaceLabel ?? "workspace")")
            .font(AtlasFont.mono(10)).tracking(1.0)
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 14)
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
        // Contain without fused label: each file row stays a button.
        .accessibilityElement(children: .contain)
    }
}

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
        .accessibilityAddTraits(item.id == selected?.id ? [.isButton, .isSelected] : .isButton)
        .accessibilityHint(item.id == selected?.id ? "selecionado no preview" : "abre o preview deste artefato")
    }
}

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

extension ArtifactSheet {
    func artifactListRowLabel(item: AtlasTraceArtifacts.Item) -> some View {
        HStack(spacing: 10) {
            artifactListRowLeading(item: item)
            Spacer()
            artifactListRowMeta(item: item)
        }
        .padding(.vertical, 10)
        .frame(minHeight: 48)
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
        Text("nenhum artefato visualizável")
            .font(AtlasFont.serifItalic(15))
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityIdentifier(A11yID.artifactsEmpty)
            .accessibilityLabel("sem artefatos visualizáveis nesta execução")
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
            .accessibilityLabel("preview falhou, \(message)")
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
            ArtifactViewerA11y.spokenTooLarge(
                name: selected?.name ?? "artefato",
                bytes: bytes
            )
        )
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
    var mountSpoken: String {
        let n = min(mountRevealed, deliveryChecks.count)
        let tail = mountComplete ? "entrega liberada" : "montando provas"
        return "montagem da entrega, prova \(n) de \(deliveryChecks.count), \(tail)"
    }
}

// Montagem animada da entrega — só quando o contrato publica provas reais.

extension ArtifactSheet {
    @ViewBuilder
    var artifactMount: some View {
        artifactMountStack
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
    var deliveryChecks: [ArtifactDeliveryCheck] { ArtifactDeliveryProof.checks(from: changeReview) }
    var hasDeliveryProof: Bool { !deliveryChecks.isEmpty }
    var mountComplete: Bool { !hasDeliveryProof || mountRevealed >= deliveryChecks.count }
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

extension ArtifactDeliveryCheck {
    var isPassing: Bool {
        let s = status.lowercased()
        return s == "pass" || s == "passed"
    }

    var spoken: String { "\(label), status \(status)" }
}

// Provas de montagem — só controles/testes reais do contrato C15 (nunca inventa 0/3).

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


// Cycle 044 fuse → ArtifactViewer.swift

// Preview helpers do ArtifactSheet — fora do shell para a régua (~160).

enum ArtifactViewer {}

extension ArtifactViewer {
    static func byteLabel(_ bytes: Int) -> String {
        if bytes < 1_024 { return "\(bytes) B" }
        if bytes < 1_048_576 { return "\(max(1, bytes / 1_024)) KB" }
        let mb = Double(bytes) / 1_048_576
        return String(format: "%.1f MB", mb).replacingOccurrences(of: ".", with: ",")
    }
}

extension ArtifactViewer {
    static func kindLabelImageMarkdown(_ kind: AtlasTraceArtifacts.Item.Kind) -> String? {
        switch kind {
        case .image: return "imagem"
        case .markdown: return "markdown"
        default: return nil
        }
    }
}

extension ArtifactViewer {
    static func kindLabelDocument(_ kind: AtlasTraceArtifacts.Item.Kind) -> String? {
        if let imageMd = kindLabelImageMarkdown(kind) { return imageMd }
        switch kind {
        case .text: return "texto"
        case .diff: return "diff"
        default: return nil
        }
    }
}

extension ArtifactViewer {
    static func kindLabel(_ kind: AtlasTraceArtifacts.Item.Kind) -> String {
        kindLabelDocument(kind) ?? "arquivo"
    }
}

struct ArtifactPreviewContent: View {
    let item: AtlasTraceArtifacts.Item
    let content: AtlasArtifactContent

    var body: some View {
        Group { previewSwitch }
    }
}

extension ArtifactPreviewContent {
    var imageDecodeFailure: some View {
        ArtifactFileFicha(
            name: item.name,
            subtitle: "imagem não pôde ser decodificada · \(ArtifactViewer.byteLabel(item.byteSize))"
        )
        .accessibilityLabel(
            ArtifactViewerA11y.spokenDecodeFailure(name: item.name, bytes: item.byteSize)
        )
    }
}

extension ArtifactPreviewContent {
    @ViewBuilder
    var imagePreviewBranch: some View {
        if let image = UIImage(data: content.data) {
            ZoomableArtifactImage(image: image, name: item.name)
        } else {
            imageDecodeFailure
        }
    }
}

extension ArtifactPreviewContent {
    @ViewBuilder
    var previewSwitch: some View {
        switch item.kind {
        case .image:
            imagePreviewBranch
        default:
            textishPreview
        }
    }
}

extension ArtifactPreviewContent {
    @ViewBuilder
    var diffPreview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(String(decoding: content.data, as: UTF8.self))
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
                .textSelection(.enabled)
        }
        .frame(maxHeight: 360)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ArtifactViewerA11y.spokenPreview(item: item))
        .accessibilityHint("arraste horizontalmente para ler o diff")
    }
}

extension ArtifactPreviewContent {
    @ViewBuilder
    var textishDocumentPreview: some View {
        switch item.kind {
        case .markdown, .text:
            textishMarkdownPreview(content.data)
        case .diff:
            diffPreview
        default:
            EmptyView()
        }
    }
}

extension ArtifactPreviewContent {
    @ViewBuilder
    var textishFilePreview: some View {
        ArtifactFileFicha(
            name: item.name,
            subtitle: "\(ArtifactViewer.byteLabel(item.byteSize)) · sha \(String(item.sha256.prefix(12)))"
        )
    }
}

extension ArtifactPreviewContent {
    @ViewBuilder
    func textishMarkdownPreview(_ content: Data) -> some View {
        AtlasMarkdownView(text: String(decoding: content, as: UTF8.self), streaming: false)
    }
}

extension ArtifactPreviewContent {
    @ViewBuilder
    var textishPreview: some View {
        switch item.kind {
        case .markdown, .text, .diff:
            textishDocumentPreview
        case .file:
            textishFilePreview
        default:
            EmptyView()
        }
    }
}

/// Sem inventar dimensões; sha só quando o contrato publica.

enum ArtifactViewerA11y {
    static func spokenFicha(name: String, subtitle: String) -> String {
        "\(name), \(subtitle)"
    }
}

extension ArtifactViewerA11y {
    static func spokenDecodeFailure(name: String, bytes: Int) -> String {
        "imagem \(name) não pôde ser decodificada, \(ArtifactViewer.byteLabel(bytes))"
    }
}

extension ArtifactViewerA11y {
    static func spokenPreviewImageMarkdown(item: AtlasTraceArtifacts.Item, size: String) -> String? {
        switch item.kind {
        case .image:
            return "preview de imagem \(item.name), \(size)"
        case .markdown:
            return "preview markdown \(item.name), \(size)"
        default:
            return nil
        }
    }
}

extension ArtifactViewerA11y {
    static func spokenPreviewDocument(item: AtlasTraceArtifacts.Item, size: String) -> String? {
        if let imageMd = spokenPreviewImageMarkdown(item: item, size: size) { return imageMd }
        switch item.kind {
        case .text:
            return "preview de texto \(item.name), \(size)"
        case .diff:
            return "preview de diff \(item.name), \(size)"
        default:
            return nil
        }
    }
}

extension ArtifactViewerA11y {
    static func spokenPreviewFile(item: AtlasTraceArtifacts.Item, kind: String, size: String) -> String {
        let sha = String(item.sha256.prefix(12))
        return "arquivo \(item.name), \(kind), \(size), sha \(sha)"
    }
}

extension ArtifactViewerA11y {
    static func spokenPreview(item: AtlasTraceArtifacts.Item) -> String {
        let kind = ArtifactViewer.kindLabel(item.kind)
        let size = ArtifactViewer.byteLabel(item.byteSize)
        return spokenPreviewDocument(item: item, size: size)
            ?? spokenPreviewFile(item: item, kind: kind, size: size)
    }
}

extension ArtifactViewerA11y {
    static func spokenTooLarge(name: String, bytes: Int) -> String {
        "\(name), grande demais para visualizar aqui, \(ArtifactViewer.byteLabel(bytes))"
    }
}

extension TraceEvidenceUnavailable {
    @ViewBuilder
    var unavailableIconTitle: some View {
        Image(systemName: systemImage)
            .font(.title2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
        Text(title)
            .font(AtlasFont.serif(18, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .multilineTextAlignment(.center)
            .accessibilityHidden(true)
    }
}

extension TraceEvidenceUnavailable {
    @ViewBuilder
    var unavailableSubtitle: some View {
        if let subtitle, !subtitle.isEmpty {
            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
        }
    }
}

extension TraceEvidenceUnavailable {
    var unavailableStack: some View {
        VStack(spacing: 12) {
            unavailableIconTitle
            unavailableSubtitle
        }
    }
}

extension TraceEvidenceCopy {
    static func knownMissingRunReason(_ reason: String) -> String? {
        switch reason {
        case "no_workspace": return "sem workspace ligado a esta execução"
        case "no_run": return "nenhum run de engenharia vinculado"
        default: return nil
        }
    }
}

extension TraceEvidenceCopy {
    static func knownUnavailableReason(_ reason: String) -> String? {
        if let missing = knownMissingRunReason(reason) { return missing }
        switch reason {
        case "multiple_runs": return "mais de um run — evidência indisponível"
        case "ambiguous_linked_runs": return "vínculo ambíguo entre runs"
        default: return nil
        }
    }
}

/// Copy editorial para `reason` do contrato trace-scoped — nunca inventa motivo.
enum TraceEvidenceCopy {
    static func unavailableReason(_ reason: String?) -> String? {
        guard let reason, !reason.isEmpty else { return nil }
        return knownUnavailableReason(reason)
            ?? reason.replacingOccurrences(of: "_", with: " ")
    }

    static func unavailableSpoken(prefix: String, reason: String?) -> String {
        var parts = [prefix]
        if let reason = unavailableReason(reason) { parts.append(reason) }
        return parts.joined(separator: ", ")
    }
}

/// Empty/unavailable compartilhado por ArtifactSheet e ChangeReviewSheet.

struct TraceEvidenceUnavailable: View {
    let title: String
    let subtitle: String?
    let identifier: String
    let spoken: String
    var systemImage: String = "doc.text"

    var body: some View {
        unavailableStack
            .padding(36)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spoken)
            .accessibilityIdentifier(identifier)
    }
}

/// Loading compartilhado por ArtifactSheet e ChangeReviewSheet.

struct TraceEvidenceLoading: View {
    let text: String
    let reduceMotion: Bool

    var body: some View {
        VStack(spacing: 12) {
            BreathingDiamond(size: 10, reduceMotion: reduceMotion)
            Text(text)
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
        // Live wait state; Reduce Motion keeps a static announcement.
        .accessibilityAddTraits(reduceMotion ? .isStaticText : [.isStaticText, .updatesFrequently])
    }
}

/// Fala nome, escala atual e ações; silêncio sem inventar dimensões.

enum ArtifactViewerZoomA11y {
    static func spokenImage(name: String, scale: CGFloat) -> String {
        if scale <= 1.01 {
            return "imagem \(name), tamanho normal"
        }
        let pct = Int((scale * 100).rounded())
        return "imagem \(name), ampliada \(pct) por cento"
    }

    static let zoomHint = "pinça para aproximar, arraste quando ampliada, toque duas vezes ou use ações para redefinir"

    static let resetAction = "Redefinir zoom"
}

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
            .accessibilityLabel(ArtifactViewerZoomA11y.spokenImage(name: name, scale: scale))
            .accessibilityHint(ArtifactViewerZoomA11y.zoomHint)
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
            .accessibilityAction(named: ArtifactViewerZoomA11y.resetAction) { resetZoom() }
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
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
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


struct ArtifactFileFicha: View {
    let name: String
    let subtitle: String

    var body: some View {
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArtifactViewerA11y.spokenFicha(name: name, subtitle: subtitle))
    }
}
