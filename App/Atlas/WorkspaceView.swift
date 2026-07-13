import SwiftUI
import AtlasCore

// Dentro de um workspace (repo): as conversas dele, com filtro de área no topo
// (Tudo / Operacional / Autônomos / Programação). Título em Fraunces serif.
struct WorkspaceView: View {
    @Environment(AtlasSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    let workspaceKey: String?
    let title: String
    @State private var area: AtlasArea = .tudo

    private var threads: [AtlasAiThread] {
        let base = session.threads(inWorkspace: workspaceKey)
        return area == .tudo ? base : base.filter { AtlasArea.of($0) == area }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                areaFilter
                listView
            }
            newPill
        }
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                    .frame(width: 40, height: 40).background(Circle().fill(AtlasTheme.surface))
            }
            Spacer()
            Text(title).font(AtlasFont.serif(20, .semibold)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 4).padding(.bottom, 4)
    }

    // MARK: - Filtro de área

    private var areaFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AtlasArea.allCases) { a in
                    let active = a == area
                    Button { area = a } label: {
                        Text(a.label)
                            .font(.system(.subheadline, weight: .medium))
                            .foregroundStyle(active ? AtlasTheme.accent : AtlasTheme.textSecondary)
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(
                                Capsule().fill(active ? AtlasTheme.goldVeil : AtlasTheme.surface)
                                    .overlay(Capsule().stroke(active ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
        }
        .padding(.vertical, 10)
    }

    // MARK: - Lista

    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if threads.isEmpty {
                    // Vazio editorial: convite, não aviso de sistema.
                    VStack(spacing: 14) {
                        Text("✦")
                            .font(AtlasFont.serif(24)).foregroundStyle(AtlasTheme.accent.opacity(0.45))
                        Text(area == .tudo
                             ? "“Nenhuma conversa aqui ainda.”"
                             : "“Nada em \(area.label) — por enquanto.”")
                            .font(AtlasFont.serifItalic(17)).foregroundStyle(AtlasTheme.textSecondary)
                            .multilineTextAlignment(.center)
                        Text("comece uma abaixo")
                            .font(.system(.footnote)).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .frame(maxWidth: .infinity).padding(.top, 72).padding(.horizontal, 40)
                } else {
                    ForEach(threads) { t in
                        NavigationLink(value: Route.thread(id: t.id, title: t.title)) {
                            ThreadRow(thread: t)
                        }
                        .buttonStyle(.plain)
                        if t.id != threads.last?.id {
                            Divider().overlay(AtlasTheme.separator).padding(.leading, AtlasTheme.Space.screen + 36)
                        }
                    }
                }
            }
            .padding(.bottom, 96)
        }
        .scrollIndicators(.hidden)
        .refreshable { await session.loadThreads() }
    }

    // MARK: - Nova conversa

    private var newPill: some View {
        NavigationLink(value: Route.new) {
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
