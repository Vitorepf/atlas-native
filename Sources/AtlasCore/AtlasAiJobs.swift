import Foundation

// Jobs cluster do Atlas AI, portado de lib/api/atlasAi.ts (AtlasAiJob & cia +
// os endpoints /ai/jobs/*). O decoder do AtlasClient usa `.convertFromSnakeCase`,
// então snake_case do servidor vira camelCase sem CodingKeys. Todo campo que o
// servidor pode omitir ou mandar `null` é Optional — senão o decode quebra.
//
// Uniões abertas (`AtlasAiProvider | string`, status, action) ficam `String`:
// um enum estrito quebraria o decode num valor novo. AtlasAiChoiceAction ->
// String pelo mesmo motivo.
// Client: AtlasClient+AiJobs.swift · Models: AtlasAiJobs+Models.swift

/// `atlas_decide_execution` — estado do Atlas Decide anexado ao job. O TS tem
/// index signature `[key: string]: unknown`, omitida aqui (Decodable ignora
/// chaves JSON desconhecidas por padrão).
public struct AtlasAiExecutionState: Codable, Sendable {
    public let strategy: String?
    public let activationStatus: String?
    public let blockedReason: String?
    public let atlasDecideStage: String?
    public let dependencyState: String?
    public let dependencyJobId: String?
    public let dependentJobId: String?
    public let dependencyProvider: String?
    public let dependencyModel: String?
    public let dependencyTimeoutSeconds: Int?
}

/// Uma opção que o job oferece quando `awaiting_user_choice` (trocar provider,
/// baixar modelo, esperar, cancelar, etc.). `action` é união aberta -> String.
public struct AtlasAiChoiceOption: Codable, Sendable, Identifiable {
    public let id: String
    public let label: String
    public let description: String?
    public let action: String
    public let provider: String?
    public let model: String?
    public let availableAtIso: String?
    public let cliCommand: String?
    public let reason: String?
}
