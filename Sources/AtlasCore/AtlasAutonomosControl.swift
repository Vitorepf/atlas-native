import Foundation

/// Controle do loop (start/pause/resume/kill), decisões do operador.
/// Transferência de missão e recibos de revert vivem em
/// `AtlasAutonomosTransfer.swift`. Sinais governados, não promessas de processo.
public enum AtlasAutonomosRunAction: String, Codable, Sendable, Equatable, CaseIterable, Identifiable {
    case pause
    case resume
    case kill
    case clearKill = "clear-kill"

    public var id: String { rawValue }
}

/// Um sinal governado, não uma falsa promessa de parar processo: o servidor
/// escreve o sinal e o loop o honra na próxima fronteira de iteração.
public struct AtlasAutonomosRunControlInput: Codable, Sendable, Equatable {
    public let action: AtlasAutonomosRunAction
    public let operatorActor: String
    public let reason: String
    public let focus: String?

    public init(action: AtlasAutonomosRunAction, operatorActor: String, reason: String, focus: String? = nil) {
        self.action = action
        self.operatorActor = operatorActor.trimmingCharacters(in: .whitespacesAndNewlines)
        self.reason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        self.focus = focus?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Estado público de um sinal que o loop lê no próximo limite seguro. O
/// servidor não publica path, conteúdo do arquivo ou outro detalhe operacional.
public struct AtlasAutonomosSignalState: Codable, Sendable, Equatable {
    public let active: Bool
}

public struct AtlasAutonomosRunControlResponse: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let areaId: String
    public let focus: String
    public let action: AtlasAutonomosRunAction
    public let operatorActor: String
    public let applied: Bool
    public let killSwitch: AtlasAutonomosSignalState
    public let pause: AtlasAutonomosSignalState
    public let note: String

    public var isPaused: Bool { pause.active }
    public var isKilled: Bool { killSwitch.active }
}

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
