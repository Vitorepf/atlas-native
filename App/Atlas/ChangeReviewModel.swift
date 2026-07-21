import AtlasCore
import Foundation
import Observation

// IDLE-COMPRESS ChangeReviewModel fused

// --- ChangeReviewModel+Apply.swift ---
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

// --- ChangeReviewModel+Refresh.swift ---
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

    func refreshArtifacts(traceId: TraceID) async {
        do {
            artifactsByTrace[traceId] = try await client.getTraceArtifacts(traceId: traceId)
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

// --- ChangeReviewModel.swift ---
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
