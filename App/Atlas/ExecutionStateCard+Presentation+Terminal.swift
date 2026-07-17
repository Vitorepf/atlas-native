import SwiftUI
import AtlasCore

// Terminal spoken kinds — peel de ExecutionStateCard+Presentation.

extension ExecutionStateCard {
    var spokenKindTerminal: String {
        switch state.kind {
        case .failed: return "execução falhou"
        case .completed: return "execução concluída"
        default: return spokenKindAttention ?? "execução"
        }
    }
}
