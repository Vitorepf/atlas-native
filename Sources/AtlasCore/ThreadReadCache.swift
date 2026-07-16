import Foundation

/// Cache local da última leitura bem-sucedida de uma conversa. Ele existe para
/// stale-while-revalidate: abrir a thread mostra a verdade mais recente deste
/// aparelho imediatamente, e a rede substitui o snapshot quando responder.
public actor ThreadReadCache {
    public struct Message: Codable, Sendable, Equatable {
        public let id: String
        public let role: String
        public let content: String
        public let traceId: String?
        public let provider: String?
        public let model: String?

        public init(
            id: String,
            role: String,
            content: String,
            traceId: String? = nil,
            provider: String? = nil,
            model: String? = nil
        ) {
            self.id = id
            self.role = role
            self.content = content
            self.traceId = traceId
            self.provider = provider
            self.model = model
        }
    }

    public struct Snapshot: Codable, Sendable, Equatable {
        public let threadId: String
        public let capturedAt: Date
        public let workspacePath: String?
        public let messages: [Message]

        public init(
            threadId: String,
            capturedAt: Date,
            workspacePath: String? = nil,
            messages: [Message]
        ) {
            self.threadId = threadId
            self.capturedAt = capturedAt
            self.workspacePath = workspacePath
            self.messages = messages
        }
    }

    private struct Envelope: Codable {
        var schemaVersion = 1
        var snapshots: [String: Snapshot]
    }

    private let fileURL: URL
    private var snapshots: [String: Snapshot]

    public init(fileURL: URL) {
        self.fileURL = fileURL
        if let data = try? Data(contentsOf: fileURL),
           let envelope = try? JSONDecoder().decode(Envelope.self, from: data),
           envelope.schemaVersion == 1 {
            snapshots = envelope.snapshots
        } else {
            snapshots = [:]
        }
    }

    public static func applicationSupportFileURL(
        fileManager: FileManager = .default
    ) -> URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        return base
            .appendingPathComponent("AtlasNative", isDirectory: true)
            .appendingPathComponent("thread-read-cache.v1.json")
    }

    public func load(threadId: String) -> Snapshot? {
        snapshots[threadId]
    }

    public func save(snapshot: Snapshot) throws {
        snapshots[snapshot.threadId] = snapshot
        try persist()
    }

    private func persist() throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(Envelope(snapshots: snapshots))
        try data.write(to: fileURL, options: [.atomic])
    }
}
