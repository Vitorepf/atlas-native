import SwiftUI
import AtlasCore

// State label — peel de AtlasCodeProvenanceHeader+Dateline.

extension AtlasCodeProvenanceSheet {
    var stateLabel: String {
        switch state {
        case .onMain: return "NA MAIN"
        // A lei em português e em caixa alta de manchete — nunca o id cru.
        case .violating: return ruleId.map { "FORA DA LINHA · \(AtlasCodeIssue.law($0, trunk: trunk).uppercased())" } ?? "FORA DA LINHA"
        case .healed: return "CURADO"
        case .history: return "HISTÓRIA"
        }
    }
}
