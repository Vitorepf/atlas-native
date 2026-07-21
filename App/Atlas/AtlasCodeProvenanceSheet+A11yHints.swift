import Foundation
import AtlasCore

// Provenance spoken fail/load — peel de AtlasCodeProvenanceSheet+A11ySpokenCopy.

extension AtlasCodeProvenanceSheet {
    func spokenLoading() -> String { "lendo proveniência do commit" }

    func spokenFailed(_ message: String) -> String {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "proveniência indisponível" }
        return "proveniência indisponível, \(trimmed)"
    }

    static let sheetHint = "estado do commit, lei aplicável e o que o ledger registrou"
    static let askHint = "abre conversa com este commit no assunto"
}
