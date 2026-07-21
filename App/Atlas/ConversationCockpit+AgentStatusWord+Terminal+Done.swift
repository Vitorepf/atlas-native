import SwiftUI
import AtlasCore

// Succeeded/failed terminal words — peel de AgentStatusWord+Terminal.

extension AgentRow {
    var statusWordDone: String? {
        switch turnStatus {
        case .succeeded: return "pronto"
        case .failed: return "falhou"
        case .cancelled: return "cancelado"
        default: return nil
        }
    }
}
