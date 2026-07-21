import Foundation
import AtlasCore
import SwiftUI

// MARK: - Judgment

/// Pure StateCard chrome grammar for `AtlasExecutionPresentationState.Kind`
/// (WAVE-052). One map: icon · badge · spoken · tint · freezesTimer.
enum ExecutionStateCardJudgment {

    // MARK: Icon

    static func iconName(for kind: AtlasExecutionPresentationState.Kind) -> String {
        switch kind {
        case .attentionRequired: return "exclamationmark.shield"
        case .awaitingExternal: return "hourglass"
        case .recovering: return "arrow.triangle.2.circlepath"
        case .replanning: return "arrow.triangle.branch"
        case .failed: return "xmark.octagon"
        case .completed: return "checkmark.seal"
        }
    }

    // MARK: Badge (uppercase product strip)

    static func badge(for kind: AtlasExecutionPresentationState.Kind) -> String? {
        switch kind {
        case .attentionRequired: return "PAUSADO"
        case .awaitingExternal: return "AGUARDANDO"
        case .recovering: return "RECONECTANDO"
        case .replanning: return "REPLANEJANDO"
        case .failed: return "FALHOU"
        case .completed: return "CONCLUÍDO"
        }
    }

    // MARK: Spoken

    static func spoken(for kind: AtlasExecutionPresentationState.Kind) -> String {
        switch kind {
        case .attentionRequired:
            return "execução pausada, aguardando decisão"
        case .awaitingExternal:
            return "aguardando sistema externo"
        case .recovering:
            return "reconectando"
        case .replanning:
            return "replanejando"
        case .failed:
            return "execução falhou"
        case .completed:
            return "execução concluída"
        }
    }

    // MARK: Tint

    static func tint(for kind: AtlasExecutionPresentationState.Kind) -> Color {
        switch kind {
        case .attentionRequired: return AtlasTheme.accent
        case .awaitingExternal, .recovering: return AtlasTheme.textSecondary
        case .replanning: return AtlasTheme.accent
        case .failed: return AtlasTheme.domOperacional
        case .completed: return AtlasTheme.domAutonomos
        }
    }

    /// Optional attention overlay tint (nil = use default surface stroke).
    static func attentionTint(for kind: AtlasExecutionPresentationState.Kind) -> Color? {
        switch kind {
        case .attentionRequired: return AtlasTheme.accent
        case .awaitingExternal, .recovering: return AtlasTheme.textSecondary
        case .failed: return AtlasTheme.domOperacional
        case .replanning, .completed: return nil
        }
    }

    // MARK: Timer freeze

    /// Paused timer chrome only for human/external wait faces.
    static func freezesTimer(for kind: AtlasExecutionPresentationState.Kind) -> Bool {
        switch kind {
        case .attentionRequired, .awaitingExternal: return true
        case .recovering, .replanning, .failed, .completed: return false
        }
    }

    static func productWord(for kind: AtlasExecutionPresentationState.Kind) -> String {
        kind.rawValue
    }

    static let retryLabel = "retomar execução a partir do último checkpoint"
    static let retryHint = "reenfileira o job que falhou"
}
