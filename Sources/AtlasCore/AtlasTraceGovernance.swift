import Foundation

/// Decode das três provas que o servidor já emite no metadata do trace e que
/// nenhuma superfície lia (C18 diff_stats, C19 plan_revisions, C21
/// council_review — nascidos em `9a06fd4c56` / `4b2b61f974` do atlas-server).
///
/// Projeção PURA sobre `metadata`: se a chave não existe, o valor é `nil` e a
/// casca não mostra nada. Ausência nunca vira zero, e nada aqui infere
/// veredito que o servidor não produziu.
public enum AtlasTraceGovernance {

    // MARK: - C18 · diff real do turno

    /// "+48 −12" de verdade: `git diff --shortstat` medido no workspace.
    public struct DiffStats: Equatable, Sendable {
        public let filesTouched: Int
        public let linesAdded: Int
        public let linesRemoved: Int

        /// A frase que a casca mostra. Sem tocar arquivo, não há frase.
        public var headline: String {
            let files = filesTouched == 1 ? "1 arquivo" : "\(filesTouched) arquivos"
            return "\(files) · +\(linesAdded) −\(linesRemoved)"
        }
    }

    public static func diffStats(from metadata: JSONObject?) -> DiffStats? {
        guard let raw = object(metadata?["diff_stats"]) else { return nil }
        guard let files = int(raw["files_touched"]),
              let added = int(raw["lines_added"]),
              let removed = int(raw["lines_removed"]) else { return nil }
        return DiffStats(filesTouched: files, linesAdded: added, linesRemoved: removed)
    }

    // MARK: - C19 · histórico de plano (replanejamento)

    public struct PlanRevision: Equatable, Sendable, Identifiable {
        public let revision: Int
        public let iteration: Int?
        public let reason: String?
        public let archivedAt: String?

        public var id: Int { revision }

        /// Motivo em linguagem humana — o canon do servidor é técnico.
        public var humanReason: String {
            switch reason {
            case "quality_gate_requested_repair": return "o gate de qualidade pediu reparo"
            case .some(let other) where !other.isEmpty: return other
            default: return "replanejado"
            }
        }
    }

    /// Versões arquivadas do plano, em ordem. Vazio = nunca replanejou.
    public static func planRevisions(from metadata: JSONObject?) -> [PlanRevision] {
        guard let raw = array(metadata?["plan_revisions"]) else { return [] }
        return raw.compactMap { entry in
            guard let item = object(entry), let revision = int(item["revision"]) else { return nil }
            return PlanRevision(
                revision: revision,
                iteration: int(item["iteration"]),
                reason: string(item["reason"]),
                archivedAt: string(item["archived_at"])
            )
        }
    }

    // MARK: - C21 · pareceres do conselho

    /// Posição pública de um membro. Sem raciocínio privado, sem veredito
    /// inventado: divergência aparece como status distinto entre membros.
    public struct CouncilMember: Equatable, Sendable, Identifiable {
        public let provider: String
        public let model: String?
        public let status: String
        public let responseHash: String?
        public let errorCode: String?
        public let latencyMs: Int?

        public var id: String { provider }

        public var succeeded: Bool { status == "succeeded" }
    }

    public static func councilReview(from metadata: JSONObject?) -> [CouncilMember] {
        guard let raw = array(metadata?["council_review"]) else { return [] }
        return raw.compactMap { entry in
            guard let item = object(entry),
                  let provider = string(item["provider"]),
                  let status = string(item["status"]) else { return nil }
            return CouncilMember(
                provider: provider,
                model: string(item["model"]),
                status: status,
                responseHash: string(item["response_hash"]),
                errorCode: string(item["error_code"]),
                latencyMs: int(item["latency_ms"])
            )
        }
    }

    /// Houve divergência? É FATO derivado: hashes distintos entre membros que
    /// concluíram. Nunca um "veredito" fabricado pela casca.
    public static func councilDiverged(_ members: [CouncilMember]) -> Bool {
        let hashes = Set(members.filter(\.succeeded).compactMap(\.responseHash))
        return hashes.count > 1
    }

    // MARK: - Leitura tolerante do JSON

    private static func object(_ value: JSONValue?) -> [String: JSONValue]? {
        if case .object(let dict) = value { return dict }
        return nil
    }

    private static func array(_ value: JSONValue?) -> [JSONValue]? {
        if case .array(let items) = value { return items }
        return nil
    }

    private static func string(_ value: JSONValue?) -> String? {
        if case .string(let text) = value, !text.isEmpty { return text }
        return nil
    }

    private static func int(_ value: JSONValue?) -> Int? {
        switch value {
        case .number(let number): return Int(number)
        case .string(let text): return Int(text)
        default: return nil
        }
    }
}
