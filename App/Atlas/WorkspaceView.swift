import AtlasCore
import SwiftUI

// Cycle 044 fuse → WorkspaceView.swift

// Dentro de um workspace (repo): as conversas dele, com filtro de área no topo
// (Tudo / Operacional / Autônomos / Programação). Título em Fraunces serif.
// Vazio ≠ offline: falha de rede usa a mesma voz da home (`AtlasFailureCopy`).
// Chrome: +Chrome · lista: +Scroll · spoken: +A11y · empty: WorkspaceEmptyStates
struct WorkspaceView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let workspaceKey: String?
    let title: String
    /// Modo sem projeto: só conversas com workspace nulo (perguntas, pesquisas,
    /// pensamento livre — o uso GPT-no-iPhone). O projeto é opcional, não regra.
    var freeOnly: Bool = false
    @State var area: AtlasArea = .tudo

    var body: some View {
        workspaceScreenChrome(workspaceBodyStack)
    }
}

extension WorkspaceView {
    var workspaceBodyStack: some View {
        ZStack(alignment: .bottom) {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                if !showsNetworkFailure && !showsLoadingShell && hasThreadsToFilter {
                    areaFilter
                }
                listView
            }
            if !showsNetworkFailure && !showsLoadingShell {
                newPill
            }
        }
    }
}

extension WorkspaceView {
    func workspaceScreenChrome<Content: View>(_ content: Content) -> some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            .accessibilityIdentifier(A11yID.workspaceScreen)
            // Contain without fused screen label so filter/list/pill stay focusable.
            .accessibilityElement(children: .contain)
    }
}

extension WorkspaceView {
    var areaFilterChipRow: some View {
        HStack(spacing: 8) {
            ForEach(AtlasArea.allCases) { a in
                areaFilterChip(a, active: a == area)
            }
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
    }
}

extension WorkspaceView {
    var areaFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            areaFilterChipRow
        }
        .padding(.vertical, 10)
        .accessibilityIdentifier(A11yID.workspaceAreaFilter)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: area)
    }
}

