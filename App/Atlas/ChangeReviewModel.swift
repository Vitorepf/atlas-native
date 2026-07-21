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
