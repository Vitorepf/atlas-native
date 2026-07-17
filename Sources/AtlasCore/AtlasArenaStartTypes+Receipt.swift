import Foundation

public struct AtlasArenaStartReceipt: Sendable, Equatable, Decodable {
    public static let schemaVersion = "atlas.arena.start_receipt.v1"

    public let schemaVersion: String
    public let status: String
    public let receiptHash: String
    public let runsPlanned: Int
    public let started: Bool
    public let workerImplemented: Bool
    public let providerInvoked: Bool?
    public let note: String?

    enum CodingKeys: String, CodingKey {
        case schemaVersion, status, receiptHash, runsPlanned, started, workerImplemented, providerInvoked, note
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try values.requireSchema(Self.schemaVersion, forKey: .schemaVersion, message: "Unsupported Atlas Arena start receipt schema.")
        status = try values.decode(String.self, forKey: .status)
        receiptHash = try values.decode(String.self, forKey: .receiptHash)
        runsPlanned = try values.decode(Int.self, forKey: .runsPlanned)
        started = try values.decodeIfPresent(Bool.self, forKey: .started) ?? false
        workerImplemented = try values.decodeIfPresent(Bool.self, forKey: .workerImplemented) ?? false
        providerInvoked = try values.decodeIfPresent(Bool.self, forKey: .providerInvoked)
        note = try values.decodeIfPresent(String.self, forKey: .note)
    }

    public var isEnqueued: Bool { status == "enqueued" && !started }
}

public enum AtlasArenaClientError: Error, Sendable, Equatable {
    case invalidStartInput
}
