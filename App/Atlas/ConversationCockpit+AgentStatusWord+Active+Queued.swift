import SwiftUI
import AtlasCore

// Queued/processing words — peel de AgentStatusWord+Active.

extension AgentRow {
    var statusWordQueued: String? {
        switch turnStatus {
        case .queued: return "na fila"
        case .processing: return "processando"
        default: return nil
        }
    }
}
