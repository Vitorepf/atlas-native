import Foundation

public struct AtlasAutonomosCycleRevertInput: Codable, Sendable, Equatable {
    public let operatorActor: String
    public let reason: String
    public let focus: String?

    public init(operatorActor: String, reason: String, focus: String? = nil) {
        self.operatorActor = operatorActor.trimmingCharacters(in: .whitespacesAndNewlines)
        self.reason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        self.focus = focus?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var isLocallyValidForSubmission: Bool { !operatorActor.isEmpty && !reason.isEmpty }
}

public enum AtlasAutonomosCycleRevertStatus: String, Codable, Sendable, Equatable {
    case enqueued
    case blocked
}

public struct AtlasAutonomosCycleRevertTarget: Codable, Sendable, Equatable {
    public let cycleIndex: Int
    public let cycleId: String
    public let mergeHash: String
}

public struct AtlasAutonomosCycleRevertMission: Codable, Sendable, Equatable {
    public let type: String
    public let status: String
    public let targetMergeHash: String
    public let commandIntent: String
    public let workerImplemented: Bool
    public let workerGap: String?
}

public struct AtlasAutonomosCycleRevertResponse: Decodable, Sendable, Equatable {
    public static let schemaVersion = "atlas.software_company_stewardship.loop_cycle_revert.v1"

    public let schemaVersion: String
    public let status: AtlasAutonomosCycleRevertStatus
    public let areaId: String
    public let focus: String
    public let cycleIndex: Int
    public let cycleId: String
    public let mergeHash: String
    public let revertOf: AtlasAutonomosCycleRevertTarget
    public let receiptId: String
    public let queue: String
    public let operatorActor: String
    public let gitRevertPerformed: Bool
    public let workerImplemented: Bool
    public let mission: AtlasAutonomosCycleRevertMission
    public let note: String?

    enum CodingKeys: String, CodingKey {
        case schemaVersion, status, areaId, focus, cycleIndex, cycleId, mergeHash,
             revertOf, receiptId, queue, operatorActor, gitRevertPerformed,
             workerImplemented, mission, note
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let schemaVersion = try values.requireSchema(
            Self.schemaVersion,
            forKey: .schemaVersion,
            message: "Unsupported Autonomos cycle revert schema."
        )
        let status = try values.decode(AtlasAutonomosCycleRevertStatus.self, forKey: .status)
        let gitRevertPerformed = try values.decode(Bool.self, forKey: .gitRevertPerformed)
        let workerImplemented = try values.decode(Bool.self, forKey: .workerImplemented)
        guard status == .enqueued, gitRevertPerformed == false, workerImplemented == false else {
            throw DecodingError.dataCorruptedError(
                forKey: .status,
                in: values,
                debugDescription: "M08 only represents an enqueued request; no git revert is claimed by the endpoint."
            )
        }

        self.schemaVersion = schemaVersion
        self.status = status
        self.areaId = try values.decode(String.self, forKey: .areaId)
        self.focus = try values.decode(String.self, forKey: .focus)
        self.cycleIndex = try values.decode(Int.self, forKey: .cycleIndex)
        self.cycleId = try values.decode(String.self, forKey: .cycleId)
        self.mergeHash = try values.decode(String.self, forKey: .mergeHash)
        self.revertOf = try values.decode(AtlasAutonomosCycleRevertTarget.self, forKey: .revertOf)
        self.receiptId = try values.decode(String.self, forKey: .receiptId)
        self.queue = try values.decode(String.self, forKey: .queue)
        self.operatorActor = try values.decode(String.self, forKey: .operatorActor)
        self.gitRevertPerformed = gitRevertPerformed
        self.workerImplemented = workerImplemented
        self.mission = try values.decode(AtlasAutonomosCycleRevertMission.self, forKey: .mission)
        self.note = try values.decodeIfPresent(String.self, forKey: .note)
    }
}
