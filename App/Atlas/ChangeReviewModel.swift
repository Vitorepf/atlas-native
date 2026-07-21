import Foundation
import Observation
import AtlasCore

@MainActor
@Observable
final class ChangeReviewModel {
    /// Revisões carregadas sob demanda e sempre indexadas pelo trace público.
    /// A casca pode mostrar ausência/indisponibilidade, mas não fabricar patch,
    /// resultado de check ou decisão antes desta leitura canônica.
    var changeReviewsByTrace: [TraceID: AtlasTraceChangeReview] = [:]  // set interno: família de peels
    /// Provas de governança do turno (C18 diff_stats · C19 plan_revisions ·
    /// C21 council_review). Vêm do metadata do trace; ausência = nada a dizer.
    var governanceByTrace: [TraceID: AtlasAiTrace] = [:]  // set interno: família de peels
    /// Manifestos de artefatos do turno. `unavailable` pode ser guardado, mas
    /// a casca só renderiza quando o contrato vem `available` com itens reais.
    var artifactsByTrace: [TraceID: AtlasTraceArtifacts] = [:]
    /// Conteúdo de diff só entra aqui depois de o patch ser confirmado na
    /// projeção do mesmo trace; a View nunca faz a requisição por conta própria.
    var changeReviewDiffsByKey: [String: AtlasTraceChangeReviewDiffResponse] = [:]  // set interno: família de peels
    var toast: String?

    @ObservationIgnored var onTraceUpdated: (@MainActor (TraceID, AtlasAiTrace) -> Void)?
    @ObservationIgnored let artifactContentCache = NSCache<NSString, CachedArtifactContent>()
    /// Coalesce: um refresh in-flight por trace (evita 3 GETs × N bolhas no scroll).
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


/// Decisões de revisão (run e arquivo) — fora do shell ChangeReviewModel.
extension ChangeReviewModel {
    /// Aceita ou rejeita o run inteiro através do recibo do servidor. Não há
    /// ação local otimista: a UI só muda depois que a decisão e seu evento no
    /// ledger foram persistidos e devolvidos pela mesma rota trace-scoped.
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

    /// Decide um arquivo somente depois de provar que ele pertence ao patch já
    /// vinculado ao mesmo trace. A resposta também é revalidada antes de tocar
    /// no estado observado pela casca, eliminando aceite cruzado entre runs.
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
