import SwiftUI
import AtlasCore

// State label — peel de AtlasCodeProvenanceHeader+Dateline.
// Violating → AtlasCodeProvenanceHeader+Dateline+StateLabel+Violating.swift
// Healthy → AtlasCodeProvenanceHeader+Dateline+StateLabel+Healthy.swift

extension AtlasCodeProvenanceSheet {
    var stateLabel: String {
        if let healthy = stateLabelHealthy { return healthy }
        switch state {
        case .violating: return stateLabelViolating
        case .history: return "HISTÓRIA"
        default: return "HISTÓRIA"
        }
    }
}
