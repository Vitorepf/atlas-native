import Foundation
import Observation
import AtlasCore

@MainActor
@Observable
final class ChangeReviewModel {
    /// Revisões carregadas sob demanda e sempre indexadas pelo trace público.
    /// A casca pode mostrar ausência/indisponibilidade, mas não fabricar patch,
    /// resultado de check ou decisão antes desta leitura canônica.
    private(set) var changeReviewsByTrace: [TraceID: AtlasTraceChangeReview] = [:]
    /// Provas de governança do turno (C18 diff_stats · C19 plan_revisions ·
    /// C21 council_review). Vêm do metadata do trace; ausência = nada a dizer.
    private(set) var governanceByTrace: [TraceID: AtlasAiTrace] = [:]
    /// Manifestos de artefatos do turno. `unavailable` pode ser guardado, mas
    /// a casca só renderiza quando o contrato vem `available` com itens reais.
    private(set) var artifactsByTrace: [TraceID: AtlasTraceArtifacts] = [:]
    /// Conteúdo de diff só entra aqui depois de o patch ser confirmado na
    /// projeção do mesmo trace; a View nunca faz a requisição por conta própria.
    private(set) var changeReviewDiffsByKey: [String: AtlasTraceChangeReviewDiffResponse] = [:]
    var toast: String?

    @ObservationIgnored var onTraceUpdated: (@MainActor (TraceID, AtlasAiTrace) -> Void)?
    @ObservationIgnored private let artifactContentCache = NSCache<NSString, CachedArtifactContent>()

    private let client: AtlasClient

    init(client: AtlasClient) {
        self.client = client
        artifactContentCache.countLimit = 8
    }

    /// Carrega a superfície de artefatos/revisão do trace. A resposta que não
    /// ecoa o mesmo trace é descartada, pois vinculá-la à bolha errada seria um
    /// vazamento de evidência entre execuções.
    func refreshChangeReview(traceId: TraceID) async {
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

    func changeReviewDiff(traceId: TraceID, patchId: PatchID) -> AtlasTraceChangeReviewDiffResponse? {
        changeReviewDiffsByKey[Self.changeReviewDiffKey(traceId: traceId, patchId: patchId)]
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

    private func notifyTraceUpdated(_ traceId: TraceID) async {
        if let refreshed = try? await client.getAiInteraction(traceId) {
            onTraceUpdated?(traceId, refreshed.trace)
        }
    }

    private static func changeReviewDiffKey(traceId: TraceID, patchId: PatchID) -> String {
        "\(traceId.rawValue):\(patchId.rawValue)"
    }
}

private final class CachedArtifactContent {
    let content: AtlasArtifactContent

    init(_ content: AtlasArtifactContent) {
        self.content = content
    }
}

func atlasUserMessage(for error: Error) -> String {
    if error is AtlasInteractionStreamError {
        return "A conexão com a execução caiu. O Atlas retomará este turno automaticamente."
    }
    if let urlError = error as? URLError {
        switch urlError.code {
        case .networkConnectionLost, .notConnectedToInternet, .cannotConnectToHost,
             .cannotFindHost, .timedOut:
            return "A conexão caiu. O Atlas vai recuperar este turno quando a rede voltar."
        default:
            return "Não foi possível falar com o Atlas agora. Tente novamente."
        }
    }
    if let api = error as? AtlasApiError {
        switch api.status {
        case 401, 403: return "A sessão do Atlas precisa ser reconectada."
        case 408, 429: return "O Atlas está ocupado. Este turno continua recuperável."
        case 500...599: return "O servidor Atlas está temporariamente indisponível."
        default: return api.message
        }
    }
    return "A execução foi interrompida. Tente novamente."
}
