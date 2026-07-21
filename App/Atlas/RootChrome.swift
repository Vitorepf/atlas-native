import AtlasCore
import Foundation
import SwiftUI

// Cycle 044 fuse → RootChrome.swift

// Presentation-only chrome shared by RootView / WorkspaceView / SearchView.
// Route + navigation stay in RootView.
// Rows: RootChrome+Rows.swift · Controls: RootChrome+Controls.swift
// A11y: RootChrome+SectionA11y.swift

/// Label de seção da home (CONVERSAS / OPERAÇÃO / WORKSPACES).
@MainActor
@ViewBuilder
func sectionLabel(_ t: String, accessibilityID: String? = nil) -> some View {
    // A linha premium do site: hairlines em fade ladeando o rótulo.
    HStack(spacing: 12) {
        LinearGradient(colors: [AtlasTheme.separator.opacity(0), AtlasTheme.separator],
                       startPoint: .leading, endPoint: .trailing)
            .frame(height: 1)
        Text(t)
            .atlasSans(11, .semibold)
            .tracking(1.55)
            .foregroundStyle(AtlasTheme.textTertiary)
            .fixedSize()
        LinearGradient(colors: [AtlasTheme.separator, AtlasTheme.separator.opacity(0)],
                       startPoint: .leading, endPoint: .trailing)
            .frame(height: 1)
    }
    .padding(.horizontal, AtlasTheme.Space.screen)
    .padding(.top, 18)
    .padding(.bottom, 11)
    .accessibilityElement(children: .combine)
    .accessibilityAddTraits(.isHeader)
    .homeSectionA11yID(accessibilityID)
}

/// O ✦ respirando — a marca viva do Atlas nos estados de espera.
struct BreathingGlyph: View {
    let reduceMotion: Bool
    @State var on = false
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

private struct HomeSectionA11yID: ViewModifier {
    let id: String?
    func body(content: Content) -> some View {
        if let id {
            content.accessibilityIdentifier(id)
        } else {
            content
        }
    }
}

extension View {
    func homeSectionA11yID(_ id: String?) -> some View {
        modifier(HomeSectionA11yID(id: id))
    }
}

extension CircleButton {
    var circleButtonLabel: some View {
        Image(systemName: icon)
            .atlasSans(15, .medium).foregroundStyle(AtlasTheme.textSecondary)
            .frame(width: 44, height: 44).atlasGlassCircle()
            .overlay(alignment: .topTrailing) {
                badgeOverlay
            }
    }
}

struct CircleButton: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let icon: String
    /// Ponto de exceção: só aparece quando existe algo que fala. Silêncio é o
    /// estado normal — o botão não carrega contador decorativo.
    var badge: Bool = false
    let action: () -> Void
    var body: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            action()
        } label: {
            circleButtonLabel
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .accessibilityAddTraits(.isButton)
    }
}

extension CircleButton {
    @ViewBuilder
    var badgeOverlay: some View {
        if badge {
            Circle()
                .fill(AtlasCodePalette.alert)
                .frame(width: 9, height: 9)
                .overlay(Circle().strokeBorder(AtlasTheme.bg, lineWidth: 1.5))
                .offset(x: 1, y: -1)
                .accessibilityHidden(true)
        }
    }
}

/// Contagem zero = «nenhuma conversa»; badge só quando o model marca atenção real.

enum RootChromeRowA11y {
    static func workspaceSpoken(
        name: String,
        count: Int?,
        detail: String?,
        badge: Bool
    ) -> String {
        var parts = [name]
        if let count {
            parts.append(workspaceCountPart(count))
        }
        parts.append(contentsOf: workspaceDetailParts(detail: detail, badge: badge))
        return parts.joined(separator: ", ")
    }
}

extension RootChromeRowA11y {
    static func workspaceCountPart(_ count: Int) -> String {
        if count == 0 {
            return "nenhuma conversa"
        }
        return "\(count) conversa\(count == 1 ? "" : "s")"
    }
}

extension RootChromeRowA11y {
    static func workspaceDetailParts(detail: String?, badge: Bool) -> [String] {
        var parts: [String] = []
        if let detail, !detail.isEmpty {
            parts.append(detail)
        }
        if badge {
            parts.append("atenção necessária")
        }
        return parts
    }
}

extension RootChromeRowA11y {
    static func threadSpoken(
        title: String,
        messageCount: Int,
        isRunning: Bool,
        isNew: Bool,
        hasWorkspace: Bool
    ) -> String {
        var parts = [title]
        parts.append(contentsOf: threadStatusParts(
            messageCount: messageCount,
            isRunning: isRunning,
            isNew: isNew,
            hasWorkspace: hasWorkspace
        ))
        return parts.joined(separator: ", ")
    }
}