extension WorkspaceView {
    func areaFilterChip(_ a: AtlasArea, active: Bool) -> some View {
        Button {
            guard area != a else { return }
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            if reduceMotion {
                area = a
            } else {
                withAnimation(AtlasMotion.editorial) { area = a }
            }
        } label: {
            areaFilterChipLabel(a, active: active)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("área \(a.label)")
        .accessibilityHint("filtra conversas já carregadas")
        .accessibilityAddTraits(active ? [.isButton, .isSelected] : .isButton)
    }
}

extension WorkspaceView {
    func areaFilterChipLabel(_ a: AtlasArea, active: Bool) -> some View {
        Text(a.label)
            .font(.system(.subheadline, weight: .medium))
            .foregroundStyle(active ? AtlasTheme.accent : AtlasTheme.textSecondary)
            .padding(.horizontal, 14).padding(.vertical, 7)
            .frame(minHeight: 44) // HIG interactive minimum
            .contentShape(Capsule())
            .background(
                Capsule().fill(active ? AtlasTheme.goldVeil : AtlasTheme.surface)
                    .overlay(Capsule().stroke(active ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
            )
    }
}

extension WorkspaceView {
    var newPill: some View {
        NavigationLink(value: Route.new(workspaceKey: freeOnly ? nil : workspaceKey)) {
            newPillLabel
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            // Soft: workspace write pill is invitation (AgenticPill class).
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
        })
        .accessibilityLabel("nova conversa")
        .accessibilityHint("abre o compositor para escrever ao Atlas")
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(10) // primary write pill surfaces early in VO
        .accessibilityIdentifier(A11yID.workspaceNewPill)
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(
            LinearGradient(colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}

extension WorkspaceView {
    // Mesma pílula agêntica da home: ✦ ouro + vidro (padrão §6). Sem mic —
    // voz está fora EM DEFINITIVO (canon §6).
    var newPillLabel: some View {
        HStack(spacing: 10) {
            Text("✦").font(AtlasFont.serif(16))
                .foregroundStyle(AtlasTheme.accent)
                .frame(width: 30, height: 30)
                .accessibilityHidden(true)
            Text("Escreva ao Atlas").font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 13)
        .frame(minHeight: 48) // HIG 44pt; same breath as AgenticPill
        .contentShape(Capsule())
        .atlasGlassCapsule()
    }
}

extension WorkspaceThreadsSection {
    var caption: String {
        if area == .tudo {
            return "\(threads.count) conversa\(threads.count == 1 ? "" : "s")"
        }
        return "\(threads.count) em \(area.label)"
    }
}

extension WorkspaceThreadsSection {
    var spokenCaption: String {
        if area == .tudo {
            return "\(threads.count) conversa\(threads.count == 1 ? "" : "s") em \(screenTitle)"
        }
        return "\(threads.count) conversa\(threads.count == 1 ? "" : "s") em \(area.label), \(screenTitle)"
    }
}

extension WorkspaceThreadsSection {
    var captionHeader: some View {
        Text(caption.uppercased())
            .font(.system(.caption, weight: .semibold)).tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(spokenCaption)
            .accessibilityIdentifier(A11yID.workspaceThreadsCaption)
    }
}

extension WorkspaceView {
    var showsLoadingShell: Bool {
        guard session.threads.isEmpty else { return false }
        switch session.phase {
        case .idle, .loading: return true
        default: return false
        }
    }
}

extension WorkspaceView {
    var showsNetworkFailure: Bool {
        guard session.threads.isEmpty else { return false }
        if case .failed = session.phase { return true }
        return false
    }
}

extension WorkspaceView {
    var listView: some View {
        ScrollView {
            workspaceListChrome(
                LazyVStack(spacing: 0) {
                    scrollPhaseContent
                }
            )
        }
        .scrollIndicators(.hidden)
        .refreshable { await session.loadThreads() }
    }
}

extension WorkspaceView {
    func workspaceListChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(.bottom, 96)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: area)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: threads.map(\.id))
    }
}

extension WorkspaceView {
    var listNetworkFailure: some View {
        AtlasNetworkFailureEmpty(
            kind: session.failureKind,
            hasToken: session.hasToken,
            host: session.host,
            retryHint: "reconecta e recarrega conversas deste workspace",
            retryAccessibilityIdentifier: A11yID.workspaceRetry,
            accessibilityIdentifier: A11yID.workspaceOffline,
            onRetry: { Task { await session.loadThreads() } }
        )
    }
}

extension WorkspaceView {
    @ViewBuilder
    var listLoadedContent: some View {
        if threads.isEmpty {
            WorkspaceEditorialEmpty(area: area, freeOnly: freeOnly, screenTitle: title)
        } else {
            WorkspaceThreadsSection(
                threads: threads,
                area: area,
                screenTitle: title,
                reduceMotion: reduceMotion
            )
        }
    }
}

extension WorkspaceView {
    @ViewBuilder
    var scrollPhaseContent: some View {
        if showsLoadingShell {
            WorkspaceLoadingEmpty(reduceMotion: reduceMotion)
                .accessibilityIdentifier(A11yID.workspaceLoading)
        } else if showsNetworkFailure {
            listNetworkFailure
        } else {
            listLoadedContent
        }
    }
}

struct WorkspaceThreadLink: View {
    let thread: AtlasAiThread
    let reduceMotion: Bool
    var newBadgeSuppressed: Bool = false

    var body: some View {
        threadLinkA11y
    }
}

extension WorkspaceThreadLink {
    var threadLinkA11y: some View {
        NavigationLink(value: Route.thread(id: ThreadID(thread.id), title: thread.title)) {
            ThreadRow(thread: thread, newBadgeSuppressed: newBadgeSuppressed, ownsAccessibility: false)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
        })
        .accessibilityLabel(SearchThreadLink.spokenLabel(thread))
        .accessibilityHint(
            TurnPresence.shared.runningTitles.contains(thread.title)
                ? "Atlas executando nesta conversa"
                : "abre a conversa"
        )
        .accessibilityAddTraits(
            TurnPresence.shared.runningTitles.contains(thread.title) && !reduceMotion
                ? [.isButton, .updatesFrequently]
                : .isButton
        )
        .accessibilityIdentifier(A11yID.workspaceThread(thread.id))
        .transition(threadTransition)
    }
}

extension WorkspaceThreadLink {
    var threadTransition: AnyTransition {
        reduceMotion ? .opacity : .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 6)),
            removal: .opacity
        )
    }
}

extension WorkspaceView {
    var threads: [AtlasAiThread] {
        let base = freeOnly
            ? session.threads.filter { $0.workspace == nil }
            : session.threads(inWorkspace: workspaceKey)
        return area == .tudo ? base : base.filter { AtlasArea.of($0) == area }
    }

