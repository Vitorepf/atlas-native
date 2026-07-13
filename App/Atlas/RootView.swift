import SwiftUI
import AtlasCore

// Rotas: um workspace (repo), uma thread existente, ou conversa nova.
enum Route: Hashable {
    case workspace(key: String?, title: String)
    case thread(id: String, title: String)
    case new
}

// Home Workspaces-primeiro (estilo Cursor, tema Atlas): masthead Fraunces, lista
// de repos reais (campo `workspace` das threads) + "Todas" + "Adicionar". Entrar
// num workspace abre suas conversas com filtro de área.
struct RootView: View {
    @Environment(AtlasSession.self) private var session
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottom) {
                AtlasTheme.bg.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    topBar
                        .padding(.horizontal, AtlasTheme.Space.screen)
                        .padding(.top, 4)
                        .padding(.bottom, 14)

                    content
                }

                inputBar
            }
            .navigationBarHidden(true)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .workspace(let key, let title):
                    WorkspaceView(workspaceKey: key, title: title)
                case .thread(let id, let title):
                    ConversationView(client: session.client, threadId: id, title: title)
                case .new:
                    ConversationView(client: session.client, threadId: nil, title: "Nova conversa")
                }
            }
        }
        .tint(AtlasTheme.accent)
        .task { if session.phase == .idle { await session.loadThreads() } }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(AtlasTheme.surface)
                .frame(width: 44, height: 44)
                .overlay(Image(systemName: "person.fill").font(.system(size: 18)).foregroundStyle(AtlasTheme.textSecondary))
                .overlay(Circle().stroke(AtlasTheme.separator, lineWidth: 1))
            Spacer()
            CircleButton(icon: "magnifyingglass") {}
            CircleButton(icon: "plus") { path.append(Route.new) }
        }
        // Nameplate "Atlas" centralizado + filete dourado — a assinatura
        // editorial do masthead (mesma do ícone).
        .overlay {
            VStack(spacing: 5) {
                Text("Atlas")
                    .font(AtlasFont.serif(24, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Rectangle()
                    .fill(AtlasTheme.accent.opacity(0.6))
                    .frame(width: 30, height: 1.5)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Atlas")
            .accessibilityAddTraits(.isHeader)
            // Cap deliberado: em AXXXL o nameplate colidia com busca/+ (evidência
            // 03). Marca limita a própria escala; o CONTEÚDO escala livre.
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        }
    }

    // MARK: - Content (workspaces)

    @ViewBuilder
    private var content: some View {
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
                    }
                }
                .padding(.horizontal, 44)
            }

        default:   // .loaded, ou refresh/erro com conteúdo já em tela
            ScrollView {
                LazyVStack(spacing: 0) {
                    sectionLabel("WORKSPACES")

                    WorkspaceRow(icon: "tray.full", name: "Todas as conversas", count: session.threads.count) {
                        path.append(Route.workspace(key: nil, title: "Todas"))
                    }
                    ForEach(session.workspaces) { ws in
                        rowDivider
                        WorkspaceRow(icon: "folder", name: ws.name, count: ws.count) {
                            path.append(Route.workspace(key: ws.id, title: ws.name))
                        }
                    }
                    rowDivider
                    WorkspaceRow(icon: "folder.badge.plus", name: "Adicionar workspace", count: nil) {
                        // ponytail: placeholder — abrir picker de repo entra numa próxima rodada
                    }
                }
                .padding(.bottom, 96)
            }
            .scrollIndicators(.hidden)
            .refreshable { await session.loadThreads() }
        }
    }

    // Copy por TIPO de falha (failureKind — contrato entregue pelo Codex, §5).
    // Cada falha diz o que houve e o que fazer, na voz do Atlas.
    private var failureHeadline: String {
        guard session.hasToken else { return "Falta a chave do Atlas." }
        switch session.failureKind {
        case .offline: return "Você está sem internet."
        case .timedOut: return "O Mac não respondeu a tempo."
        case .connectionRefused: return "O servidor do Atlas não está de pé."
        case .connectionLost: return "A conexão caiu no meio do caminho."
        case .unauthorized: return "A chave do Atlas foi recusada."
        case .serverUnavailable: return "O servidor está indisponível."
        case .other, nil: return "O servidor está fora de alcance."
        }
    }

    private var failureHint: String {
        guard session.hasToken else { return "Configure o token no Mac e reinstale — nada foi perdido." }
        switch session.failureKind {
        case .offline: return "Sem rede no iPhone. O Atlas volta sozinho assim que a conexão voltar."
        case .timedOut: return "Confira se o Mac está acordado e o Tailscale ligado — a conversa continua de onde parou."
        case .connectionRefused: return "No Mac, suba o servidor: o container atlas-backend parou."
        case .connectionLost: return "Instabilidade momentânea — tentar de novo costuma resolver."
        case .unauthorized: return "O ATLAS_TOKEN mudou no servidor. Atualize o Secrets.xcconfig e reinstale."
        case .serverUnavailable: return "O servidor respondeu, mas está fora do ar. Veja os logs no Mac."
        case .other, nil: return "Confira se o Mac está acordado e o Tailscale ligado — a conversa continua de onde parou."
        }
    }

    private func sectionLabel(_ t: String) -> some View {
        Text(t)
            .font(.system(.caption, weight: .semibold))
            .tracking(1.4)
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 6)
            .padding(.bottom, 12)
    }

    private var rowDivider: some View {
        Divider().overlay(AtlasTheme.separator).padding(.leading, AtlasTheme.Space.screen + 36)
    }

    private func centered<V: View>(@ViewBuilder _ v: () -> V) -> some View {
        VStack { Spacer(); v(); Spacer() }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Input pill → conversa nova

    private var inputBar: some View {
        Button { path.append(Route.new) } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus").font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 30, height: 30).background(Circle().fill(AtlasTheme.surfaceHi))
                Text("Escreva ao Atlas").font(.system(.callout)).foregroundStyle(AtlasTheme.textTertiary)
                Spacer()
                Image(systemName: "mic.fill").font(.system(size: 17)).foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 30, height: 30)
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(Capsule().fill(AtlasTheme.surface).overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1)))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(
            LinearGradient(colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}

// MARK: - Componentes compartilhados

/// O ✦ respirando — a marca viva do Atlas nos estados de espera.
struct BreathingGlyph: View {
    let reduceMotion: Bool
    @State private var on = false
    var body: some View {
        Text("✦")
            .font(AtlasFont.serif(30)).foregroundStyle(AtlasTheme.accent)
            .shadow(color: AtlasTheme.accent.opacity(0.30), radius: 4, y: 1)
            .scaleEffect(on ? 1.08 : 1).opacity(on ? 0.8 : 1)
            .onAppear {
                if !reduceMotion {
                    withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) { on = true }
                }
            }
            .accessibilityHidden(true)
    }
}

struct CircleButton: View {
    let icon: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium)).foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 44, height: 44).background(Circle().fill(AtlasTheme.surface))
        }
    }
}

private struct WorkspaceRow: View {
    let icon: String
    let name: String
    let count: Int?
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon).font(.system(size: 18)).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
                Text(name).font(.system(.body)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                Spacer(minLength: 8)
                if let count { Text("\(count)").font(.system(.callout)).foregroundStyle(AtlasTheme.textTertiary) }
                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// Linha de conversa — compartilhada com a WorkspaceView.
struct ThreadRow: View {
    let thread: AtlasAiThread
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "bubble.left").font(.system(size: 17)).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
            Text(thread.title).font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1).truncationMode(.tail)
            Spacer(minLength: 8)
            Text("\(thread.messageCount)").font(.system(size: 16)).foregroundStyle(AtlasTheme.textTertiary)
            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(AtlasTheme.textTertiary)
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
        .contentShape(Rectangle())
    }
}
