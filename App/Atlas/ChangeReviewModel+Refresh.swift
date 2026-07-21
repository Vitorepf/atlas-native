import Foundation
import AtlasCore

/// Refresh/load da revisão — peel de `ChangeReviewModel.swift`.
extension ChangeReviewModel {
    /// Carrega a superfície de artefatos/revisão do trace. A resposta que não
    /// ecoa o mesmo trace é descartada, pois vinculá-la à bolha errada seria um
    /// vazamento de evidência entre execuções.
    func refreshChangeReview(traceId: TraceID) async {
        // Já temos revisão (ou in-flight): não dispare rede de novo por bolha.
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
            // O mesmo toque que abre a revisão traz as provas do turno.
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

    /// Busca o diff somente se o patch já pertence à revisão canônica do trace.
    /// Isso evita tanto rede na casca quanto a mistura de artefatos entre traces.
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
