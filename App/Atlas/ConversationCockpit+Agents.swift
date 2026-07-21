import AtlasCore
import SwiftUI

// Cycle 024 fuse → ConversationCockpit+Agents.swift

extension AgentRow {
    var agentRowContent: some View {
        HStack(spacing: 8) {
            Circle().fill(statusColor).frame(width: 6, height: 6)
            Text(agent.agent ?? providerWord(agent.provider))
                .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.textSecondary)
            agentModelLabel
            Spacer()
            Text(statusWord).font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textTertiary)
        }
    }
}

struct AgentRow: View {
    let agent: ExecAgent
    var compactLane = false
    var body: some View {
        agentRowChrome(agentRowContent)
    }
}

extension AgentRow {
    func agentRowChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(.vertical, compactLane ? 3 : 0)
            .padding(.horizontal, compactLane ? 8 : 0)
            .background {
                if compactLane {
                    Capsule().fill(AtlasTheme.bgRecessed)
                }
            }
    }
}

extension AgentRow {
    @ViewBuilder
    var agentModelLabel: some View {
        if let m = agent.model, !m.isEmpty, !m.hasSuffix("_default") {
            Text(m).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary).lineLimit(1)
        }
    }
}

extension AgentRow {
    var statusColorActive: Color? {
        switch turnStatus {
        case .processing: return AtlasTheme.accent
        case .succeeded: return AtlasTheme.domAutonomos
        default: return nil
        }
    }
}

extension AgentRow {
    var turnStatus: AtlasTurnStatus { AtlasTurnStatus(rawValue: agent.status) }

    var statusColor: Color {
        if let active = statusColorActive { return active }
        switch turnStatus {
        case .failed, .cancelled: return AtlasTheme.domOperacional
        default: return AtlasTheme.textTertiary
        }
    }
}

extension AgentRow {
    var statusWordQueued: String? {
        switch turnStatus {
        case .queued: return "na fila"
        case .processing: return "processando"
        default: return nil
        }
    }
}

extension AgentRow {
    var statusWordActive: String? {
        if let queued = statusWordQueued { return queued }
        switch turnStatus {
        case .awaitingUserChoice: return "aguardando"
        case .awaitingExternal: return "aguardando externo"
        default: return nil
        }
    }
}

extension AgentRow {
    var statusWordDone: String? {
        switch turnStatus {
        case .succeeded: return "pronto"
        case .failed: return "falhou"
        case .cancelled: return "cancelado"
        default: return nil
        }
    }
}

extension AgentRow {
    var statusWordTerminal: String {
        if let done = statusWordDone { return done }
        if case .unknown(let raw) = turnStatus { return raw }
        return statusWordActive ?? "—"
    }
}

extension AgentRow {
    var statusWord: String {
        statusWordActive ?? statusWordTerminal
    }
}