    /// Filtro só existe quando há o que filtrar: chips numa lista vazia
    /// são ruído (regra da casa: controle sem efeito não aparece).
    var hasThreadsToFilter: Bool {
        freeOnly
            ? session.threads.contains { $0.workspace == nil }
            : !session.threads(inWorkspace: workspaceKey).isEmpty
    }
}

extension WorkspaceView {
    var header: some View {
        HStack(spacing: 12) {
            headerBackButton
            Spacer()
            Text(title)
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
                .accessibilityLabel(headerSpokenTitle)
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 4)
        .padding(.bottom, 4)
    }

    var headerBackButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .atlasSans(17, .semibold).foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 44, height: 44).atlasGlassCircle()
                .contentShape(Circle())
        }
        .accessibilityLabel("voltar")
        .accessibilityHint("fecha o workspace")
    }

    var headerSpokenTitle: String {
        if freeOnly { return "conversas sem projeto" }
        return title
    }
}

extension WorkspaceThreadsSection {
    @ViewBuilder
    func threadRowLoop(_ t: AtlasAiThread, newBadgeSuppressed: Bool = false) -> some View {
        WorkspaceThreadLink(thread: t, reduceMotion: reduceMotion, newBadgeSuppressed: newBadgeSuppressed)
        threadRowSeparator(after: t)
    }
}

extension WorkspaceThreadsSection {
    @ViewBuilder
    func threadRowSeparator(after thread: AtlasAiThread) -> some View {
        if thread.id != threads.last?.id {
            Divider().overlay(AtlasTheme.separator)
                .padding(.leading, AtlasTheme.Space.screen + 36)
        }
    }
}

extension WorkspaceThreadsSection {
    /// Badge "novo" saturado (maioria de 6+ linhas) perde o poder de
    /// discriminar — silencia em bloco; a ordenação já diz recência.
    var newBadgeSaturated: Bool {
        threads.count >= 6
            && threads.lazy.filter(ConversationModel.hasNewerContent).count * 2 > threads.count
    }

    @ViewBuilder
    var threadRows: some View {
        let saturated = newBadgeSaturated
        ForEach(threads) { t in
            threadRowLoop(t, newBadgeSuppressed: saturated)
        }
    }
}

struct WorkspaceThreadsSection: View {
    let threads: [AtlasAiThread]
    let area: AtlasArea
    let screenTitle: String
    let reduceMotion: Bool

    var body: some View {
        Group {
            captionHeader
            threadRows
        }
    }
}


// Cycle 044 fuse → WorkspaceEmptyStates.swift

// Estados vazios do WorkspaceView (offline) —

/// Falha de rede compartilhada — home, workspace e conversa (voz via `AtlasFailureCopy`).
struct AtlasNetworkFailureEmpty: View {
    let kind: AtlasNetworkFailureKind?
    let hasToken: Bool
    let host: String
    var topPadding: CGFloat = 56
    var retryHint: String = "reconecta ao servidor Atlas"
    var retryAccessibilityIdentifier: String?
    let accessibilityIdentifier: String
    let onRetry: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        failureChrome(failureCopyBlock)
    }
}

extension WorkspaceEditorialEmpty {
    var editorialFootnote: String {
        if freeOnly {
            return "perguntas e pensamento livre começam abaixo"
        }
        return "comece uma abaixo — o projeto é opcional"
    }
}

extension WorkspaceEditorialEmpty {
    var editorialHeadline: String {
        if area != .tudo {
            return "“Nada em \(area.label) — por enquanto.”"
        }
        if freeOnly {
            return "“Nenhuma conversa sem projeto ainda.”"
        }
        return "“Nenhuma conversa em \(screenTitle) ainda.”"
    }
}

extension WorkspaceEditorialEmpty {
    var headline: String { editorialHeadline }
    var footnote: String { editorialFootnote }
}

/// ✦ + headline editorial compartilhado — workspace vazio e search miss.
struct AtlasEditorialGlyphEmpty: View {
    let headline: String
    var footnote: String? = nil
    let accessibilityIdentifier: String
    var spokenLabel: String? = nil

    var body: some View {
        editorialStack
            .frame(maxWidth: .infinity).padding(.top, 72).padding(.horizontal, 40)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenLabel ?? headline)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier(accessibilityIdentifier)
    }
}

extension WorkspaceEditorialEmpty {
    var spokenLabel: String {
        let lead: String
        if area != .tudo {
            lead = "nada em \(area.label) em \(screenTitle)"
        } else if freeOnly {
            lead = "nenhuma conversa sem projeto ainda"
        } else {
            lead = "nenhuma conversa em \(screenTitle) ainda"
        }
        return "\(lead). \(footnote)"
    }
}

