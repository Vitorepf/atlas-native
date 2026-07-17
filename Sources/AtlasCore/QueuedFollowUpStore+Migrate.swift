import Foundation

extension QueuedFollowUpStore {
    /// Retira apenas a cabeça FIFO. Mantido para consumidores administrativos;
    /// a conversa usa `peek` + recibo de persistência para não abrir uma janela
    /// de perda entre a fila e a outbox.
    public func dequeue(scope: String) throws -> QueuedMessage? {
        guard var messages = scopes[scope], !messages.isEmpty else { return nil }
        let message = messages.removeFirst()
        if messages.isEmpty { scopes.removeValue(forKey: scope) }
        else { scopes[scope] = messages }
        try persist()
        return message
    }

    /// Converte a fila da conversa nova (`local-*`) para sua thread canônica.
    /// A ordenação por data mantém FIFO mesmo se a thread já possuir itens de um
    /// relaunch anterior; o id é desempate determinístico.
    public func migrate(scope source: String, to destination: String) throws {
        guard source != destination, let pending = scopes.removeValue(forKey: source), !pending.isEmpty else { return }
        let merged = (scopes[destination] ?? []) + pending
        scopes[destination] = merged.sorted {
            if $0.createdAt != $1.createdAt { return $0.createdAt < $1.createdAt }
            return $0.id < $1.id
        }
        try persist()
    }
}
