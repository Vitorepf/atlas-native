import SwiftUI
import AtlasCore

// Agent row status word + color (WAVE-003 W3 fuse).

extension AgentRow {
    var turnStatus: AtlasTurnStatus { AtlasTurnStatus(rawValue: agent.status) }

    var statusColor: Color {
        switch turnStatus {
        case .processing: return AtlasTheme.accent
        case .succeeded: return AtlasTheme.domAutonomos
        case .failed, .cancelled: return AtlasTheme.domOperacional
        default: return AtlasTheme.textTertiary
        }
    }

    var statusWord: String {
        switch turnStatus {
        case .queued: return "na fila"
        case .processing: return "processando"
        case .awaitingUserChoice: return "aguardando"
        case .awaitingExternal: return "aguardando externo"
        case .succeeded: return "pronto"
        case .failed: return "falhou"
        case .cancelled: return "cancelado"
        case .unknown(let raw): return raw
        default: return "—"
        }
    }
}
