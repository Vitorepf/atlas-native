import SwiftUI
import AtlasCore

// Selo e resumo falado — peel de ExecutionStateCard (régua ~160).
// Timers → ExecutionStateCard+Timers.swift
// Chrome → ExecutionStateCard+PresentationChrome.swift
// Badge → ExecutionStateCard+KindBadge.swift

extension ExecutionStateCard {
    var spokenKind: String? {
        switch state.kind {
        case .attentionRequired: return "execução pausada, aguardando decisão"
        case .awaitingExternal: return "aguardando sistema externo"
        case .recovering: return "reconectando"
        case .replanning: return "replanejando"
        case .failed: return "execução falhou"
        case .completed: return "execução concluída"
        }
    }
}
