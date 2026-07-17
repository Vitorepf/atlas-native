import Foundation

public enum AtlasAutonomosStartRunMode: String, Codable, Sendable, Equatable, CaseIterable, Identifiable {
    case dryRun = "dry_run"
    case execute

    public var id: String { rawValue }
}

/// O comando apenas enfileira o runner. `execute` é deliberado e exige uma
/// justificativa; o lease de `/live` continua sendo a única confirmação de
/// que o loop começou.
public struct AtlasAutonomosStartRunInput: Codable, Sendable, Equatable {
    public let mode: AtlasAutonomosStartRunMode
    public let operatorActor: String
    public let operatorReason: String
    public let focus: String?

    public init(
        mode: AtlasAutonomosStartRunMode = .dryRun,
        operatorActor: String,
        operatorReason: String = "",
        focus: String? = nil
    ) {
        self.mode = mode
        self.operatorActor = operatorActor.trimmingCharacters(in: .whitespacesAndNewlines)
        self.operatorReason = operatorReason.trimmingCharacters(in: .whitespacesAndNewlines)
        self.focus = focus?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var isLocallyValidForSubmission: Bool {
        !operatorActor.isEmpty && (mode != .execute || !operatorReason.isEmpty)
    }
}

public struct AtlasAutonomosStartRunResponse: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let status: String
    public let launch: String
    public let queue: String
    public let areaId: String
    public let focus: String
    public let mode: AtlasAutonomosStartRunMode
    public let execute: Bool
    public let requiresWorker: Bool
    public let operatorActor: String
    public let operatorReasonRecorded: Bool
    public let started: Bool
    public let mergePerformed: Bool
    public let providerInvoked: Bool
    public let note: String

    public var isEnqueued: Bool { status == "enqueued" && launch == "queued_job" && !started }
}
