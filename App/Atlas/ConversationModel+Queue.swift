import Foundation
import AtlasCore

/// C11 fila de follow-ups — persistência/FIFO fora do arquivo principal
/// para ConversationModel ficar sob a régua (<800).
@MainActor
extension ConversationModel {
    /// Enfileira uma instrução como próximo turno. É deliberadamente assíncrono:
    /// a confirmação visual só acontece depois do JSON atômico do Core.
    func queue(text: String) async {
        do {
            guard let message = try await queueStore.enqueue(text: text, scope: queueScope) else { return }
            queuedMessages.append(message)
            AtlasNativeSnapshotWriter.shared.recordQueuedCount(queuedMessages.count)
            toast = "Adicionada à fila"
        } catch {
            toast = "Não foi possível guardar esta instrução na fila."
        }
    }

    /// “Enviar agora” no Fable/Cursor significa enviar no PRÓXIMO turno. Nunca
    /// cancela a execução ou substitui o stream que está em andamento.
    func promote(id: QueuedMessage.ID) async {
        do {
            try await queueStore.promote(id: id, scope: queueScope)
            queuedMessages = await queueStore.messages(scope: queueScope)
            AtlasNativeSnapshotWriter.shared.recordQueuedCount(queuedMessages.count)
        } catch {
            toast = "Não foi possível reordenar a fila."
        }
    }

    func removeQueued(id: QueuedMessage.ID) async {
        do {
            try await queueStore.remove(id: id, scope: queueScope)
            queuedMessages = await queueStore.messages(scope: queueScope)
            AtlasNativeSnapshotWriter.shared.recordQueuedCount(queuedMessages.count)
        } catch {
            toast = "Não foi possível remover esta instrução."
        }
    }

    func loadQueuedMessages() async {
        queuedMessages = await queueStore.messages(scope: queueScope)
        AtlasNativeSnapshotWriter.shared.recordQueuedCount(queuedMessages.count)
    }

    func adoptQueueScope(threadId: ThreadID) async {
        let canonicalScope = "thread:\(threadId.rawValue)"
        adoptDraftScope(canonicalScope)
        guard canonicalScope != queueScope else { return }
        do {
            try await queueStore.migrate(scope: queueScope, to: canonicalScope)
            queueScope = canonicalScope
            await loadQueuedMessages()
        } catch {
            // Mantém o escopo provisório em memória para não abandonar follow-up
            // algum; a próxima abertura pode tentar a migração de novo.
            toast = "A fila continua segura neste aparelho; a conversa ainda está sincronizando."
        }
    }

    func drainQueuedMessages() async {
        while !isSending && activeRun == nil {
            let next = await queueStore.peek(scope: queueScope)
            guard let next else { return }
            let completedSuccessfully = await sendTurn(
                next.text,
                effort: effort,
                drainQueueOnSuccess: false,
                queuedMessageId: next.id
            )
            // Uma falha/atenção pede decisão do operador; a fila restante fica
            // intacta e visível, nunca dispara trabalho em cascata às cegas.
            guard completedSuccessfully else { return }
        }
    }

    /// Uma instrução só sai da fila após o `InteractionRun` persistir o mesmo
    /// turno na outbox. Se o processo morrer entre estas operações, o vínculo
    /// followUpId salvo na outbox faz a recuperação repetir esta reconciliação.
    func consumeQueuedMessageAfterPersistence(id: QueuedMessage.ID) async {
        do {
            try await queueStore.remove(id: id, scope: queueScope)
            queuedMessages = await queueStore.messages(scope: queueScope)
            AtlasNativeSnapshotWriter.shared.recordQueuedCount(queuedMessages.count)
        } catch {
            // Erro na limpeza é conservador: a instrução segue visível e
            // recuperável, em vez de sumir sem um turno durável correspondente.
            toast = "A próxima instrução continua guardada e será reconciliada."
        }
    }
}
