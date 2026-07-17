import Foundation

// JSON codec + App Group store — peel de AtlasNativeSnapshot (régua anti-inchaço).

public extension JSONEncoder {
    static func atlasNativeSnapshotEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(date.formatted(.iso8601.year().month().day().time(includingFractionalSeconds: false).timeZone(separator: .omitted)))
        }
        return encoder
    }
}

public extension JSONDecoder {
    static func atlasNativeSnapshotDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            guard let date = AtlasTime.date(raw) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid Atlas snapshot timestamp.")
            }
            return date
        }
        return decoder
    }
}

public actor AtlasNativeSnapshotStore {
    public let fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    public static func appGroupFileURL(
        fileManager: FileManager = .default,
        groupIdentifier: String = AtlasNativeSnapshot.appGroupIdentifier
    ) -> URL? {
        fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)?
            .appendingPathComponent(AtlasNativeSnapshot.relativePath)
    }

    public func load() throws -> AtlasNativeSnapshot {
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder.atlasNativeSnapshotDecoder().decode(AtlasNativeSnapshot.self, from: data)
    }

    public func save(_ snapshot: AtlasNativeSnapshot) throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try JSONEncoder.atlasNativeSnapshotEncoder().encode(snapshot)
        try data.write(to: fileURL, options: [.atomic])
    }
}
