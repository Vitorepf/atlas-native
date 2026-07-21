import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive commit-provenance drill face (WAVE-057).
enum AtlasCodeProvenanceFace: Equatable {
    case loading
    case failed(String)
    case empty
    case body(files: Int)

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .failed: return "failed"
        case .empty: return "empty"
        case .body: return "body"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading:
            return "lendo proveniência do commit"
        case .failed(let message):
            let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { return "proveniência indisponível" }
            return "proveniência indisponível, \(trimmed)"
        case .empty:
            return "ledger sem detalhe neste recorte"
        case .body(let files):
            return files == 1
                ? "1 arquivo na proveniência"
                : "\(files) arquivos na proveniência"
        }
    }

    var contentPhaseID: String {
        switch self {
        case .loading: return "loading"
        case .failed: return "failed"
        case .empty: return "loaded-empty"
        case .body(let files): return "loaded-\(files)"
        }
    }
}

// MARK: - Judgment

/// Pure provenance drill grammar — face · body gate · state kicker · pack.
enum AtlasCodeProvenanceJudgment {

    static func hasLoadedBody(_ provenance: AtlasCodeProvenance) -> Bool {
        provenance.commitBody?.nonEmpty != nil
            || provenance.operatorQuote?.nonEmpty != nil
            || !(provenance.gates?.isEmpty ?? true)
            || !(provenance.obra?.isEmpty ?? true)
            || !provenance.files.isEmpty
    }

    static func face(
        phase: AtlasCodeProvenanceModel.Phase
    ) -> AtlasCodeProvenanceFace {
        switch phase {
        case .idle, .loading:
            return .loading
        case .failed(let message):
            return .failed(message)
        case .loaded(let provenance):
            if hasLoadedBody(provenance) {
                return .body(files: provenance.files.count)
            }
            return .empty
        }
    }

    /// Product state kicker aligned with commit-row / graph vocabulary.
    static func spokenStateKicker(
        state: AtlasCodeNodeState,
        trunk: String?
    ) -> String {
        let linha = trunk?.nonEmpty ?? "main"
        switch state {
        case .onMain: return "na \(linha)"
        case .healed: return "curado"
        case .violating: return "fora da \(linha)"
        case .history: return "história"
        }
    }

    static let commitHashLabel = "hash do commit"

    static func headerTitle(node: AtlasCodeGraphNode) -> String {
        node.message?.nonEmpty ?? String(node.hash.prefix(8))
    }

    static func spokenSheet(
        node: AtlasCodeGraphNode,
        state: AtlasCodeNodeState,
        trunk: String?,
        phase: AtlasCodeProvenanceModel.Phase
    ) -> String {
        let face = face(phase: phase)
        var parts = [
            "proveniência do commit",
            headerTitle(node: node),
            spokenStateKicker(state: state, trunk: trunk),
            face.spokenFace
        ]
        if case .loaded(let provenance) = phase, let headline = provenance.diffHeadline {
            parts.append(headline)
        }
        return parts.joined(separator: ", ")
    }

    static func packFacts(
        node: AtlasCodeGraphNode,
        state: AtlasCodeNodeState,
        trunk: String?,
        phase: AtlasCodeProvenanceModel.Phase,
        ruleId: String?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(phase: phase)
        facts.append("provenance_face: \(face.productWord)")
        facts.append("commit: \(String(node.hash.prefix(7)))")
        facts.append("row_state: \(AtlasCodeGraphJudgment.productWord(for: state))")
        if let ruleId {
            facts.append("rule: \(ruleId)")
        }
        switch face {
        case .loading:
            absences.append("proveniência ainda carregando")
        case .failed(let msg):
            absences.append("proveniência falhou")
            if !msg.isEmpty { facts.append("provenance_error: \(msg)") }
        case .empty:
            absences.append("ledger sem detalhe neste recorte")
        case .body(let files):
            facts.append("provenance_files: \(files)")
            if case .loaded(let provenance) = phase {
                if provenance.agent.isEmpty {
                    absences.append("agente de proveniência ausente")
                } else {
                    facts.append("provenance_agent: \(provenance.agent)")
                }
                if let obra = provenance.obra, !obra.isEmpty {
                    facts.append("obra: \(obra)")
                }
                let filePack = packFileFacts(provenance.files)
                facts.append(contentsOf: filePack.facts)
                absences.append(contentsOf: filePack.absences)
            }
        }
        return (facts, absences)
    }

    // MARK: File row spoken (WAVE-101 · was AtlasCodeFileRowA11y)

    static func spokenFile(_ file: AtlasCodeFileChange) -> String {
        var parts = [file.path, verb(for: file.status)]
        if let from = file.renamedFrom { parts.append("de \(from)") }
        if let additions = file.additions, let deletions = file.deletions {
            parts.append("\(additions) linhas adicionadas")
            parts.append("\(deletions) removidas")
        } else {
            parts.append("arquivo binário")
        }
        return parts.joined(separator: ", ")
    }

    static func verb(for status: AtlasCodeFileStatus) -> String {
        verbMutate(for: status) ?? verbTransform(for: status)
    }

    static func verbMutate(for status: AtlasCodeFileStatus) -> String? {
        switch status {
        case .added: return "adicionado"
        case .modified: return "alterado"
        case .deleted: return "removido"
        default: return nil
        }
    }

    static func verbRenameCopy(for status: AtlasCodeFileStatus) -> String? {
        switch status {
        case .renamed: return "renomeado"
        case .copied: return "copiado"
        default: return nil
        }
    }

    static func verbTransform(for status: AtlasCodeFileStatus) -> String {
        if let rename = verbRenameCopy(for: status) { return rename }
        switch status {
        case .typeChanged: return "tipo alterado"
        case .unknown: return "mudança desconhecida"
        default: return verbMutate(for: status) ?? "mudança desconhecida"
        }
    }

    static func packFileFacts(
        _ files: [AtlasCodeFileChange]
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        facts.append("prov_files_total: \(files.count)")
        if files.isEmpty {
            absences.append("nenhum arquivo na proveniência")
            return (facts, absences)
        }
        for file in files.prefix(5) {
            facts.append("prov_file_sample: \(file.path) · \(verb(for: file.status))")
        }
        return (facts, absences)
    }
}
