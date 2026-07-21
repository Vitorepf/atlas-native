import SwiftUI
import AtlasCore

// IDLE-COMPRESS body

extension RootHomeSections {
    func arenaSpokenLabel(regression: String?, domainUnavailable: Bool) -> String {
        // WAVE-047: Home never elevates regression (ordem 2026-07-18).
        _ = regression
        return HomeOpsJudgment.arenaFace(domainUnavailable: domainUnavailable).spoken
    }
}

extension RootHomeSections {
    static func codeTopBarLabel(hub: AtlasCodeHubModel?) -> String {
        guard let hub else { return "Atlas Código" }
        if let exception = hub.exception {
            return "Atlas Código, \(exception.count) exceções em \(exception.repo)"
        }
        return "Atlas Código, código quieto"
    }
}

extension RootHomeSections {
    /// WORKSPACES some quando não há pastas reais.
    var showsWorkspacesSection: Bool { !session.workspaces.isEmpty }
}

extension RootHomeSections {
    func workspaceSpokenLabel(name: String, count: Int?) -> String {
        guard let count else { return name }
        return "\(name), \(count) conversa\(count == 1 ? "" : "s")"
    }
}

extension RootHomeSections {
    @ViewBuilder
    var addWorkspaceRow: some View {
        WorkspaceRow(icon: "folder.badge.plus", name: "Adicionar workspace",
                     count: nil,
                     a11yID: A11yID.homeAddWorkspace,
                     spokenOverride: "adicionar workspace",
                     spokenHint: "escolhe um repositório do Mac") {
            showingWorkspacePicker = true
        }
        .sheet(isPresented: $showingWorkspacePicker) {
            AtlasWorkspacePickerSheet(client: session.client) { key, title in
                showingWorkspacePicker = false
                onNavigate(.workspace(key: key, title: title))
            }
        }
    }
}

extension RootHomeSections {
    @ViewBuilder
    var arenaEntryRow: some View {
        WorkspaceRow(
            icon: "chart.line.uptrend.xyaxis",
            name: "Arena",
            count: nil,
            // Home NÃO fala de regressão (ordem 2026-07-18, repetida): a linha
            // é limpa; o assunto vive DENTRO da Arena.
            a11yID: A11yID.arenaHomeEntry,
            spokenOverride: arenaSpokenLabel(
                regression: nil,
                domainUnavailable: session.arena.isDomainUnavailable
            ),
            spokenHint: "abre medição de regressão"
        ) {
            onNavigate(.arena)
        }
    }
}

extension RootHomeSections {
    // Modelo mental do operador: conversa é LIVRE ou pertence a um workspace.
    // Uma linha aqui, workspaces na seção deles — zero filtro, zero duplicata.
    @ViewBuilder
    var conversasSection: some View {
        sectionLabel("CONVERSAS", accessibilityID: A11yID.homeConversasSection)
        WorkspaceRow(icon: "bubble.left.and.bubble.right", name: "Conversas livres",
                     count: homeConversationCount,
                     detail: session.auditModeEnabled ? auditDetail : nil,
                     a11yID: A11yID.homeConversasEntry,
                     spokenOverride: conversasEntrySpokenLabel(),
                     spokenHint: "abre as conversas sem workspace") {
            onNavigate(.conversas)
        }
    }
}

extension RootHomeSections {
    func conversasEntrySpokenLabel() -> String {
        var parts = ["Conversas livres"]
        let n = homeConversationThreadCount
        if n == 0 {
            parts.append("nenhuma conversa")
        } else {
            parts.append("\(n) conversa\(n == 1 ? "" : "s")")
        }
        if session.auditModeEnabled {
            parts.append(auditDetail)
        }
        return parts.joined(separator: ", ")
    }
}

extension RootHomeSections {
    var auditDetail: String {
        let n = homeConversationCount ?? 0
        return "auditoria · livres · \(n) threads"
    }
}

extension RootHomeSections {
    var homeConversationThreadCount: Int { freeThreadCount }
}

extension RootHomeSections {
    var freeThreadCount: Int {
        session.threads.filter { $0.workspace == nil }.count
    }
}

extension RootHomeSections {
    var homeConversationCount: Int? {
        let n = homeConversationThreadCount
        return n > 0 ? n : nil
    }
}

extension RootHomeSections {
    @ViewBuilder
    var failureSection: some View {
        centered {
            AtlasNetworkFailureEmpty(
                kind: session.failureKind,
                hasToken: session.hasToken,
                host: session.host,
                topPadding: 0,
                retryHint: "reconecta ao servidor Atlas",
                retryAccessibilityIdentifier: A11yID.homeRetry,
                accessibilityIdentifier: A11yID.homeOffline,
                onRetry: { Task { await session.loadThreads() } }
            )
        }
    }
}

