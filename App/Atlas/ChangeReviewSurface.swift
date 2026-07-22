import SwiftUI
import AtlasCore

// WAVE-013 fused ChangeReviewView.swift

extension ChangeReviewGovernanceSection {
    func governanceChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AtlasTheme.surface.opacity(0.45), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
            .accessibilityIdentifier(A11yID.reviewGovernance)
    }
}

extension ChangeReviewPatchCard {
    func patchCardChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .atlasCard()
            .accessibilityElement(children: .contain)
            .accessibilityLabel(ChangeReviewJudgment.spokenPatchCard(patch: patch, diffExpanded: diffExpanded))
            .accessibilityIdentifier(A11yID.reviewPatchCard(patch.id))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: diffExpanded)
    }
}

extension ChangeReviewPatchCard {
    var patchCardShell: some View {
        patchCardChrome { patchCardBody }
    }
}

struct ChangeReviewDiffView: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let patch: AtlasTraceChangeReview.Patch
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var loadSettled = false

    var body: some View {
        Group {
            diffBody(response: reviews.changeReviewDiff(traceId: traceId, patchId: patch.patchID))
        }
        .task(id: patch.id) {
            await diffLoadTask()
        }
    }
}


// MARK: - ChangeReview chrome (peel de ChangeReviewSections)
// Toast → ChangeReviewSections+Toast.swift

struct ChangeReviewCaption: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text).font(AtlasFont.mono(10)).tracking(1.0).foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(ChangeReviewJudgment.spokenCaption(text))
    }
}

extension ChangeReviewRunHeader {
    func runHeaderChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.card).fill(AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.card).stroke(AtlasTheme.goldBorder, lineWidth: 1))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(ChangeReviewJudgment.spokenRunHeader(run: run))
            .accessibilityIdentifier(A11yID.reviewRunHeader)
    }
}

struct ChangeReviewToast: View {
    let reviews: ChangeReviewModel
    var reduceMotion: Bool = false

    var body: some View {
        if let t = reviews.toast {
            toastCapsule(t)
                .accessibilityLabel(ChangeReviewJudgment.spokenToast(t))
                .accessibilityIdentifier(A11yID.reviewToast)
                .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                .task { await dismissToastAfterDelay() }
        }
    }
}

extension ChangeReviewToast {
    func dismissToastAfterDelay() async {
        try? await Task.sleep(nanoseconds: 1_400_000_000)
        if reduceMotion { reviews.toast = nil }
        else { withAnimation(AtlasMotion.editorial) { reviews.toast = nil } }
    }
}

extension ChangeReviewToast {
    func toastCapsule(_ text: String) -> some View {
        Text(text)
            .font(AtlasFont.serifItalic(14)).foregroundStyle(AtlasTheme.textPrimary)
            .padding(.horizontal, 16).padding(.vertical, 9)
            .background(Capsule().fill(AtlasTheme.surfaceHi).overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
            .padding(.top, 8)
    }
}

extension ChangeReviewSheet {
    @ViewBuilder
    func reviewAvailableContent(_ review: AtlasTraceChangeReview) -> some View {
        switch review.state {
        case .unavailable:
            reviewUnavailableContent(review)
        case .available:
            reviewAvailableBranch(review)
        }
    }
}

extension ChangeReviewSheet {
    @ViewBuilder
    func reviewAvailableBranch(_ review: AtlasTraceChangeReview) -> some View {
        if Self.hasReviewSurface(review) {
            ChangeReviewAvailableContent(
                reviews: reviews,
                traceId: traceId,
                review: review,
                expandedDiffPatch: $expandedDiffPatch,
                applying: $applying
            )
        } else {
            reviewEmptySurface()
        }
    }
}

struct ChangeReviewAvailableContent: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let review: AtlasTraceChangeReview
    @Binding var expandedDiffPatch: String?
    @Binding var applying: Bool

    var body: some View {
        reviewSections
    }
}

extension ChangeReviewSheet {
    func reviewUnavailableContent(_ review: AtlasTraceChangeReview) -> some View {
        TraceEvidenceUnavailable(
            title: "Sem revisão de mudanças nesta execução.",
            subtitle: TraceEvidenceCopy.unavailableReason(review.reason),
            identifier: A11yID.reviewUnavailable,
            spoken: TraceEvidenceCopy.unavailableSpoken(
                prefix: "sem revisão de mudanças nesta execução",
                reason: review.reason
            ),
            systemImage: "doc.text.magnifyingglass"
        )
    }
}

