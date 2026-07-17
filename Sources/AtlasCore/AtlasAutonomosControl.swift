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
