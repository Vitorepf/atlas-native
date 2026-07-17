import Foundation

// MARK: - Seam 1 · bytes por offset

public protocol AttachmentByteSource: Sendable {
    var totalBytes: Int { get }
    func read(offset: Int, length: Int) throws -> Data
}

public struct DataByteSource: AttachmentByteSource {
    private let data: Data
    public var totalBytes: Int { data.count }
    public init(_ data: Data) { self.data = data }
    public func read(offset: Int, length: Int) throws -> Data {
        let end = min(offset + length, data.count)
        guard offset >= 0, offset < end else { return Data() }
        return data.subdata(in: offset..<end)
    }
}

/// FileHandle com seek+read — Files/fileImporter/NSOpenPanel. Diferente do
/// expo-file-system, leitura por offset NUNCA é indisponível → sem fallback.
public struct FileByteSource: AttachmentByteSource {
    private let handle: FileByteSourceHandle
    public let totalBytes: Int
    public init(url: URL) throws {
        let scoped = url.startAccessingSecurityScopedResource()
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
            let openHandle = try FileHandle(forReadingFrom: url)
            self.totalBytes = (attrs[.size] as? Int) ?? (attrs[.size] as? NSNumber)?.intValue ?? 0
            self.handle = FileByteSourceHandle(handle: openHandle, scopedURL: scoped ? url : nil)
        } catch {
            if scoped { url.stopAccessingSecurityScopedResource() }
            throw error
        }
    }
    public func read(offset: Int, length: Int) throws -> Data {
        try handle.read(offset: offset, length: length)
    }
}

private final class FileByteSourceHandle: @unchecked Sendable {
    private let handle: FileHandle
    private let scopedURL: URL?
    private let lock = NSLock()

    init(handle: FileHandle, scopedURL: URL?) {
        self.handle = handle
        self.scopedURL = scopedURL
    }

    deinit {
        try? handle.close()
        scopedURL?.stopAccessingSecurityScopedResource()
    }

    func read(offset: Int, length: Int) throws -> Data {
        lock.lock()
        defer { lock.unlock() }
        try handle.seek(toOffset: UInt64(offset))
        return try handle.read(upToCount: length) ?? Data()
    }
}