extension ChangeReviewSheet {
    func reviewEmptySurface() -> some View {
        TraceEvidenceUnavailable(
            title: "Revisão ligada, mas sem patches nem provas publicadas.",
            subtitle: "o servidor confirmou o vínculo, porém não há diff, checks ou achados a mostrar.",
            identifier: A11yID.reviewEmpty,
            spoken: "revisão ligada mas sem patches nem provas publicadas",
            systemImage: "doc.text.magnifyingglass"
        )
    }
}

extension ChangeReviewSheet {
    var reviewSheetChrome: some View {
        NavigationStack {
            // Fundo como .background: destrava o scroll-edge material da barra.
            content
                .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle("Revisar mudanças")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { reviewToolbar }
            .overlay(alignment: .top) { ChangeReviewToast(reviews: reviews, reduceMotion: reduceMotion) }
            .accessibilityIdentifier(A11yID.reviewSheet)
            .accessibilityLabel(spokenReviewSheetLabel())
            .accessibilityValue(reviewSheetFace.productWord)
            .accessibilityHint(Self.reviewSheetHint)
        }
    }
}

struct ChangeReviewSheet: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var expandedDiffPatch: String?
    @State var applying = false
    @State var loadFinished = false

    var review: AtlasTraceChangeReview? { reviews.changeReviewsByTrace[traceId] }

    var body: some View {
        reviewSheetChrome
            .task { await refreshReviewTask() }
    }
}

// MARK: - Diff view body

// MARK: - Diff body states
extension ChangeReviewDiffView {
    @ViewBuilder
    var diffBodyLoading: some View {
        TraceEvidenceLoading(text: "carregando diff…", reduceMotion: reduceMotion)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
    }
}

extension ChangeReviewDiffView {
    @ViewBuilder
    var diffBodyUnavailable: some View {
        Text("diff indisponível para este patch")
            .font(AtlasFont.serifItalic(13))
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .accessibilityLabel(ChangeReviewJudgment.spokenDiffUnavailable)
            .accessibilityIdentifier(A11yID.reviewDiffUnavailable)
    }
}

extension ChangeReviewDiffView {
    @ViewBuilder
    func diffBody(response: AtlasTraceChangeReviewDiffResponse?) -> some View {
        if let response {
            loadedDiff(response)
        } else if !loadSettled {
            diffBodyLoading
        } else {
            diffBodyUnavailable
        }
    }
}

// MARK: - Load task
extension ChangeReviewDiffView {
    func diffLoadTask() async {
        loadSettled = false
        if reviews.changeReviewDiff(traceId: traceId, patchId: patch.patchID) == nil {
            await reviews.refreshChangeReviewDiff(traceId: traceId, patchId: patch.patchID)
        }
        loadSettled = true
    }
}

// MARK: - Loaded diff
extension ChangeReviewDiffView {
    @ViewBuilder
    func loadedDiffScroll(_ response: AtlasTraceChangeReviewDiffResponse) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(response.diff.content)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
                .textSelection(.enabled)
                .padding(10)
        }
        .frame(maxHeight: 320)
        .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.bgRecessed))
    }
}

extension ChangeReviewDiffView {
    @ViewBuilder
    func loadedDiff(_ response: AtlasTraceChangeReviewDiffResponse) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            loadedDiffScroll(response)
            loadedDiffWarnings(response)
        }
        .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
    }
}

extension ChangeReviewDiffView {
    @ViewBuilder
    func loadedDiffWarnings(_ response: AtlasTraceChangeReviewDiffResponse) -> some View {
        if response.diff.truncated {
            Text("diff truncado — \(response.diff.returnedBytes) de \(response.diff.sizeBytes) bytes")
                .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
        }
        if response.patch.hashMatches == false {
            ChangeReviewHashWarning()
        }
    }
}

// MARK: - Sheet body

// MARK: - Sheet face / spoken

extension ChangeReviewSheet {
    /// Exclusive sheet face from loadFinished + review.
    var reviewSheetFace: ChangeReviewSheetFace {
        ChangeReviewSheetJudgment.face(loadFinished: loadFinished, review: review)
    }

    func spokenReviewSheetLabel() -> String {
        ChangeReviewSheetJudgment.spokenSheet(loadFinished: loadFinished, review: review)
    }

    static var reviewSheetHint: String { ChangeReviewSheetJudgment.spokenSheetHint }

    /// Patches, checks, testes ou achados — nunca UI vazia fingindo conteúdo.
    static func hasReviewSurface(_ review: AtlasTraceChangeReview) -> Bool {
        ChangeReviewJudgment.hasReviewSurface(review)
    }

    func refreshReviewTask() async {
        await reviews.refreshChangeReview(traceId: traceId)
        loadFinished = true
    }

