import SwiftUI
import AtlasCore

// Busca REAL sobre as conversas (o dado já vive na sessão — filtro local,
// zero rede na casca). Sem query: as recentes com caption. Com query: título
// folded (caso+acento insensível). Tocar navega pra conversa.
struct SearchView: View {
    @Environment(AtlasSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var query = ""
    @FocusState private var focused: Bool

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespaces)
    }

    private var isBrowsingRecent: Bool { trimmedQuery.isEmpty }

    private var results: [AtlasAiThread] {
        let q = trimmedQuery.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        if q.isEmpty { return Array(session.threads.prefix(12)) }
        return session.threads.filter {
            $0.title.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                .contains(q)
        }
    }

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                list
            }
        }
        .navigationBarHidden(true)
        .accessibilityIdentifier(A11yID.searchScreen)
        .onAppear { focused = true }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                    .frame(width: 40, height: 40).background(Circle().fill(AtlasTheme.surface))
            }
            .accessibilityLabel("voltar")

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15)).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                ZStack(alignment: .leading) {
                    Text("Buscar conversas")
                        .font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.textTertiary)
                        .opacity(query.isEmpty ? 1 : 0).allowsHitTesting(false)
                    TextField("", text: $query)
                        .font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary)
                        .tint(AtlasTheme.accent).focused($focused)
                        .submitLabel(.search)
                        .accessibilityLabel("buscar conversas")
                        .accessibilityIdentifier(A11yID.searchField)
                }
                if !query.isEmpty {
                    Button { query = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15)).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("limpar busca")
                    .accessibilityIdentifier(A11yID.searchClear)
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(Capsule().fill(AtlasTheme.surface)
                .overlay(Capsule().stroke(focused ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1)))
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 4).padding(.bottom, 10)
    }

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if results.isEmpty {
                    emptyState
                } else {
                    if isBrowsingRecent {
                        Text("RECENTES")
                            .font(.system(.caption, weight: .semibold)).tracking(1.4)
                            .foregroundStyle(AtlasTheme.textTertiary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AtlasTheme.Space.screen).padding(.bottom, 8)
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityIdentifier(A11yID.searchRecentCaption)
                    }
                    ForEach(results) { t in
                        NavigationLink(value: Route.thread(id: ThreadID(t.id), title: t.title)) {
                            ThreadRow(thread: t)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier(A11yID.searchResult(t.id))
                        if t.id != results.last?.id {
                            Divider().overlay(AtlasTheme.separator)
                                .padding(.leading, AtlasTheme.Space.screen + 36)
                        }
                    }
                }
            }
            .padding(.bottom, 40)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: trimmedQuery)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: results.map(\.id))
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
    }

    /// Vazio honesto: sem query = sem recentes; com query = miss no recorte carregado.
    private var emptyState: some View {
        VStack(spacing: 14) {
            Text("✦")
                .font(AtlasFont.serif(24)).foregroundStyle(AtlasTheme.accent.opacity(0.45))
            if isBrowsingRecent {
                Text("“Ainda não há conversas recentes.”")
                    .font(AtlasFont.serifItalic(17)).foregroundStyle(AtlasTheme.textSecondary)
                    .multilineTextAlignment(.center)
                Text("as mais recentes aparecem aqui")
                    .font(.system(.footnote)).foregroundStyle(AtlasTheme.textTertiary)
            } else {
                // "Nada com X" é afirmação ABSOLUTA só sobre a janela carregada
                // (teto de 100). Confessa o recorte quando ele existe.
                Text(session.threads.count >= 100
                     ? "“Nada com ‘\(trimmedQuery)’ nas 100 conversas mais recentes.”"
                     : "“Nada com ‘\(trimmedQuery)’.”")
                    .font(AtlasFont.serifItalic(17)).foregroundStyle(AtlasTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity).padding(.top, 72).padding(.horizontal, 40)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(A11yID.searchEmpty)
    }
}
