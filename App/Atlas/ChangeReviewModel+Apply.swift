import Foundation
import AtlasCore

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
