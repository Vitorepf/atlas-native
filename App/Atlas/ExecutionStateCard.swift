import SwiftUI
import AtlasCore

/// Cena operacional do Fable 5: o estado chega pronto do ledger e só então a
/// conversa oferece uma ação. Não há botão, prazo ou risco criado pela casca.
struct ExecutionStateCard: View {
    let state: AtlasExecutionPresentationState
    let jobId: JobID?
    let onChoose: (JobID, String) -> Void
    /// C17: job falho que aceita retry. Presente → o card de falha oferece
    /// "Retomar" (reenfileira o job real). Sem ele, a falha fica só informada.
    var retryableJobId: JobID? = nil
    var onRetry: (JobID) -> Void = { _ in }

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

private struct ExecutionStateActionStyle: ButtonStyle {
    let style: AtlasExecutionPresentationState.ActionStyle

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foreground)
            .background(Capsule().fill(background.opacity(configuration.isPressed ? 0.72 : 1)))
            .overlay(Capsule().stroke(border, lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }

    private var background: Color {
        switch style {
        case .primary: return AtlasTheme.accent
        case .secondary: return AtlasTheme.surfaceHi
        case .destructive: return AtlasTheme.domOperacional.opacity(0.2)
        }
    }

    private var foreground: Color {
        style == .primary ? AtlasTheme.bg : AtlasTheme.textPrimary
    }

    private var border: Color {
        style == .destructive ? AtlasTheme.domOperacional.opacity(0.55) : AtlasTheme.separator
    }
}

// A PROVA da execução — o que Cursor não mostra: depois da resposta, os passos
// ficam (persistentes, expansíveis), com o Atlas Decide (por que este modelo)
// e o quality gate (a auto-avaliação). Fechado = uma linha discreta.
struct ExecutionProof: View {
    let bubble: ChatBubble
    var artifactItems: [AtlasTraceArtifacts.Item] = []
    var onOpenArtifacts: (TraceID) -> Void = { _ in }
    @State private var open = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                withAnimation(.easeOut(duration: 0.22)) { open.toggle() }
            } label: {
                HStack(spacing: 10) {
                    Circle().fill(AtlasTheme.accent).frame(width: 10, height: 10)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Obra concluída")
                            .font(.system(.subheadline, weight: .semibold))
                            .foregroundStyle(AtlasTheme.textPrimary)
                        Text(summaryLine)
                            .font(.system(.caption)).foregroundStyle(AtlasTheme.textTertiary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                    Text(open ? "Fechar" : "Abrir")
                        .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("prova da execução, \(bubble.activities.count) passos")
            .accessibilityHint(open ? "toque para fechar" : "toque para expandir")

            if open {
                VStack(alignment: .leading, spacing: 7) {
                    ForEach(bubble.activities) { act in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Image(systemName: activityIcon(act.kind))
                                .font(.system(size: 11)).foregroundStyle(AtlasTheme.accent.opacity(0.8))
                                .frame(width: 15)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(act.title)
                                    .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                                if let d = act.detail, !d.isEmpty {
                                    Text(d).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                                        .lineLimit(2).truncationMode(.middle)
                                }
                            }
                        }
                    }
                    if let d = bubble.decisionSummary {
                        Divider().overlay(AtlasTheme.separatorSoft)
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.triangle.branch")
                                .font(.system(size: 11)).foregroundStyle(AtlasTheme.accent.opacity(0.8)).frame(width: 15)
                            Text(decideLine(d))
                                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                                .lineLimit(2)
                        }
                        if let r = d.reason, !r.isEmpty {
                            Text("“\(r)”")
                                .font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textSecondary)
                                .padding(.leading, 23)
                        }
                    }
                    if let q = bubble.qualitySummary {
                        HStack(spacing: 6) {
                            Image(systemName: "seal")
                                .font(.system(size: 11)).foregroundStyle(qualityColor(q)).frame(width: 15)
                            Text("quality \(String(format: "%.1f", q.score)) · \(q.status)" +
                                 (q.flagCount > 0 ? " · \(q.flagCount) alertas" : ""))
                                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                        }
                    }
                    if !artifactItems.isEmpty, let traceId = bubble.traceId {
                        Button {
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            onOpenArtifacts(traceId)
                        } label: {
                            HStack(spacing: 6) {
                                Text("⎘")
                                    .font(AtlasFont.mono(12))
                                    .foregroundStyle(AtlasTheme.accent.opacity(0.8))
                                    .frame(width: 15)
                                Text("ARTEFATOS (\(artifactItems.count))")
                                    .font(AtlasFont.mono(12))
                                    .foregroundStyle(AtlasTheme.textSecondary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(AtlasTheme.textTertiary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier(A11yID.artifactsRow)
                        .accessibilityLabel("artefatos desta execução, \(artifactItems.count)")
                    }
                }
                .padding(.top, 8)
                .padding(.leading, 4)
                .transition(.opacity)
            }
        }
        .padding(.vertical, 8).padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10).fill(AtlasTheme.surface.opacity(0.35))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
        )
    }

    private var summaryLine: String {
        var parts: [String] = []
        if !bubble.activities.isEmpty { parts.append("\(bubble.activities.count) passos") }
        if let ms = bubble.elapsedMs, ms > 0 { parts.append(humanDuration(ms)) }
        if let q = bubble.qualitySummary { parts.append("quality \(String(format: "%.1f", q.score))") }
        return parts.isEmpty ? "provas e histórico preservados" : parts.joined(separator: " · ")
    }

    private func decideLine(_ d: AtlasDecisionSummary) -> String {
        var out = "atlas decide"
        if let m = d.routeMode { out += " · \(m)" }
        if let p = d.selectedProvider { out += " · \(p)" }
        if let c = d.confidenceScore { out += " · conf \(String(format: "%.2f", c))" }
        if d.wasOverridden { out += " · override" }
        return out
    }

    private func qualityColor(_ q: AtlasQualitySummary) -> Color {
        q.status.lowercased().contains("pass") || q.score >= 0.7
            ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional
    }
}
