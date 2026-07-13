import Foundation

public struct PreparedInteraction: Sendable {
    public let input: CreateAiInteractionInput
    public let wasPending: Bool
    /// Identificador local da instrução de follow-up que originou este turno.
    /// Nunca é enviado ao servidor; serve somente para reconciliar a outbox
    /// com a fila local após relaunch.
    public let followUpId: String?
}

/// Outbox mínima e profunda: um JSON atômico, carregado inteiro. Preserva o
/// `clientId` que torna o create idempotente no servidor e sobrevive a kill,
/// relaunch, timeout e troca de rede sem introduzir SwiftData.
public actor InteractionOutbox {
    private struct PendingInteraction: Codable {
        var input: CreateAiInteractionInput
        var followUpId: String?
    }

    private struct Envelope: Codable {
        var schemaVersion = 2
        var pending: [PendingInteraction]
    }

    private let fileURL: URL
    private var items: [PendingInteraction]

    public init(fileURL: URL) {
        self.fileURL = fileURL
        if let data = try? Data(contentsOf: fileURL),
           let envelope = try? JSONDecoder().decode(Envelope.self, from: data),
           envelope.schemaVersion == 2 {
            items = envelope.pending
        } else if let data = try? Data(contentsOf: fileURL),
                  let legacy = try? JSONDecoder().decode(LegacyEnvelope.self, from: data),
                  legacy.schemaVersion == 1 {
            items = legacy.pending.map { PendingInteraction(input: $0, followUpId: nil) }
        } else {
            items = []
        }
    }

    public static func applicationSupportFileURL(
        fileManager: FileManager = .default
    ) -> URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        return base
            .appendingPathComponent("AtlasNative", isDirectory: true)
            .appendingPathComponent("interaction-outbox.v1.json")
    }

    public func prepare(
        _ rawInput: CreateAiInteractionInput,
        followUpId: String? = nil
    ) throws -> PreparedInteraction {
        var input = rawInput
        if input.clientId.flatMap(UUID.init(uuidString:)) == nil {
            input.clientId = UUID().uuidString.lowercased()
        }
        let clientId = input.clientId!
        let index = items.firstIndex { $0.input.clientId == clientId }
        let resolvedFollowUpId: String?
        if let index {
            // A recuperação chama prepare sem o follow-up explícito. Preservar
            // o vínculo anterior permite reconciliar a fila depois do relaunch.
            resolvedFollowUpId = followUpId ?? items[index].followUpId
            items[index] = PendingInteraction(input: input, followUpId: resolvedFollowUpId)
        } else {
            resolvedFollowUpId = followUpId
            items.append(PendingInteraction(input: input, followUpId: resolvedFollowUpId))
        }
        try persist()
        return PreparedInteraction(input: input, wasPending: index != nil, followUpId: resolvedFollowUpId)
    }

    public func pending(threadId: String? = nil) -> [CreateAiInteractionInput] {
        let filtered = threadId.map { id in items.filter { $0.input.threadId == id } } ?? items
        return filtered.map(\.input)
    }

    /// Vínculo da fila de um turno já preparado. Uso exclusivo da recuperação
    /// local; o servidor não recebe nem persiste esse identificador.
    public func followUpId(clientId: String) -> String? {
        items.first(where: { $0.input.clientId == clientId })?.followUpId
    }

    public func remove(clientId: String) throws {
        items.removeAll { $0.input.clientId == clientId }
        try persist()
    }

    private func persist() throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(Envelope(pending: items))
        try data.write(to: fileURL, options: [.atomic])
    }

    private struct LegacyEnvelope: Codable {
        var schemaVersion: Int
        var pending: [CreateAiInteractionInput]
    }
}
