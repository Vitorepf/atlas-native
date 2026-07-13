import Foundation

/// Uma instrução enviada enquanto um turno ainda executa. Ela nunca interrompe
/// o turno atual: o operador pode promovê-la para ser a próxima, removê-la, ou
/// deixá-la drenar em FIFO quando a execução concluir.
public struct QueuedMessage: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let text: String
    public let createdAt: Date

    public init(id: String = UUID().uuidString.lowercased(), text: String, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}

/// Persistência pequena e atômica da fila por conversa. O escopo provisório
/// permite enfileirar antes de o servidor devolver a thread; depois o model
/// migra para o id canônico sem perder a ordem. Foundation-only e reutilizável
/// pelo macOS futuro, sem SwiftData nem estado escondido na View.
public actor QueuedFollowUpStore {
    private struct Envelope: Codable {
        var schemaVersion = 1
        var scopes: [String: [QueuedMessage]]
    }

    private let fileURL: URL
    private var scopes: [String: [QueuedMessage]]

    public init(fileURL: URL) {
        self.fileURL = fileURL
        if let data = try? Data(contentsOf: fileURL),
           let envelope = try? JSONDecoder().decode(Envelope.self, from: data),
           envelope.schemaVersion == 1 {
            scopes = envelope.scopes
        } else {
            scopes = [:]
        }
    }

    public static func applicationSupportFileURL(
        fileManager: FileManager = .default
    ) -> URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        return base
            .appendingPathComponent("AtlasNative", isDirectory: true)
            .appendingPathComponent("queued-follow-ups.v1.json")
    }

    public func messages(scope: String) -> [QueuedMessage] {
        scopes[scope] ?? []
    }

    @discardableResult
    public func enqueue(text: String, scope: String, createdAt: Date = Date()) throws -> QueuedMessage? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let message = QueuedMessage(text: trimmed, createdAt: createdAt)
        scopes[scope, default: []].append(message)
        try persist()
        return message
    }

    /// Move uma mensagem para a frente. “Enviar agora” significa próximo turno,
    /// nunca cancelar/substituir a execução em curso.
    public func promote(id: QueuedMessage.ID, scope: String) throws {
        guard var messages = scopes[scope],
              let index = messages.firstIndex(where: { $0.id == id }) else { return }
        let message = messages.remove(at: index)
        messages.insert(message, at: 0)
        scopes[scope] = messages
        try persist()
    }

    public func remove(id: QueuedMessage.ID, scope: String) throws {
        guard var messages = scopes[scope] else { return }
        messages.removeAll { $0.id == id }
        if messages.isEmpty { scopes.removeValue(forKey: scope) }
        else { scopes[scope] = messages }
        try persist()
    }

    /// Retira apenas a cabeça FIFO. O model só chama isto quando começa o
    /// próximo turno, portanto um crash antes do envio não apaga a mensagem.
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

    private func persist() throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(Envelope(scopes: scopes))
        try data.write(to: fileURL, options: [.atomic])
    }
}
