import Foundation
import AtlasCore

// Reconnect helpers no bubble (transporte + ledger) — fusão WAVE-006.

extension ChatBubble {
    var showsReconnectSurface: Bool {
        reconnectNotice != nil
            || (streaming && executionPresentationState?.kind == .recovering)
    }

    /// Linha principal: aviso do stream quando existe; senão título público do ledger.
    var reconnectPrimaryLine: String? {
        if let notice = reconnectNotice { return notice }
        guard streaming, executionPresentationState?.kind == .recovering else { return nil }
        return executionPresentationState?.title
    }

    var reconnectBannerIcon: String {
        executionPresentationState?.kind == .recovering
            ? "arrow.triangle.2.circlepath"
            : "wifi.exclamationmark"
    }

    /// Detalhe/checkpoint só do contrato de apresentação — nunca retry inventado.
    var reconnectSecondaryLines: [String] {
        guard streaming, executionPresentationState?.kind == .recovering else { return [] }
        var lines: [String] = []
        if reconnectNotice == nil, let detail = executionPresentationState?.detail {
            lines.append(detail)
        }
        if let checkpoint = executionPresentationState?.checkpoint {
            lines.append("checkpoint · \(checkpoint)")
        }
        return lines
    }

    var reconnectActiveTimerMs: Int? {
        guard streaming,
              executionPresentationState?.kind == .recovering,
              let timer = executionPresentationState?.timer
        else { return nil }
        return timer.elapsedActiveMilliseconds
    }

    var reconnectSpokenLabel: String {
        var parts: [String] = []
        if let notice = reconnectNotice {
            parts.append(notice)
        } else if let state = executionPresentationState, state.kind == .recovering {
            parts.append(state.title)
            if let detail = state.detail { parts.append(detail) }
            if let checkpoint = state.checkpoint { parts.append("checkpoint \(checkpoint)") }
        }
        if let ms = reconnectActiveTimerMs {
            parts.append("tempo ativo \(ExecutionStateCard.clock(ms))")
        }
        return parts.isEmpty ? "reconectando" : parts.joined(separator: ". ")
    }
}