extension RootChromeRowA11y {
    static func spokenThreadMessageCount(_ messageCount: Int) -> [String] {
        if messageCount == 0 {
            return ["nenhuma mensagem"]
        }
        return ["\(messageCount) mensagem\(messageCount == 1 ? "" : "ns")"]
    }
}

extension RootChromeRowA11y {
    static func threadHint(isRunning: Bool) -> String {
        isRunning ? "Atlas executando nesta conversa" : "abre a conversa"
    }
}

extension RootChromeRowA11y {
    static func threadMessageParts(messageCount: Int, isRunning: Bool) -> [String] {
        if isRunning { return spokenThreadRunning() }
        return spokenThreadMessageCount(messageCount)
    }
}

extension RootChromeRowA11y {
    static func spokenThreadRunning() -> [String] {
        ["Atlas executando"]
    }
}

extension RootChromeRowA11y {
    static func threadStatusParts(
        messageCount: Int,
        isRunning: Bool,
        isNew: Bool,
        hasWorkspace: Bool
    ) -> [String] {
        var parts = threadMessageParts(messageCount: messageCount, isRunning: isRunning)
        if isNew && !isRunning {
            parts.append("novo desde a última visita")
        }
        if hasWorkspace {
            parts.append("com workspace")
        }
        return parts
    }
}

struct WorkspaceRow: View {
    let icon: String
    let name: String
    let count: Int?
    var detail: String?
    var badge: Bool = false
    /// Voz/identidade vivem NO botão: rotular por fora cria um invólucro
    /// `Other` mudo por cima e apaga o botão para VoiceOver e XCUITest.
    var a11yID: String?
    var spokenOverride: String?
    var spokenHint: String?
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            action()
        } label: {
            rowContent
        }
        .buttonStyle(.plain)
        // Sem accessibilityElement(children:) aqui: Button JÁ é elemento de
        // a11y; recriar o elemento gera um invólucro `Other` e emudece o botão.
        .accessibilityLabel(spokenOverride ?? RootChromeRowA11y.workspaceSpoken(name: name, count: count, detail: detail, badge: badge))
        .accessibilityHint(spokenHint ?? "abre \(name)")
        .accessibilityIdentifier(a11yID ?? "")
        .accessibilityAddTraits(.isButton)
    }
}

extension WorkspaceRow {
    @ViewBuilder
    var workspaceRowLeadingStack: some View {
        workspaceRowLeading
        workspaceRowNameStack
    }
}

extension WorkspaceRow {
    @ViewBuilder
    var workspaceRowTrailingStack: some View {
        Spacer(minLength: 8)
        rowTrailing
    }
}

extension WorkspaceRow {
    var workspaceRowHBox: some View {
        HStack(spacing: 14) {
            workspaceRowLeadingStack
            workspaceRowTrailingStack
        }
    }
}

extension WorkspaceRow {
    var workspaceRowLeading: some View {
        // Hierarchical: o SF ganha profundidade de dois tons (régua premium).
        Image(systemName: icon)
            .symbolRenderingMode(.hierarchical)
            .atlasSans(18).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
            .accessibilityHidden(true)
    }
}

extension WorkspaceRow {
    var workspaceRowNameStack: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(name).font(.system(.body)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                .accessibilityHidden(true)
            rowDetail
        }
    }
}

extension WorkspaceRow {
    var rowContent: some View {
        workspaceRowHBox
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
            .frame(minHeight: 48, alignment: .center)
            .contentShape(Rectangle())
    }
}

