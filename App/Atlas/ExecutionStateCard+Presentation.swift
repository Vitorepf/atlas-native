import SwiftUI
import AtlasCore

// Selo e resumo falado — peel de ExecutionStateCard (régua ~160).
// Timers → ExecutionStateCard+Timers.swift
// Chrome → ExecutionStateCard+PresentationChrome.swift

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

    /// Selo 1:1 com `kind` — nunca copy inventada além do mapeamento canônico.
    var kindBadge: String? {
        switch state.kind {
        case .attentionRequired: return "PAUSADO"
        case .awaitingExternal: return "AGUARDANDO"
        case .recovering: return "RECONECTANDO"
        case .replanning: return "REPLANEJANDO"
        case .failed: return "FALHOU"
        case .completed: return nil
        }
    }
}
