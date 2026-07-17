import Foundation

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
    var scopes: [String: [QueuedMessage]]

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

    /// Lê a cabeça FIFO sem consumi-la. O model primeiro persiste o turno na
    /// outbox e só remove a mensagem após receber esse recibo.
    public func peek(scope: String) -> QueuedMessage? {
        scopes[scope]?.first
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

    func persist() throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(Envelope(scopes: scopes))
        try data.write(to: fileURL, options: [.atomic])
    }
}
