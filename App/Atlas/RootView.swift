import SwiftUI
import AtlasCore

// Rota de navegação: abrir uma thread existente ou começar uma nova.
enum Route: Hashable {
    case thread(id: String, title: String)
    case new
}

// Home do Atlas no espírito do Cursor mobile: top bar com botões circulares,
// título grande, lista de conversas limpa e a pílula de input flutuante que
// abre uma conversa nova. Dado real do AtlasCore.
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
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .padding(.horizontal, AtlasTheme.Space.screen)
                        .padding(.top, 18)
                        .padding(.bottom, 8)

                    content
                }

                inputBar
            }
            .navigationBarHidden(true)
            .navigationDestination(for: Route.self) { route in
                switch route {
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
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(AtlasTheme.textSecondary)
                )
                .overlay(Circle().stroke(AtlasTheme.separator, lineWidth: 1))

            Spacer()

            CircleButton(icon: "magnifyingglass") {}
            CircleButton(icon: "plus") { path.append(Route.new) }
        }
    }

    // MARK: - Content states

    @ViewBuilder
    private var content: some View {
        switch session.phase {
        case .idle, .loading:
            centered { ProgressView().tint(AtlasTheme.textSecondary) }

        case .failed(let message):
            centered {
                VStack(spacing: 10) {
                    Image(systemName: "bolt.horizontal.circle")
                        .font(.system(size: 30))
                        .foregroundStyle(AtlasTheme.textTertiary)
                    Text(session.hasToken ? "Servidor desconectado" : "Falta o ATLAS_TOKEN")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AtlasTheme.textSecondary)
                    Text(session.hasToken ? "em \(session.host)" : "configure em Secrets.xcconfig")
                        .font(.system(size: 13))
                        .foregroundStyle(AtlasTheme.textTertiary)
                    Button("Tentar de novo") { Task { await session.loadThreads() } }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AtlasTheme.accent)
                        .padding(.top, 4)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                let _ = message
            }

        case .loaded where session.threads.isEmpty:
            centered {
                Text("Nenhuma conversa ainda")
                    .font(.system(size: 16))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }

        case .loaded:
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(session.threads) { thread in
                        Button {
                            path.append(Route.thread(id: thread.id, title: thread.title))
                        } label: {
                            ThreadRow(thread: thread)
                        }
                        .buttonStyle(.plain)

                        if thread.id != session.threads.last?.id {
                            Divider().overlay(AtlasTheme.separator)
                                .padding(.leading, AtlasTheme.Space.screen)
                        }
                    }
                }
                .padding(.bottom, 96)
            }
            .scrollIndicators(.hidden)
            .refreshable { await session.loadThreads() }
        }
    }

    private func centered<V: View>(@ViewBuilder _ v: () -> V) -> some View {
        VStack { Spacer(); v(); Spacer() }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Input pill → abre conversa nova

    private var inputBar: some View {
        Button { path.append(Route.new) } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(AtlasTheme.surfaceHi))
                Text("Escreva ao Atlas")
                    .font(.system(size: 16))
                    .foregroundStyle(AtlasTheme.textTertiary)
                Spacer()
                Image(systemName: "mic.fill")
                    .font(.system(size: 17))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 30, height: 30)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(AtlasTheme.surface)
                    .overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 28)
        .padding(.bottom, 6)
        .background(
            LinearGradient(
                colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

// MARK: - Componentes

struct CircleButton: View {
    let icon: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(AtlasTheme.surface))
        }
    }
}

private struct ThreadRow: View {
    let thread: AtlasAiThread
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "bubble.left")
                .font(.system(size: 17))
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 22)

            Text(thread.title)
                .font(.system(size: 16))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer(minLength: 8)

            Text("\(thread.messageCount)")
                .font(.system(size: 16))
                .foregroundStyle(AtlasTheme.textTertiary)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.vertical, AtlasTheme.Space.row)
        .contentShape(Rectangle())
    }
}
