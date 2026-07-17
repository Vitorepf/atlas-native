import SwiftUI
import AtlasCore

/// Cena operacional do Fable 5: o estado chega pronto do ledger e só então a
/// conversa oferece uma ação. Não há botão, prazo ou risco criado pela casca.
/// Ações → ExecutionStateCard+Actions; prova → ExecutionProof.swift.
struct ExecutionStateCard: View {
    let state: AtlasExecutionPresentationState
    let jobId: JobID?
    let onChoose: (JobID, String) -> Void
    /// C17: job falho que aceita retry. Presente → o card de falha oferece
    /// "Retomar" (reenfileira o job real). Sem ele, a falha fica só informada.
    var retryableJobId: JobID? = nil
    var onRetry: (JobID) -> Void = { _ in }
    var onSteer: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(tint)
                Text(state.title)
                    .font(.system(.footnote, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Spacer(minLength: 0)
                if state.kind == .attentionRequired {
                    Text("PAUSADO")
                        .font(AtlasFont.mono(10)).tracking(0.8)
                        .foregroundStyle(tint)
                }
            }
            if let detail = state.detail {
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let deadline = state.deadline {
                Text("Próxima mudança: \(deadline)")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
            }
            // Ações são renderizadas sempre que o SERVIDOR as declarar (não só
            // em atenção): assim uma falha recuperável, uma espera externa ou um
            // replanejamento com ação aparecem sozinhos quando o contrato existir
            // — nunca um botão inventado pela casca.
            if let jobId, !state.actions.isEmpty {
                HStack(spacing: 8) {
                    ForEach(state.actions) { action in
                        Button { onChoose(jobId, action.id) } label: {
                            Text(action.title)
                                .font(.system(.caption, weight: .semibold))
                                .lineLimit(1)
                                .padding(.horizontal, 11).padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ExecutionStateActionStyle(style: action.style))
                    }
                }
            } else if state.kind == .failed, let retryableJobId {
                // C17: falha sem ação declarada pelo servidor → oferecemos o
                // retry real do job (reenfileira do ponto de falha).
                Button { onRetry(retryableJobId) } label: {
                    Text("Retomar")
                        .font(.system(.caption, weight: .semibold))
                        .padding(.horizontal, 11).padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(ExecutionStateActionStyle(style: .primary))
            }
            if let onSteer {
                Button(action: onSteer) {
                    Text("Redirecionar")
                        .font(.system(.caption, weight: .semibold))
                        .lineLimit(1)
                        .padding(.horizontal, 11).padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(ExecutionStateActionStyle(style: .secondary))
                .accessibilityLabel("redirecionar esta execução")
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AtlasTheme.surface.opacity(0.68))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(tint.opacity(0.42), lineWidth: 1))
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(state.title)
    }

    private var tint: Color {
        switch state.kind {
        case .attentionRequired: return AtlasTheme.accent
        case .awaitingExternal, .recovering: return AtlasTheme.textSecondary
        case .failed: return AtlasTheme.domOperacional
        case .replanning, .completed: return AtlasTheme.domAutonomos
        }
    }

    private var icon: String {
        switch state.kind {
        case .attentionRequired: return "exclamationmark.shield"
        case .awaitingExternal: return "hourglass"
        case .recovering: return "arrow.triangle.2.circlepath"
        case .replanning: return "arrow.triangle.branch"
        case .failed: return "xmark.octagon"
        case .completed: return "checkmark.seal"
        }
    }
}
