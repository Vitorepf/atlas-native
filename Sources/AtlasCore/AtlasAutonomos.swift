import Foundation

/// Contratos da superfície 24/7 do Atlas Continuous Stewardship Loop.
/// Esta família é deliberadamente independente de threads/conversas: missão,
/// lock, ciclo, backlog e recibos pertencem ao Autônomos, não a um chat.
public struct AtlasAutonomosAreasResponse: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let readOnly: Bool
    public let areas: [AtlasAutonomosArea]
    public let areaCount: Int
    public let defaultArea: String?
    public let defaultFocus: String?
}

public struct AtlasAutonomosArea: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let areaName: String
    public let focus: String
    public let autonomyTier: Int
    public let maxTierForArea: Int
    public let devMode: String
    public let registered: Bool
    public let objective: String
    public let ownedSystems: [String]
    public let repoScope: JSONObject
    public let stopConditions: [String]
    public let runState: JSONObject

    enum CodingKeys: String, CodingKey {
        case id = "areaId", areaName, focus, autonomyTier, maxTierForArea,
             devMode, registered, objective, ownedSystems, repoScope,
             stopConditions, runState
    }

    public var isLocked: Bool { runState["lock"]?["held"]?.boolValue ?? false }
}

public struct AtlasAutonomosLiveResponse: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let areaId: String
    public let focus: String
    public let portfolioId: String
    public let readOnly: Bool
    /// Produto Mode completo é heterogêneo; o Core preserva o envelope sem
    /// a casca decodificar/interpretar JSON bruto.
    public let cockpit: JSONObject
    public let runState: JSONObject

    public var isRunning: Bool { runState["lock"]?["held"]?.boolValue ?? false }
    public var isPaused: Bool { runState["pause"]?["active"]?.boolValue ?? false }
    public var isKilled: Bool { runState["kill_switch"]?["active"]?.boolValue ?? false }
}

public struct AtlasAutonomosCyclesResponse: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let areaId: String
    public let focus: String
    public let ledgerRecordCountTotal: Int
    public let returnedCount: Int
    public let cycles: [JSONValue]
}

public struct AtlasAutonomosBacklogResponse: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let areaId: String
    public let focus: String
    public let readOnly: Bool
    public let findings: JSONObject
    public let workOrders: [JSONValue]
    public let inboxItems: [JSONValue]
    public let budgets: JSONObject
}

public enum AtlasAutonomosRunAction: String, Codable, Sendable, Equatable, CaseIterable {
    case pause
    case resume
    case kill
    case clearKill = "clear-kill"
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

public struct AtlasAutonomosRunControlResponse: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let areaId: String
    public let focus: String
    public let action: AtlasAutonomosRunAction
    public let operatorActor: String
    public let applied: Bool
    public let killSwitch: JSONObject
    public let pause: JSONObject
    public let note: String

    public var isPaused: Bool { pause["active"]?.boolValue ?? false }
    public var isKilled: Bool { killSwitch["active"]?.boolValue ?? false }
}

public extension AtlasClient {
    func listAutonomosAreas() async throws -> AtlasAutonomosAreasResponse {
        try await get("/ai/software-company-stewardship/loop/areas")
    }

    func autonomosLive(area: String, focus: String? = nil) async throws -> AtlasAutonomosLiveResponse {
        let query = atlasQueryString([("focus", focus.map { .string($0) })])
        return try await get("/ai/software-company-stewardship/loop/\(atlasPathComponent(area))/live\(query)")
    }

    func autonomosCycles(area: String, focus: String? = nil, tail: Int = 20) async throws -> AtlasAutonomosCyclesResponse {
        let query = atlasQueryString([
            ("focus", focus.map { .string($0) }),
            ("tail", .int(tail)),
        ])
        return try await get("/ai/software-company-stewardship/loop/\(atlasPathComponent(area))/cycles\(query)")
    }

    func autonomosBacklog(area: String, focus: String? = nil, limit: Int = 20) async throws -> AtlasAutonomosBacklogResponse {
        let query = atlasQueryString([
            ("focus", focus.map { .string($0) }),
            ("limit", .int(limit)),
        ])
        return try await get("/ai/software-company-stewardship/loop/\(atlasPathComponent(area))/backlog\(query)")
    }

    func controlAutonomosRun(
        area: String,
        input: AtlasAutonomosRunControlInput
    ) async throws -> AtlasAutonomosRunControlResponse {
        guard !input.operatorActor.isEmpty else {
            throw AtlasAutonomosClientError.missingOperatorActor
        }
        return try await post(
            "/ai/software-company-stewardship/loop/\(atlasPathComponent(area))/run-control",
            body: input,
            timeout: 30
        )
    }
}

public enum AtlasAutonomosClientError: Error, Sendable, Equatable {
    case missingOperatorActor
}

private func atlasPathComponent(_ value: String) -> String {
    value.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? value
}