    var reviewToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            AtlasCloseToolbarButton(
                spokenLabel: ChangeReviewSheetJudgment.spokenClose,
                spokenHint: ChangeReviewSheetJudgment.spokenCloseHint,
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
    }

    @ViewBuilder
    var content: some View {
        if review == nil {
            reviewUnavailableContent
        } else if let review {
            reviewAvailableContent(review)
        }
    }

    @ViewBuilder
    var reviewUnavailableContent: some View {
        if !loadFinished, review == nil {
            TraceEvidenceLoading(text: "consultando a revisão…", reduceMotion: reduceMotion)
        } else if loadFinished, review == nil {
            TraceEvidenceUnavailable(
                title: "Não foi possível consultar a revisão.",
                subtitle: "feche e tente de novo — o motivo pode estar no aviso superior.",
                identifier: A11yID.reviewLoadFailure,
                spoken: "não foi possível consultar a revisão",
                systemImage: "doc.text.magnifyingglass"
            )
        }
    }
}

// MARK: - Available content sections

extension ChangeReviewAvailableContent {
    @ViewBuilder
    var reviewSections: some View {
        if let run = review.run { ChangeReviewRunHeader(run: run) }
        ChangeReviewRiskStrip(review: review)
        ChangeReviewGovernanceSection(reviews: reviews, traceId: traceId)
        reviewPatchTail
    }

    @ViewBuilder
    var reviewSectionsAfterPatches: some View {
        if !review.controls.isEmpty { ChangeReviewControlsSection(controls: review.controls) }
        if !review.testRuns.isEmpty { ChangeReviewTestsSection(tests: review.testRuns) }
        if !review.review.findings.isEmpty { ChangeReviewFindingsSection(findings: review.review.findings) }
        if !review.review.operatorActions.isEmpty {
            ChangeReviewDecidedSection(actions: review.review.operatorActions)
        }
        ChangeReviewRunActions(
            review: review,
            reviews: reviews,
            traceId: traceId,
            applying: $applying
        )
    }

    @ViewBuilder
    var reviewPatchTail: some View {
        // riskFlags-first patches before quiet ones.
        ForEach(ChangeReviewJudgment.rankPatches(review.patches)) { patch in
            ChangeReviewPatchCard(
                reviews: reviews,
                traceId: traceId,
                patch: patch,
                expandedDiffPatch: $expandedDiffPatch
            )
        }
        reviewSectionsAfterPatches
    }
}

// MARK: - ChangeReviewModel

extension ChangeReviewModel {
    func applyChangeReview(
        traceId: TraceID,
        action: AtlasTraceChangeReview.Action,
        note: String? = nil
    ) async {
        do {
            let response = try await client.applyTraceChangeReview(
                traceId: traceId,
                input: .init(action: action, actor: "mobile_operator", note: note)
            )
            guard response.changeReview.traceId == traceId else {
                toast = "A decisão foi recusada porque o recibo não corresponde à execução."
                return
            }
            changeReviewsByTrace[traceId] = response.changeReview
            await notifyTraceUpdated(traceId)
        } catch {
            toast = atlasUserMessage(for: error)
        }
    }

    func applyChangeReviewFile(
        traceId: TraceID,
        patchId: PatchID,
        filePath: String,
        action: AtlasTraceChangeReview.Action,
        note: String? = nil
    ) async {
        if changeReviewsByTrace[traceId] == nil {
            await refreshChangeReview(traceId: traceId)
        }
        guard changeReviewsByTrace[traceId]?.patches.contains(where: { $0.patchID == patchId && $0.contains(filePath) }) == true else {
            toast = "Este arquivo não pertence ao patch desta execução."
            return
        }
        do {
            let response = try await client.applyTraceChangeReviewFile(
                traceId: traceId,
                input: .init(
                    patchId: patchId,
                    filePath: filePath,
                    action: action,
                    actor: "mobile_operator",
                    note: note
                )
            )
            guard response.changeReview.traceId == traceId,
                  response.fileReviewReceipt.patchId == patchId,
                  response.fileReviewReceipt.filePath == filePath,
                  response.fileReviewReceipt.action == action,
                  response.changeReview.patches.contains(where: {
                      $0.patchID == patchId && $0.fileReviews.contains(where: {
                          $0.filePath == filePath && $0.action == action
                      })
                  }) else {
                toast = "A decisão por arquivo não corresponde ao patch revisado."
                return
            }
            changeReviewsByTrace[traceId] = response.changeReview
            await notifyTraceUpdated(traceId)
        } catch {
            toast = atlasUserMessage(for: error)
        }
    }