extension WorkspaceRow {
    @ViewBuilder
    var rowDetail: some View {
        // Voz calma: o ponto vermelho (badge) é o único alerta da linha —
        // texto em vermelho por cima dele era sinal duplicado gritando.
        if let detail, !detail.isEmpty {
            Text(detail)
                .font(.system(.caption))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

extension WorkspaceRow {
    @ViewBuilder
    var rowTrailing: some View {
        rowTrailingBadge
        rowTrailingCount
    }
}

extension WorkspaceRow {
    @ViewBuilder
    var rowTrailingBadge: some View {
        if badge {
            Circle()
                .fill(AtlasTheme.alert)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)
        }
    }
}

extension WorkspaceRow {
    @ViewBuilder
    var rowTrailingCount: some View {
        if let count {
            // Número é meta: mono editorial quieto (ausência = ausência).
            Text("\(count)")
                .font(AtlasFont.mono(12, .medium))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
        }
        Image(systemName: "chevron.right")
            .atlasSans(11, .semibold)
            .foregroundStyle(AtlasTheme.textTertiary.opacity(0.55))
            .accessibilityHidden(true)
    }
}

extension ThreadRow {
    func threadA11yChrome<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                RootChromeRowA11y.threadSpoken(
                    title: thread.title,
                    messageCount: thread.messageCount,
                    isRunning: isRunning,
                    isNew: isNew,
                    hasWorkspace: workspaceTint != nil
                )
            )
            .accessibilityHint(RootChromeRowA11y.threadHint(isRunning: isRunning))
            // Running rows re-speak presence; Reduce Motion keeps static copy.
            .accessibilityAddTraits(
                isRunning && !reduceMotion
                    ? [.isButton, .updatesFrequently]
                    : .isButton
            )
    }
}

extension ThreadRow {
    var rowContent: some View {
        HStack(spacing: 14) {
            rowLead
            Text(thread.title).font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1).truncationMode(.tail)
                .accessibilityHidden(true)
            Spacer(minLength: 8)
            rowTrailing
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
        .frame(minHeight: 48, alignment: .center)
        .overlay(alignment: .leading) { rowWorkspaceTint }
        .contentShape(Rectangle())
    }
}

extension ThreadRow {
    @ViewBuilder
    var rowLead: some View {
        if isRunning {
            BreathingDiamond(size: 9, reduceMotion: reduceMotion).frame(width: 22)
                .accessibilityHidden(true)
        } else {
            Image(systemName: "bubble.left")
                .atlasSans(17).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
                .accessibilityHidden(true)
        }
    }
}

extension ThreadRow {
    @ViewBuilder
    var newThreadBadge: some View {
        if isNew && !isRunning {
            Text("novo")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.accent)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Capsule().fill(AtlasTheme.goldVeil))
                .accessibilityHidden(true)
        }
    }
}

extension ThreadRow {
    @ViewBuilder
    var rowWorkspaceTint: some View {
        if let workspaceTint {
            Rectangle()
                .fill(workspaceTint.opacity(0.85))
                .frame(width: 2)
                .padding(.vertical, 10)
                .accessibilityHidden(true)
        }
    }
}

extension ThreadRow {
    @ViewBuilder
    var rowTrailing: some View {
        rowTrailingStatus
        Image(systemName: "chevron.right")
            .atlasSans(13, .semibold).foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}

extension ThreadRow {
    var rowTrailingCount: some View {
        Text("\(thread.messageCount)")
            .atlasSans(16)
            .foregroundStyle(AtlasTheme.textTertiary)
            .monospacedDigit()
            .modifier(NumericTextTransition(enabled: !reduceMotion))
            .accessibilityHidden(true)
    }
}

extension ThreadRow {
    @ViewBuilder
    var rowTrailingRunning: some View {
        Text("executando").font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.accent)
            .accessibilityHidden(true)
    }
}

extension ThreadRow {
    @ViewBuilder
    var rowTrailingStatus: some View {
        newThreadBadge
        if isRunning {
            rowTrailingRunning
        } else {
            rowTrailingCount
        }
    }
}

// Linha de conversa — compartilhada com Search/Workspace. Hub vivo: turno
// executando troca ícone por losango e contador por "executando".

struct ThreadRow: View {
    let thread: AtlasAiThread
    /// Sinal saturado não discrimina: quando a maioria da lista seria "novo",
    /// o dono da lista silencia o badge em bloco (volta quando for exceção).
    var newBadgeSuppressed: Bool = false
    /// When false, a parent NavigationLink owns VO label/traits (Search/Workspace).
    var ownsAccessibility: Bool = true
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var isRunning: Bool { TurnPresence.shared.runningTitles.contains(thread.title) }
    var isNew: Bool { !newBadgeSuppressed && ConversationModel.hasNewerContent(thread) }
    var workspaceTint: Color? { thread.workspace.map(threadWorkspaceColor) }

    var body: some View {
        if ownsAccessibility {
            threadA11yChrome(rowContent)
        } else {
            rowContent
        }
    }
}

func threadWorkspaceColor(_ workspace: String) -> Color {
    let palette = [AtlasTheme.accent, AtlasTheme.prussian, AtlasTheme.domAutonomos, AtlasTheme.domOperacional]
    let total = workspace.unicodeScalars.reduce(0) { $0 + Int($1.value) }
    return palette[abs(total) % palette.count]
}
