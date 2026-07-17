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
        public let stepTitles: [String]

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
                archivedAt: string(item["archived_at"]),
                stepTitles: planStepTitles(from: item)
            )
        }
    }
}
