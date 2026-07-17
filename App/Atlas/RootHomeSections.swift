import SwiftUI
import AtlasCore

// Conteúdo da home (estados + listas CONVERSAS/OPERAÇÃO/WORKSPACES) —
// peel de RootView. Route e NavigationStack ficam no shell.

struct RootHomeSections: View {
    @Environment(AtlasSession.self) private var session
    var reduceMotion: Bool
    @Binding var homeWorkspaceFilter: String?
    var onNavigate: (Route) -> Void
    var onOpenThread: (ThreadID, String) -> Void

    var body: some View {
        switch session.phase {
        case .idle where session.threads.isEmpty, .loading where session.threads.isEmpty:
            centered {
                VStack(spacing: 18) {
                    BreathingGlyph(reduceMotion: reduceMotion)
                    Text("abrindo o Atlas…")
                        .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textTertiary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("abrindo o Atlas")
                .accessibilityIdentifier(A11yID.homeLoading)
            }

        case .failed where session.threads.isEmpty:
            centered {
                // Falha editorial: diz O QUE houve e O QUE fazer — nunca um beco
                // sem saída. Voz do Atlas, não voz de sistema.
                VStack(spacing: 0) {
                    Text("✦")
                        .font(AtlasFont.serif(28)).foregroundStyle(AtlasTheme.accent.opacity(0.55))
                    Spacer().frame(height: 28)
                    Text(failureHeadline)
                        .font(AtlasFont.serif(22, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                        .multilineTextAlignment(.center)
                    Spacer().frame(height: 12)
                    Text(session.hasToken ? "\(session.host):3737" : "ATLAS_TOKEN · Secrets.xcconfig")
                        .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.textTertiary)
                    Spacer().frame(height: 16)
                    Text(failureHint)
                        .font(.system(.subheadline)).lineSpacing(5)
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .multilineTextAlignment(.center)
                    if session.hasToken {
                        Spacer().frame(height: 28)
                        Button {
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            Task { await session.loadThreads() }
                        } label: {
                            Text("Tentar de novo")
                                .font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.accent)
                                .padding(.horizontal, 22).padding(.vertical, 10)
                                .background(Capsule().fill(AtlasTheme.goldVeil)
                                    .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
                        }
                        .buttonStyle(PressableScale())
                        .accessibilityHint("reconecta ao servidor Atlas")
                        .accessibilityIdentifier(A11yID.homeRetry)
                    }
                }
                .padding(.horizontal, 44)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier(A11yID.homeOffline)
                .accessibilityLabel("\(failureHeadline). \(failureHint)")
            }

        default:   // .loaded, ou refresh/erro com conteúdo já em tela
            ScrollView {
                LazyVStack(spacing: 0) {
                    // M13: cockpit aparece para sessões locais ou vindas de outra superfície.
                    if !TurnPresence.shared.liveSessions.isEmpty || !session.remoteLiveSessions.isEmpty {
                        LiveNowSection(
                            localSessions: TurnPresence.shared.liveSessions,
                            remoteSessions: session.remoteLiveSessions,
                            onOpen: onOpenThread
                        )
                    }
                    // A conversa é o centro — projeto é opcional. Aqui vivem as
                    // conversas SEM projeto: perguntas, pesquisas, pensamento
                    // livre (o uso GPT-no-iPhone). A pílula embaixo cria uma.
                    sectionLabel("CONVERSAS")
                    homeWorkspaceChips
                    WorkspaceRow(icon: "bubble.left.and.bubble.right", name: homeConversationLabel,
                                 count: homeConversationCount,
                                 detail: session.auditModeEnabled ? auditDetail : nil) {
                        onNavigate(homeConversationRoute)
                    }
                    rowDivider
                    sectionLabel("OPERAÇÃO")
                    WorkspaceRow(icon: "bolt.horizontal.circle", name: "Autônomos", count: nil) {
                        onNavigate(.autonomos)
                    }
                    rowDivider
                    WorkspaceRow(
                        icon: "chart.line.uptrend.xyaxis",
                        name: "Arena",
                        count: nil,
                        detail: session.arena.regressionException,
                        badge: session.arena.regressionException != nil
                    ) {
                        onNavigate(.arena)
                    }
                    .accessibilityIdentifier(A11yID.arenaHomeEntry)
                    rowDivider
                    sectionLabel("WORKSPACES")

                    WorkspaceRow(icon: "tray.full", name: "Todas as conversas", count: session.threads.count) {
                        onNavigate(.workspace(key: nil, title: "Todas"))
                    }
                    ForEach(session.workspaces) { ws in
                        rowDivider
                        WorkspaceRow(icon: "folder", name: ws.name, count: ws.count) {
                            onNavigate(.workspace(key: ws.id, title: ws.name))
                        }
                    }
                }
                .padding(.bottom, 96)
            }
            .scrollIndicators(.hidden)
            .refreshable { await session.loadThreads() }
        }
    }

    // Copy por TIPO de falha (failureKind — contrato §5; voz partilhada em AtlasFailureCopy).
    private var failureHeadline: String {
        AtlasFailureCopy.headline(kind: session.failureKind, hasToken: session.hasToken)
    }

    private var failureHint: String {
        AtlasFailureCopy.hint(kind: session.failureKind, hasToken: session.hasToken)
    }

    private var rowDivider: some View {
        Divider().overlay(AtlasTheme.separator).padding(.leading, AtlasTheme.Space.screen + 36)
    }

    private func centered<V: View>(@ViewBuilder _ v: () -> V) -> some View {
        VStack { Spacer(); v(); Spacer() }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
