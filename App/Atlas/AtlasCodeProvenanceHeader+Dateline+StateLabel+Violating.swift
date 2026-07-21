import SwiftUI
import AtlasCore

// Violating state label — peel de AtlasCodeProvenanceHeader+Dateline+StateLabel.

extension AtlasCodeProvenanceSheet {
    var stateLabelViolating: String {
        ruleId.map { "FORA DA LINHA · \(AtlasCodeIssue.law($0, trunk: trunk).uppercased())" } ?? "FORA DA LINHA"
    }
}
