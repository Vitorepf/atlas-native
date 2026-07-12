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
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottom) {
                AtlasTheme.bg.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    topBar
                        .padding(.horizontal, AtlasTheme.Space.screen)
                        .padding(.top, 4)

                    Text("Atlas")
                        .font(AtlasFont.serif(38, .bold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .padding(.horizontal, AtlasTheme.Space.screen)
                        .padding(.top, 16)
                        .padding(.bottom, 10)

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
    }

    // MARK: - Content (workspaces)

    @ViewBuilder
    private var content: some View {
        switch session.phase {
        case .idle, .loading where session.threads.isEmpty:
            centered { ProgressView().tint(AtlasTheme.textSecondary) }

        case .failed where session.threads.isEmpty:
            centered {
                VStack(spacing: 10) {
                    Image(systemName: "bolt.horizontal.circle").font(.system(size: 30)).foregroundStyle(AtlasTheme.textTertiary)
                    Text(session.hasToken ? "Servidor desconectado" : "Falta o ATLAS_TOKEN")
                        .font(.system(size: 16, weight: .medium)).foregroundStyle(AtlasTheme.textSecondary)
                    Text(session.hasToken ? "em \(session.host)" : "configure em Secrets.xcconfig")
                        .font(.system(size: 13)).foregroundStyle(AtlasTheme.textTertiary)
                    Button("Tentar de novo") { Task { await session.loadThreads() } }
                        .font(.system(size: 15, weight: .medium)).foregroundStyle(AtlasTheme.accent).padding(.top, 4)
                }
                .multilineTextAlignment(.center).padding(.horizontal, 40)
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

    private func sectionLabel(_ t: String) -> some View {
        Text(t)
            .font(.system(size: 12, weight: .semibold))
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
                Text("Escreva ao Atlas").font(.system(size: 16)).foregroundStyle(AtlasTheme.textTertiary)
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
                Text(name).font(.system(size: 17)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                Spacer(minLength: 8)
                if let count { Text("\(count)").font(.system(size: 16)).foregroundStyle(AtlasTheme.textTertiary) }
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
            Text(thread.title).font(.system(size: 16)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1).truncationMode(.tail)
            Spacer(minLength: 8)
            Text("\(thread.messageCount)").font(.system(size: 16)).foregroundStyle(AtlasTheme.textTertiary)
            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(AtlasTheme.textTertiary)
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
        .contentShape(Rectangle())
    }
}