    func notifyTraceUpdated(_ traceId: TraceID) async {
        if let refreshed = try? await client.getAiInteraction(traceId) {
            onTraceUpdated?(traceId, refreshed.trace)
        }
    }
}

extension ChangeReviewModel {
    func refreshChangeReview(traceId: TraceID) async {
        if changeReviewsByTrace[traceId] != nil { return }
        guard !changeReviewInFlight.contains(traceId) else { return }
        changeReviewInFlight.insert(traceId)
        defer { changeReviewInFlight.remove(traceId) }
        do {
            async let reviewResponse = client.getTraceChangeReview(traceId)
            async let artifactsResponse = client.getTraceArtifacts(traceId: traceId)
            let response = try await reviewResponse
            guard response.changeReview.traceId == traceId else {
                toast = "A revisão recebida não corresponde a esta execução."
                return
            }
            changeReviewsByTrace[traceId] = response.changeReview
            if let artifacts = try? await artifactsResponse {
                artifactsByTrace[traceId] = artifacts
            }
            if let trace = try? await client.getAiInteraction(traceId).trace,
               trace.id == traceId.rawValue || trace.traceKey == traceId.rawValue {
                governanceByTrace[traceId] = trace
            }
        } catch {
            toast = atlasUserMessage(for: error)
        }
    }

    func loadArtifactContent(traceId: TraceID, item: AtlasTraceArtifacts.Item) async throws -> AtlasArtifactContent {
        guard artifactsByTrace[traceId]?.state == .available,
              artifactsByTrace[traceId]?.items.contains(where: { $0.id == item.id && $0.sha256 == item.sha256 }) == true else {
            let error = AtlasApiError(status: 0, path: "trace-artifacts", message: "Este artefato não pertence ao manifesto desta execução.")
            toast = error.message
            throw error
        }

        let key = NSString(string: item.sha256)
        if let cached = artifactContentCache.object(forKey: key) {
            return cached.content
        }

        do {
            let content = try await client.getTraceArtifactContent(traceId: traceId, item: item)
            artifactContentCache.setObject(CachedArtifactContent(content), forKey: key)
            return content
        } catch {
            toast = atlasUserMessage(for: error)
            throw error
        }
    }

    func refreshChangeReviewDiff(traceId: TraceID, patchId: PatchID) async {
        if changeReviewsByTrace[traceId] == nil {
            await refreshChangeReview(traceId: traceId)
        }
        guard changeReviewsByTrace[traceId]?.patches.contains(where: { $0.patchID == patchId }) == true else {
            toast = "Este diff não pertence à revisão desta execução."
            return
        }
        do {
            let response = try await client.getTraceChangeReviewDiff(traceId: traceId, patchId: patchId)
            guard response.patch.patchID == patchId else {
                toast = "O diff recebido não corresponde ao artefato solicitado."
                return
            }
            changeReviewDiffsByKey[Self.changeReviewDiffKey(traceId: traceId, patchId: patchId)] = response
        } catch {
            toast = atlasUserMessage(for: error)
        }
    }
}

@MainActor
@Observable
final class ChangeReviewModel {
    var changeReviewsByTrace: [TraceID: AtlasTraceChangeReview] = [:]  // set interno: família de peels
    var governanceByTrace: [TraceID: AtlasAiTrace] = [:]  // set interno: família de peels
    var artifactsByTrace: [TraceID: AtlasTraceArtifacts] = [:]
    var changeReviewDiffsByKey: [String: AtlasTraceChangeReviewDiffResponse] = [:]  // set interno: família de peels
    var toast: String?

    @ObservationIgnored var onTraceUpdated: (@MainActor (TraceID, AtlasAiTrace) -> Void)?
    @ObservationIgnored let artifactContentCache = NSCache<NSString, CachedArtifactContent>()
    @ObservationIgnored var changeReviewInFlight: Set<TraceID> = []

    let client: AtlasClient

    init(client: AtlasClient) {
        self.client = client
        artifactContentCache.countLimit = 8
    }

    func changeReviewDiff(traceId: TraceID, patchId: PatchID) -> AtlasTraceChangeReviewDiffResponse? {
        changeReviewDiffsByKey[Self.changeReviewDiffKey(traceId: traceId, patchId: patchId)]
    }

    static func changeReviewDiffKey(traceId: TraceID, patchId: PatchID) -> String {
        "\(traceId.rawValue):\(patchId.rawValue)"
    }
}

final class CachedArtifactContent {
    let content: AtlasArtifactContent

    init(_ content: AtlasArtifactContent) {
        self.content = content
    }
}
