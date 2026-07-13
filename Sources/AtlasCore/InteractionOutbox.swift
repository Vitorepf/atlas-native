import Foundation

public struct PreparedInteraction: Sendable {
    public let input: CreateAiInteractionInput
    public let wasPending: Bool
}

/// Outbox mínima e profunda: um JSON atômico, carregado inteiro. Preserva o
/// `clientId` que torna o create idempotente no servidor e sobrevive a kill,
/// relaunch, timeout e troca de rede sem introduzir SwiftData.
public actor InteractionOutbox {
    private struct Envelope: Codable {
        var schemaVersion = 1
        var pending: [CreateAiInteractionInput]
    }

    private let fileURL: URL
    private var items: [CreateAiInteractionInput]

    public init(fileURL: URL) {
        self.fileURL = fileURL
        if let data = try? Data(contentsOf: fileURL),
           let envelope = try? JSONDecoder().decode(Envelope.self, from: data),
           envelope.schemaVersion == 1 {
            items = envelope.pending
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

    public func prepare(_ rawInput: CreateAiInteractionInput) throws -> PreparedInteraction {
        var input = rawInput
        if input.clientId.flatMap(UUID.init(uuidString:)) == nil {
            input.clientId = UUID().uuidString.lowercased()
        }
        let clientId = input.clientId!
        let index = items.firstIndex { $0.clientId == clientId }
        if let index {
            items[index] = input
        } else {
            items.append(input)
        }
        try persist()
        return PreparedInteraction(input: input, wasPending: index != nil)
    }

    public func pending(threadId: String? = nil) -> [CreateAiInteractionInput] {
        guard let threadId else { return items }
        return items.filter { $0.threadId == threadId }
    }

    public func remove(clientId: String) throws {
        items.removeAll { $0.clientId == clientId }
        try persist()
    }

    private func persist() throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(Envelope(pending: items))
        try data.write(to: fileURL, options: [.atomic])
    }
}
