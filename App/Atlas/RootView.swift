import SwiftUI
import AtlasCore

// Primeira tela Swift pura: a lista de threads do Atlas AI, lida do servidor real
// via AtlasCore. Prova o fio ponta-a-ponta (rede → decode → SwiftUI). O polimento
// editorial (masthead/dateline/pixel-fiel) é a tarefa seguinte; aqui a barra é
// "renderiza dado real, com estados de loading/erro/vazio honestos".
struct RootView: View {
    @Environment(AtlasSession.self) private var session

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Atlas")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task { await session.loadThreads() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
        }
        .task {
            if session.phase == .idle { await session.loadThreads() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch session.phase {
        case .idle, .loading:
            ProgressView("Conectando a \(session.host)…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let message):
            ContentUnavailableView {
                Label("Sem conexão", systemImage: "bolt.horizontal.circle")
            } description: {
                Text(session.hasToken ? message : "Falta o ATLAS_TOKEN — configure em Config.xcconfig / Secrets.xcconfig.")
                    .font(.footnote.monospaced())
            } actions: {
                Button("Tentar de novo") { Task { await session.loadThreads() } }
            }

        case .loaded where session.threads.isEmpty:
            ContentUnavailableView("Nenhuma thread", systemImage: "tray")

        case .loaded:
            List(session.threads) { thread in
                ThreadRow(thread: thread)
            }
            .listStyle(.plain)
            .refreshable { await session.loadThreads() }
        }
    }
}

private struct ThreadRow: View {
    let thread: AtlasAiThread

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(thread.title)
                .font(.headline)
                .lineLimit(2)
            HStack(spacing: 8) {
                Label("\(thread.messageCount)", systemImage: "text.bubble")
                Text(thread.surface)
                if let provider = thread.lastProvider {
                    Text(provider)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