extension AtlasEditorialGlyphEmpty {
    var editorialCopyStack: some View {
        VStack(spacing: 8) {
            Text(headline)
                .font(AtlasFont.serifItalic(17)).foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
            if let footnote {
                Text(footnote)
                    .font(.system(.footnote)).foregroundStyle(AtlasTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .accessibilityHidden(true)
            }
        }
    }
}

extension AtlasEditorialGlyphEmpty {
    var editorialGlyph: some View {
        Text("✦")
            .font(AtlasFont.serif(24)).foregroundStyle(AtlasTheme.accent.opacity(0.45))
            .accessibilityHidden(true)
    }
}

extension AtlasEditorialGlyphEmpty {
    var editorialStack: some View {
        VStack(spacing: 14) {
            editorialGlyph
            editorialCopyStack
        }
    }
}

struct WorkspaceEditorialEmpty: View {
    let area: AtlasArea
    let freeOnly: Bool
    let screenTitle: String

    var body: some View {
        editorialGlyph
    }
}

extension AtlasNetworkFailureEmpty {
    @ViewBuilder
    func retryButtonWithIdentifier<Content: View>(_ button: Content) -> some View {
        if let retryAccessibilityIdentifier {
            button.accessibilityIdentifier(retryAccessibilityIdentifier)
        } else {
            button
        }
    }
}

extension AtlasNetworkFailureEmpty {
    @ViewBuilder
    var retryButton: some View {
        retryButtonWithIdentifier(
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onRetry()
            } label: {
                retryLabel
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("tentar de novo")
            .accessibilityHint(retryHint)
            .accessibilityAddTraits(.isButton)
            .accessibilitySortPriority(8)
        )
    }
}

extension AtlasNetworkFailureEmpty {
    func failureChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(.horizontal, 44).padding(.top, topPadding)
            .frame(maxWidth: .infinity)
            // Contain without container label so retry stays focusable.
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(accessibilityIdentifier)
    }
}

extension WorkspaceEditorialEmpty {
    var editorialGlyph: some View {
        AtlasEditorialGlyphEmpty(
            headline: headline,
            footnote: footnote,
            accessibilityIdentifier: A11yID.workspaceEmpty,
            spokenLabel: spokenLabel
        )
    }
}

extension AtlasNetworkFailureEmpty {
    var failureCopyBlock: some View {
        VStack(spacing: 0) {
            failureCopyText
            if hasToken {
                Spacer().frame(height: 28)
                retryButton
            }
        }
    }
}

extension AtlasNetworkFailureEmpty {
    var failureCopyText: some View {
        VStack(spacing: 0) {
            Text("✦")
                .font(AtlasFont.serif(28)).foregroundStyle(AtlasTheme.accent.opacity(0.55))
                .accessibilityHidden(true)
            Spacer().frame(height: 28)
            Text(AtlasFailureCopy.headline(kind: kind, hasToken: hasToken))
                .font(AtlasFont.serif(22, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            Spacer().frame(height: 12)
            failureHostAndHint
        }
    }
}

extension AtlasNetworkFailureEmpty {
    var failureHostAndHint: some View {
        Group {
            Text(hasToken ? "\(host):3737" : "ATLAS_TOKEN · Secrets.xcconfig")
                .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityLabel(hasToken ? "servidor \(host) porta 3737" : "token ATLAS ausente em Secrets")
            Spacer().frame(height: 16)
            Text(AtlasFailureCopy.hint(kind: kind, hasToken: hasToken))
                .font(.system(.subheadline)).lineSpacing(5)
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct WorkspaceLoadingEmpty: View {
    var reduceMotion: Bool
    var text: String = "abrindo conversas…"
    var spoken: String? = nil
    var topPadding: CGFloat = 72

    var body: some View {
        VStack(spacing: 18) {
            BreathingGlyph(reduceMotion: reduceMotion)
            Text(text)
                .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textTertiary)
        }
        .frame(maxWidth: .infinity).padding(.top, topPadding)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spoken ?? text)
        .accessibilityAddTraits(.isHeader)
    }
}

extension AtlasNetworkFailureEmpty {
    var retryLabel: some View {
        Text("Tentar de novo")
            .font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.accent)
            .padding(.horizontal, 22).padding(.vertical, 12)
            .frame(minHeight: 48) // match primary CTA breath
            .background(Capsule().fill(AtlasTheme.goldVeil)
                .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
            .contentShape(Capsule())
    }
}
