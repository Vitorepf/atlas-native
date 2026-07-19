import Foundation

public struct AtlasArenaStopInput: Codable, Sendable, Equatable {
    public let operatorActor: String
    public let operatorReason: String

    public init(operatorActor: String, operatorReason: String) {
        self.operatorActor = operatorActor.trimmingCharacters(in: .whitespacesAndNewlines)
        self.operatorReason = operatorReason.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var isLocallyValidForSubmission: Bool {
        !operatorActor.isEmpty && !operatorReason.isEmpty
    }
}

public enum AtlasArenaStopStatus: String, Codable, Sendable, Equatable {
    case stopping
    case stopped
    case completed
    case failed
}

public struct AtlasArenaStopReceipt: Sendable, Equatable, Decodable {
    public static let schemaVersion = "atlas.arena.stop_receipt.v1"

    public let schemaVersion: String
    public let measurementIdPublic: String
    public let status: AtlasArenaStopStatus
    public let accepted: Bool
    public let receiptHash: String
    public let requestedAt: String?
    public let queuedStopped: Int
    public let runningStopRequested: Int
    public let alreadyStopped: Int
    public let stopsAfterCurrentCase: Bool

    enum CodingKeys: String, CodingKey {
        case schemaVersion, measurementIdPublic, status, accepted, receiptHash, requestedAt
        case queuedStopped, runningStopRequested, alreadyStopped, stopsAfterCurrentCase
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try values.requireSchema(
            Self.schemaVersion,
            forKey: .schemaVersion,
            message: "Unsupported Atlas Arena stop-receipt schema."
        )
        measurementIdPublic = try values.decode(String.self, forKey: .measurementIdPublic)
        status = try values.decode(AtlasArenaStopStatus.self, forKey: .status)
        accepted = try values.decode(Bool.self, forKey: .accepted)
        receiptHash = try values.decode(String.self, forKey: .receiptHash)
        requestedAt = try values.decodeIfPresent(String.self, forKey: .requestedAt)
        queuedStopped = try values.decodeIfPresent(Int.self, forKey: .queuedStopped) ?? 0
        runningStopRequested = try values.decodeIfPresent(Int.self, forKey: .runningStopRequested) ?? 0
        alreadyStopped = try values.decodeIfPresent(Int.self, forKey: .alreadyStopped) ?? 0
        stopsAfterCurrentCase = try values.decodeIfPresent(Bool.self, forKey: .stopsAfterCurrentCase) ?? false
    }
}
