import SwiftUI
import AtlasCore

// State label — peel de AtlasCodeProvenanceHeader+Dateline.
// Violating → AtlasCodeProvenanceHeader+Dateline+StateLabel+Violating.swift

extension AtlasCodeProvenanceSheet {
    var stateLabel: String {
        switch state {
        case .onMain: return "NA MAIN"
        case .violating: return stateLabelViolating
        case .healed: return "CURADO"
        case .history: return "HISTÓRIA"
        }
    }
}
