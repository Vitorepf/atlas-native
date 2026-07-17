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

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Cena 01/13: só renderiza quando o contrato traz informação além do
    /// silêncio pós-prova. `.completed` vazio cede lugar à `ExecutionProof`.
    static func shouldDisplay(state: AtlasExecutionPresentationState) -> Bool {
        if state.kind == .completed,
           state.actions.isEmpty,
           state.detail == nil,
           state.checkpoint == nil,
           state.deadline == nil {
            return false
        }
        return true
    }

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
                if let badge = kindBadge {
                    Text(badge)
                        .font(AtlasFont.mono(10)).tracking(0.8)
                        .foregroundStyle(tint)
                        .accessibilityHidden(true)
                }
            }
            if let detail = state.detail {
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            // Checkpoint / timer / deadline: só campos tipados do contrato.
            // recovering não tem retry_count no v1 — se o servidor publicar
            // tentativas, elas vêm em `detail`; a casca não inventa contagem.
            if let checkpoint = state.checkpoint {
                Text("checkpoint · \(checkpoint)")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .accessibilityLabel("checkpoint \(checkpoint)")
            }
            if state.kind == .recovering, let timer = state.timer {
                Text("ativo \(Self.clock(timer.elapsedActiveMilliseconds))")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
                    .accessibilityLabel("tempo ativo \(Self.clock(timer.elapsedActiveMilliseconds))")
            }
            if let deadline = state.deadline {
                Text("Próxima mudança: \(deadline)")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .accessibilityLabel("próxima mudança \(deadline)")
            }
            // Ações = somente `state.actions` declaradas pelo servidor (cena 01).
            // Falha (cena 13): resume/retry só quando há pills do contrato OU
            // `retryableJobId` real no model — nunca um botão inventado sem ambos.
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
                        .buttonStyle(ExecutionStateActionStyle(
                            style: action.style,
                            reduceMotion: reduceMotion
                        ))
                        .accessibilityHint("ação declarada pelo servidor")
                    }
                }
            } else if state.kind == .failed, state.actions.isEmpty, let retryableJobId {
                // C17: falha sem action no presentation state → retry do job real.
                Button { onRetry(retryableJobId) } label: {
                    Text("Retomar")
                        .font(.system(.caption, weight: .semibold))
                        .padding(.horizontal, 11).padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(ExecutionStateActionStyle(
                    style: .primary,
                    reduceMotion: reduceMotion
                ))
                .accessibilityLabel("retomar execução a partir do último checkpoint")
                .accessibilityHint("reenfileira o job que falhou")
            }
            if let onSteer {
                Button(action: onSteer) {
                    Text("Redirecionar")
                        .font(.system(.caption, weight: .semibold))
                        .lineLimit(1)
                        .padding(.horizontal, 11).padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(ExecutionStateActionStyle(
                    style: .secondary,
                    reduceMotion: reduceMotion
                ))
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
        .accessibilityLabel(spokenSummary)
        .accessibilityIdentifier(A11yID.executionStateCard)
    }

    private var spokenSummary: String {
        var parts: [String] = []
        if let kind = spokenKind { parts.append(kind) }
        parts.append(state.title)
        if let detail = state.detail { parts.append(detail) }
        if let checkpoint = state.checkpoint { parts.append("checkpoint \(checkpoint)") }
        if state.kind == .recovering, let timer = state.timer {
            parts.append("tempo ativo \(Self.clock(timer.elapsedActiveMilliseconds))")
        }
        if let deadline = state.deadline { parts.append("próxima mudança \(deadline)") }
        if !state.actions.isEmpty {
            parts.append("\(state.actions.count) ação\(state.actions.count == 1 ? "" : "ões") disponíveis")
        }
        return parts.joined(separator: ". ")
    }

    private var spokenKind: String? {
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
    private var kindBadge: String? {
        switch state.kind {
        case .attentionRequired: return "PAUSADO"
        case .awaitingExternal: return "AGUARDANDO"
        case .recovering: return "RECONECTANDO"
        case .replanning: return "REPLANEJANDO"
        case .failed: return "FALHOU"
        case .completed: return nil
        }
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

    private static func clock(_ ms: Int) -> String {
        let s = max(0, ms / 1000)
        return s >= 3600
            ? String(format: "%d:%02d:%02d", s / 3600, (s % 3600) / 60, s % 60)
            : String(format: "%d:%02d", s / 60, s % 60)
    }
}
